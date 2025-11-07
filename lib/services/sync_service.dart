import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import '../models/sync_queue_item.dart';
import 'database_service.dart';
import 'serverpod_client_service.dart';
import 'serverpod_sync_service.dart';
import 'photo_storage_service.dart';

/// Enhanced SyncService using Serverpod backend
/// Maintains backward compatibility while using type-safe Serverpod calls
class SyncService {
  static final SyncService _instance = SyncService._internal();
  final DatabaseService _dbService = DatabaseService();
  final ServerpodClientService _clientService = ServerpodClientService();
  final ServerpodSyncService _serverpodSync = ServerpodSyncService();

  bool _isSyncing = false;
  DateTime? _lastSyncTime;

  factory SyncService() => _instance;

  SyncService._internal();

  bool get isSyncing => _isSyncing;
  DateTime? get lastSyncTime => _lastSyncTime;

  Future<void> queueForSync({
    required String entityType,
    required String entityId,
    required String operation,
    required Map<String, dynamic> payload,
  }) async {
    final db = await _dbService.database;

    final syncItem = {
      'id': '${DateTime.now().millisecondsSinceEpoch}',
      'entity_type': entityType,
      'entity_id': entityId,
      'operation': operation,
      'payload': jsonEncode(payload),
      'retry_count': 0,
      'created_at': DateTime.now().toIso8601String(),
      'is_completed': 0,
    };

    await db.insert('sync_queue', syncItem);
  }

  Future<int> getPendingCount() async {
    final db = await _dbService.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM sync_queue WHERE is_completed = 0',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<List<SyncQueueItem>> getPendingItems() async {
    final db = await _dbService.database;
    final results = await db.query(
      'sync_queue',
      where: 'is_completed = ?',
      whereArgs: [0],
      orderBy: 'created_at ASC',
      limit: 50,
    );

    return results.map((json) {
      return SyncQueueItem(
        id: json['id'] as String,
        entityType: json['entity_type'] as String,
        entityId: json['entity_id'] as String,
        operation: json['operation'] as String,
        payload: json['payload'] as String,
        retryCount: json['retry_count'] as int,
        createdAt: DateTime.parse(json['created_at'] as String),
        lastAttempt: json['last_attempt'] != null
            ? DateTime.parse(json['last_attempt'] as String)
            : null,
        error: json['error'] as String?,
        isCompleted: json['is_completed'] == 1,
      );
    }).toList();
  }

  Future<bool> syncAll() async {
    if (_isSyncing) {
      return false;
    }

    _isSyncing = true;

    try {
      // Use Serverpod's bidirectional sync service
      final results = await _serverpodSync.performSync();

      // Check if sync was successful
      if (results.containsKey('error')) {
        _isSyncing = false;
        return false;
      }

      // Sync completed successfully
      _lastSyncTime = DateTime.now();
      _isSyncing = false;

      // Log sync results
      print('Sync completed: ${results['pulled']} pulled, ${results['pushed']} pushed, ${results['conflicts']} conflicts');

      return true;
    } catch (e) {
      print('Sync error: $e');
      _isSyncing = false;
      return false;
    }
  }

  Future<void> _syncItem(SyncQueueItem item) async {
    final payload = jsonDecode(item.payload) as Map<String, dynamic>;
    http.Response? response;

    switch (item.entityType) {
      case 'photo':
        response = await _syncPhoto(item, payload);
        break;
      case 'client':
        response = await _syncClient(item, payload);
        break;
      case 'mainSite':
        response = await _syncMainSite(item, payload);
        break;
      case 'subSite':
        response = await _syncSubSite(item, payload);
        break;
      case 'equipment':
        response = await _syncEquipment(item, payload);
        break;
    }

    if (response != null &&
        response.statusCode >= 200 &&
        response.statusCode < 300) {
      await _markSyncComplete(item);
    } else {
      throw Exception('Sync failed with status ${response?.statusCode}');
    }
  }

  Future<http.Response> _syncPhoto(
    SyncQueueItem item,
    Map<String, dynamic> payload,
  ) async {
    try {
      if (item.operation == 'create') {
        final storedPath = payload['filePath'] as String;
        final file = PhotoStorageService.tryResolveLocalFile(storedPath);

        if (file != null && await file.exists()) {
          final client = _clientService.client;
          final bytes = await file.readAsBytes();
          final byteData = ByteData.sublistView(Uint8List.fromList(bytes));

          // Upload photo using Serverpod
          await client.photo.uploadPhoto(
            payload['equipmentId'] as String,
            byteData,
            file.path.split('/').last,
            (payload['latitude'] as num?)?.toDouble() ?? 0.0,
            (payload['longitude'] as num?)?.toDouble() ?? 0.0,
            DateTime.parse(payload['timestamp'] as String),
            payload['capturedBy'] as String? ?? 'unknown',
            payload['importSource'] as String? ?? 'camera',
          );

          return http.Response('{"success": true}', 200);
        }
      }

      return http.Response('{"error": "Invalid operation"}', 400);
    } catch (e) {
      return http.Response('{"error": "$e"}', 500);
    }
  }

