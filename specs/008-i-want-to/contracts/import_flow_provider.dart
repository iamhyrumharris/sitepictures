/// Provider Contract: ImportFlowProvider
///
/// Manages UI state for initiating gallery imports from different entry points,
/// coordinates with ImportService, handles permission messaging, duplicate prompts,
/// and final success/error feedback.

import '../../../lib/services/import_service.dart';
import '../../../lib/models/destination_context.dart';
import '../../../lib/models/import_batch.dart';
import '../../../lib/models/photo_asset.dart';

abstract class ImportFlowProvider {
  /// Current status of the UI flow.
  ImportFlowState get state;

  /// Last error message shown to the user (null when no error).
  String? get errorMessage;

  /// Latest batch summary for completion screen/snackbar.
  ImportBatch? get lastBatch;

  /// Initializes the provider for a given entry point and default destination.
  void configure({
    required ImportEntryPoint entryPoint,
    required DestinationContext defaultDestination,
  });

  /// Request permission and, if granted, show the picker.
  ///
  /// Returns `true` if assets were selected (even if zero after duplicate filtering),
  /// `false` if the user cancelled or permissions were denied.
  Future<bool> startImport();

  /// When the user selects a destination (e.g., Before or After), update context.
  void updateDestination(DestinationContext destination);

  /// Clears transient error state and allows the UI to retry.
  void dismissError();

  /// Expose progress for UI binding (mapped from ImportService.progressStream).
  Stream<ImportProgress> progress();
}

enum ImportFlowState {
  idle,
  awaitingPermission,
  selectingAssets,
  processing,
  completed,
  error,
}
