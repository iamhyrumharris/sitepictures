import 'dart:async';
import 'dart:io';
import '../models/photo_session.dart';
import '../models/save_context.dart';
import '../models/save_result.dart';
import '../models/equipment.dart';
import '../models/photo_folder.dart';
import '../models/folder_photo.dart';
import '../providers/all_photos_provider.dart';
import '../providers/sync_state.dart';
import '../services/database_service.dart';
import '../services/photo_storage_service.dart';

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

/// Context-aware photo save service for all save workflows
class PhotoSaveService {
  final DatabaseService _db;
  final PhotoStorageService _storage;
  final StreamController<SaveProgress> _progressController =
      StreamController<SaveProgress>.broadcast();
  final AllPhotosProvider? _allPhotosProvider;
  final SyncState? _syncState;

  PhotoSaveService({
    required DatabaseService databaseService,
    required PhotoStorageService storageService,
    AllPhotosProvider? allPhotosProvider,
    SyncState? syncState,
  }) : _db = databaseService,
       _storage = storageService,
       _allPhotosProvider = allPhotosProvider,
       _syncState = syncState;

  /// Stream of save progress events during incremental save
  Stream<SaveProgress> get progressStream => _progressController.stream;

  /// Save photos to equipment's general photos collection (no folder association)
  Future<SaveResult> saveToEquipment({
    required List<TempPhoto> photos,
    required Equipment equipment,
  }) async {
    final startTime = DateTime.now();
    print('PhotoSave: Starting saveToEquipment for ${photos.length} photo(s)');
    print(
      'PhotoSave: Target equipment: ${equipment.name} (ID: ${equipment.id})',
    );

    if (photos.isEmpty) {
      print('PhotoSave: ERROR - No photos to save');
      return SaveResult.criticalFailure(error: 'No photos to save');
    }

    try {
      // Validate storage availability
      print('PhotoSave: Validating storage availability...');
      final hasStorage = await hasStorageAvailable(photos);
      if (!hasStorage) {
        print('PhotoSave: ERROR - Insufficient storage space');
        return SaveResult.criticalFailure(
          error: 'Insufficient storage space',
          sessionPreserved: true,
        );
      }
      print('PhotoSave: Storage validation passed');

      // Verify equipment still exists
      print('PhotoSave: Verifying equipment exists...');
      final db = await _db.database;
      final equipmentCheck = await db.query(
        'equipment',
        where: 'id = ? AND is_active = 1',
        whereArgs: [equipment.id],
      );

      if (equipmentCheck.isEmpty) {
        print('PhotoSave: ERROR - Equipment no longer exists or is inactive');
        return SaveResult.criticalFailure(
          error: 'Equipment no longer exists',
          sessionPreserved: true,
        );
      }
      print('PhotoSave: Equipment verification passed');

      // Save photos incrementally
      print('PhotoSave: Starting incremental save...');
      final savedIds = <String>[];
      final failedIds = <String>[];

      for (int i = 0; i < photos.length; i++) {
        final tempPhoto = photos[i];

        // Emit progress event
        _progressController.add(
          SaveProgress(
            current: i + 1,
            total: photos.length,
            currentPhotoId: tempPhoto.id,
          ),
        );

        print(
          'PhotoSave: Saving photo ${i + 1}/${photos.length} (ID: ${tempPhoto.id})',
        );

        try {
          await _savePhotoToEquipment(
            tempPhoto: tempPhoto,
            equipmentId: equipment.id,
          );
          savedIds.add(tempPhoto.id);
          print('PhotoSave: Successfully saved photo ${tempPhoto.id}');
        } catch (e) {
          // Non-critical error: log and continue
          print('PhotoSave: ERROR - Failed to save photo ${tempPhoto.id}: $e');
          failedIds.add(tempPhoto.id);
        }
      }

      // Calculate elapsed time
      final elapsed = DateTime.now().difference(startTime);
      print('PhotoSave: Operation completed in ${elapsed.inMilliseconds}ms');
      print(
        'PhotoSave: Results - ${savedIds.length} succeeded, ${failedIds.length} failed',
      );

      // Return result based on outcome
      if (failedIds.isEmpty) {
        print(
          'PhotoSave: SUCCESS - All photos saved to equipment "${equipment.name}"',
        );
        final result = SaveResult.complete(savedIds);
        _notifyAllPhotosProvider(savedIds);
        return result;
      } else {
        print('PhotoSave: PARTIAL - Some photos failed to save');
        final result = SaveResult.partial(
          successful: savedIds.length,
          failed: failedIds.length,
          savedIds: savedIds,
        );
        _notifyAllPhotosProvider(savedIds);
        return result;
      }
    } catch (e) {
      // Critical error: preserve session
      print('PhotoSave: CRITICAL ERROR - saveToEquipment failed: $e');
      print('PhotoSave: Session preserved for retry');
      return SaveResult.criticalFailure(
        error: e.toString(),
        sessionPreserved: true,
      );
    }
  }

