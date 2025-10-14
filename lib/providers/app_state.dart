import 'package:flutter/foundation.dart';
import '../models/client.dart';
import '../models/site.dart';
import '../models/equipment.dart';
import '../models/photo.dart';
import '../models/user.dart';
import '../models/photo_folder.dart';
import '../services/database_service.dart';
import '../services/api_service.dart';
import '../services/folder_service.dart';

class AppState extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  bool _isOnline = true;
  User? _currentUser;

  final _dbService = DatabaseService();
  final _apiService = ApiService();
  final _folderService = FolderService();

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isOnline => _isOnline;
  User? get currentUser => _currentUser;

  void setCurrentUser(User? user) {
    _currentUser = user;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void setOnlineStatus(bool online) {
    _isOnline = online;
    notifyListeners();
  }

  // Client methods
  Future<List<Client>> getClients({bool? isActive}) async {
    try {
      final db = await _dbService.database;
      // Filter out system clients (is_system = 0) from user-facing lists
      final List<Map<String, dynamic>> maps = await db.query(
        'clients',
        where: isActive != null ? 'is_active = ? AND is_system = 0' : 'is_system = 0',
        whereArgs: isActive != null ? [isActive ? 1 : 0] : null,
        orderBy: 'name ASC',
      );
      return maps.map((map) => Client.fromMap(map)).toList();
    } catch (e) {
      setError('Failed to load clients: $e');
      return [];
    }
  }

  Future<Client?> getClient(String id) async {
    try {
      final db = await _dbService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'clients',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (maps.isEmpty) return null;
      return Client.fromMap(maps.first);
    } catch (e) {
      setError('Failed to load client: $e');
      return null;
    }
  }

  Future<void> createClient(String name, String? description) async {
    try {
      final client = Client(
        name: name,
        description: description,
        createdBy: _currentUser?.id ?? 'unknown',
      );
      final db = await _dbService.database;
      await db.insert('clients', client.toMap());

      notifyListeners();
    } catch (e) {
      setError('Failed to create client: $e');
      rethrow;
    }
  }

  // Main Site methods
  Future<List<MainSite>> getMainSites(String clientId) async {
    try {
      final db = await _dbService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'main_sites',
        where: 'client_id = ? AND is_active = ?',
        whereArgs: [clientId, 1],
        orderBy: 'name ASC',
      );
      return maps.map((map) => MainSite.fromMap(map)).toList();
    } catch (e) {
      setError('Failed to load main sites: $e');
      return [];
    }
  }

  Future<MainSite?> getMainSite(String id) async {
    try {
      final db = await _dbService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'main_sites',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (maps.isEmpty) return null;
      return MainSite.fromMap(maps.first);
    } catch (e) {
      setError('Failed to load main site: $e');
      return null;
    }
  }

  Future<void> createMainSite(
    String clientId,
    String name,
    String? address,
  ) async {
    try {
      final site = MainSite(
        clientId: clientId,
        name: name,
        address: address,
        createdBy: _currentUser?.id ?? 'unknown',
      );
      final db = await _dbService.database;
      await db.insert('main_sites', site.toMap());
      notifyListeners();
    } catch (e) {
      setError('Failed to create main site: $e');
      rethrow;
    }
  }

  Future<void> deleteMainSite(String siteId) async {
    try {
      final db = await _dbService.database;

      // Soft delete
      await db.update(
        'main_sites',
        {'is_active': 0},
        where: 'id = ?',
        whereArgs: [siteId],
      );

      notifyListeners();
    } catch (e) {
      setError('Failed to delete main site: $e');
      rethrow;
    }
  }

  Future<void> updateMainSite(
    String siteId,
    String name,
    String? address,
  ) async {
    try {
      final db = await _dbService.database;

      await db.update(
        'main_sites',
        {
          'name': name,
          'address': address,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [siteId],
      );

      notifyListeners();
    } catch (e) {
      setError('Failed to update main site: $e');
      rethrow;
    }
  }

  // SubSite methods
  Future<List<SubSite>> getSubSites(String mainSiteId) async {
    try {
      final db = await _dbService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'sub_sites',
        where: 'main_site_id = ? AND is_active = ?',
        whereArgs: [mainSiteId, 1],
        orderBy: 'name ASC',
      );
      return maps.map((map) => SubSite.fromMap(map)).toList();
    } catch (e) {
      setError('Failed to load sub sites: $e');
      return [];
    }
  }

  Future<SubSite?> getSubSite(String id) async {
    try {
      final db = await _dbService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'sub_sites',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (maps.isEmpty) return null;
      return SubSite.fromMap(maps.first);
    } catch (e) {
      setError('Failed to load sub site: $e');
      return null;
    }
  }

  Future<void> createSubSite(
    String name,
    String? description, {
    String? clientId,
    String? mainSiteId,
    String? parentSubSiteId,
  }) async {
    try {
      final subSite = SubSite(
        clientId: clientId,
        mainSiteId: mainSiteId,
        parentSubSiteId: parentSubSiteId,
        name: name,
        description: description,
        createdBy: _currentUser?.id ?? 'unknown',
      );
      final db = await _dbService.database;
      await db.insert('sub_sites', subSite.toMap());
      notifyListeners();
    } catch (e) {
      setError('Failed to create sub site: $e');
      rethrow;
    }
  }

  Future<List<SubSite>> getSubSitesForClient(String clientId) async {
    try {
      final db = await _dbService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'sub_sites',
        where: 'client_id = ? AND is_active = ?',
        whereArgs: [clientId, 1],
        orderBy: 'name ASC',
      );
      return maps.map((map) => SubSite.fromMap(map)).toList();
    } catch (e) {
      setError('Failed to load subsites for client: $e');
      return [];
    }
  }

  Future<List<SubSite>> getNestedSubSites(String parentSubSiteId) async {
    try {
      final db = await _dbService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'sub_sites',
        where: 'parent_subsite_id = ? AND is_active = ?',
        whereArgs: [parentSubSiteId, 1],
        orderBy: 'name ASC',
      );
      return maps.map((map) => SubSite.fromMap(map)).toList();
    } catch (e) {
      setError('Failed to load nested subsites: $e');
      return [];
    }
  }

  // Equipment methods
  Future<List<Equipment>> getEquipmentForMainSite(String mainSiteId) async {
    try {
      final db = await _dbService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'equipment',
        where: 'main_site_id = ? AND is_active = ?',
        whereArgs: [mainSiteId, 1],
        orderBy: 'name ASC',
      );
      return maps.map((map) => Equipment.fromMap(map)).toList();
    } catch (e) {
      setError('Failed to load equipment: $e');
      return [];
    }
  }

  Future<List<Equipment>> getEquipmentForSubSite(String subSiteId) async {
    try {
      final db = await _dbService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'equipment',
        where: 'sub_site_id = ? AND is_active = ?',
        whereArgs: [subSiteId, 1],
        orderBy: 'name ASC',
      );
      return maps.map((map) => Equipment.fromMap(map)).toList();
    } catch (e) {
      setError('Failed to load equipment: $e');
      return [];
    }
  }

  Future<Equipment?> getEquipment(String id) async {
    try {
      final db = await _dbService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'equipment',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (maps.isEmpty) return null;
      return Equipment.fromMap(maps.first);
    } catch (e) {
      setError('Failed to load equipment: $e');
      return null;
    }
  }

  Future<void> createEquipment(
    String name, {
    String? clientId,
    String? mainSiteId,
    String? subSiteId,
    String? serialNumber,
  }) async {
    try {
      final equipment = Equipment(
        name: name,
        clientId: clientId,
        mainSiteId: mainSiteId,
        subSiteId: subSiteId,
        serialNumber: serialNumber,
        createdBy: _currentUser?.id ?? 'unknown',
      );
      final db = await _dbService.database;
      await db.insert('equipment', equipment.toMap());
      notifyListeners();
    } catch (e) {
      setError('Failed to create equipment: $e');
      rethrow;
    }
  }

  Future<List<Equipment>> getEquipmentForClient(String clientId) async {
    try {
      final db = await _dbService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'equipment',
        where: 'client_id = ? AND is_active = ?',
        whereArgs: [clientId, 1],
        orderBy: 'name ASC',
      );
      return maps.map((map) => Equipment.fromMap(map)).toList();
    } catch (e) {
      setError('Failed to load equipment for client: $e');
      return [];
    }
  }

  // Photo methods
  Future<List<Photo>> getPhotos(String equipmentId) async {
    try {
      final db = await _dbService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'photos',
        where: 'equipment_id = ?',
        whereArgs: [equipmentId],
        orderBy: 'timestamp DESC',
      );
      return maps.map((map) => Photo.fromMap(map)).toList();
    } catch (e) {
      setError('Failed to load photos: $e');
      return [];
    }
  }

  // Folder methods (T008)

  /// Get all photos with folder information
  Future<List<Photo>> getPhotosWithFolderInfo(String equipmentId) async {
    try {
      final maps = await _dbService.getAllPhotosWithFolderInfo(equipmentId);
      return maps.map((map) => Photo.fromMap(map)).toList();
    } catch (e) {
      setError('Failed to load photos with folder info: $e');
      return [];
    }
  }

  /// Get all folders for an equipment
  Future<List<PhotoFolder>> getFoldersForEquipment(String equipmentId) async {
    try {
      final folders = await _folderService.getFolders(equipmentId);
      return folders;
    } catch (e) {
      setError('Failed to load folders: $e');
      return [];
    }
  }

  /// Create a new folder
  Future<PhotoFolder?> createFolder({
    required String equipmentId,
    required String workOrder,
  }) async {
    try {
      if (_currentUser == null) {
        setError('No user logged in');
        return null;
      }

      final folder = await _folderService.createFolder(
        equipmentId: equipmentId,
        workOrder: workOrder,
        createdBy: _currentUser!.id,
      );

      notifyListeners();
      return folder;
    } catch (e) {
      setError('Failed to create folder: $e');
      return null;
    }
  }

  // Search method
  Future<List<SearchResult>> search(String query) async {
    try {
      final results = <SearchResult>[];
      final db = await _dbService.database;
      final searchPattern = '%$query%';

      // Search clients (excluding system clients)
      final clients = await db.query(
        'clients',
        where: 'name LIKE ? AND is_active = ? AND is_system = 0',
        whereArgs: [searchPattern, 1],
        limit: 20,
      );
      results.addAll(
        clients.map(
          (c) => SearchResult(
            id: c['id'] as String,
            title: c['name'] as String,
            subtitle: 'Client',
            type: SearchResultType.client,
          ),
        ),
      );

      // Search main sites
      final mainSites = await db.query(
        'main_sites',
        where: 'name LIKE ? AND is_active = ?',
        whereArgs: [searchPattern, 1],
        limit: 20,
      );
      results.addAll(
        mainSites.map(
          (s) => SearchResult(
            id: s['id'] as String,
            title: s['name'] as String,
            subtitle: 'Main Site',
            type: SearchResultType.mainSite,
          ),
        ),
      );

      // Search equipment
      final equipment = await db.query(
        'equipment',
        where: '(name LIKE ? OR serial_number LIKE ?) AND is_active = ?',
        whereArgs: [searchPattern, searchPattern, 1],
        limit: 20,
      );
      results.addAll(
        equipment.map(
          (e) => SearchResult(
            id: e['id'] as String,
            title: e['name'] as String,
            subtitle: e['serial_number'] != null
                ? 'Equipment - S/N: ${e['serial_number']}'
                : 'Equipment',
            type: SearchResultType.equipment,
          ),
        ),
      );

      return results;
    } catch (e) {
      setError('Search failed: $e');
      return [];
    }
  }
}

// Search result model (moved from search_screen.dart to here for sharing)
class SearchResult {
  final String id;
  final String title;
  final String subtitle;
  final SearchResultType type;

  SearchResult({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.type,
  });
}

enum SearchResultType { client, mainSite, subSite, equipment }
