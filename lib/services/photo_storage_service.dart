import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../models/photo_session.dart';

/// Service for managing temporary photo storage during capture sessions
class PhotoStorageService {
  static const _uuid = Uuid();
  static String? _documentsDirectory;

  /// Save captured photo to temporary storage and create TempPhoto entity
  /// Returns TempPhoto with filePath and generated thumbnail
  Future<TempPhoto> saveTempPhoto(XFile xFile, int displayOrder) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final sessionDir = Directory('${tempDir.path}/camera_session');

      if (!await sessionDir.exists()) {
        await sessionDir.create(recursive: true);
      }

      final timestamp = DateTime.now();
      final fileName = 'photo_${timestamp.millisecondsSinceEpoch}.jpg';
      final targetPath = '${sessionDir.path}/$fileName';

      // Copy XFile to temp storage
      await File(xFile.path).copy(targetPath);

      // Generate thumbnail (100x100, 70% quality)
      final thumbnailData = await _generateThumbnail(targetPath);

      return TempPhoto(
        id: _uuid.v4(),
        filePath: targetPath,
        captureTimestamp: timestamp,
        displayOrder: displayOrder,
        thumbnailData: thumbnailData,
      );
    } catch (e) {
      throw Exception('Failed to save temp photo: ${e.toString()}');
    }
  }

  /// Delete temporary photo file
  Future<void> deleteTempPhoto(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      // Silently handle deletion errors (idempotent)
    }
  }

  /// Clear all photos for a session
  Future<void> clearSessionPhotos(List<TempPhoto> photos) async {
    for (final photo in photos) {
      await deleteTempPhoto(photo.filePath);
    }
  }

  /// Move temporary photo to permanent storage
  /// Returns the new permanent file path
  Future<String> moveToPermanent(TempPhoto tempPhoto, {required String permanentDir}) async {
    try {
      // Create permanent storage directory structure
      await ensureInitialized();
      final basePath = _documentsDirectory!;
      final photoDir = Directory(p.join(basePath, 'photos', permanentDir));

      if (!await photoDir.exists()) {
        await photoDir.create(recursive: true);
      }

      // Generate permanent file name using timestamp
      final timestamp = tempPhoto.captureTimestamp;
      final fileName = 'photo_${timestamp.millisecondsSinceEpoch}_${tempPhoto.id}.jpg';
      final permanentPath = p.join(photoDir.path, fileName);

      // Move file from temp to permanent location
      final tempFile = File(tempPhoto.filePath);
      if (await tempFile.exists()) {
        await tempFile.copy(permanentPath);
        await tempFile.delete(); // Clean up temp file
      } else {
        throw Exception('Temporary photo file not found: ${tempPhoto.filePath}');
      }

      return p.relative(permanentPath, from: basePath);
    } catch (e) {
      throw Exception('Failed to move photo to permanent storage: ${e.toString()}');
    }
  }

  /// Generate thumbnail from image file
  /// Returns Uint8List of compressed thumbnail (100x100, 70% quality)
  Future<Uint8List?> _generateThumbnail(String filePath) async {
    try {
      final result = await FlutterImageCompress.compressWithFile(
        filePath,
        minWidth: 100,
        minHeight: 100,
        quality: 70,
        format: CompressFormat.jpeg,
      );
      return result;
    } catch (e) {
      // Return null if thumbnail generation fails
      return null;
    }
  }

  /// Regenerate thumbnail for a photo (used after session restoration)
  Future<Uint8List?> regenerateThumbnail(String filePath) async {
    return await _generateThumbnail(filePath);
  }

  /// Clean up old session files (orphaned sessions > 24 hours old)
  Future<void> cleanupOldSessions() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final sessionDir = Directory('${tempDir.path}/camera_session');

      if (!await sessionDir.exists()) {
        return;
      }

      final now = DateTime.now();
      final files = await sessionDir.list().toList();

      for (final entity in files) {
        if (entity is File) {
          final stat = await entity.stat();
          final age = now.difference(stat.modified);

          // Delete files older than 24 hours
          if (age.inHours > 24) {
            try {
              await entity.delete();
            } catch (e) {
              // Continue cleanup even if individual deletion fails
            }
          }
        }
      }
    } catch (e) {
      // Best-effort cleanup - don't throw errors
    }
  }

  /// Resolves a stored (relative or absolute) photo path to an absolute path.
  /// Throws if called with a remote URL (e.g. remote://).
  static String resolveAbsolutePath(String storedPath) {
    if (_isRemotePath(storedPath)) {
      throw ArgumentError('Cannot resolve remote photo path: $storedPath');
    }
    if (p.isAbsolute(storedPath)) {
      return storedPath;
    }
    final basePath = _documentsDirectory;
    if (basePath == null) {
      throw StateError(
        'PhotoStorageService not initialized. Call ensureInitialized() during app startup.',
      );
    }
    return p.join(basePath, storedPath);
  }

  /// Returns a File for the stored path, or null if the path refers to a remote asset.
  static File? tryResolveLocalFile(String storedPath) {
    if (_isRemotePath(storedPath)) {
      return null;
    }
    final absolutePath = resolveAbsolutePath(storedPath);
    return File(absolutePath);
  }

  /// Indicates whether the stored path represents a remote asset.
  static bool _isRemotePath(String storedPath) {
    final lower = storedPath.toLowerCase();
    return lower.startsWith('remote://') ||
        lower.startsWith('http://') ||
        lower.startsWith('https://');
  }

  /// Converts an absolute path inside the app documents directory into a stored (relative) path.
  /// If the path is already relative or remote, it is returned unchanged.
  static String toStoredPath(String absolutePath) {
    if (_isRemotePath(absolutePath)) {
      return absolutePath;
    }
    if (!p.isAbsolute(absolutePath)) {
      return absolutePath;
    }
    final basePath = _documentsDirectory;
    if (basePath == null) {
      throw StateError(
        'PhotoStorageService not initialized. Call ensureInitialized() during app startup.',
      );
    }
    final normalizedBase = p.normalize(basePath);
    final normalizedAbsolute = p.normalize(absolutePath);
    if (normalizedAbsolute == normalizedBase ||
        p.isWithin(normalizedBase, normalizedAbsolute)) {
      return p.relative(normalizedAbsolute, from: normalizedBase);
    }
    return absolutePath;
  }

  /// Ensures the documents directory base path is cached for synchronous lookups.
  static Future<void> ensureInitialized() async {
    if (_documentsDirectory != null) {
      return;
    }
    final appDir = await getApplicationDocumentsDirectory();
    _documentsDirectory = appDir.path;
  }

  /// Persists remote photo bytes into the local documents directory and returns the stored path.
  static Future<String> saveRemoteBytes(
    Uint8List bytes, {
    required String remoteId,
  }) async {
    await ensureInitialized();
    final basePath = _documentsDirectory!;
    final remoteDir = Directory(p.join(basePath, 'photos', 'remote'));
    if (!await remoteDir.exists()) {
      await remoteDir.create(recursive: true);
    }

    final fileName =
        'remote_${remoteId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final filePath = p.join(remoteDir.path, fileName);
    final file = File(filePath);
    await file.writeAsBytes(bytes, flush: true);
    return p.relative(filePath, from: basePath);
  }
}