  /// Save photos to folder with before/after categorization
  Future<SaveResult> saveToFolder({
    required List<TempPhoto> photos,
    required PhotoFolder folder,
    required BeforeAfter category,
  }) async {
    final startTime = DateTime.now();
    final categoryStr = category == BeforeAfter.before ? 'Before' : 'After';
    print('PhotoSave: Starting saveToFolder for ${photos.length} photo(s)');
    print('PhotoSave: Target folder: ${folder.name} (ID: ${folder.id})');
    print('PhotoSave: Category: $categoryStr');

    if (photos.isEmpty) {
      print('PhotoSave: ERROR - No photos to save');
      return SaveResult.criticalFailure(error: 'No photos to save');
    }

    try {
      // Validate storage availability
      print('PhotoSave: Validating storage availability...');
      final hasStorage = await hasStorageAvailable(photos);
      if (!hasStorage) {
        print('PhotoSave: ERROR - Insufficient storage space');
        return SaveResult.criticalFailure(
          error: 'Insufficient storage space',
          sessionPreserved: true,
        );
      }
      print('PhotoSave: Storage validation passed');

      // Verify folder still exists
      print('PhotoSave: Verifying folder exists...');
      final db = await _db.database;
      final folderCheck = await db.query(
        'photo_folders',
        where: 'id = ? AND is_deleted = 0',
        whereArgs: [folder.id],
      );

      if (folderCheck.isEmpty) {
        print('PhotoSave: ERROR - Folder was deleted during capture');
        return SaveResult.criticalFailure(
          error: 'Folder was deleted during capture',
          sessionPreserved: true,
        );
      }
      print('PhotoSave: Folder verification passed');

      // Save photos incrementally
      print('PhotoSave: Starting incremental save to $categoryStr...');
      final savedIds = <String>[];
      final failedIds = <String>[];

      for (int i = 0; i < photos.length; i++) {
        final tempPhoto = photos[i];

        // Emit progress event
        _progressController.add(
          SaveProgress(
            current: i + 1,
            total: photos.length,
            currentPhotoId: tempPhoto.id,
          ),
        );

        print(
          'PhotoSave: Saving photo ${i + 1}/${photos.length} (ID: ${tempPhoto.id}) to $categoryStr',
        );

        try {
          await _savePhotoToFolder(
            tempPhoto: tempPhoto,
            equipmentId: folder.equipmentId,
            folderId: folder.id,
            category: category,
          );
          savedIds.add(tempPhoto.id);
          print('PhotoSave: Successfully saved photo ${tempPhoto.id}');
        } catch (e) {
          // Non-critical error: log and continue
          print('PhotoSave: ERROR - Failed to save photo ${tempPhoto.id}: $e');
          failedIds.add(tempPhoto.id);
        }
      }

      // Calculate elapsed time
      final elapsed = DateTime.now().difference(startTime);
      print('PhotoSave: Operation completed in ${elapsed.inMilliseconds}ms');
      print(
        'PhotoSave: Results - ${savedIds.length} succeeded, ${failedIds.length} failed',
      );

      // Return result based on outcome
      if (failedIds.isEmpty) {
        print(
          'PhotoSave: SUCCESS - All photos saved to folder "${folder.name}" ($categoryStr)',
        );
        final result = SaveResult.complete(savedIds);
        _notifyAllPhotosProvider(savedIds);
        return result;
      } else {
        print('PhotoSave: PARTIAL - Some photos failed to save');
        final result = SaveResult.partial(
          successful: savedIds.length,
          failed: failedIds.length,
          savedIds: savedIds,
        );
        _notifyAllPhotosProvider(savedIds);
        return result;
      }
    } catch (e) {
      // Critical error: preserve session
      print('PhotoSave: CRITICAL ERROR - saveToFolder failed: $e');
      print('PhotoSave: Session preserved for retry');
      return SaveResult.criticalFailure(
        error: e.toString(),
        sessionPreserved: true,
      );
    }
  }

  /// Save photos based on SaveContext (generic orchestrator)
  Future<SaveResult> savePhotos({
    required List<TempPhoto> photos,
    required SaveContext context,
  }) async {
    // This method should not be called for home context
    if (context.type == SaveContextType.home) {
      throw UnsupportedError(
        'Home context should use QuickSaveService, not PhotoSaveService',
      );
    }

    // For equipment context, we need to fetch the equipment
    if (context.type == SaveContextType.equipment) {
      if (context.equipmentId == null) {
        return SaveResult.criticalFailure(
          error: 'Equipment ID missing from context',
        );
      }

      // Fetch equipment from database
      final db = await _db.database;
      final equipmentMaps = await db.query(
        'equipment',
        where: 'id = ?',
        whereArgs: [context.equipmentId],
      );

      if (equipmentMaps.isEmpty) {
        return SaveResult.criticalFailure(
          error: 'Equipment not found',
          sessionPreserved: true,
        );
      }

      final equipment = Equipment.fromMap(equipmentMaps.first);
      return await saveToEquipment(photos: photos, equipment: equipment);
    }

    // For folder context, we need to fetch the folder
    if (context.type == SaveContextType.folderBefore ||
        context.type == SaveContextType.folderAfter) {
      if (context.folderId == null) {
        return SaveResult.criticalFailure(
          error: 'Folder ID missing from context',
        );
      }

      // Fetch folder from database
      final db = await _db.database;
      final folderMaps = await db.query(
        'photo_folders',
        where: 'id = ?',
        whereArgs: [context.folderId],
      );

      if (folderMaps.isEmpty) {
        return SaveResult.criticalFailure(
          error: 'Folder not found',
          sessionPreserved: true,
        );
      }

      final folder = PhotoFolder.fromMap(folderMaps.first);
      final category = context.type == SaveContextType.folderBefore
          ? BeforeAfter.before
          : BeforeAfter.after;

      return await saveToFolder(
        photos: photos,
        folder: folder,
        category: category,
      );
    }

    return SaveResult.criticalFailure(error: 'Invalid save context');
  }

