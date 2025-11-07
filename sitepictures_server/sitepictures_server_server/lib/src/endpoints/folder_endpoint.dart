import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

class FolderEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  Future<PhotoFolderRecord> upsertFolder(
    Session session,
    PhotoFolderRecord record,
  ) async {
    final existing = await PhotoFolderRecord.db.findFirstRow(
      session,
      where: (t) => t.folderId.equals(record.folderId),
    );

    final now = DateTime.now().toUtc();
    final createdAt = existing?.createdAt ?? record.createdAt ?? now;
    final normalized = record.copyWith(
      id: existing?.id,
      createdAt: createdAt,
      updatedAt: now,
    );

    return existing == null
        ? await PhotoFolderRecord.db.insertRow(session, normalized)
        : await PhotoFolderRecord.db.updateRow(session, normalized);
  }

  Future<List<PhotoFolderRecord>> pullFolders(
    Session session,
    DateTime? lastSync,
  ) async {
    final since = lastSync?.toUtc();
    return await PhotoFolderRecord.db.find(
      session,
      where: since != null ? (t) => t.updatedAt > since : null,
      orderBy: (t) => t.updatedAt,
    );
  }

  Future<FolderPhotoRecord> upsertFolderPhoto(
    Session session,
    FolderPhotoRecord record,
  ) async {
    final existing = await FolderPhotoRecord.db.findFirstRow(
      session,
      where: (t) =>
          t.folderId.equals(record.folderId) &
          t.photoId.equals(record.photoId),
    );

    final now = DateTime.now().toUtc();
    final normalized = record.copyWith(
      id: existing?.id,
      addedAt: record.addedAt ?? now,
    );

    return existing == null
        ? await FolderPhotoRecord.db.insertRow(session, normalized)
        : await FolderPhotoRecord.db.updateRow(session, normalized);
  }

  Future<List<FolderPhotoRecord>> pullFolderPhotos(
    Session session,
    DateTime? lastSync,
  ) async {
    final since = lastSync?.toUtc();
    return await FolderPhotoRecord.db.find(
      session,
      where: since != null ? (t) => t.addedAt > since : null,
      orderBy: (t) => t.addedAt,
    );
  }
}