  Future<http.Response> _syncClient(
    SyncQueueItem item,
    Map<String, dynamic> payload,
  ) async {
    try {
      final client = _clientService.client;

      switch (item.operation) {
        case 'create':
          await client.company.createCompany(
            payload['name'] as String,
            payload['description'] as String?,
            payload['createdBy'] as String,
          );
          return http.Response('{"success": true}', 200);

        case 'update':
          await client.company.updateCompany(
            payload['uuid'] as String,
            payload['name'] as String?,
            payload['description'] as String?,
          );
          return http.Response('{"success": true}', 200);

        case 'delete':
          await client.company.deleteCompany(payload['uuid'] as String);
          return http.Response('{"success": true}', 200);

        default:
          return http.Response('{"error": "Invalid operation"}', 400);
      }
    } catch (e) {
      return http.Response('{"error": "$e"}', 500);
    }
  }

  Future<http.Response> _syncMainSite(
    SyncQueueItem item,
    Map<String, dynamic> payload,
  ) async {
    try {
      final client = _clientService.client;

      switch (item.operation) {
        case 'create':
          await client.site.createMainSite(
            payload['clientId'] as String,
            payload['name'] as String,
            payload['address'] as String?,
            (payload['latitude'] as num?)?.toDouble(),
            (payload['longitude'] as num?)?.toDouble(),
            payload['createdBy'] as String,
          );
          return http.Response('{"success": true}', 200);

        case 'update':
          await client.site.updateMainSite(
            payload['uuid'] as String,
            payload['name'] as String?,
            payload['address'] as String?,
            (payload['latitude'] as num?)?.toDouble(),
            (payload['longitude'] as num?)?.toDouble(),
          );
          return http.Response('{"success": true}', 200);

        case 'delete':
          await client.site.deleteMainSite(payload['uuid'] as String);
          return http.Response('{"success": true}', 200);

        default:
          return http.Response('{"error": "Invalid operation"}', 400);
      }
    } catch (e) {
      return http.Response('{"error": "$e"}', 500);
    }
  }

  Future<http.Response> _syncSubSite(
    SyncQueueItem item,
    Map<String, dynamic> payload,
  ) async {
    try {
      final client = _clientService.client;

      switch (item.operation) {
        case 'create':
          await client.site.createSubSite(
            payload['name'] as String,
            payload['description'] as String?,
            payload['createdBy'] as String,
            clientId: payload['clientId'] as String?,
            mainSiteId: payload['mainSiteId'] as String?,
          );
          return http.Response('{"success": true}', 200);

        case 'update':
          await client.site.updateSubSite(
            payload['uuid'] as String,
            payload['name'] as String?,
            payload['description'] as String?,
          );
          return http.Response('{"success": true}', 200);

        case 'delete':
          await client.site.deleteSubSite(payload['uuid'] as String);
          return http.Response('{"success": true}', 200);

        default:
          return http.Response('{"error": "Invalid operation"}', 400);
      }
    } catch (e) {
      return http.Response('{"error": "$e"}', 500);
    }
  }

  Future<http.Response> _syncEquipment(
    SyncQueueItem item,
    Map<String, dynamic> payload,
  ) async {
    try {
      final client = _clientService.client;

      switch (item.operation) {
        case 'create':
          await client.equipment.createEquipment(
            payload['name'] as String,
            payload['serialNumber'] as String?,
            payload['manufacturer'] as String?,
            payload['model'] as String?,
            payload['createdBy'] as String,
            clientId: payload['clientId'] as String,
            mainSiteId: payload['mainSiteId'] as String?,
            subSiteId: payload['subSiteId'] as String?,
          );
          return http.Response('{"success": true}', 200);

        case 'update':
          await client.equipment.updateEquipment(
            payload['uuid'] as String,
            payload['name'] as String?,
            payload['serialNumber'] as String?,
            payload['manufacturer'] as String?,
            payload['model'] as String?,
          );
          return http.Response('{"success": true}', 200);

        case 'delete':
          await client.equipment.deleteEquipment(payload['uuid'] as String);
          return http.Response('{"success": true}', 200);

        default:
          return http.Response('{"error": "Invalid operation"}', 400);
      }
    } catch (e) {
      return http.Response('{"error": "$e"}', 500);
    }
  }

  Future<void> _markSyncComplete(SyncQueueItem item) async {
    final db = await _dbService.database;
    await db.update(
      'sync_queue',
      {'is_completed': 1, 'last_attempt': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<void> _handleSyncError(SyncQueueItem item, String error) async {
    final db = await _dbService.database;
    final newRetryCount = item.retryCount + 1;

    await db.update(
      'sync_queue',
      {
        'retry_count': newRetryCount,
        'last_attempt': DateTime.now().toIso8601String(),
        'error': error,
      },
      where: 'id = ?',
      whereArgs: [item.id],
    );

    // After 3 retries, mark as completed to avoid infinite retries
    if (newRetryCount >= 3) {
      await db.update(
        'sync_queue',
        {'is_completed': 1},
        where: 'id = ?',
        whereArgs: [item.id],
      );
    }
  }

  Future<void> clearCompletedItems() async {
    final db = await _dbService.database;
    final cutoffDate = DateTime.now().subtract(const Duration(days: 7));

    await db.delete(
      'sync_queue',
      where: 'is_completed = 1 AND created_at < ?',
      whereArgs: [cutoffDate.toIso8601String()],
    );
  }
}
