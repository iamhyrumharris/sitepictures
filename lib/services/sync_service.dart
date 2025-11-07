import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';

import '../models/client.dart';
import '../models/photo.dart';
import '../models/site.dart';
import '../models/equipment.dart';
import '../models/photo_folder.dart';
import '../models/folder_photo.dart';
import '../models/duplicate_registry_entry.dart';
import '../models/sync_queue_item.dart';
import 'api_service.dart';
import 'database_service.dart';
import 'photo_storage_service.dart';
import 'serverpod_client_service.dart';
import 'serverpod_site_service.dart';
import 'serverpod_photo_service.dart';
import 'serverpod_equipment_service.dart';
import 'serverpod_folder_service.dart';
import 'serverpod_import_service.dart';

class SyncService {
  static final SyncService _instance = SyncService._internal();
  final DatabaseService _dbService = DatabaseService();
  final ApiService _apiService = ApiService();
  final ServerpodPhotoService _remotePhotoService =
      ServerpodPhotoService.instance;
  final ServerpodClientService _remoteClientService =
      ServerpodClientService.instance;
  final ServerpodSiteService _remoteSiteService =
      ServerpodSiteService.instance;
  final ServerpodEquipmentService _remoteEquipmentService =
      ServerpodEquipmentService.instance;
  final ServerpodFolderService _remoteFolderService =
      ServerpodFolderService.instance;
  final ServerpodImportService _remoteImportService =
      ServerpodImportService.instance;

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

      await _pullRemoteClients();
      await _pullRemotePhotoFolders();
      await _pullRemoteFolderPhotos();
      await _pullRemoteMainSites();
      await _pullRemoteSubSites();
      await _pullRemoteEquipment();
      await _pullRemoteImportBatches();
      await _pullRemoteDuplicateEntries();
      await _pullRemotePhotos();

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

    final type = item.entityType.toLowerCase();
    switch (type) {
      case 'photo':
        response = await _syncPhoto(item, payload);
        break;
      case 'client':
        response = await _syncClient(item, payload);
        break;
      case 'mainsite':
        response = await _syncMainSite(item, payload);
        break;
      case 'subsite':
        response = await _syncSubSite(item, payload);
        break;
      case 'equipment':
        response = await _syncEquipment(item, payload);
        break;
      case 'photofolder':
        response = await _syncPhotoFolder(item, payload);
        break;
      case 'folderphoto':
        response = await _syncFolderPhoto(item, payload);
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
    if (item.operation != 'create') {
      return http.Response('', 400);
    }

    final db = await _dbService.database;
    final results = await db.query(
      'photos',
      where: 'id = ?',
      whereArgs: [item.entityId],
      limit: 1,
    );

    if (results.isEmpty) {
      return http.Response('', 404);
    }

    final photo = Photo.fromMap(results.first);
    final file = PhotoStorageService.tryResolveLocalFile(photo.filePath);
    Uint8List? bytes;
    if (file != null && await file.exists()) {
      bytes = await file.readAsBytes();
    }

    await _remotePhotoService.uploadPhoto(
      photo: photo,
      fileBytes: bytes,
    );

    await db.update(
      'photos',
      {
        'is_synced': 1,
        'synced_at': DateTime.now().toIso8601String(),
        'remote_url': 'remote://${photo.id}',
      },
      where: 'id = ?',
      whereArgs: [photo.id],
    );

    return http.Response('ok', 200);
  }

  Future<void> _pullRemoteClients() async {
    try {
      final lastSync = await _dbService.getLatestClientUpdatedAt();
      final remoteClients = await _remoteClientService.pullClients(lastSync);
      if (remoteClients.isEmpty) {
        return;
      }

      final db = await _dbService.database;
      for (final client in remoteClients) {
        final clientMap = client.toMap();
        final existing = await db.query(
          'clients',
          where: 'id = ?',
          whereArgs: [client.id],
          limit: 1,
        );

        if (existing.isEmpty) {
          await db.insert('clients', clientMap);
        } else {
          await db.update(
            'clients',
            clientMap,
            where: 'id = ?',
            whereArgs: [client.id],
          );
        }
      }
    } catch (_) {
      // Ignore pull errors to keep sync resilient.
    }
  }

  Future<void> _pullRemotePhotoFolders() async {
    try {
      final lastSync = await _dbService.getLatestPhotoFolderUpdatedAt();
      final remoteFolders = await _remoteFolderService.pullFolders(lastSync);
      if (remoteFolders.isEmpty) {
        return;
      }

      final db = await _dbService.database;
      for (final folder in remoteFolders) {
        final map = folder.toMap();
        final existing = await db.query(
          'photo_folders',
          where: 'id = ?',
          whereArgs: [folder.id],
          limit: 1,
        );
        if (existing.isEmpty) {
          await db.insert('photo_folders', map);
        } else {
          await db.update(
            'photo_folders',
            map,
            where: 'id = ?',
            whereArgs: [folder.id],
          );
        }
      }
    } catch (_) {}
  }

