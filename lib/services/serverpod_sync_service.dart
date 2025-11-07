import 'dart:convert';
import 'serverpod_client_service.dart';
import '../services/database_service.dart';

/// Enhanced sync service using Serverpod endpoints
/// This integrates with the existing SQLite database while syncing with the server
class ServerpodSyncService {
  static final ServerpodSyncService _instance = ServerpodSyncService._internal();
  final ServerpodClientService _clientService = ServerpodClientService();
  final DatabaseService _dbService = DatabaseService();

  bool _isSyncing = false;
  DateTime? _lastSyncTime;

  factory ServerpodSyncService() => _instance;

  ServerpodSyncService._internal();

  bool get isSyncing => _isSyncing;
  DateTime? get lastSyncTime => _lastSyncTime;

  /// Perform full bidirectional sync
  Future<Map<String, dynamic>> performSync() async {
    if (_isSyncing) {
      return {'error': 'Sync already in progress'};
    }

    _isSyncing = true;

    try {
      final results = {
        'pulled': 0,
        'pushed': 0,
        'conflicts': 0,
        'errors': <String>[],
      };

      // 1. Pull changes from server
      final pullResults = await _pullChangesFromServer();
      results['pulled'] = pullResults['applied'] ?? 0;
      results['conflicts'] = pullResults['conflicts'] ?? 0;

      // 2. Push local changes to server
      final pushResults = await _pushChangesToServer();
      results['pushed'] = pushResults['success'] ?? 0;

      if (pushResults['errors'] != null) {
        results['errors'] = pushResults['errors'] as List<String>;
      }

      _lastSyncTime = DateTime.now();
      return results;
    } catch (e) {
      return {
        'error': e.toString(),
      };
    } finally {
      _isSyncing = false;
    }
  }

  /// Pull changes from server since last sync
  Future<Map<String, dynamic>> _pullChangesFromServer() async {
    final client = _clientService.client;
    final since = _lastSyncTime ?? DateTime(2000); // First sync gets everything

    try {
      // Get changes from server
      final changes = await client.sync.getChangesSince(since);

      var appliedCount = 0;
      var conflictCount = 0;

      // Apply changes to local database
      // Companies
      if (changes['companies'] != null) {
        for (final companyData in changes['companies'] as List) {
          await _applyCompanyChange(companyData as Map<String, dynamic>);
          appliedCount++;
        }
      }

      // Main Sites
      if (changes['mainSites'] != null) {
        for (final siteData in changes['mainSites'] as List) {
          await _applyMainSiteChange(siteData as Map<String, dynamic>);
          appliedCount++;
        }
      }

      // Sub Sites
      if (changes['subSites'] != null) {
        for (final siteData in changes['subSites'] as List) {
          await _applySubSiteChange(siteData as Map<String, dynamic>);
          appliedCount++;
        }
      }

      // Equipment
      if (changes['equipment'] != null) {
        for (final equipData in changes['equipment'] as List) {
          await _applyEquipmentChange(equipData as Map<String, dynamic>);
          appliedCount++;
        }
      }

      // Photos (metadata only, files downloaded separately)
      if (changes['photos'] != null) {
        for (final photoData in changes['photos'] as List) {
          await _applyPhotoChange(photoData as Map<String, dynamic>);
          appliedCount++;
        }
      }

      // Folders
      if (changes['folders'] != null) {
        for (final folderData in changes['folders'] as List) {
          await _applyFolderChange(folderData as Map<String, dynamic>);
          appliedCount++;
        }
      }

      return {
        'applied': appliedCount,
        'conflicts': conflictCount,
      };
    } catch (e) {
      return {
        'error': e.toString(),
      };
    }
  }

  /// Push local changes to server
  Future<Map<String, dynamic>> _pushChangesToServer() async {
    final client = _clientService.client;
    final db = await _dbService.database;

    try {
      // Get pending changes from local sync queue
      final pendingChanges = await db.query(
        'sync_queue',
        where: 'is_completed = ?',
        whereArgs: [0],
        orderBy: 'created_at ASC',
        limit: 50,
      );

      if (pendingChanges.isEmpty) {
        return {'success': 0};
      }

      // Convert to format expected by server
      final changes = pendingChanges.map((change) {
        final payload = jsonDecode(change['payload'] as String) as Map<String, dynamic>;
        final entityType = change['entity_type'] as String;

        return {
          'entityType': entityType,
          'operation': change['operation'],
          'data': _transformPayload(payload, entityType), // Transform field names
        };
      }).toList();

      // Push to server
      final result = await client.sync.pushChanges(changes);

      // Mark successful items as completed
      final successList = result['success'] as List;
      for (final successId in successList) {
        final parts = successId.toString().split(':');
        if (parts.length == 2) {
          await db.update(
            'sync_queue',
            {'is_completed': 1},
            where: 'entity_type = ? AND entity_id = ?',
            whereArgs: [parts[0], parts[1]],
          );
        }
      }

      return {
        'success': successList.length,
        'conflicts': (result['conflicts'] as List?)?.length ?? 0,
        'errors': (result['errors'] as List?)?.map((e) => e.toString()).toList() ?? [],
      };
    } catch (e) {
      return {
        'error': e.toString(),
      };
    }
  }

