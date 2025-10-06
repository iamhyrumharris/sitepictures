import 'package:flutter/foundation.dart';
import '../services/sync_service.dart';
import '../services/background_sync_service.dart';

class SyncState extends ChangeNotifier {
  final SyncService _syncService = SyncService();

  bool _isSyncing = false;
  int _pendingCount = 0;
  DateTime? _lastSyncTime;
  String? _syncError;

  bool get isSyncing => _isSyncing;
  int get pendingCount => _pendingCount;
  int get pendingItems => _pendingCount; // Alias for pendingCount
  DateTime? get lastSyncTime => _lastSyncTime;
  String? get syncError => _syncError;

  Future<void> initialize() async {
    await updatePendingCount();
    _lastSyncTime = _syncService.lastSyncTime;
    notifyListeners();
  }

  Future<void> updatePendingCount() async {
    _pendingCount = await _syncService.getPendingCount();
    notifyListeners();
  }

  Future<bool> syncAll() async {
    if (_isSyncing) return false;

    _isSyncing = true;
    _syncError = null;
    notifyListeners();

    try {
      final success = await _syncService.syncAll();

      if (success) {
        _lastSyncTime = DateTime.now();
        await updatePendingCount();
      } else {
        _syncError = 'Sync failed';
      }

      _isSyncing = false;
      notifyListeners();

      return success;
    } catch (e) {
      _syncError = e.toString();
      _isSyncing = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> queueForSync({
    required String entityType,
    required String entityId,
    required String operation,
    required Map<String, dynamic> payload,
  }) async {
    await _syncService.queueForSync(
      entityType: entityType,
      entityId: entityId,
      operation: operation,
      payload: payload,
    );
    await updatePendingCount();
  }

  // Manual sync method for UI button
  Future<void> manualSync() async {
    await syncAll();
  }

  // Trigger immediate background sync
  Future<void> triggerBackgroundSync() async {
    await BackgroundSyncService.triggerImmediateSync();
  }
}
