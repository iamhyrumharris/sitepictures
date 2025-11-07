import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';

/// Photo Folder management endpoint
class FolderEndpoint extends Endpoint {
  /// Get all folders for equipment
  Future<List<PhotoFolder>> getFoldersByEquipment(
    Session session,
    String equipmentId,
  ) async {
    return await PhotoFolder.db.find(
      session,
      where: (t) =>
          t.equipmentId.equals(equipmentId) & t.isDeleted.equals(false),
      orderBy: (t) => t.createdAt,
      orderDescending: true,
    );
  }

  /// Get folder by UUID
  Future<PhotoFolder?> getFolderByUuid(Session session, String uuid) async {
    return await PhotoFolder.db.findFirstRow(
      session,
      where: (t) => t.uuid.equals(uuid) & t.isDeleted.equals(false),
    );
  }

  /// Create new folder
  Future<PhotoFolder> createFolder(
    Session session,
    String equipmentId,
    String name,
    String workOrder,
    String createdBy,
  ) async {
    final folder = PhotoFolder(
      uuid: _generateUuid(),
      equipmentId: equipmentId,
      name: name,
      workOrder: workOrder,
      createdAt: DateTime.now(),
      createdBy: createdBy,
      isDeleted: false,
    );

    await PhotoFolder.db.insertRow(session, folder);
    return folder;
  }

  /// Add photo to folder
  Future<FolderPhoto> addPhotoToFolder(
    Session session,
    String folderId,
    String photoId,
    String beforeAfter, // 'before' or 'after'
  ) async {
    // Check if already exists
    final existing = await FolderPhoto.db.findFirstRow(
      session,
      where: (t) => t.folderId.equals(folderId) & t.photoId.equals(photoId),
    );

    if (existing != null) {
      throw Exception('Photo already in folder');
    }

    final folderPhoto = FolderPhoto(
      folderId: folderId,
      photoId: photoId,
      beforeAfter: beforeAfter,
      addedAt: DateTime.now(),
    );

    await FolderPhoto.db.insertRow(session, folderPhoto);
    return folderPhoto;
  }

  /// Get photos in folder
  Future<List<FolderPhoto>> getPhotosInFolder(
    Session session,
    String folderId, {
    String? beforeAfterFilter,
  }) async {
    if (beforeAfterFilter != null) {
      return await FolderPhoto.db.find(
        session,
        where: (t) =>
            t.folderId.equals(folderId) &
            t.beforeAfter.equals(beforeAfterFilter),
        orderBy: (t) => t.addedAt,
        orderDescending: true,
      );
    } else {
      return await FolderPhoto.db.find(
        session,
        where: (t) => t.folderId.equals(folderId),
        orderBy: (t) => t.addedAt,
        orderDescending: true,
      );
    }
  }

  /// Remove photo from folder
  Future<void> removePhotoFromFolder(
    Session session,
    String folderId,
    String photoId,
  ) async {
    final folderPhoto = await FolderPhoto.db.findFirstRow(
      session,
      where: (t) => t.folderId.equals(folderId) & t.photoId.equals(photoId),
    );

    if (folderPhoto != null) {
      await FolderPhoto.db.deleteRow(session, folderPhoto);
    }
  }

  /// Soft delete folder
  Future<void> deleteFolder(Session session, String uuid) async {
    final folder = await getFolderByUuid(session, uuid);
    if (folder == null) {
      throw Exception('Folder not found');
    }

    folder.isDeleted = true;
    await PhotoFolder.db.updateRow(session, folder);
  }

  String _generateUuid() {
    return '${DateTime.now().millisecondsSinceEpoch}-${DateTime.now().microsecond % 10000}';
  }
}
