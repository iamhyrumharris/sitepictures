import 'package:sqflite/sqflite.dart';
import '../models/folder_photo.dart';
import 'database_service.dart';

class NeedsAssignedMoveSummary {
  final List<String> movedPhotoIds;
  final List<String> impactedFolderIds;

  const NeedsAssignedMoveSummary({
    required this.movedPhotoIds,
    required this.impactedFolderIds,
  });

  factory NeedsAssignedMoveSummary.empty() =>
      const NeedsAssignedMoveSummary(movedPhotoIds: [], impactedFolderIds: []);

  bool get hasChanges =>
      movedPhotoIds.isNotEmpty || impactedFolderIds.isNotEmpty;
}

/// Handles moving photos and folders out of the global "Needs Assigned" area.
class NeedsAssignedMoveService {
  NeedsAssignedMoveService({DatabaseService? databaseService})
    : _dbService = databaseService ?? DatabaseService();

  final DatabaseService _dbService;

  Future<NeedsAssignedMoveSummary> moveItems({
    required List<String> photoIds,
    required List<String> folderIds,
    required String sourceEquipmentId,
    required String targetEquipmentId,
    String? targetFolderId,
    BeforeAfter? targetCategory,
  }) async {
    if ((targetFolderId == null) != (targetCategory == null)) {
      throw ArgumentError(
        'targetFolderId and targetCategory must either both be null or both be provided.',
      );
    }

    final db = await _dbService.database;

    return await db.transaction((txn) async {
      final validatedPhotoIds = await _validatePhotos(
        txn,
        photoIds,
        sourceEquipmentId,
      );

      final folderPhotoEntries = await _getFolderPhotos(
        txn,
        folderIds,
        sourceEquipmentId,
      );

      final photosFromFolders = folderPhotoEntries
          .map((entry) => entry.photoId)
          .where((id) => id.isNotEmpty)
          .toSet();

      final allPhotoIds = <String>{...validatedPhotoIds, ...photosFromFolders};

      if (allPhotoIds.isEmpty) {
        return NeedsAssignedMoveSummary.empty();
      }

      await _clearExistingFolderAssociations(txn, allPhotoIds.toList());

      await _updatePhotoEquipment(txn, allPhotoIds.toList(), targetEquipmentId);

      if (targetFolderId != null && targetCategory != null) {
        await _validateTargetFolder(txn, targetFolderId, targetEquipmentId);
        await _associatePhotosToFolder(
          txn,
          allPhotoIds.toList(),
          targetFolderId,
          targetCategory,
        );
      }

      return NeedsAssignedMoveSummary(
        movedPhotoIds: allPhotoIds.toList(),
        impactedFolderIds: folderIds,
      );
    });
  }

  Future<NeedsAssignedMoveSummary> moveFoldersToEquipment({
    required List<String> folderIds,
    required String sourceEquipmentId,
    required String targetEquipmentId,
  }) async {
    if (folderIds.isEmpty) {
      return NeedsAssignedMoveSummary.empty();
    }

    final db = await _dbService.database;

    return await db.transaction((txn) async {
      final folderPhotos = await _getFolderPhotos(
        txn,
        folderIds,
        sourceEquipmentId,
      );

      final photoIds = folderPhotos.map((fp) => fp.photoId).toSet().toList();

      if (photoIds.isNotEmpty) {
        await _updatePhotoEquipment(txn, photoIds, targetEquipmentId);
      }

      final placeholders = List.filled(folderIds.length, '?').join(',');
      await txn.rawUpdate(
        'UPDATE photo_folders SET equipment_id = ?, is_deleted = 0 WHERE id IN ($placeholders)',
        [targetEquipmentId, ...folderIds],
      );

      return NeedsAssignedMoveSummary(
        movedPhotoIds: photoIds,
        impactedFolderIds: folderIds,
      );
    });
  }

  Future<NeedsAssignedMoveSummary> mergeFoldersIntoExisting({
    required List<String> folderIds,
    required String sourceEquipmentId,
    required String targetFolderId,
    required String targetEquipmentId,
  }) async {
    if (folderIds.isEmpty) {
      return NeedsAssignedMoveSummary.empty();
    }

    final db = await _dbService.database;

    return await db.transaction((txn) async {
      await _validateTargetFolder(txn, targetFolderId, targetEquipmentId);

      final folderPhotos = await _getFolderPhotos(
        txn,
        folderIds,
        sourceEquipmentId,
      );

      final photoIds = folderPhotos.map((fp) => fp.photoId).toSet().toList();

      if (photoIds.isNotEmpty) {
        await _updatePhotoEquipment(txn, photoIds, targetEquipmentId);
        await _clearExistingFolderAssociations(txn, photoIds);
        await _associatePhotosWithCategories(txn, folderPhotos, targetFolderId);
      }

      await _markFoldersDeleted(txn, folderIds);

      return NeedsAssignedMoveSummary(
        movedPhotoIds: photoIds,
        impactedFolderIds: folderIds,
      );
    });
  }

