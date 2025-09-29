import 'dart:async';
import 'package:flutter/material.dart';
import '../models/client.dart';
import '../models/site.dart';
import '../models/equipment.dart';
import 'storage_service.dart';

class NavigationService {
  static NavigationService? _instance;
  final StorageService _storageService = StorageService.instance;

  final List<NavigationNode> _navigationStack = [];
  final StreamController<List<NavigationNode>> _breadcrumbController =
      StreamController<List<NavigationNode>>.broadcast();

  NavigationService._();

  static NavigationService get instance {
    _instance ??= NavigationService._();
    return _instance!;
  }

  Stream<List<NavigationNode>> get breadcrumbStream => _breadcrumbController.stream;
  List<NavigationNode> get currentPath => List.unmodifiable(_navigationStack);

  NavigationNode? get currentNode => _navigationStack.isNotEmpty ? _navigationStack.last : null;

  bool get canGoBack => _navigationStack.length > 1;

  Future<void> navigateToRoot() async {
    _navigationStack.clear();
    _navigationStack.add(NavigationNode(
      id: 'root',
      name: 'Home',
      type: NavigationType.root,
      data: null,
    ));
    _updateBreadcrumb();
  }

  Future<void> navigateToNeedsAssignment() async {
    _navigationStack.clear();
    _navigationStack.add(NavigationNode(
      id: 'root',
      name: 'Home',
      type: NavigationType.root,
      data: null,
    ));
    _navigationStack.add(NavigationNode(
      id: 'needs_assignment',
      name: 'Needs Assignment',
      type: NavigationType.needsAssignment,
      data: null,
    ));
    _updateBreadcrumb();
  }

  Future<void> navigateToClient(Client client) async {
    final stopwatch = Stopwatch()..start();

    _clearToType(NavigationType.root);
    _navigationStack.add(NavigationNode(
      id: client.id,
      name: client.name,
      type: NavigationType.client,
      data: client,
    ));
    _updateBreadcrumb();

    final elapsed = stopwatch.elapsedMilliseconds;
    if (elapsed > 500) {
      print('Warning: Navigation took ${elapsed}ms');
    }
  }

  Future<void> navigateToSite(Site site, {Client? client}) async {
    final stopwatch = Stopwatch()..start();

    if (client != null) {
      await navigateToClient(client);
    } else if (!_hasType(NavigationType.client)) {
      final loadedClient = await _loadClient(site.clientId);
      if (loadedClient != null) {
        await navigateToClient(loadedClient);
      }
    }

    _clearToType(NavigationType.client);
    _navigationStack.add(NavigationNode(
      id: site.id,
      name: site.name,
      type: NavigationType.site,
      data: site,
    ));
    _updateBreadcrumb();

    final elapsed = stopwatch.elapsedMilliseconds;
    if (elapsed > 500) {
      print('Warning: Navigation took ${elapsed}ms');
    }
  }

  Future<void> navigateToEquipment(Equipment equipment, {Site? site, Client? client}) async {
    final stopwatch = Stopwatch()..start();

    if (site != null) {
      await navigateToSite(site, client: client);
    } else if (!_hasType(NavigationType.site)) {
      final loadedSite = await _loadSite(equipment.siteId);
      if (loadedSite != null) {
        await navigateToSite(loadedSite, client: client);
      }
    }

    _clearToType(NavigationType.site);
    _navigationStack.add(NavigationNode(
      id: equipment.id,
      name: equipment.name,
      type: NavigationType.equipment,
      data: equipment,
    ));
    _updateBreadcrumb();

    final elapsed = stopwatch.elapsedMilliseconds;
    if (elapsed > 500) {
      print('Warning: Navigation took ${elapsed}ms');
    }
  }

  Future<void> goBack() async {
    if (canGoBack) {
      _navigationStack.removeLast();
      _updateBreadcrumb();
    }
  }

  Future<void> goBackTo(NavigationType type) async {
    _clearToType(type);
    _updateBreadcrumb();
  }

  Future<void> navigateByPath(List<String> path) async {
    if (path.isEmpty) {
      await navigateToRoot();
      return;
    }

    _navigationStack.clear();
    _navigationStack.add(NavigationNode(
      id: 'root',
      name: 'Home',
      type: NavigationType.root,
      data: null,
    ));

    for (int i = 0; i < path.length; i++) {
      final segment = path[i];

      if (i == 0) {
        final client = await _loadClientByName(segment);
        if (client != null) {
          _navigationStack.add(NavigationNode(
            id: client.id,
            name: client.name,
            type: NavigationType.client,
            data: client,
          ));
        }
      } else if (i == 1) {
        final clientNode = _findNodeByType(NavigationType.client);
        if (clientNode != null) {
          final site = await _loadSiteByName(segment, clientNode.id);
          if (site != null) {
            _navigationStack.add(NavigationNode(
              id: site.id,
              name: site.name,
              type: NavigationType.site,
              data: site,
            ));
          }
        }
      } else if (i == 2) {
        final siteNode = _findNodeByType(NavigationType.site);
        if (siteNode != null) {
          final equipment = await _loadEquipmentByName(segment, siteNode.id);
          if (equipment != null) {
            _navigationStack.add(NavigationNode(
              id: equipment.id,
              name: equipment.name,
              type: NavigationType.equipment,
              data: equipment,
            ));
          }
        }
      }
    }

    _updateBreadcrumb();
  }

