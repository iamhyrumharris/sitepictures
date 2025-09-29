import 'dart:io';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:image/image.dart' as img;
import '../models/photo.dart';
import 'storage_service.dart';

class FileService {
  static FileService? _instance;
  final StorageService _storageService = StorageService.instance;
  String? _photosDirectory;
  String? _thumbnailsDirectory;
  String? _tempDirectory;

  FileService._();

  static FileService get instance {
    _instance ??= FileService._();
    return _instance!;
  }

  Future<void> initialize() async {
    final appDir = await getApplicationDocumentsDirectory();
    _photosDirectory = path.join(appDir.path, 'photos');
    _thumbnailsDirectory = path.join(appDir.path, 'thumbnails');
    _tempDirectory = path.join(appDir.path, 'temp');

    await Directory(_photosDirectory!).create(recursive: true);
    await Directory(_thumbnailsDirectory!).create(recursive: true);
    await Directory(_tempDirectory!).create(recursive: true);
  }

  Future<String> savePhotoFile(Uint8List data, {String? fileName}) async {
    await _ensureDirectoriesExist();

    fileName ??= '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final filePath = path.join(_photosDirectory!, fileName);

    final file = File(filePath);
    await file.writeAsBytes(data);

    return filePath;
  }

  Future<Uint8List?> readPhotoFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        return await file.readAsBytes();
      }
    } catch (e) {
      print('Error reading photo file: $e');
    }
    return null;
  }

  Future<bool> deletePhotoFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();

        final thumbnailPath = _getThumbnailPath(filePath);
        final thumbnailFile = File(thumbnailPath);
        if (await thumbnailFile.exists()) {
          await thumbnailFile.delete();
        }

        return true;
      }
    } catch (e) {
      print('Error deleting photo file: $e');
    }
    return false;
  }

  Future<String> generateThumbnail(String photoPath, {int size = 200}) async {
    await _ensureDirectoriesExist();

    final thumbnailPath = _getThumbnailPath(photoPath);
    final thumbnailFile = File(thumbnailPath);

    if (await thumbnailFile.exists()) {
      return thumbnailPath;
    }

    try {
      final file = File(photoPath);
      final bytes = await file.readAsBytes();

      final image = img.decodeImage(bytes);
      if (image == null) {
        throw Exception('Failed to decode image');
      }

      final thumbnail = img.copyResize(
        image,
        width: size,
        height: (image.height * size / image.width).round(),
      );

      final thumbnailBytes = img.encodeJpg(thumbnail, quality: 80);
      await thumbnailFile.writeAsBytes(thumbnailBytes);

      return thumbnailPath;
    } catch (e) {
      print('Error generating thumbnail: $e');
      return photoPath;
    }
  }

  String _getThumbnailPath(String photoPath) {
    final fileName = path.basename(photoPath);
    final thumbnailName = 'thumb_$fileName';
    return path.join(_thumbnailsDirectory!, thumbnailName);
  }

  Future<String> calculateFileHash(String filePath) async {
    try {
      final file = File(filePath);
      final bytes = await file.readAsBytes();
      final digest = sha256.convert(bytes);
      return digest.toString();
    } catch (e) {
      throw Exception('Failed to calculate file hash: $e');
    }
  }

  Future<bool> verifyFileIntegrity(String filePath, String expectedHash) async {
    try {
      final actualHash = await calculateFileHash(filePath);
      return actualHash == expectedHash;
    } catch (e) {
      return false;
    }
  }

  Future<StorageInfo> getStorageInfo() async {
    await _ensureDirectoriesExist();

    int totalSize = 0;
    int photoCount = 0;
    int thumbnailCount = 0;

    final photosDir = Directory(_photosDirectory!);
    if (await photosDir.exists()) {
      final photos = photosDir.listSync(recursive: false);
      for (final file in photos) {
        if (file is File) {
          final stat = await file.stat();
          totalSize += stat.size;
          photoCount++;
        }
      }
    }

    final thumbnailsDir = Directory(_thumbnailsDirectory!);
    if (await thumbnailsDir.exists()) {
      final thumbnails = thumbnailsDir.listSync(recursive: false);
      for (final file in thumbnails) {
        if (file is File) {
          final stat = await file.stat();
          totalSize += stat.size;
          thumbnailCount++;
        }
      }
    }

    final availableSpace = await _getAvailableSpace();

    return StorageInfo(
      totalSizeBytes: totalSize,
      photoCount: photoCount,
      thumbnailCount: thumbnailCount,
      availableSpaceBytes: availableSpace,
    );
  }

  Future<int> _getAvailableSpace() async {
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        final tempDir = await getTemporaryDirectory();
        final stat = await tempDir.stat();
        return stat.size;
      } else {
        return 1000000000;
      }
    } catch (e) {
      return 0;
    }
  }

  Future<void> cleanupOrphanedFiles() async {
    await _ensureDirectoriesExist();

    final photosDir = Directory(_photosDirectory!);
    if (!await photosDir.exists()) return;

    final db = await _storageService.database;
    final photoRecords = await db.query('photos', columns: ['file_name']);
    final validFiles = photoRecords.map((p) => p['file_name'] as String).toSet();

    final files = photosDir.listSync(recursive: false);
    for (final file in files) {
      if (file is File) {
        final filePath = file.path;
        if (!validFiles.contains(filePath)) {
          print('Deleting orphaned file: $filePath');
          await file.delete();

          final thumbnailPath = _getThumbnailPath(filePath);
          final thumbnailFile = File(thumbnailPath);
          if (await thumbnailFile.exists()) {
            await thumbnailFile.delete();
          }
        }
      }
    }
  }

  Future<void> cleanupTempFiles() async {
    await _ensureDirectoriesExist();

    final tempDir = Directory(_tempDirectory!);
    if (!await tempDir.exists()) return;

    final now = DateTime.now();
    final files = tempDir.listSync(recursive: false);

    for (final file in files) {
      if (file is File) {
        final stat = await file.stat();
        final age = now.difference(stat.modified);
        if (age.inHours > 24) {
          print('Deleting old temp file: ${file.path}');
          await file.delete();
        }
      }
    }
  }

  Future<String> copyPhotoToTemp(String sourcePath) async {
    await _ensureDirectoriesExist();

    final sourceFile = File(sourcePath);
    if (!await sourceFile.exists()) {
      throw Exception('Source file does not exist');
    }

    final fileName = path.basename(sourcePath);
    final tempPath = path.join(_tempDirectory!, fileName);

    await sourceFile.copy(tempPath);
    return tempPath;
  }

  Future<void> movePhotoFromTemp(String tempPath, String destinationPath) async {
    final tempFile = File(tempPath);
    if (!await tempFile.exists()) {
      throw Exception('Temp file does not exist');
    }

    final destFile = File(destinationPath);
    final destDir = destFile.parent;
    if (!await destDir.exists()) {
      await destDir.create(recursive: true);
    }

    await tempFile.rename(destinationPath);
  }

  Future<bool> hasEnoughSpace({int requiredMegabytes = 100}) async {
    final info = await getStorageInfo();
    final requiredBytes = requiredMegabytes * 1024 * 1024;
    return info.availableSpaceBytes > requiredBytes;
  }

  Future<void> _ensureDirectoriesExist() async {
    if (_photosDirectory == null) {
      await initialize();
    }
  }

  Future<List<String>> getPhotoFilePaths() async {
    await _ensureDirectoriesExist();

    final photosDir = Directory(_photosDirectory!);
    if (!await photosDir.exists()) return [];

    final files = photosDir.listSync(recursive: false);
    return files
        .whereType<File>()
        .map((f) => f.path)
        .where((p) => p.endsWith('.jpg') || p.endsWith('.jpeg') || p.endsWith('.png'))
        .toList();
  }

  String get photosDirectory => _photosDirectory ?? '';
  String get thumbnailsDirectory => _thumbnailsDirectory ?? '';
  String get tempDirectory => _tempDirectory ?? '';
}

class StorageInfo {
  final int totalSizeBytes;
  final int photoCount;
  final int thumbnailCount;
  final int availableSpaceBytes;

  StorageInfo({
    required this.totalSizeBytes,
    required this.photoCount,
    required this.thumbnailCount,
    required this.availableSpaceBytes,
  });

  String get totalSizeFormatted {
    if (totalSizeBytes < 1024) return '$totalSizeBytes B';
    if (totalSizeBytes < 1024 * 1024) return '${(totalSizeBytes / 1024).toStringAsFixed(1)} KB';
    if (totalSizeBytes < 1024 * 1024 * 1024) return '${(totalSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(totalSizeBytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  String get availableSpaceFormatted {
    if (availableSpaceBytes < 1024 * 1024 * 1024) {
      return '${(availableSpaceBytes / (1024 * 1024)).toStringAsFixed(0)} MB';
    }
    return '${(availableSpaceBytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  double get usagePercentage {
    if (availableSpaceBytes == 0) return 100.0;
    final totalSpace = totalSizeBytes + availableSpaceBytes;
    return (totalSizeBytes / totalSpace) * 100;
  }
}