  Future<List<String>> _validatePhotos(
    Transaction txn,
    List<String> photoIds,
    String expectedEquipmentId,
  ) async {
    if (photoIds.isEmpty) {
      return const <String>[];
    }

    final placeholders = List.filled(photoIds.length, '?').join(',');
    final rows = await txn.query(
      'photos',
      columns: ['id'],
      where: 'id IN ($placeholders) AND equipment_id = ?',
      whereArgs: [...photoIds, expectedEquipmentId],
    );

    if (rows.length != photoIds.length) {
      throw Exception(
        'Some selected photos could not be moved. They may have already been reassigned.',
      );
    }

    return rows.map((row) => row['id'] as String).toList();
  }

  Future<List<FolderPhoto>> _getFolderPhotos(
    Transaction txn,
    List<String> folderIds,
    String expectedEquipmentId,
  ) async {
    if (folderIds.isEmpty) {
      return const <FolderPhoto>[];
    }

    final placeholders = List.filled(folderIds.length, '?').join(',');
    final folderRows = await txn.query(
      'photo_folders',
      columns: ['id'],
      where: 'id IN ($placeholders) AND equipment_id = ? AND is_deleted = 0',
      whereArgs: [...folderIds, expectedEquipmentId],
    );

    if (folderRows.length != folderIds.length) {
      throw Exception('Some selected folders are no longer available to move.');
    }

    final photoRows = await txn.query(
      'folder_photos',
      columns: ['folder_id', 'photo_id', 'before_after', 'added_at'],
      where: 'folder_id IN ($placeholders)',
      whereArgs: folderIds,
    );

    return photoRows.map(FolderPhoto.fromMap).toList();
  }

  Future<void> _clearExistingFolderAssociations(
    Transaction txn,
    List<String> photoIds,
  ) async {
    if (photoIds.isEmpty) {
      return;
    }

    final placeholders = List.filled(photoIds.length, '?').join(',');
    await txn.delete(
      'folder_photos',
      where: 'photo_id IN ($placeholders)',
      whereArgs: photoIds,
    );
  }

  Future<void> _validateTargetFolder(
    Transaction txn,
    String folderId,
    String expectedEquipmentId,
  ) async {
    final result = await txn.query(
      'photo_folders',
      columns: ['id'],
      where: 'id = ? AND equipment_id = ? AND is_deleted = 0',
      whereArgs: [folderId, expectedEquipmentId],
      limit: 1,
    );

    if (result.isEmpty) {
      throw Exception('Target folder is no longer available.');
    }
  }

  Future<void> _updatePhotoEquipment(
    Transaction txn,
    List<String> photoIds,
    String targetEquipmentId,
  ) async {
    final placeholders = List.filled(photoIds.length, '?').join(',');
    await txn.rawUpdate(
      'UPDATE photos SET equipment_id = ? WHERE id IN ($placeholders)',
      [targetEquipmentId, ...photoIds],
    );
  }

  Future<void> _associatePhotosToFolder(
    Transaction txn,
    List<String> photoIds,
    String folderId,
    BeforeAfter category,
  ) async {
    final now = DateTime.now();

    for (final photoId in photoIds) {
      final folderPhoto = FolderPhoto(
        folderId: folderId,
        photoId: photoId,
        beforeAfter: category,
        addedAt: now,
      );

      await txn.insert(
        'folder_photos',
        folderPhoto.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<void> _associatePhotosWithCategories(
    Transaction txn,
    List<FolderPhoto> entries,
    String targetFolderId,
  ) async {
    if (entries.isEmpty) {
      return;
    }

    final now = DateTime.now();

    for (final entry in entries) {
      final folderPhoto = FolderPhoto(
        folderId: targetFolderId,
        photoId: entry.photoId,
        beforeAfter: entry.beforeAfter,
        addedAt: now,
      );

      await txn.insert(
        'folder_photos',
        folderPhoto.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<void> _markFoldersDeleted(
    Transaction txn,
    List<String> folderIds,
  ) async {
    final placeholders = List.filled(folderIds.length, '?').join(',');
    await txn.update(
      'photo_folders',
      {'is_deleted': 1},
      where: 'id IN ($placeholders)',
      whereArgs: folderIds,
    );
  }
}
