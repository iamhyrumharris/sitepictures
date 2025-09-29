import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../models/sync_package.dart';
import '../storage_service.dart';
import '../database/database_helper.dart';

class SyncQueue {
  static const int _maxRetries = 10;
  static const Duration _retryDelay = Duration(seconds: 30);
  static const int _batchSize = 50;

  final DatabaseHelper _db;
  final StorageService _storage;
  final String _apiUrl;
  Timer? _syncTimer;
  bool _isSyncing = false;
  final _syncController = StreamController<SyncStatus>.broadcast();
  Stream<SyncStatus> get syncStatus => _syncController.stream;

  SyncQueue({
    required DatabaseHelper database,
    required StorageService storage,
    required String apiUrl,
  })  : _db = database,
        _storage = storage,
        _apiUrl = apiUrl;

  Future<void> initialize() async {
    final connectivity = Connectivity();
    connectivity.onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none && !_isSyncing) {
        processPendingSync();
      }
    });

    _syncTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      if (!_isSyncing) {
        processPendingSync();
      }
    });

    final hasConnection = await _checkConnectivity();
    if (hasConnection) {
      processPendingSync();
    }
  }

  Future<void> addToQueue(SyncPackage package) async {
    package.status = SyncStatus.pending;
    package.retryCount = 0;
    package.lastAttempt = null;

    await _db.insertSyncPackage(package);
    _syncController.add(SyncStatus.pending);

    if (!_isSyncing && await _checkConnectivity()) {
      processPendingSync();
    }
  }

  Future<void> processPendingSync() async {
    if (_isSyncing) return;
    _isSyncing = true;
    _syncController.add(SyncStatus.syncing);

    try {
      final hasConnection = await _checkConnectivity();
      if (!hasConnection) {
        _syncController.add(SyncStatus.pending);
        return;
      }

      final pendingPackages = await _db.getPendingSyncPackages(_batchSize);
      if (pendingPackages.isEmpty) {
        _syncController.add(SyncStatus.synced);
        return;
      }

      debugPrint('Processing ${pendingPackages.length} sync packages');

      final deviceId = await _storage.getDeviceId();
      final batch = pendingPackages.map((pkg) {
        pkg.status = SyncStatus.syncing;
        return pkg.toJson();
      }).toList();

      final response = await http.post(
        Uri.parse('$_apiUrl/sync/changes'),
        headers: {
          'Content-Type': 'application/json',
          'X-Device-ID': deviceId,
        },
        body: jsonEncode({
          'deviceId': deviceId,
          'packages': batch,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        final processed = result['processed'] as int;
        final conflicts = result['conflicts'] as List?;

        for (final package in pendingPackages) {
          package.status = SyncStatus.synced;
          await _db.updateSyncPackageStatus(package.id, SyncStatus.synced);
        }

        if (conflicts != null && conflicts.isNotEmpty) {
          await _handleConflicts(conflicts);
        }

        debugPrint('Successfully synced $processed packages');
        _syncController.add(SyncStatus.synced);

        final remaining = await _db.getPendingSyncPackagesCount();
        if (remaining > 0) {
          await Future.delayed(const Duration(seconds: 2));
          await processPendingSync();
        }
      } else if (response.statusCode == 409) {
        final conflicts = jsonDecode(response.body)['conflicts'] as List;
        await _handleConflicts(conflicts);
        _syncController.add(SyncStatus.failed);
      } else {
        await _handleSyncFailure(pendingPackages);
      }
    } catch (e) {
      debugPrint('Sync error: $e');
      _syncController.add(SyncStatus.failed);
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _handleConflicts(List conflicts) async {
    for (final conflict in conflicts) {
      final entityId = conflict['entityId'] as String;
      final entityType = conflict['entityType'] as String;
      final versions = conflict['versions'] as List;

      debugPrint('Conflict detected for $entityType:$entityId - merging all versions');

      for (final version in versions) {
        final deviceId = version['deviceId'] as String;
        final timestamp = DateTime.parse(version['timestamp'] as String);
        final data = version['data'] as Map<String, dynamic>;

        await _db.insertConflictVersion(
          entityId: entityId,
          entityType: entityType,
          deviceId: deviceId,
          timestamp: timestamp,
          data: data,
        );
      }
    }
  }

  Future<void> _handleSyncFailure(List<SyncPackage> packages) async {
    for (final package in packages) {
      package.retryCount++;
      package.lastAttempt = DateTime.now();

      if (package.retryCount >= _maxRetries) {
        package.status = SyncStatus.failed;
        await _db.updateSyncPackageStatus(package.id, SyncStatus.failed);
        debugPrint('Package ${package.id} failed after $maxRetries retries');
      } else {
        package.status = SyncStatus.pending;
        await _db.updateSyncPackage(package);
        debugPrint('Package ${package.id} will retry (attempt ${package.retryCount})');
      }
    }

    Future.delayed(_retryDelay, () {
      if (!_isSyncing) {
        processPendingSync();
      }
    });
  }

  Future<bool> _checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  Future<void> downloadChanges() async {
    if (!await _checkConnectivity()) return;

    try {
      final deviceId = await _storage.getDeviceId();
      final lastSync = await _storage.getLastSyncTimestamp();
      final since = lastSync ?? DateTime.now().subtract(const Duration(days: 30));

      final response = await http.get(
        Uri.parse('$_apiUrl/sync/changes/${since.toIso8601String()}?deviceId=$deviceId'),
        headers: {
          'X-Device-ID': deviceId,
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        final changes = result['changes'] as List;
        final lastModified = DateTime.parse(result['lastModified'] as String);

        for (final change in changes) {
          final package = SyncPackage.fromJson(change);
          if (package.deviceId != deviceId) {
            await _applyRemoteChange(package);
          }
        }

        await _storage.setLastSyncTimestamp(lastModified);
        debugPrint('Downloaded ${changes.length} changes');
      }
    } catch (e) {
      debugPrint('Download changes error: $e');
    }
  }

  Future<void> _applyRemoteChange(SyncPackage package) async {
    try {
      switch (package.entityType) {
        case 'Photo':
          await _db.mergePhoto(package.data);
          break;
        case 'Client':
          await _db.mergeClient(package.data);
          break;
        case 'Site':
          await _db.mergeSite(package.data);
          break;
        case 'Equipment':
          await _db.mergeEquipment(package.data);
          break;
        case 'Revision':
          await _db.mergeRevision(package.data);
          break;
        case 'GPSBoundary':
          await _db.mergeBoundary(package.data);
          break;
      }
    } catch (e) {
      debugPrint('Error applying remote change: $e');
    }
  }

  Future<SyncStatistics> getStatistics() async {
    final pending = await _db.getPendingSyncPackagesCount();
    final failed = await _db.getFailedSyncPackagesCount();
    final synced = await _db.getSyncedPackagesCount();
    final lastSync = await _storage.getLastSyncTimestamp();

    return SyncStatistics(
      pendingCount: pending,
      failedCount: failed,
      syncedCount: synced,
      lastSync: lastSync,
      isOnline: await _checkConnectivity(),
      isSyncing: _isSyncing,
    );
  }

  Future<void> retryFailed() async {
    final failed = await _db.getFailedSyncPackages();
    for (final package in failed) {
      package.status = SyncStatus.pending;
      package.retryCount = 0;
      await _db.updateSyncPackage(package);
    }
    processPendingSync();
  }

  Future<void> clearSyncedPackages() async {
    await _db.deleteSyncedPackages();
  }

  void dispose() {
    _syncTimer?.cancel();
    _syncController.close();
  }
}

class SyncStatistics {
  final int pendingCount;
  final int failedCount;
  final int syncedCount;
  final DateTime? lastSync;
  final bool isOnline;
  final bool isSyncing;

  SyncStatistics({
    required this.pendingCount,
    required this.failedCount,
    required this.syncedCount,
    this.lastSync,
    required this.isOnline,
    required this.isSyncing,
  });

  double get successRate {
    final total = syncedCount + failedCount;
    if (total == 0) return 1.0;
    return syncedCount / total;
  }
}