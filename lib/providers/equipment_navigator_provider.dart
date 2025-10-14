import 'package:flutter/foundation.dart';
import '../models/equipment.dart';
import '../models/equipment_navigation_node.dart';
import '../models/client.dart';
import '../models/site.dart';
import '../services/database_service.dart';

/// T019: Provider for managing equipment navigator state
/// Handles hierarchical navigation (Client → Site → Equipment) with lazy loading
class EquipmentNavigatorProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();

  List<EquipmentNavigationNode> _navigationPath = [];
  List<EquipmentNavigationNode> _currentChildren = [];
  Equipment? _selectedEquipment;
  bool _isLoading = false;
  String? _errorMessage;

  /// Current navigation path (breadcrumb trail)
  List<EquipmentNavigationNode> get navigationPath => List.unmodifiable(_navigationPath);

  /// Current node's children
  List<EquipmentNavigationNode> get currentChildren => List.unmodifiable(_currentChildren);

  /// Currently selected equipment (null if none selected)
  Equipment? get selectedEquipment => _selectedEquipment;

  /// Loading state
  bool get isLoading => _isLoading;

  /// Error message (if any)
  String? get errorMessage => _errorMessage;

  /// Initialize navigator at root (clients list)
  Future<void> initialize() async {
    _isLoading = true;
    _errorMessage = null;
    _navigationPath.clear();
    _selectedEquipment = null;
    notifyListeners();

    try {
      final db = await _db.database;

      // Load all active user clients (filter out system clients)
      final clientMaps = await db.query(
        'clients',
        where: 'is_active = 1 AND is_system = 0',
        orderBy: 'name ASC',
      );

      _currentChildren = clientMaps.map<EquipmentNavigationNode>((map) {
        final client = Client.fromMap(map);
        return EquipmentNavigationNode.client(
          id: client.id,
          name: client.name,
        );
      }).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load clients: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Navigate into a node (expand)
  Future<void> navigateInto(EquipmentNavigationNode node) async {
    if (node.type == NavigationNodeType.equipment) {
      throw StateError('Cannot navigate into equipment node - equipment has no children');
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Load children for this node
      final children = await _loadChildren(node);

      // Add node to navigation path
      _navigationPath.add(node);
      _currentChildren = children;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Navigate back (pop breadcrumb)
  void navigateBack() {
    if (_navigationPath.isEmpty) {
      throw StateError('Already at root - cannot navigate back');
    }

    // Remove last node from path
    _navigationPath.removeLast();

    // Clear selection
    _selectedEquipment = null;

    // Reload children for parent level
    if (_navigationPath.isEmpty) {
      // Back to root - reload clients
      initialize();
    } else {
      // Back to parent node
      final parent = _navigationPath.last;
      _loadAndSetChildren(parent);
    }
  }

  /// Select equipment
  void selectEquipment(Equipment equipment) {
    _selectedEquipment = equipment;
    notifyListeners();
  }

  /// Clear selection
  void clearSelection() {
    _selectedEquipment = null;
    notifyListeners();
  }

  /// Reset navigator to initial state
  void reset() {
    _navigationPath.clear();
    _currentChildren.clear();
    _selectedEquipment = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  /// Load and set children for a node
  Future<void> _loadAndSetChildren(EquipmentNavigationNode node) async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentChildren = await _loadChildren(node);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load children for a node based on its type
  Future<List<EquipmentNavigationNode>> _loadChildren(EquipmentNavigationNode node) async {
    final db = await _db.database;

    switch (node.type) {
      case NavigationNodeType.client:
        // Load main sites and sub sites for this client
        return await _loadClientChildren(db, node.id);

      case NavigationNodeType.mainSite:
        // Load sub sites and equipment for this main site
        return await _loadMainSiteChildren(db, node.id);

      case NavigationNodeType.subSite:
        // Load child sub sites and equipment for this sub site
        return await _loadSubSiteChildren(db, node.id);

      case NavigationNodeType.equipment:
        throw StateError('Equipment nodes have no children');
    }
  }

  /// Load children for a client node (main sites + sub sites + equipment)
  Future<List<EquipmentNavigationNode>> _loadClientChildren(dynamic db, String clientId) async {
    final children = <EquipmentNavigationNode>[];

    // Load main sites
    final mainSiteMaps = await db.query(
      'main_sites',
      where: 'client_id = ? AND is_active = 1',
      whereArgs: [clientId],
      orderBy: 'name ASC',
    );

    children.addAll(mainSiteMaps.map<EquipmentNavigationNode>((map) {
      final site = MainSite.fromMap(map);
      return EquipmentNavigationNode.mainSite(
        id: site.id,
        name: site.name,
        parentId: clientId,
      );
    }).toList());

    // Load sub sites directly under client
    final subSiteMaps = await db.query(
      'sub_sites',
      where: 'client_id = ? AND is_active = 1',
      whereArgs: [clientId],
      orderBy: 'name ASC',
    );

    children.addAll(subSiteMaps.map<EquipmentNavigationNode>((map) {
      final site = SubSite.fromMap(map);
      return EquipmentNavigationNode.subSite(
        id: site.id,
        name: site.name,
        parentId: clientId,
      );
    }).toList());

    // Load equipment directly under client
    final equipmentMaps = await db.query(
      'equipment',
      where: 'client_id = ? AND main_site_id IS NULL AND sub_site_id IS NULL AND is_active = 1',
      whereArgs: [clientId],
      orderBy: 'name ASC',
    );

    children.addAll(equipmentMaps.map<EquipmentNavigationNode>((map) {
      final equipment = Equipment.fromMap(map);
      return EquipmentNavigationNode.equipment(
        id: equipment.id,
        name: equipment.name,
        parentId: clientId,
      );
    }).toList());

    return children;
  }

  /// Load children for a main site node (sub sites + equipment)
  Future<List<EquipmentNavigationNode>> _loadMainSiteChildren(dynamic db, String mainSiteId) async {
    final children = <EquipmentNavigationNode>[];

    // Load sub sites under this main site
    final subSiteMaps = await db.query(
      'sub_sites',
      where: 'main_site_id = ? AND is_active = 1',
      whereArgs: [mainSiteId],
      orderBy: 'name ASC',
    );

    children.addAll(subSiteMaps.map<EquipmentNavigationNode>((map) {
      final site = SubSite.fromMap(map);
      return EquipmentNavigationNode.subSite(
        id: site.id,
        name: site.name,
        parentId: mainSiteId,
      );
    }).toList());

    // Load equipment under this main site
    final equipmentMaps = await db.query(
      'equipment',
      where: 'main_site_id = ? AND is_active = 1',
      whereArgs: [mainSiteId],
      orderBy: 'name ASC',
    );

    children.addAll(equipmentMaps.map<EquipmentNavigationNode>((map) {
      final equipment = Equipment.fromMap(map);
      return EquipmentNavigationNode.equipment(
        id: equipment.id,
        name: equipment.name,
        parentId: mainSiteId,
      );
    }).toList());

    return children;
  }

  /// Load children for a sub site node (child sub sites + equipment)
  Future<List<EquipmentNavigationNode>> _loadSubSiteChildren(dynamic db, String subSiteId) async {
    final children = <EquipmentNavigationNode>[];

    // Load child sub sites
    final subSiteMaps = await db.query(
      'sub_sites',
      where: 'parent_subsite_id = ? AND is_active = 1',
      whereArgs: [subSiteId],
      orderBy: 'name ASC',
    );

    children.addAll(subSiteMaps.map<EquipmentNavigationNode>((map) {
      final site = SubSite.fromMap(map);
      return EquipmentNavigationNode.subSite(
        id: site.id,
        name: site.name,
        parentId: subSiteId,
      );
    }).toList());

    // Load equipment under this sub site
    final equipmentMaps = await db.query(
      'equipment',
      where: 'sub_site_id = ? AND is_active = 1',
      whereArgs: [subSiteId],
      orderBy: 'name ASC',
    );

    children.addAll(equipmentMaps.map<EquipmentNavigationNode>((map) {
      final equipment = Equipment.fromMap(map);
      return EquipmentNavigationNode.equipment(
        id: equipment.id,
        name: equipment.name,
        parentId: subSiteId,
      );
    }).toList());

    return children;
  }
}
