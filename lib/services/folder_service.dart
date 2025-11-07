import 'package:sqflite/sqflite.dart';
import '../models/photo_folder.dart';
import '../models/folder_photo.dart';
import '../models/photo.dart';
import 'database_service.dart';

class FolderService {
  final DatabaseService _dbService;

  FolderService({DatabaseService? dbService})
    : _dbService = dbService ?? DatabaseService();

  /// Create a new folder
  Future<PhotoFolder> createFolder({
    required String equipmentId,
    required String workOrder,
    required String createdBy,
  }) async {
    final folder = PhotoFolder(
      equipmentId: equipmentId,
      workOrder: workOrder,
      createdBy: createdBy,
    );

    if (!folder.isValid()) {
      throw ArgumentError('Invalid folder data');
    }

    final db = await _dbService.database;
    await db.insert('photo_folders', folder.toMap());

    return folder;
  }

  /// Get all folders for an equipment
  Future<List<PhotoFolder>> getFolders(String equipmentId) async {
    final maps = await _dbService.getFoldersForEquipment(equipmentId);
    return maps.map((map) => PhotoFolder.fromMap(map)).toList();
  }

  /// Get a single folder by ID
  Future<PhotoFolder?> getFolderById(String folderId) async {
    final map = await _dbService.getFolderById(folderId);
    return map != null ? PhotoFolder.fromMap(map) : null;
  }

  /// Rename an existing folder
  Future<void> renameFolder({
    required String folderId,
    required String newName,
  }) async {
    final trimmed = newName.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('Folder name cannot be empty.');
    }
    if (trimmed.length > 100) {
      throw ArgumentError('Folder name too long (max 100 characters).');
    }

    final db = await _dbService.database;
    final updated = await db.update(
      'photo_folders',
      {
        'name': trimmed,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ? AND is_deleted = 0',
      whereArgs: [folderId],
    );

    if (updated == 0) {
      throw Exception('Folder not found or already deleted.');
    }
  }

  /// Delete a folder
  Future<void> deleteFolder({
    required String folderId,
    required bool deletePhotos,
  }) async {
    return await _dbService.transaction((txn) async {
      if (deletePhotos) {
        // Delete all photos in the folder
        final photoMaps = await txn.rawQuery(
          '''
          SELECT photo_id FROM folder_photos WHERE folder_id = ?
        ''',
          [folderId],
        );

        final photoIds = photoMaps.map((m) => m['photo_id'] as String).toList();

        for (final photoId in photoIds) {
          await txn.delete('photos', where: 'id = ?', whereArgs: [photoId]);
        }
        // CASCADE will delete folder_photos entries
      } else {
        // Just remove the folder-photo associations (orphan photos)
        await txn.delete(
          'folder_photos',
          where: 'folder_id = ?',
          whereArgs: [folderId],
        );
      }

      // Soft delete the folder
      await txn.update(
        'photo_folders',
        {
          'is_deleted': 1,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [folderId],
      );
    });
  }

  /// Add a photo to a folder
  Future<void> addPhotoToFolder({
    required String folderId,
    required String photoId,
    required BeforeAfter beforeAfter,
  }) async {
    final folderPhoto = FolderPhoto(
      folderId: folderId,
      photoId: photoId,
      beforeAfter: beforeAfter,
    );

    if (!folderPhoto.isValid()) {
      throw ArgumentError('Invalid folder photo data');
    }

    final db = await _dbService.database;
    await db.insert(
      'folder_photos',
      folderPhoto.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get photo counts for a folder (before and after)
  Future<Map<String, int>> getPhotoCountsForFolder(String folderId) async {
    final db = await _dbService.database;
    final result = await db.rawQuery(
      '''
      SELECT
        COUNT(CASE WHEN before_after = 'before' THEN 1 END) AS before_count,
        COUNT(CASE WHEN before_after = 'after' THEN 1 END) AS after_count
      FROM folder_photos
      WHERE folder_id = ?
    ''',
      [folderId],
    );

    if (result.isEmpty) {
      return {'before': 0, 'after': 0};
    }

    return {
      'before': result.first['before_count'] as int,
      'after': result.first['after_count'] as int,
    };
  }

  /// Get before photos for a folder
  Future<List<Photo>> getBeforePhotos(String folderId) async {
    final maps = await _dbService.getBeforePhotos(folderId);
    return maps.map((map) => Photo.fromMap(map)).toList();
  }

  /// Get after photos for a folder
  Future<List<Photo>> getAfterPhotos(String folderId) async {
    final maps = await _dbService.getAfterPhotos(folderId);
    return maps.map((map) => Photo.fromMap(map)).toList();
  }
}
