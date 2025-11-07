import 'dart:typed_data';
import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';

/// Photo endpoint with file upload support using Serverpod storage
class PhotoEndpoint extends Endpoint {
  /// Get all photos for equipment
  Future<List<Photo>> getPhotosByEquipment(
    Session session,
    String equipmentId, {
    int limit = 50,
    int offset = 0,
  }) async {
    return await Photo.db.find(
      session,
      where: (t) => t.equipmentId.equals(equipmentId),
      orderBy: (t) => t.timestamp,
      orderDescending: true,
      limit: limit,
      offset: offset,
    );
  }

  /// Get photo by UUID
  Future<Photo?> getPhotoByUuid(Session session, String uuid) async {
    return await Photo.db.findFirstRow(
      session,
      where: (t) => t.uuid.equals(uuid),
    );
  }

  /// Create photo metadata (file upload handled separately via Serverpod file upload)
  Future<Photo> createPhoto(
    Session session,
    String equipmentId,
    String filePath,
    double latitude,
    double longitude,
    DateTime timestamp,
    String capturedBy,
    int fileSize, {
    String? thumbnailPath,
    String? sourceAssetId,
    String? fingerprintSha1,
    String? importBatchId,
    String importSource = 'camera',
  }) async {
    final photo = Photo(
      uuid: _generateUuid(),
      equipmentId: equipmentId,
      filePath: filePath,
      thumbnailPath: thumbnailPath,
      latitude: latitude,
      longitude: longitude,
      timestamp: timestamp,
      capturedBy: capturedBy,
      fileSize: fileSize,
      isSynced: true, // Mark as synced since it's on server
      syncedAt: DateTime.now(),
      sourceAssetId: sourceAssetId,
      fingerprintSha1: fingerprintSha1,
      importBatchId: importBatchId,
      importSource: importSource,
      createdAt: DateTime.now(),
    );

    await Photo.db.insertRow(session, photo);
    return photo;
  }

  /// Upload photo file and create metadata
  /// This combines file upload with metadata creation
  Future<Photo> uploadPhoto(
    Session session,
    String equipmentId,
    ByteData fileData,
    String fileName,
    double latitude,
    double longitude,
    DateTime timestamp,
    String capturedBy,
    String importSource,
  ) async {
    // Generate unique file path
    final uuid = _generateUuid();
    final filePath = 'photos/$equipmentId/$uuid/$fileName';

    // Store file using Serverpod's cloud storage
    await session.storage.storeFile(
      storageId: 'public',
      path: filePath,
      byteData: fileData,
    );

    // Create photo metadata
    return await createPhoto(
      session,
      equipmentId,
      filePath,
      latitude,
      longitude,
      timestamp,
      capturedBy,
      fileData.lengthInBytes,
      importSource: importSource,
    );
  }

  /// Get unsynced photos (for sync operations from client to server)
  Future<List<Photo>> getUnsyncedPhotos(Session session) async {
    return await Photo.db.find(
      session,
      where: (t) => t.isSynced.equals(false),
      orderBy: (t) => t.createdAt,
      limit: 100,
    );
  }

  /// Mark photo as synced
  Future<void> markPhotoAsSynced(Session session, String uuid) async {
    final photo = await getPhotoByUuid(session, uuid);
    if (photo == null) {
      throw Exception('Photo not found');
    }

    photo.isSynced = true;
    photo.syncedAt = DateTime.now();
    await Photo.db.updateRow(session, photo);
  }

  /// Delete photo (hard delete from storage and database)
  Future<void> deletePhoto(Session session, String uuid) async {
    final photo = await getPhotoByUuid(session, uuid);
    if (photo == null) {
      throw Exception('Photo not found');
    }

    // Delete file from storage
    try {
      await session.storage.deleteFile(
        storageId: 'public',
        path: photo.filePath,
      );
    } catch (e) {
      session.log('Failed to delete photo file: $e', level: LogLevel.warning);
    }

    // Delete thumbnail if exists
    if (photo.thumbnailPath != null) {
      try {
        await session.storage.deleteFile(
          storageId: 'public',
          path: photo.thumbnailPath!,
        );
      } catch (e) {
        session.log(
          'Failed to delete thumbnail file: $e',
          level: LogLevel.warning,
        );
      }
    }

    // Delete from database
    await Photo.db.deleteRow(session, photo);
  }

  /// Get photo file URL (for downloading)
  Future<String?> getPhotoUrl(Session session, String uuid) async {
    final photo = await getPhotoByUuid(session, uuid);
    if (photo == null) {
      return null;
    }

    // Generate temporary access URL (valid for 1 hour)
    final uri = session.storage.getPublicUrl(
      storageId: 'public',
      path: photo.filePath,
    );
    return uri.toString();
  }

  String _generateUuid() {
    return '${DateTime.now().millisecondsSinceEpoch}-${DateTime.now().microsecond % 10000}';
  }
}
