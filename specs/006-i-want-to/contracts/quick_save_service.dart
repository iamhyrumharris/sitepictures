/// Service Contract: QuickSaveService
///
/// Purpose: Handles Quick Save logic from home camera context
/// - Single photo: Save as "Image - YYYY-MM-DD" in global "Needs Assigned"
/// - Multiple photos: Create folder "Folder - YYYY-MM-DD" in global "Needs Assigned"
/// - Sequential numbering for same-date saves

import '../../../lib/models/photo_session.dart';
import '../../../lib/models/quick_save_item.dart';
import '../../../lib/models/save_result.dart';

abstract class QuickSaveService {
  /// Execute Quick Save operation for photos from home camera context
  ///
  /// [photos]: List of temporary photos from camera session
  ///
  /// Returns [SaveResult] with outcome:
  /// - success: true if all photos saved
  /// - successfulCount: Number of photos saved successfully
  /// - savedIds: List of photo IDs successfully saved
  /// - sessionPreserved: true if critical error occurred and session preserved
  ///
  /// Behavior:
  /// - If photos.length == 1: Save as standalone image "Image - YYYY-MM-DD"
  /// - If photos.length >= 2: Create folder "Folder - YYYY-MM-DD" and save all photos
  /// - If date collision: Append sequential number (2), (3), etc.
  /// - Save incrementally (one-by-one) with rollback on critical failure
  /// - Generate thumbnails asynchronously (don't block save)
  ///
  /// Throws:
  /// - StorageException: Insufficient storage space
  /// - DatabaseException: Critical database error (triggers rollback)
  Future<SaveResult> quickSave(List<TempPhoto> photos);

  /// Generate unique name for Quick Save item with sequential numbering
  ///
  /// [baseName]: Base name without disambiguation ("Image - 2025-10-13")
  /// [itemType]: Type of item (singlePhoto or folder)
  ///
  /// Returns: Unique name with sequential number if needed
  /// - First occurrence: "Folder - 2025-10-13"
  /// - Second occurrence: "Folder - 2025-10-13 (2)"
  /// - Third occurrence: "Folder - 2025-10-13 (3)"
  ///
  /// Implementation: Query existing items matching prefix, find max number, increment
  Future<String> generateUniqueName({
    required String baseName,
    required QuickSaveType itemType,
  });

  /// Validate storage availability before Quick Save
  ///
  /// [photos]: Photos to be saved
  ///
  /// Returns: true if sufficient storage available
  ///
  /// Calculation: Free space >= (total photo size * 1.5) + 100MB buffer
  /// The 1.5x multiplier accounts for thumbnails and temporary files
  Future<bool> hasStorageAvailable(List<TempPhoto> photos);
}

/// Example Usage:
///
/// ```dart
/// final quickSaveService = QuickSaveServiceImpl(
///   databaseService: DatabaseService(),
///   photoStorageService: PhotoStorageService(),
///   logger: Logger(),
/// );
///
/// // From PhotoCaptureProvider after Done button
/// final result = await quickSaveService.quickSave(
///   provider.session.photos,
/// );
///
/// if (result.success) {
///   showSnackBar('Saved to Needs Assigned');
/// } else if (result.successfulCount > 0) {
///   showSnackBar('${result.successfulCount} of ${result.successfulCount + result.failedCount} photos saved');
/// } else {
///   showError('Save failed: ${result.error}');
/// }
/// ```
