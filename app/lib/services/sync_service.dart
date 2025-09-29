import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/photo.dart';
import '../models/sync_package.dart';
import 'storage_service.dart';
import 'file_service.dart';

/// Sync service for background synchronization with conflict resolution
/// Handles offline-first sync with merge-all strategy and retry logic
class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final _storageService = StorageService();
  final _fileService = FileService();
  final _uuid = const Uuid();

  // Sync state management
  bool _isSyncing = false;
  Timer? _backgroundTimer;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  // Configuration
  static const String _baseUrl = 'https://api.fieldphoto.com/v1';
  static const Duration _syncInterval = Duration(minutes: 5);
  static const Duration _quickSyncInterval = Duration(minutes: 1);
  static const int _maxRetries = 3;
  static const int _batchSize = 50;

  // Network state
  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  bool get isOnline => _connectionStatus != ConnectivityResult.none;

  // Sync statistics
  int _successfulSyncs = 0;
  int _failedSyncs = 0;
  DateTime? _lastSyncAttempt;
  DateTime? _lastSuccessfulSync;
  String? _lastSyncError;

  /// Initialize sync service with connectivity monitoring
  Future<void> initialize() async {
    try {
      // Check initial connectivity status
      _connectionStatus = await Connectivity().checkConnectivity();

      // Start monitoring connectivity changes
      _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
        (ConnectivityResult result) {
          _connectionStatus = result;
          _onConnectivityChanged(result);
        },
      );

      // Start background sync timer
      _startBackgroundSync();

      debugPrint('SyncService initialized. Online: $isOnline');

    } catch (e) {
      debugPrint('SyncService initialization failed: $e');
      rethrow;
    }
  }

  /// Start background sync with automatic scheduling
  void _startBackgroundSync() {
    _backgroundTimer?.cancel();

    final interval = isOnline ? _syncInterval : _quickSyncInterval;

    _backgroundTimer = Timer.periodic(interval, (timer) {
      if (isOnline && !_isSyncing) {
        _performBackgroundSync();
      }
    });

    debugPrint('Background sync started with ${interval.inMinutes}min interval');
  }

  /// Handle connectivity changes
  void _onConnectivityChanged(ConnectivityResult result) {
    final wasOnline = _connectionStatus != ConnectivityResult.none;
    final isNowOnline = result != ConnectivityResult.none;

    if (!wasOnline && isNowOnline) {
      debugPrint('Device came online, triggering sync');
      _performBackgroundSync();
    }

    _startBackgroundSync(); // Restart timer with new interval
  }

  /// Perform background sync operation
  Future<void> _performBackgroundSync() async {
    try {
      await syncPendingPackages();
    } catch (e) {
      debugPrint('Background sync failed: $e');
    }
  }

  /// Create sync package for any entity change
  Future<void> createSyncPackage({
    required EntityType entityType,
    required String entityId,
    required Operation operation,
    required Map<String, dynamic> data,
    String? deviceId,
  }) async {
    final package = SyncPackage(
      entityType: entityType,
      entityId: entityId,
      operation: operation,
      data: data,
      timestamp: DateTime.now(),
      deviceId: deviceId ?? 'default-device',
    );

    await _storageService.insertSyncPackage(package.toMap());

    // Trigger immediate sync if online
    if (isOnline && !_isSyncing) {
      unawaited(_performQuickSync());
    }

    debugPrint('Sync package created: ${package.operation} ${package.entityType}');
  }

  /// Sync all pending packages with retry logic
  Future<SyncResult> syncPendingPackages() async {
    if (_isSyncing) {
      return SyncResult(
        success: false,
        message: 'Sync already in progress',
        packagesSynced: 0,
        packagesTotal: 0,
      );
    }

    if (!isOnline) {
      return SyncResult(
        success: false,
        message: 'Device offline',
        packagesSynced: 0,
        packagesTotal: 0,
      );
    }

    _isSyncing = true;
    _lastSyncAttempt = DateTime.now();

    try {
      final pendingPackages = await _storageService.getPendingSyncPackages();

      if (pendingPackages.isEmpty) {
        _lastSuccessfulSync = DateTime.now();
        return SyncResult(
          success: true,
          message: 'No packages to sync',
          packagesSynced: 0,
          packagesTotal: 0,
        );
      }

      debugPrint('Starting sync of ${pendingPackages.length} packages');

      int successCount = 0;
      int totalCount = pendingPackages.length;

      // Process packages in batches
      for (int i = 0; i < pendingPackages.length; i += _batchSize) {
        final batch = pendingPackages.skip(i).take(_batchSize).toList();
        final batchResult = await _syncBatch(batch);
        successCount += batchResult;

        // Short delay between batches to avoid overwhelming server
        if (i + _batchSize < pendingPackages.length) {
          await Future.delayed(const Duration(milliseconds: 100));
        }
      }

      _successfulSyncs++;
      _lastSuccessfulSync = DateTime.now();
      _lastSyncError = null;

      return SyncResult(
        success: true,
        message: 'Sync completed successfully',
        packagesSynced: successCount,
        packagesTotal: totalCount,
      );

    } catch (e) {
      _failedSyncs++;
      _lastSyncError = e.toString();

      debugPrint('Sync failed: $e');

      return SyncResult(
        success: false,
        message: e.toString(),
        packagesSynced: 0,
        packagesTotal: 0,
      );

    } finally {
      _isSyncing = false;
    }
  }

  /// Sync a batch of packages
  Future<int> _syncBatch(List<Map<String, dynamic>> batch) async {
    int successCount = 0;

    for (final packageData in batch) {
      final package = SyncPackage.fromMap(packageData);

      try {
        final success = await _syncSinglePackage(package);
        if (success) {
          successCount++;
          await _storageService.updateSyncPackageStatus(
            package.id,
            'COMPLETED',
            lastAttempt: DateTime.now(),
          );
        }

      } catch (e) {
        await _handleSyncFailure(package, e.toString());
      }
    }

    return successCount;
  }

  /// Sync a single package with conflict resolution
  Future<bool> _syncSinglePackage(SyncPackage package) async {
    switch (package.entityType) {
      case EntityType.photo:
        return await _syncPhoto(package);
      case EntityType.equipment:
        return await _syncEquipment(package);
      case EntityType.site:
        return await _syncSite(package);
      case EntityType.client:
        return await _syncClient(package);
      default:
        throw Exception('Unsupported entity type: ${package.entityType}');
    }
  }

  /// Sync photo with file upload
  Future<bool> _syncPhoto(SyncPackage package) async {
    final photo = Photo.fromMap(package.data);

    try {
      // Upload photo file first
      final fileUploadSuccess = await _uploadPhotoFile(photo);
      if (!fileUploadSuccess) {
        return false;
      }

      // Then sync photo metadata
      final response = await _makeApiRequest(
        'POST',
        '/photos',
        body: package.data,
      );

      if (response.statusCode == 200 || response.statusCode == 409) {
        // 409 = conflict, handle with merge strategy
        if (response.statusCode == 409) {
          await _handlePhotoConflict(photo, response);
        }

        // Mark local photo as synced
        final updatedPhoto = photo.copyWith(isSynced: true);
        await _storageService.updatePhoto(updatedPhoto);

        return true;
      }

      return false;

    } catch (e) {
      debugPrint('Photo sync failed: $e');
      return false;
    }
  }

  /// Upload photo file to server
  Future<bool> _uploadPhotoFile(Photo photo) async {
    try {
      final photoPath = await _fileService.getPhotoPath(photo.fileName);
      final file = File(photoPath);

      if (!await file.exists()) {
        throw Exception('Photo file not found: ${photo.fileName}');
      }

      final bytes = await file.readAsBytes();

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/photos/${photo.id}/file'),
      );

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: photo.fileName,
        ),
      );

      final response = await request.send();
      return response.statusCode == 200;

    } catch (e) {
      debugPrint('Photo file upload failed: $e');
      return false;
    }
  }

  /// Handle photo conflicts with merge-all strategy
  Future<void> _handlePhotoConflict(Photo localPhoto, http.Response response) async {
    try {
      final serverData = json.decode(response.body);
      final serverPhoto = Photo.fromMap(serverData['data']);

      // Merge-all strategy: keep both versions with conflict markers
      final conflictPhoto = localPhoto.copyWith(
        notes: '${localPhoto.notes ?? ''}\n[CONFLICT: Server version exists]',
      );

      await _storageService.updatePhoto(conflictPhoto);

      debugPrint('Photo conflict resolved with merge-all strategy');

    } catch (e) {
      debugPrint('Photo conflict resolution failed: $e');
    }
  }

  /// Sync equipment data
  Future<bool> _syncEquipment(SyncPackage package) async {
    try {
      final response = await _makeApiRequest(
        'POST',
        '/equipment',
        body: package.data,
      );

      return response.statusCode == 200 || response.statusCode == 409;

    } catch (e) {
      debugPrint('Equipment sync failed: $e');
      return false;
    }
  }

  /// Sync site data
  Future<bool> _syncSite(SyncPackage package) async {
    try {
      final response = await _makeApiRequest(
        'POST',
        '/sites',
        body: package.data,
      );

      return response.statusCode == 200 || response.statusCode == 409;

    } catch (e) {
      debugPrint('Site sync failed: $e');
      return false;
    }
  }

  /// Sync client data
  Future<bool> _syncClient(SyncPackage package) async {
    try {
      final response = await _makeApiRequest(
        'POST',
        '/clients',
        body: package.data,
      );

      return response.statusCode == 200 || response.statusCode == 409;

    } catch (e) {
      debugPrint('Client sync failed: $e');
      return false;
    }
  }

  /// Handle sync failure with retry logic
  Future<void> _handleSyncFailure(SyncPackage package, String error) async {
    final currentRetryCount = package.retryCount;

    if (currentRetryCount < _maxRetries) {
      await _storageService.updateSyncPackageStatus(
        package.id,
        'PENDING',
        lastAttempt: DateTime.now(),
        retryCount: currentRetryCount + 1,
        errorMessage: error,
      );

      debugPrint('Package ${package.id} scheduled for retry (${currentRetryCount + 1}/$_maxRetries)');

    } else {
      await _storageService.updateSyncPackageStatus(
        package.id,
        'FAILED',
        lastAttempt: DateTime.now(),
        errorMessage: error,
      );

      debugPrint('Package ${package.id} failed after $maxRetries retries');
    }
  }

  /// Make HTTP API request with proper error handling
  Future<http.Response> _makeApiRequest(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse('$_baseUrl$endpoint');

    final defaultHeaders = {
      'Content-Type': 'application/json',
      'User-Agent': 'FieldPhoto Pro Mobile',
    };

    final requestHeaders = {...defaultHeaders, ...?headers};

    http.Response response;

    switch (method.toUpperCase()) {
      case 'GET':
        response = await http.get(uri, headers: requestHeaders);
        break;
      case 'POST':
        response = await http.post(
          uri,
          headers: requestHeaders,
          body: body != null ? json.encode(body) : null,
        );
        break;
      case 'PUT':
        response = await http.put(
          uri,
          headers: requestHeaders,
          body: body != null ? json.encode(body) : null,
        );
        break;
      case 'DELETE':
        response = await http.delete(uri, headers: requestHeaders);
        break;
      default:
        throw Exception('Unsupported HTTP method: $method');
    }

    if (response.statusCode >= 400) {
      throw Exception('API request failed: ${response.statusCode} ${response.body}');
    }

    return response;
  }

  /// Perform quick sync for immediate operations
  Future<void> _performQuickSync() async {
    try {
      await syncPendingPackages();
    } catch (e) {
      debugPrint('Quick sync failed: $e');
    }
  }

  /// Get sync status and statistics
  SyncStatus getSyncStatus() {
    return SyncStatus(
      isSyncing: _isSyncing,
      isOnline: isOnline,
      lastSyncAttempt: _lastSyncAttempt,
      lastSuccessfulSync: _lastSuccessfulSync,
      successfulSyncs: _successfulSyncs,
      failedSyncs: _failedSyncs,
      lastError: _lastSyncError,
    );
  }

  /// Force immediate sync
  Future<SyncResult> forcSync() async {
    return await syncPendingPackages();
  }

  /// Download server changes to local database
  Future<bool> downloadServerChanges() async {
    if (!isOnline) return false;

    try {
      final lastSync = _lastSuccessfulSync ?? DateTime.fromMillisecondsSinceEpoch(0);

      final response = await _makeApiRequest(
        'GET',
        '/sync/changes?since=${lastSync.toIso8601String()}',
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await _applyServerChanges(data['changes']);
        return true;
      }

      return false;

    } catch (e) {
      debugPrint('Download server changes failed: $e');
      return false;
    }
  }

  /// Apply server changes to local database
  Future<void> _applyServerChanges(List<dynamic> changes) async {
    for (final change in changes) {
      try {
        // Process each change based on entity type and operation
        // Implementation would handle merging server changes with local data
        debugPrint('Processing server change: ${change['entity_type']} ${change['operation']}');

      } catch (e) {
        debugPrint('Failed to apply server change: $e');
      }
    }
  }

  /// Clean up old sync packages
  Future<void> cleanupOldSyncPackages() async {
    try {
      final cutoffDate = DateTime.now().subtract(const Duration(days: 30));

      final db = await _storageService.database;
      await db.delete(
        'sync_packages',
        where: 'status = ? AND created_at < ?',
        whereArgs: ['COMPLETED', cutoffDate.toIso8601String()],
      );

      debugPrint('Old sync packages cleaned up');

    } catch (e) {
      debugPrint('Sync package cleanup failed: $e');
    }
  }

  /// Dispose sync service resources
  Future<void> dispose() async {
    _backgroundTimer?.cancel();
    await _connectivitySubscription?.cancel();
    debugPrint('SyncService disposed');
  }

  /// Get pending sync package count
  Future<int> getPendingPackageCount() async {
    final packages = await _storageService.getPendingSyncPackages();
    return packages.length;
  }
}

/// Sync result data class
class SyncResult {
  final bool success;
  final String message;
  final int packagesSynced;
  final int packagesTotal;

  SyncResult({
    required this.success,
    required this.message,
    required this.packagesSynced,
    required this.packagesTotal,
  });
}

/// Sync status data class
class SyncStatus {
  final bool isSyncing;
  final bool isOnline;
  final DateTime? lastSyncAttempt;
  final DateTime? lastSuccessfulSync;
  final int successfulSyncs;
  final int failedSyncs;
  final String? lastError;

  SyncStatus({
    required this.isSyncing,
    required this.isOnline,
    this.lastSyncAttempt,
    this.lastSuccessfulSync,
    required this.successfulSyncs,
    required this.failedSyncs,
    this.lastError,
  });
}