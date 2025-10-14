/// Service Contract: PhotoSaveService
///
/// Purpose: Context-aware photo save orchestration for all save workflows
/// - Equipment direct save (from All Photos tab)
/// - Folder before/after categorized save
/// - Incremental save with rollback on critical failure

import '../../../lib/models/photo_session.dart';
import '../../../lib/models/save_context.dart';
import '../../../lib/models/save_result.dart';
import '../../../lib/models/equipment.dart';
import '../../../lib/models/photo_folder.dart';

abstract class PhotoSaveService {
  /// Save photos to equipment's general photos collection (no folder association)
  ///
  /// [photos]: List of temporary photos from camera session
  /// [equipment]: Target equipment
  ///
  /// Returns [SaveResult] with outcome
  ///
  /// Behavior:
  /// - Saves photos incrementally (one-by-one)
  /// - Associates photos with equipment via equipment_id
  /// - No folder association (standalone photos)
  /// - Moves photos from temp storage to permanent storage
  /// - Generates thumbnails asynchronously
  /// - Non-critical errors: Continue saving remaining photos
  /// - Critical errors: Rollback saved photos, preserve session
  ///
  /// Throws:
  /// - EquipmentNotFoundException: If equipment no longer exists
  /// - StorageException: Insufficient storage
  /// - DatabaseException: Critical database error
  Future<SaveResult> saveToEquipment({
    required List<TempPhoto> photos,
    required Equipment equipment,
  });

  /// Save photos to folder with before/after categorization
  ///
  /// [photos]: List of temporary photos from camera session
  /// [folder]: Target folder
  /// [category]: Before or after categorization
  ///
  /// Returns [SaveResult] with outcome
  ///
  /// Behavior:
  /// - Saves photos incrementally (one-by-one)
  /// - Associates photos with equipment (from folder.equipmentId)
  /// - Creates folder_photos junction entries with before_after flag
  /// - Maintains separation between before and after photos
  /// - Moves photos from temp storage to permanent storage
  /// - Generates thumbnails asynchronously
  /// - Non-critical errors: Continue saving remaining photos
  /// - Critical errors: Rollback saved photos, preserve session
  ///
  /// Throws:
  /// - FolderNotFoundException: If folder was deleted during capture
  /// - EquipmentNotFoundException: If equipment no longer exists
  /// - StorageException: Insufficient storage
  /// - DatabaseException: Critical database error
  Future<SaveResult> saveToFolder({
    required List<TempPhoto> photos,
    required PhotoFolder folder,
    required BeforeAfter category,
  });

  /// Save photos based on SaveContext (generic orchestrator)
  ///
  /// [photos]: List of temporary photos from camera session
  /// [context]: Save context determining save behavior
  ///
  /// Returns [SaveResult] with outcome
  ///
  /// Behavior:
  /// - Delegates to appropriate save method based on context.type
  /// - home: Throws exception (should use QuickSaveService)
  /// - equipment: Calls saveToEquipment
  /// - folder_before/folder_after: Calls saveToFolder
  ///
  /// This method provides unified interface for camera_capture_page
  Future<SaveResult> savePhotos({
    required List<TempPhoto> photos,
    required SaveContext context,
  });

  /// Validate storage availability before save
  ///
  /// [photos]: Photos to be saved
  ///
  /// Returns: true if sufficient storage available
  ///
  /// Calculation: Free space >= (total photo size * 1.5) + 100MB buffer
  Future<bool> hasStorageAvailable(List<TempPhoto> photos);

  /// Stream of save progress events during incremental save
  ///
  /// Emits progress events with current/total photo counts
  /// Useful for progress indicators in UI
  ///
  /// Example emission:
  /// - SaveProgress(current: 1, total: 10, currentPhotoId: 'photo-1')
  /// - SaveProgress(current: 2, total: 10, currentPhotoId: 'photo-2')
  /// - ...
  Stream<SaveProgress> get progressStream;
}

/// Save progress event data
class SaveProgress {
  final int current;
  final int total;
  final String currentPhotoId;

  SaveProgress({
    required this.current,
    required this.total,
    required this.currentPhotoId,
  });

  double get percentage => (current / total) * 100;
}

/// Example Usage:
///
/// ```dart
/// final photoSaveService = PhotoSaveServiceImpl(
///   databaseService: DatabaseService(),
///   photoStorageService: PhotoStorageService(),
///   folderService: FolderService(),
///   logger: Logger(),
/// );
///
/// // Listen to progress
/// photoSaveService.progressStream.listen((progress) {
///   print('Saving ${progress.current} of ${progress.total}');
/// });
///
/// // From camera_capture_page (equipment context)
/// final result = await photoSaveService.saveToEquipment(
///   photos: provider.session.photos,
///   equipment: currentEquipment,
/// );
///
/// // From camera_capture_page (folder before context)
/// final result = await photoSaveService.saveToFolder(
///   photos: provider.session.photos,
///   folder: currentFolder,
///   category: BeforeAfter.before,
/// );
///
/// // Generic (context-based)
/// final result = await photoSaveService.savePhotos(
///   photos: provider.session.photos,
///   context: provider.cameraContext,
/// );
/// ```