  String getBreadcrumbString({String separator = ' > '}) {
    return _navigationStack
        .where((node) => node.type != NavigationType.root)
        .map((node) => node.name)
        .join(separator);
  }

  Future<Map<String, dynamic>> getNavigationTree() async {
    final db = await _storageService.database;

    final clients = await db.query(
      'clients',
      where: 'is_active = ?',
      whereArgs: [1],
      orderBy: 'name ASC',
    );

    final tree = <String, dynamic>{
      'type': 'root',
      'name': 'Home',
      'children': [],
    };

    for (final clientData in clients) {
      final client = Client.fromJson(clientData);
      final clientNode = {
        'type': 'client',
        'id': client.id,
        'name': client.name,
        'children': await _getSitesTree(client.id),
      };
      tree['children'].add(clientNode);
    }

    tree['children'].add({
      'type': 'special',
      'id': 'needs_assignment',
      'name': 'Needs Assignment',
      'children': [],
    });

    return tree;
  }

  Future<List<Map<String, dynamic>>> _getSitesTree(String clientId) async {
    final sites = await _storageService.getSitesByClient(clientId);
    final tree = <Map<String, dynamic>>[];

    for (final site in sites.where((s) => s.isMainSite)) {
      final siteNode = {
        'type': 'site',
        'id': site.id,
        'name': site.name,
        'children': await _getEquipmentTree(site.id),
      };

      final subSites = sites.where((s) => s.parentSiteId == site.id);
      for (final subSite in subSites) {
        siteNode['children'].add({
          'type': 'site',
          'id': subSite.id,
          'name': subSite.name,
          'isSubSite': true,
          'children': await _getEquipmentTree(subSite.id),
        });
      }

      tree.add(siteNode);
    }

    return tree;
  }

  Future<List<Map<String, dynamic>>> _getEquipmentTree(String siteId) async {
    final equipment = await _storageService.getEquipmentBySite(siteId);

    return equipment.map((e) => {
      'type': 'equipment',
      'id': e.id,
      'name': e.name,
      'equipmentType': e.equipmentType,
      'children': [],
    }).toList();
  }

  void _clearToType(NavigationType type) {
    while (_navigationStack.isNotEmpty && _navigationStack.last.type != type) {
      _navigationStack.removeLast();
    }
  }

  bool _hasType(NavigationType type) {
    return _navigationStack.any((node) => node.type == type);
  }

  NavigationNode? _findNodeByType(NavigationType type) {
    try {
      return _navigationStack.firstWhere((node) => node.type == type);
    } catch (_) {
      return null;
    }
  }

  void _updateBreadcrumb() {
    _breadcrumbController.add(List.from(_navigationStack));
  }

  Future<Client?> _loadClient(String id) async {
    final db = await _storageService.database;
    final results = await db.query(
      'clients',
      where: 'id = ?',
      whereArgs: [id],
    );
    return results.isNotEmpty ? Client.fromJson(results.first) : null;
  }

  Future<Client?> _loadClientByName(String name) async {
    final db = await _storageService.database;
    final results = await db.query(
      'clients',
      where: 'name = ? AND is_active = ?',
      whereArgs: [name, 1],
    );
    return results.isNotEmpty ? Client.fromJson(results.first) : null;
  }

  Future<Site?> _loadSite(String id) async {
    final db = await _storageService.database;
    final results = await db.query(
      'sites',
      where: 'id = ?',
      whereArgs: [id],
    );
    return results.isNotEmpty ? Site.fromJson(results.first) : null;
  }

  Future<Site?> _loadSiteByName(String name, String clientId) async {
    final db = await _storageService.database;
    final results = await db.query(
      'sites',
      where: 'name = ? AND client_id = ? AND is_active = ?',
      whereArgs: [name, clientId, 1],
    );
    return results.isNotEmpty ? Site.fromJson(results.first) : null;
  }

  Future<Equipment?> _loadEquipmentByName(String name, String siteId) async {
    final db = await _storageService.database;
    final results = await db.query(
      'equipment',
      where: 'name = ? AND site_id = ? AND is_active = ?',
      whereArgs: [name, siteId, 1],
    );
    return results.isNotEmpty ? Equipment.fromJson(results.first) : null;
  }

  void dispose() {
    _breadcrumbController.close();
  }
}

enum NavigationType {
  root,
  client,
  site,
  equipment,
  needsAssignment,
}

class NavigationNode {
  final String id;
  final String name;
  final NavigationType type;
  final dynamic data;

  NavigationNode({
    required this.id,
    required this.name,
    required this.type,
    this.data,
  });
}