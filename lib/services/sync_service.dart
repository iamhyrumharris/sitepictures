import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import '../models/sync_queue_item.dart';
import 'database_service.dart';
import 'api_service.dart';

class SyncService {
  static final SyncService _instance = SyncService._internal();
  final DatabaseService _dbService = DatabaseService();
  final ApiService _apiService = ApiService();

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
      final pendingItems = await getPendingItems();

      for (final item in pendingItems) {
        try {
          await _syncItem(item);
        } catch (e) {
          await _handleSyncError(item, e.toString());
        }
      }

      _lastSyncTime = DateTime.now();
      _isSyncing = false;
      return true;
    } catch (e) {
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

    if (response != null && response.statusCode >= 200 && response.statusCode < 300) {
      await _markSyncComplete(item);
    } else {
      throw Exception('Sync failed with status ${response?.statusCode}');
    }
  }

  Future<http.Response> _syncPhoto(
      SyncQueueItem item, Map<String, dynamic> payload) async {
    if (item.operation == 'create') {
      final filePath = payload['filePath'] as String;
      final file = File(filePath);

      if (await file.exists()) {
        final response = await _apiService.uploadFile(
          '/equipment/${payload['equipmentId']}/photos',
          filePath,
          {
            'latitude': payload['latitude'].toString(),
            'longitude': payload['longitude'].toString(),
            'timestamp': payload['timestamp'].toString(),
          },
        );

        return http.Response(
          await response.stream.bytesToString(),
          response.statusCode,
        );
      }
    }

    return http.Response('', 400);
  }

  Future<http.Response> _syncClient(
      SyncQueueItem item, Map<String, dynamic> payload) async {
    switch (item.operation) {
      case 'create':
        return await _apiService.post('/clients', payload);
      case 'update':
        return await _apiService.put('/clients/${item.entityId}', payload);
      case 'delete':
        return await _apiService.delete('/clients/${item.entityId}');
      default:
        return http.Response('', 400);
    }
  }

  Future<http.Response> _syncMainSite(
      SyncQueueItem item, Map<String, dynamic> payload) async {
    switch (item.operation) {
      case 'create':
        return await _apiService.post(
            '/clients/${payload['clientId']}/sites', payload);
      case 'update':
        return await _apiService.put('/sites/${item.entityId}', payload);
      case 'delete':
        return await _apiService.delete('/sites/${item.entityId}');
      default:
        return http.Response('', 400);
    }
  }

  Future<http.Response> _syncSubSite(
      SyncQueueItem item, Map<String, dynamic> payload) async {
    switch (item.operation) {
      case 'create':
        return await _apiService.post(
            '/sites/${payload['mainSiteId']}/subsites', payload);
      case 'update':
        return await _apiService.put('/subsites/${item.entityId}', payload);
      case 'delete':
        return await _apiService.delete('/subsites/${item.entityId}');
      default:
        return http.Response('', 400);
    }
  }

  Future<http.Response> _syncEquipment(
      SyncQueueItem item, Map<String, dynamic> payload) async {
    switch (item.operation) {
      case 'create':
        return await _apiService.post('/equipment', payload);
      case 'update':
        return await _apiService.put('/equipment/${item.entityId}', payload);
      case 'delete':
        return await _apiService.delete('/equipment/${item.entityId}');
      default:
        return http.Response('', 400);
    }
  }

  Future<void> _markSyncComplete(SyncQueueItem item) async {
    final db = await _dbService.database;
    await db.update(
      'sync_queue',
      {
        'is_completed': 1,
        'last_attempt': DateTime.now().toIso8601String(),
      },
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
