import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../models/analytics_events.dart';
import '../models/import_batch.dart';
import 'import_service.dart';

class AnalyticsEvent {
  AnalyticsEvent({required this.name, required this.payload});

  final String name;
  final Map<String, Object?> payload;
}

/// Lightweight analytics logger that records events locally for later sync.
/// In lieu of a full telemetry pipeline, events are buffered in-memory and
/// surfaced via [pendingEvents].
class AnalyticsLogger {
  final List<AnalyticsEvent> _pendingEvents = <AnalyticsEvent>[];
  bool _telemetryEnabled = true;

  UnmodifiableListView<AnalyticsEvent> get pendingEvents =>
      UnmodifiableListView(_pendingEvents);

  void setTelemetryEnabled(bool enabled) {
    _telemetryEnabled = enabled;
  }

  Future<void> logGalleryImport(ImportResult result) async {
    final batch = result.batch;
    final durationMs = batch.completedAt == null
        ? 0
        : batch.completedAt!.difference(batch.startedAt).inMilliseconds;
    final imported = batch.importedCount;
    final averageImportMs = imported > 0 ? durationMs ~/ imported : durationMs;
    final payload = <String, Object?>{
      'batchId': batch.id,
      'entryPoint': batch.entryPoint.dbValue,
      'destination': batch.destinationCategory.dbValue,
      'permissionStatus': batch.permissionState.dbValue,
      'selectedCount': batch.selectedCount,
      'importedCount': imported,
      'duplicateCount': batch.duplicateCount,
      'failedCount': batch.failedCount,
      'durationMs': durationMs,
      'averageImportMs': averageImportMs,
      'deviceFreeSpaceBytes': batch.deviceFreeSpaceBytes,
    };

    if (result.failures.isNotEmpty) {
      payload['errorCodes'] = result.failures
          .map((failure) => failure.reason.name)
          .toSet()
          .toList();
    }

    _enqueue(
      AnalyticsEvent(
        name: AnalyticsEvents.galleryImportLogged.name,
        payload: payload,
      ),
    );

    debugPrint(
      'Analytics event [${AnalyticsEvents.galleryImportLogged.name}]: $payload',
    );
  }

  void _enqueue(AnalyticsEvent event) {
    if (!_telemetryEnabled) {
      return;
    }
    _pendingEvents.add(event);
  }

  Future<void> logPermissionEvent({
    required ImportEntryPoint entryPoint,
    required ImportPermissionState status,
  }) async {
    final payload = <String, Object?>{
      'entryPoint': entryPoint.dbValue,
      'status': status.dbValue,
      'timestamp': DateTime.now().toIso8601String(),
    };

    _enqueue(
      AnalyticsEvent(
        name: AnalyticsEvents.permissionPromptLogged.name,
        payload: payload,
      ),
    );

    debugPrint(
      'Analytics event [${AnalyticsEvents.permissionPromptLogged.name}]: $payload',
    );
  }
}
