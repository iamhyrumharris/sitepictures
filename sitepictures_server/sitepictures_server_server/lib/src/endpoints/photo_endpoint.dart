import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

/// Endpoint responsible for synchronizing photo metadata and binaries between
/// the mobile client and the Serverpod backend.
class PhotoEndpoint extends Endpoint {
  PhotoEndpoint() {
    _storageDirectory = Directory(p.join(Directory.current.path, 'storage', 'photos'));
  }

  late final Directory _storageDirectory;

  @override
  bool get requireLogin => true;

  /// Uploads or updates a photo record, optionally persisting the binary payload.
  Future<PhotoRecord> upsertPhoto(Session session, PhotoPayload payload) async {
    var record = payload.record;
    final now = DateTime.now().toUtc();

    final existing = await PhotoRecord.db.findFirstRow(
      session,
      where: (t) => t.clientId.equals(record.clientId),
    );
    final createdAt = existing?.createdAt ?? record.createdAt;

    record = record.copyWith(
      id: existing?.id,
      createdAt: createdAt,
      updatedAt: now,
      remoteUrl: record.remoteUrl ?? 'remote://${record.clientId}',
    );

    if (payload.bytes != null) {
      final storagePath = await _savePhotoBytes(record.clientId, payload.bytes!);
      record = record.copyWith(storagePath: storagePath);
    }

    return existing == null
        ? await PhotoRecord.db.insertRow(session, record)
        : await PhotoRecord.db.updateRow(session, record);
  }

  /// Returns photo payloads that have changed since [lastSync], including binaries.
  Future<List<PhotoPayload>> pullPhotos(
    Session session,
    DateTime? lastSync,
  ) async {
    final since = lastSync?.toUtc();

    final rows = await PhotoRecord.db.find(
      session,
      where: since != null ? (t) => t.updatedAt > since : null,
      orderBy: (t) => t.updatedAt,
      limit: 200,
    );

    final payloads = <PhotoPayload>[];
    for (final record in rows) {
      final bytes = await _loadPhotoBytes(record.clientId);
      payloads.add(
        PhotoPayload(
          record: record,
          bytes: bytes,
        ),
      );
    }
    return payloads;
  }

  /// Downloads a single photo payload.
  Future<PhotoPayload?> downloadPhoto(Session session, String clientId) async {
    final record = await PhotoRecord.db.findFirstRow(
      session,
      where: (t) => t.clientId.equals(clientId),
    );
    if (record == null) {
      return null;
    }
    final bytes = await _loadPhotoBytes(clientId);
    return PhotoPayload(record: record, bytes: bytes);
  }

  Future<String> _savePhotoBytes(String photoId, ByteData data) async {
    if (!await _storageDirectory.exists()) {
      await _storageDirectory.create(recursive: true);
    }

    final filePath = p.join(_storageDirectory.path, '$photoId.bin');
    final file = File(filePath);
    final bytes = data.buffer.asUint8List(
      data.offsetInBytes,
      data.lengthInBytes,
    );
    await file.writeAsBytes(bytes, flush: true);

    return p.relative(filePath, from: Directory.current.path);
  }

  Future<ByteData?> _loadPhotoBytes(String photoId) async {
    final file = File(p.join(_storageDirectory.path, '$photoId.bin'));
    if (!await file.exists()) {
      return null;
    }
    final bytes = await file.readAsBytes();
    return ByteData.view(bytes.buffer);
  }
}