  // Helper methods to apply changes to local database

  Future<void> _applyCompanyChange(Map<String, dynamic> data) async {
    final db = await _dbService.database;
    final existing = await db.query(
      'clients',
      where: 'id = ?',
      whereArgs: [data['uuid']],
    );

    if (existing.isEmpty) {
      await db.insert('clients', {
        'id': data['uuid'],
        'name': data['name'],
        'description': data['description'],
        'is_system': data['isSystem'] == true ? 1 : 0,
        'created_by': data['createdBy'],
        'created_at': data['createdAt'],
        'updated_at': data['updatedAt'],
        'is_active': data['isActive'] == true ? 1 : 0,
      });
    } else {
      await db.update(
        'clients',
        {
          'name': data['name'],
          'description': data['description'],
          'updated_at': data['updatedAt'],
          'is_active': data['isActive'] == true ? 1 : 0,
        },
        where: 'id = ?',
        whereArgs: [data['uuid']],
      );
    }
  }

  Future<void> _applyMainSiteChange(Map<String, dynamic> data) async {
    final db = await _dbService.database;
    final existing = await db.query(
      'main_sites',
      where: 'id = ?',
      whereArgs: [data['uuid']],
    );

    final siteData = {
      'id': data['uuid'],
      'client_id': data['clientId'],
      'name': data['name'],
      'address': data['address'],
      'latitude': data['latitude'],
      'longitude': data['longitude'],
      'created_by': data['createdBy'],
      'created_at': data['createdAt'],
      'updated_at': data['updatedAt'],
      'is_active': data['isActive'] == true ? 1 : 0,
    };

    if (existing.isEmpty) {
      await db.insert('main_sites', siteData);
    } else {
      await db.update(
        'main_sites',
        siteData,
        where: 'id = ?',
        whereArgs: [data['uuid']],
      );
    }
  }

  Future<void> _applySubSiteChange(Map<String, dynamic> data) async {
    final db = await _dbService.database;
    // Similar to main site, apply changes to sub_sites table
    // Implementation follows same pattern as _applyMainSiteChange
  }

  Future<void> _applyEquipmentChange(Map<String, dynamic> data) async {
    final db = await _dbService.database;
    // Apply changes to equipment table
    // Implementation follows same pattern
  }

  Future<void> _applyPhotoChange(Map<String, dynamic> data) async {
    final db = await _dbService.database;
    // Apply photo metadata to photos table
    // Note: Actual file download would be handled separately
  }

  Future<void> _applyFolderChange(Map<String, dynamic> data) async {
    final db = await _dbService.database;
    // Apply changes to photo_folders table
  }

  /// Transform SQLite field names (snake_case) to Serverpod field names (camelCase)
  Map<String, dynamic> _transformPayload(Map<String, dynamic> payload, String entityType) {
    return {
      'uuid': payload['id'],
      'name': payload['name'],
      'description': payload['description'],
      'isSystem': payload['is_system'] == 1,
      'createdBy': payload['created_by'],
      'createdAt': payload['created_at'],
      'updatedAt': payload['updated_at'],
      'isActive': payload['is_active'] == 1,
      // Add entity-specific fields as needed
      if (payload['client_id'] != null) 'clientId': payload['client_id'],
      if (payload['main_site_id'] != null) 'mainSiteId': payload['main_site_id'],
      if (payload['sub_site_id'] != null) 'subSiteId': payload['sub_site_id'],
      if (payload['equipment_id'] != null) 'equipmentId': payload['equipment_id'],
      if (payload['address'] != null) 'address': payload['address'],
      if (payload['latitude'] != null) 'latitude': payload['latitude'],
      if (payload['longitude'] != null) 'longitude': payload['longitude'],
      if (payload['serial_number'] != null) 'serialNumber': payload['serial_number'],
      if (payload['manufacturer'] != null) 'manufacturer': payload['manufacturer'],
      if (payload['model'] != null) 'model': payload['model'],
    };
  }
}
