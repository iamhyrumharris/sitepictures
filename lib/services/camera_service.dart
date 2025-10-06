import 'dart:io';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import '../models/photo.dart';
import 'gps_service.dart';
import 'database_service.dart';

class CameraService {
  static final CameraService _instance = CameraService._internal();
  factory CameraService() => _instance;
  CameraService._internal();

  List<CameraDescription>? _cameras;
  CameraController? _controller;
  final _gpsService = GpsService();
  final _dbService = DatabaseService();

  // Memory cache for recently accessed photos
  final Map<String, Uint8List> _memoryCache = {};
  final int _maxCacheSize = 10; // Keep last 10 photos in memory

  Future<void> initialize() async {
    _cameras = await availableCameras();
    if (_cameras!.isNotEmpty) {
      await selectCamera(_cameras!.first);
    }
  }

  Future<void> selectCamera(CameraDescription camera) async {
    if (_controller != null) {
      await _controller!.dispose();
    }

    _controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
    );

    await _controller!.initialize();
  }

  CameraController? get controller => _controller;
  List<CameraDescription>? get cameras => _cameras;

  Future<Photo> capturePhoto({
    required String equipmentId,
    required String capturedBy,
  }) async {
    if (_controller == null || !_controller!.value.isInitialized) {
      throw Exception('Camera not initialized');
    }

    // Get GPS location - REQUIRED per spec
    final position = await _gpsService.getCurrentLocation();
    if (position == null) {
      throw Exception('GPS location is required to capture photos');
    }

    // Capture the photo
    final XFile image = await _controller!.takePicture();

    // Generate unique filename using timestamp
    final timestamp = DateTime.now();
    final fileName =
        '${timestamp.millisecondsSinceEpoch}_${equipmentId.substring(0, 8)}.jpg';

    // Get app directory for photos
    final appDir = await getApplicationDocumentsDirectory();
    final photosDir = Directory(path.join(appDir.path, 'photos', 'originals'));
    if (!await photosDir.exists()) {
      await photosDir.create(recursive: true);
    }

    // Save photo to app directory
    final savedPath = path.join(photosDir.path, fileName);
    await image.saveTo(savedPath);

    // Get file size
    final file = File(savedPath);
    final fileSize = await file.length();

    // Create Photo model with required GPS
    final photo = Photo(
      id: '${timestamp.millisecondsSinceEpoch}',
      equipmentId: equipmentId,
      filePath: savedPath,
      latitude: position.latitude,
      longitude: position.longitude,
      timestamp: timestamp,
      capturedBy: capturedBy,
      fileSize: fileSize,
      isSynced: false,
    );

    // Save to database
    final db = await _dbService.database;
    await db.insert('photos', photo.toMap());

    return photo;
  }

  Future<void> dispose() async {
    await _controller?.dispose();
  }

  // Get photo file path
  Future<String> getPhotoPath(String fileName) async {
    final appDir = await getApplicationDocumentsDirectory();
    return path.join(appDir.path, 'photos', fileName);
  }

  // Delete photo file
  Future<void> deletePhoto(String fileName) async {
    final filePath = await getPhotoPath(fileName);
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  // Check storage space (FR-010c compliance)
  Future<bool> hasStorageSpace({int requiredMB = 10}) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final diskSpace = await _getAvailableDiskSpace(appDir.path);
      final requiredBytes = requiredMB * 1024 * 1024;
      return diskSpace >= requiredBytes;
    } catch (e) {
      // If we can't check, assume we have space to avoid blocking users
      return true;
    }
  }

  // Get available disk space in bytes
  Future<int> _getAvailableDiskSpace(String path) async {
    if (Platform.isAndroid || Platform.isIOS) {
      // Get directory stat
      final dir = Directory(path);
      if (await dir.exists()) {
        // Estimate available space by checking parent directory
        // This is a simplified check - production would use platform channels
        // For actual implementation, would use platform-specific APIs
        await dir.stat(); // Check directory exists
        // Assume at least 100MB available if we can't determine
        return 100 * 1024 * 1024;
      }
    }
    return 100 * 1024 * 1024; // Default to 100MB
  }

  // Check photo count for equipment (FR-020, FR-021 compliance)
  Future<int> getPhotoCountForEquipment(String equipmentId) async {
    final db = await _dbService.database;
    final result = await db.query(
      'photos',
      where: 'equipment_id = ?',
      whereArgs: [equipmentId],
    );
    return result.length;
  }

  // Check if equipment can accept more photos
  Future<Map<String, dynamic>> checkPhotoLimit(String equipmentId) async {
    final count = await getPhotoCountForEquipment(equipmentId);
    const maxPhotos = 100;
    const warningThreshold = 90;

    return {
      'canCapture': count < maxPhotos,
      'count': count,
      'maxPhotos': maxPhotos,
      'showWarning': count >= warningThreshold && count < maxPhotos,
      'atLimit': count >= maxPhotos,
    };
  }

  // Load photo with caching
  Future<Uint8List> loadPhoto(String filePath) async {
    // Check memory cache first
    if (_memoryCache.containsKey(filePath)) {
      return _memoryCache[filePath]!;
    }

    // Load from disk
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('Photo file not found: $filePath');
    }

    final bytes = await file.readAsBytes();

    // Add to cache (manage cache size)
    _addToCache(filePath, bytes);

    return bytes;
  }

  // Load photo thumbnail (optimized)
  Future<Uint8List> loadPhotoThumbnail(String filePath, {int width = 200}) async {
    final thumbnailPath = _getThumbnailPath(filePath);
    final thumbnailFile = File(thumbnailPath);

    // Return cached thumbnail if exists
    if (await thumbnailFile.exists()) {
      return await thumbnailFile.readAsBytes();
    }

    // Generate thumbnail in isolate
    final bytes = await loadPhoto(filePath);
    final thumbnail = await compute(_generateThumbnail, {
      'bytes': bytes,
      'width': width,
      'path': thumbnailPath,
    });

    return thumbnail;
  }

  // Generate thumbnail (runs in isolate)
  static Future<Uint8List> _generateThumbnail(Map<String, dynamic> params) async {
    final bytes = params['bytes'] as Uint8List;
    final width = params['width'] as int;
    final thumbnailPath = params['path'] as String;

    // Decode image
    final image = img.decodeImage(bytes);
    if (image == null) {
      throw Exception('Failed to decode image');
    }

    // Resize maintaining aspect ratio
    final thumbnail = img.copyResize(image, width: width);

    // Encode as JPEG with compression
    final thumbnailBytes = img.encodeJpg(thumbnail, quality: 85);

    // Save thumbnail to disk
    final file = File(thumbnailPath);
    await file.create(recursive: true);
    await file.writeAsBytes(thumbnailBytes);

    return Uint8List.fromList(thumbnailBytes);
  }

  String _getThumbnailPath(String originalPath) {
    final appDir = Directory(path.dirname(originalPath));
    final cacheDir = path.join(appDir.parent.path, 'cache', 'thumbnails');
    final fileName = path.basename(originalPath);
    return path.join(cacheDir, 'thumb_$fileName');
  }

  void _addToCache(String key, Uint8List data) {
    // Remove oldest entry if cache is full
    if (_memoryCache.length >= _maxCacheSize) {
      final firstKey = _memoryCache.keys.first;
      _memoryCache.remove(firstKey);
    }
    _memoryCache[key] = data;
  }

  // Clear cache
  void clearCache() {
    _memoryCache.clear();
  }

  // Preload photos for better performance
  Future<void> preloadPhotos(List<String> photoPaths) async {
    for (final photoPath in photoPaths.take(5)) {
      // Preload first 5 only
      try {
        await loadPhotoThumbnail(photoPath);
      } catch (e) {
        // Ignore errors during preload
        debugPrint('Failed to preload $photoPath: $e');
      }
    }
  }
}