  Future<void> _pullRemoteFolderPhotos() async {
    try {
      final lastSync = await _dbService.getLatestFolderPhotoAddedAt();
      final remoteLinks =
          await _remoteFolderService.pullFolderPhotos(lastSync);
      if (remoteLinks.isEmpty) {
        return;
      }

      final db = await _dbService.database;
      for (final link in remoteLinks) {
        await db.insert(
          'folder_photos',
          link.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    } catch (_) {}
  }

  Future<void> _pullRemoteMainSites() async {
    try {
      final lastSync = await _dbService.getLatestMainSiteUpdatedAt();
      final remoteSites = await _remoteSiteService.pullMainSites(lastSync);
      if (remoteSites.isEmpty) {
        return;
      }

      final db = await _dbService.database;
      for (final site in remoteSites) {
        final map = site.toMap();
        final existing = await db.query(
          'main_sites',
          where: 'id = ?',
          whereArgs: [site.id],
          limit: 1,
        );
        if (existing.isEmpty) {
          await db.insert('main_sites', map);
        } else {
          await db.update(
            'main_sites',
            map,
            where: 'id = ?',
            whereArgs: [site.id],
          );
        }
      }
    } catch (_) {}
  }

  Future<void> _pullRemoteSubSites() async {
    try {
      final lastSync = await _dbService.getLatestSubSiteUpdatedAt();
      final remoteSites = await _remoteSiteService.pullSubSites(lastSync);
      if (remoteSites.isEmpty) {
        return;
      }

      final db = await _dbService.database;
      for (final site in remoteSites) {
        final map = site.toMap();
        final existing = await db.query(
          'sub_sites',
          where: 'id = ?',
          whereArgs: [site.id],
          limit: 1,
        );
        if (existing.isEmpty) {
          await db.insert('sub_sites', map);
        } else {
          await db.update(
            'sub_sites',
            map,
            where: 'id = ?',
            whereArgs: [site.id],
          );
        }
      }
    } catch (_) {}
  }

  Future<void> _pullRemoteEquipment() async {
    try {
      final lastSync = await _dbService.getLatestEquipmentUpdatedAt();
      final remoteEquipment =
          await _remoteEquipmentService.pullEquipment(lastSync);
      if (remoteEquipment.isEmpty) {
        return;
      }

      final db = await _dbService.database;
      for (final equipment in remoteEquipment) {
        final map = equipment.toMap();
        final existing = await db.query(
          'equipment',
          where: 'id = ?',
          whereArgs: [equipment.id],
          limit: 1,
        );
        if (existing.isEmpty) {
          await db.insert('equipment', map);
        } else {
          await db.update(
            'equipment',
            map,
            where: 'id = ?',
            whereArgs: [equipment.id],
          );
        }
      }
    } catch (_) {}
  }

  Future<void> _pullRemotePhotos() async {
    try {
      final lastSync = await _dbService.getLatestPhotoSyncTimestamp();
      final remotePayloads = await _remotePhotoService.pullPhotos(lastSync);
      if (remotePayloads.isEmpty) {
        return;
      }

      final db = await _dbService.database;
      for (final payload in remotePayloads) {
        if (payload.bytes == null) {
          continue;
        }

        final storedPath = await PhotoStorageService.saveRemoteBytes(
          payload.bytes!,
          remoteId: payload.record.clientId,
        );

        final photo = _remotePhotoService.toLocalPhoto(
          record: payload.record,
          filePath: storedPath,
        );

        final photoMap = photo.toMap()
          ..addAll({
            'file_path': storedPath,
            'is_synced': 1,
            'synced_at': payload.record.updatedAt.toIso8601String(),
            'remote_url': photo.remoteUrl,
          });

        final existing = await db.query(
          'photos',
          where: 'id = ?',
          whereArgs: [photo.id],
          limit: 1,
        );

        if (existing.isEmpty) {
          await db.insert('photos', photoMap);
        } else {
          await db.update(
            'photos',
            photoMap,
            where: 'id = ?',
            whereArgs: [photo.id],
          );
        }
      }
    } catch (_) {
      // Remote pull is best effort; ignore failures to keep sync loop resilient.
    }
  }

  Future<void> _pullRemoteImportBatches() async {
    try {
      final lastSync = await _dbService.getLatestImportBatchUpdatedAt();
      final remoteBatches = await _remoteImportService.pullBatches(lastSync);
      if (remoteBatches.isEmpty) {
        return;
      }

      final db = await _dbService.database;
      for (final batch in remoteBatches) {
        await db.insert(
          'import_batches',
          batch.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    } catch (_) {}
  }

  Future<void> _pullRemoteDuplicateEntries() async {
    try {
      final lastSync = await _dbService.getLatestDuplicateImportedAt();
      final remoteEntries =
          await _remoteImportService.pullDuplicates(lastSync);
      if (remoteEntries.isEmpty) {
        return;
      }

      final db = await _dbService.database;
      for (final entry in remoteEntries) {
        await db.insert(
          'duplicate_registry',
          DuplicateRegistryEntry(
            id: entry.id,
            photoId: entry.photoId,
            sourceAssetId: entry.sourceAssetId,
            fingerprintSha1: entry.fingerprintSha1,
            importedAt: entry.importedAt.toLocal(),
          ).toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    } catch (_) {}
  }

  Future<http.Response> _syncClient(
    SyncQueueItem item,
    Map<String, dynamic> payload,
  ) async {
    final client = Client.fromJson(payload);
    await _remoteClientService.upsertClient(client);

    final db = await _dbService.database;
    final clientMap = client.toMap();
    final existing = await db.query(
      'clients',
      where: 'id = ?',
      whereArgs: [client.id],
      limit: 1,
    );

    if (existing.isEmpty) {
      await db.insert('clients', clientMap);
    } else {
      await db.update(
        'clients',
        clientMap,
        where: 'id = ?',
        whereArgs: [client.id],
      );
    }

    return http.Response('ok', 200);
  }

  Future<http.Response> _syncMainSite(
    SyncQueueItem item,
    Map<String, dynamic> payload,
  ) async {
    final site = MainSite.fromJson(payload);
    await _remoteSiteService.upsertMainSite(site);

    final db = await _dbService.database;
    final map = site.toMap();
    final existing = await db.query(
      'main_sites',
      where: 'id = ?',
      whereArgs: [site.id],
      limit: 1,
    );

    if (existing.isEmpty) {
      await db.insert('main_sites', map);
    } else {
      await db.update(
        'main_sites',
        map,
        where: 'id = ?',
        whereArgs: [site.id],
      );
    }

    return http.Response('ok', 200);
  }

  Future<http.Response> _syncSubSite(
    SyncQueueItem item,
    Map<String, dynamic> payload,
  ) async {
    final site = SubSite.fromJson(payload);
    await _remoteSiteService.upsertSubSite(site);

    final db = await _dbService.database;
    final map = site.toMap();
    final existing = await db.query(
      'sub_sites',
      where: 'id = ?',
      whereArgs: [site.id],
      limit: 1,
    );

    if (existing.isEmpty) {
      await db.insert('sub_sites', map);
    } else {
      await db.update(
        'sub_sites',
        map,
        where: 'id = ?',
        whereArgs: [site.id],
      );
    }

    return http.Response('ok', 200);
  }

  Future<http.Response> _syncEquipment(
    SyncQueueItem item,
    Map<String, dynamic> payload,
  ) async {
    final equipment = Equipment.fromJson(payload);
    await _remoteEquipmentService.upsertEquipment(equipment);

    final db = await _dbService.database;
    final map = equipment.toMap();
    final existing = await db.query(
      'equipment',
      where: 'id = ?',
      whereArgs: [equipment.id],
      limit: 1,
    );

    if (existing.isEmpty) {
      await db.insert('equipment', map);
    } else {
      await db.update(
        'equipment',
        map,
        where: 'id = ?',
        whereArgs: [equipment.id],
      );
    }

    return http.Response('ok', 200);
  }

  Future<http.Response> _syncPhotoFolder(
    SyncQueueItem item,
    Map<String, dynamic> payload,
  ) async {
    final folder = PhotoFolder.fromJson(payload);
    await _remoteFolderService.upsertFolder(folder);

    final db = await _dbService.database;
    final map = folder.toMap();
    final existing = await db.query(
      'photo_folders',
      where: 'id = ?',
      whereArgs: [folder.id],
      limit: 1,
    );

    if (existing.isEmpty) {
      await db.insert('photo_folders', map);
    } else {
      await db.update(
        'photo_folders',
        map,
        where: 'id = ?',
        whereArgs: [folder.id],
      );
    }

    return http.Response('ok', 200);
  }

  Future<http.Response> _syncFolderPhoto(
    SyncQueueItem item,
    Map<String, dynamic> payload,
  ) async {
    final link = FolderPhoto.fromJson(payload);
    await _remoteFolderService.upsertFolderPhoto(link);

    final db = await _dbService.database;
    await db.insert(
      'folder_photos',
      link.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return http.Response('ok', 200);
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
