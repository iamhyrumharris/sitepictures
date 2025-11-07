import 'package:sitepictures_server_client/sitepictures_server_client.dart'
    as rpc;

import '../models/photo_folder.dart';
import '../models/folder_photo.dart';
import 'serverpod_service.dart';

class ServerpodFolderService {
  ServerpodFolderService._();

  static final ServerpodFolderService instance = ServerpodFolderService._();

  final ServerpodService _serverpodService = ServerpodService.instance;

  Future<PhotoFolder> upsertFolder(PhotoFolder folder) async {
    await _serverpodService.initialize();
    final record = await _serverpodService.client.folder.upsertFolder(
      _toFolderRecord(folder),
    );
    return _fromFolderRecord(record);
  }

  Future<List<PhotoFolder>> pullFolders(DateTime? lastSync) async {
    await _serverpodService.initialize();
    final records = await _serverpodService.client.folder.pullFolders(
      lastSync?.toUtc(),
    );
    return records.map(_fromFolderRecord).toList();
  }

  Future<void> upsertFolderPhoto(FolderPhoto link) async {
    await _serverpodService.initialize();
    await _serverpodService.client.folder.upsertFolderPhoto(
      _toFolderPhotoRecord(link),
    );
  }

  Future<List<FolderPhoto>> pullFolderPhotos(DateTime? lastSync) async {
    await _serverpodService.initialize();
    final records = await _serverpodService.client.folder.pullFolderPhotos(
      lastSync?.toUtc(),
    );
    return records.map(_fromFolderPhotoRecord).toList();
  }

  rpc.PhotoFolderRecord _toFolderRecord(PhotoFolder folder) {
    return rpc.PhotoFolderRecord(
      id: null,
      folderId: folder.id,
      equipmentId: folder.equipmentId,
      name: folder.name,
      workOrder: folder.workOrder,
      createdBy: folder.createdBy,
      createdAt: folder.createdAt.toUtc(),
      updatedAt: folder.updatedAt.toUtc(),
      isDeleted: folder.isDeleted,
    );
  }

  rpc.FolderPhotoRecord _toFolderPhotoRecord(FolderPhoto link) {
    return rpc.FolderPhotoRecord(
      id: null,
      folderId: link.folderId,
      photoId: link.photoId,
      beforeAfter: link.beforeAfter.toDb(),
      addedAt: link.addedAt.toUtc(),
    );
  }

  PhotoFolder _fromFolderRecord(rpc.PhotoFolderRecord record) {
    return PhotoFolder(
      id: record.folderId,
      equipmentId: record.equipmentId,
      name: record.name,
      workOrder: record.workOrder,
      createdBy: record.createdBy,
      createdAt: record.createdAt.toLocal(),
      updatedAt: record.updatedAt.toLocal(),
      isDeleted: record.isDeleted,
    );
  }

  FolderPhoto _fromFolderPhotoRecord(rpc.FolderPhotoRecord record) {
    return FolderPhoto(
      folderId: record.folderId,
      photoId: record.photoId,
      beforeAfter: BeforeAfter.fromDb(record.beforeAfter),
      addedAt: record.addedAt.toLocal(),
    );
  }
}
