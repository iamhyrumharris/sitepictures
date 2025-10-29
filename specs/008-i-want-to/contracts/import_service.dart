/// Service Contract: ImportService
///
/// Purpose: Orchestrate imports from the native photo library into FieldPhoto Pro.
/// Handles permission negotiation, asset selection, duplicate filtering,
/// destination routing, file persistence, metadata capture, and analytics logging.

import '../../../lib/models/destination_context.dart';
import '../../../lib/models/import_batch.dart';
import '../../../lib/models/photo_asset.dart';

/// Describes an import request originating from any entry point.
class ImportRequest {
  /// Entry point that triggered the flow (home, allPhotos, equipmentBefore, etc.).
  final ImportEntryPoint entryPoint;

  /// Destination context resolved before import begins.
  final DestinationContext destination;

  /// Whether the user explicitly chose Before or After (relevant for equipment tabs).
  final BeforeAfterChoice beforeAfterChoice;

  ImportRequest({
    required this.entryPoint,
    required this.destination,
    required this.beforeAfterChoice,
  });
}

/// Result object summarizing an import batch outcome.
class ImportResult {
  final ImportBatch batch;
  final List<PhotoAsset> importedPhotos;
  final List<PhotoAsset> duplicates;
  final List<FailedImport> failures;

  ImportResult({
    required this.batch,
    required this.importedPhotos,
    required this.duplicates,
    required this.failures,
  });

  bool get hasFailures => failures.isNotEmpty;
}

class FailedImport {
  final String assetId;
  final ImportFailureReason reason;
  final String? message;

  FailedImport({
    required this.assetId,
    required this.reason,
    this.message,
  });
}

enum ImportFailureReason {
  permissionRevoked,
  storageFull,
  duplicateConflict,
  ioError,
  unsupportedFormat,
}

enum ImportEntryPoint {
  home,
  allPhotos,
  equipmentBefore,
  equipmentAfter,
  equipmentGeneral,
}

enum BeforeAfterChoice { before, after, general }

abstract class ImportService {
  /// Ensures the app has photo-library permission.
  ///
  /// Returns `true` when permission is granted or limited (user selected subset),
  /// `false` when denied/restricted.
  Future<bool> ensurePermissions({required ImportEntryPoint entryPoint});

  /// Launches the gallery picker and returns selected asset identifiers.
  ///
  /// Throws [ImportPermissionException] if permissions are not granted.
  /// Returns empty list when user cancels selection.
  Future<List<GalleryAsset>> selectAssets({
    required ImportEntryPoint entryPoint,
    int maxAssets,
  });

  /// Imports the selected assets into the destination described by [request].
  ///
  /// Responsibilities:
  /// - Create `ImportBatch` record.
  /// - Sequentially process assets, running duplicate checks before file copy.
  /// - Persist new `PhotoAsset` rows with metadata and batch association.
  /// - Queue sync jobs for newly imported photos.
  /// - Emit progress updates via [progressStream].
  ///
  /// Throws:
  /// - [ImportPermissionException] when permissions are revoked mid-flow.
  /// - [InsufficientStorageException] when available free space is below configured threshold.
  Future<ImportResult> importAssets({
    required ImportRequest request,
    required List<GalleryAsset> assets,
  });

  /// Stream of progress updates for UI to display import status.
  Stream<ImportProgress> get progressStream;
}

class GalleryAsset {
  final String assetId;
  final String? fileName;
  final DateTime? capturedAt;
  final int? fileSizeBytes;

  GalleryAsset({
    required this.assetId,
    this.fileName,
    this.capturedAt,
    this.fileSizeBytes,
  });
}

class ImportProgress {
  final int processed;
  final int total;
  final String? currentAssetId;
  final ImportStage stage;

  ImportProgress({
    required this.processed,
    required this.total,
    required this.stage,
    this.currentAssetId,
  });
}

enum ImportStage { validating, copying, saving, completed }

class ImportPermissionException implements Exception {
  final String message;

  ImportPermissionException(this.message);
}

class InsufficientStorageException implements Exception {
  final String message;

  InsufficientStorageException(this.message);
}
