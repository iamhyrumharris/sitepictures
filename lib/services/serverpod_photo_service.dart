import 'dart:typed_data';

import 'package:sitepictures_server_client/sitepictures_server_client.dart'
    as rpc;

import '../models/photo.dart';
import '../services/serverpod_service.dart';

class RemotePhotoPayload {
  RemotePhotoPayload({
    required this.record,
    required this.bytes,
  });

  final rpc.PhotoRecord record;
  final Uint8List? bytes;
}

class ServerpodPhotoService {
  ServerpodPhotoService._();

  static final ServerpodPhotoService instance = ServerpodPhotoService._();

  final ServerpodService _serverpodService = ServerpodService.instance;

  Future<rpc.PhotoRecord> uploadPhoto({
    required Photo photo,
    Uint8List? fileBytes,
  }) async {
    await _serverpodService.initialize();

    final payload = rpc.PhotoPayload(
      record: rpc.PhotoRecord(
        id: null,
        clientId: photo.id,
        equipmentId: photo.equipmentId,
        capturedBy: photo.capturedBy,
        latitude: photo.latitude,
        longitude: photo.longitude,
        timestamp: photo.timestamp.toUtc(),
        fileSize: photo.fileSize,
        importSource: photo.importSource,
        fingerprintSha1: photo.fingerprintSha1,
        importBatchId: photo.importBatchId,
        remoteUrl: photo.remoteUrl,
        storagePath: null,
        createdAt: photo.createdAt.toUtc(),
        updatedAt: DateTime.now().toUtc(),
      ),
      bytes: fileBytes != null ? ByteData.sublistView(fileBytes) : null,
    );

    return await _serverpodService.client.photo.upsertPhoto(payload);
  }

  Future<List<RemotePhotoPayload>> pullPhotos(DateTime? lastSync) async {
    await _serverpodService.initialize();
    final payloads = await _serverpodService.client.photo.pullPhotos(
      lastSync?.toUtc(),
    );
    return payloads
        .map(
          (payload) => RemotePhotoPayload(
            record: payload.record,
            bytes: payload.bytes == null
                ? null
                : payload.bytes!.buffer.asUint8List(
                    payload.bytes!.offsetInBytes,
                    payload.bytes!.lengthInBytes,
                  ),
          ),
        )
        .toList();
  }

  Future<RemotePhotoPayload?> downloadPhoto(String clientId) async {
    await _serverpodService.initialize();
    final payload =
        await _serverpodService.client.photo.downloadPhoto(clientId);
    if (payload == null) return null;
    return RemotePhotoPayload(
      record: payload.record,
      bytes: payload.bytes == null
          ? null
          : payload.bytes!.buffer.asUint8List(
              payload.bytes!.offsetInBytes,
              payload.bytes!.lengthInBytes,
            ),
    );
  }

  Photo toLocalPhoto({
    required rpc.PhotoRecord record,
    required String filePath,
  }) {
    return Photo(
      id: record.clientId,
      equipmentId: record.equipmentId,
      filePath: filePath,
      latitude: record.latitude,
      longitude: record.longitude,
      timestamp: record.timestamp.toLocal(),
      capturedBy: record.capturedBy,
      fileSize: record.fileSize,
      isSynced: true,
      syncedAt: record.updatedAt.toIso8601String(),
      remoteUrl: record.remoteUrl ?? 'remote://${record.clientId}',
      fingerprintSha1: record.fingerprintSha1,
      importBatchId: record.importBatchId,
      importSource: record.importSource,
      createdAt: record.createdAt.toLocal(),
    );
  }
}