  /// Validate storage availability before save
  Future<bool> hasStorageAvailable(List<TempPhoto> photos) async {
    try {
      // Calculate total size of photos
      int totalSize = 0;
      for (final photo in photos) {
        final file = File(photo.filePath);
        if (await file.exists()) {
          final size = await file.length();
          totalSize += size;
        }
      }

      // Calculate required space: (total size * 1.5) + 100MB buffer
      final requiredSpace = (totalSize * 1.5).toInt() + (100 * 1024 * 1024);

      // For now, return true if photos exist
      // TODO: Implement platform-specific storage check
      return totalSize > 0;
    } catch (e) {
      print('Storage validation error: $e');
      return false;
    }
  }

  /// Save individual photo to equipment (no folder association)
  Future<void> _savePhotoToEquipment({
    required TempPhoto tempPhoto,
    required String equipmentId,
  }) async {
    final db = await _db.database;

    // Move photo to permanent storage
    final storedPath = await _storage.moveToPermanent(
      tempPhoto,
      permanentDir: equipmentId,
    );

    // Get file size
    final absolutePath = PhotoStorageService.resolveAbsolutePath(storedPath);
    final file = File(absolutePath);
    final fileSize = await file.length();

    // Insert photo into database
    final photoData = {
      'id': tempPhoto.id,
      'equipment_id': equipmentId,
      'file_path': storedPath,
      'thumbnail_path': null, // Generate asynchronously later
      'latitude': 0.0, // TODO: Get from location service
      'longitude': 0.0, // TODO: Get from location service
      'timestamp': tempPhoto.captureTimestamp.toIso8601String(),
      'captured_by': 'SYSTEM', // TODO: Get from current user
      'file_size': fileSize,
      'is_synced': 0,
      'synced_at': null,
      'remote_url': null,
      'created_at': DateTime.now().toIso8601String(),
    };

    await db.insert('photos', photoData);

    // Queue for sync
    if (_syncState != null) {
      await _syncState.queueForSync(
        entityType: 'photo',
        entityId: tempPhoto.id,
        operation: 'create',
        payload: photoData,
      );
    }
  }

  /// Save individual photo to folder with before/after categorization
  Future<void> _savePhotoToFolder({
    required TempPhoto tempPhoto,
    required String equipmentId,
    required String folderId,
    required BeforeAfter category,
  }) async {
    final db = await _db.database;

    // Move photo to permanent storage
    final storedPath = await _storage.moveToPermanent(
      tempPhoto,
      permanentDir: equipmentId,
    );

    // Get file size
    final absolutePath = PhotoStorageService.resolveAbsolutePath(storedPath);
    final file = File(absolutePath);
    final fileSize = await file.length();

    // Prepare photo data
    final photoData = {
      'id': tempPhoto.id,
      'equipment_id': equipmentId,
      'file_path': storedPath,
      'thumbnail_path': null, // Generate asynchronously later
      'latitude': 0.0, // TODO: Get from location service
      'longitude': 0.0, // TODO: Get from location service
      'timestamp': tempPhoto.captureTimestamp.toIso8601String(),
      'captured_by': 'SYSTEM', // TODO: Get from current user
      'file_size': fileSize,
      'is_synced': 0,
      'synced_at': null,
      'remote_url': null,
      'created_at': DateTime.now().toIso8601String(),
    };

    // Use transaction to ensure atomicity
    await db.transaction((txn) async {
      // Insert photo
      await txn.insert('photos', photoData);

      // Create folder-photo association
      await txn.insert('folder_photos', {
        'folder_id': folderId,
        'photo_id': tempPhoto.id,
        'before_after': category.toDb(),
        'added_at': DateTime.now().toIso8601String(),
      });
    });

    // Queue for sync (outside transaction)
    if (_syncState != null) {
      await _syncState.queueForSync(
        entityType: 'photo',
        entityId: tempPhoto.id,
        operation: 'create',
        payload: photoData,
      );
    }
  }

  void _notifyAllPhotosProvider(List<String> savedIds) {
    if (_allPhotosProvider == null) {
      return;
    }
    if (savedIds.isEmpty) {
      return;
    }
    _allPhotosProvider.invalidate();
  }

  /// Dispose of resources
  void dispose() {
    _progressController.close();
  }
}
