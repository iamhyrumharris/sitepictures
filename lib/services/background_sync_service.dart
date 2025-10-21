import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:workmanager/workmanager.dart';

import 'photo_storage_service.dart';
import 'sync_service.dart';

/// Background sync service using WorkManager for Android and BGTaskScheduler for iOS
/// Implements T056 - Background sync requirements
class BackgroundSyncService {
  static const String syncTaskName = 'sitepictures_sync';
  static const String uniqueName = 'sitepictures_periodic_sync';

  static Future<void> initialize() async {
    // Background tasks only supported on Android for now
    // iOS requires additional Info.plist configuration for BGTaskScheduler
    if (!Platform.isAndroid) {
      return;
    }

    await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);

    // Register one-off sync task (will reschedule itself on completion)
    await Workmanager().registerOneOffTask(
      uniqueName,
      syncTaskName,
      initialDelay: const Duration(minutes: 15),
    );
  }

  static Future<void> cancelAll() async {
    await Workmanager().cancelAll();
  }

  static Future<void> triggerImmediateSync() async {
    await Workmanager().registerOneOffTask('immediate_sync', syncTaskName);
  }
}

/// Callback dispatcher for background work
/// Must be top-level function (not a class method)
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();

    try {
      if (task == BackgroundSyncService.syncTaskName) {
        // Initialize photo storage service before sync operations
        // This is required because background sync runs in a headless isolate
        // that doesn't have PhotoStorageService initialized
        await PhotoStorageService.ensureInitialized();

        // Perform sync operation
        final syncService = SyncService();
        await syncService.syncAll();

        // Clean up old completed items
        await syncService.clearCompletedItems();

        // Reschedule the next sync
        await Workmanager().registerOneOffTask(
          BackgroundSyncService.uniqueName,
          BackgroundSyncService.syncTaskName,
          initialDelay: const Duration(minutes: 15),
        );

        return true;
      }
      return false;
    } catch (e) {
      // Log error and return false to trigger retry
      return false;
    }
  });
}
