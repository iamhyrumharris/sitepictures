import 'dart:io';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/photo_session.dart';
import '../models/quick_save_item.dart';
import '../models/save_result.dart';
import '../services/database_service.dart';
import '../services/photo_storage_service.dart';
import '../utils/sequential_namer.dart';

/// Implementation of QuickSaveService for home camera Quick Save workflow
class QuickSaveService {
  final DatabaseService _db;
  final PhotoStorageService _storage;
  final SequentialNamer _namer;

  static const _uuid = Uuid();
  static const String _globalNeedsAssignedClientId = 'GLOBAL_NEEDS_ASSIGNED';

  QuickSaveService({
    required DatabaseService databaseService,
    required PhotoStorageService storageService,
  })  : _db = databaseService,
        _storage = storageService,
        _namer = SequentialNamer(databaseService: databaseService);

  /// Execute Quick Save operation for photos from home camera context
  Future<SaveResult> quickSave(List<TempPhoto> photos) async {
    if (photos.isEmpty) {
      return SaveResult.criticalFailure(error: 'No photos to save');
    }

    try {
      // Validate storage availability
      final hasStorage = await hasStorageAvailable(photos);
      if (!hasStorage) {
        return SaveResult.criticalFailure(
          error: 'Insufficient storage space',
          sessionPreserved: true,
        );
      }

      // Get global equipment ID for "Needs Assigned" client
      final globalEquipmentId = await _getOrCreateGlobalEquipment();

      // Generate base name with current date
      final now = DateTime.now();
      final dateStr = DateFormat('yyyy-MM-dd').format(now);
      final baseName = photos.length == 1
          ? 'Image - $dateStr'
          : 'Folder - $dateStr';

      // Get unique name with sequential numbering
      final uniqueName = await generateUniqueName(
        baseName: baseName,
        itemType: photos.length == 1
            ? QuickSaveType.singlePhoto
            : QuickSaveType.folder,
      );

      String? folderId;

      // Create folder if multiple photos
      if (photos.length > 1) {
        folderId = await _createFolder(
          equipmentId: globalEquipmentId,
          name: uniqueName,
        );
      }

      // Save photos incrementally
      final savedIds = <String>[];
      final failedIds = <String>[];

      for (final tempPhoto in photos) {
        try {
          await _savePhoto(
            tempPhoto: tempPhoto,
            equipmentId: globalEquipmentId,
            folderId: folderId,
            beforeAfter: folderId != null ? 'before' : null,
          );
          savedIds.add(tempPhoto.id);
        } catch (e) {
          // Non-critical error: log and continue
          print('Failed to save photo ${tempPhoto.id}: $e');
          failedIds.add(tempPhoto.id);
        }
      }

      // Return result based on outcome
      if (failedIds.isEmpty) {
        return SaveResult.complete(savedIds);
      } else {
        return SaveResult.partial(
          successful: savedIds.length,
          failed: failedIds.length,
          savedIds: savedIds,
        );
      }
    } catch (e) {
      // Critical error: preserve session
      return SaveResult.criticalFailure(
        error: e.toString(),
        sessionPreserved: true,
      );
    }
  }

  /// Generate unique name for Quick Save item with sequential numbering
  Future<String> generateUniqueName({
    required String baseName,
    required QuickSaveType itemType,
  }) async {
    // Get global equipment ID
    final globalEquipmentId = await _getOrCreateGlobalEquipment();

    // Use SequentialNamer to generate unique name
    return await _namer.getUniqueFolderName(
      baseName: baseName,
      equipmentId: globalEquipmentId,
    );
  }

  /// Validate storage availability before Quick Save
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

      // Check available storage (simplified - would need platform-specific implementation)
      // For now, return true if photos exist
      return totalSize > 0;
    } catch (e) {
      print('Storage validation error: $e');
      return false;
    }
  }

  /// Get or create global equipment for "Needs Assigned" client
  Future<String> _getOrCreateGlobalEquipment() async {
    final db = await _db.database;

    // Check if global equipment exists
    final existing = await db.query(
      'equipment',
      where: 'client_id = ?',
      whereArgs: [_globalNeedsAssignedClientId],
      limit: 1,
    );

    if (existing.isNotEmpty) {
      return existing.first['id'] as String;
    }

    // Create global equipment
    final equipmentId = _uuid.v4();
    await db.insert('equipment', {
      'id': equipmentId,
      'client_id': _globalNeedsAssignedClientId,
      'main_site_id': null,
      'sub_site_id': null,
      'name': 'Global Storage',
      'serial_number': null,
      'manufacturer': null,
      'model': null,
      'created_by': 'SYSTEM',
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
      'is_active': 1,
    });

    return equipmentId;
  }

  /// Create folder for multiple photos
  Future<String> _createFolder({
    required String equipmentId,
    required String name,
  }) async {
    final db = await _db.database;
    final folderId = _uuid.v4();

    await db.insert('photo_folders', {
      'id': folderId,
      'equipment_id': equipmentId,
      'name': name,
      'work_order': 'Quick Save',
      'created_at': DateTime.now().toIso8601String(),
      'created_by': 'SYSTEM',
      'is_deleted': 0,
    });

    return folderId;
  }

  /// Save individual photo to database and permanent storage
  Future<void> _savePhoto({
    required TempPhoto tempPhoto,
    required String equipmentId,
    String? folderId,
    String? beforeAfter,
  }) async {
    final db = await _db.database;

    // Move photo to permanent storage
    final permanentPath = await _storage.moveToPermanent(
      tempPhoto,
      permanentDir: equipmentId,
    );

    // Get file size
    final file = File(permanentPath);
    final fileSize = await file.length();

    // Insert photo into database
    await db.transaction((txn) async {
      await txn.insert('photos', {
        'id': tempPhoto.id,
        'equipment_id': equipmentId,
        'file_path': permanentPath,
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
      });

      // Create folder association if folder exists
      if (folderId != null && beforeAfter != null) {
        await txn.insert('folder_photos', {
          'folder_id': folderId,
          'photo_id': tempPhoto.id,
          'before_after': beforeAfter,
          'added_at': DateTime.now().toIso8601String(),
        });
      }
    });
  }
}
