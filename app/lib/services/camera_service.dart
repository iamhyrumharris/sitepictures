import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import 'package:crypto/crypto.dart';
import 'package:geolocator/geolocator.dart';
import 'package:exif/exif.dart';
import 'package:flutter/foundation.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../models/photo.dart';
import 'storage_service.dart';
import 'file_service.dart';
import 'gps_service.dart';

/// Camera service with metadata extraction and GPS integration
/// Handles photo capture with full resolution, GPS metadata, and quick capture mode
class CameraService {
  static final CameraService _instance = CameraService._internal();
  factory CameraService() => _instance;
  CameraService._internal();

  List<CameraDescription>? _cameras;
  CameraController? _controller;
  final _uuid = const Uuid();
  String? _deviceId;

  // Services
  final _storageService = StorageService();
  final _fileService = FileService();
  final _gpsService = GPSService();

  // Performance tracking for quick capture mode
  final Stopwatch _captureStopwatch = Stopwatch();

  /// Initialize camera service and available cameras
  Future<void> initialize() async {
    try {
      _cameras = await availableCameras();
      if (_cameras!.isNotEmpty) {
        await selectCamera(_cameras!.first);
      }

      // Initialize device ID
      await _initializeDeviceId();

      debugPrint('CameraService initialized with ${_cameras?.length ?? 0} cameras');
    } catch (e) {
      debugPrint('CameraService initialization failed: $e');
      rethrow;
    }
  }

  /// Select and configure camera
  Future<void> selectCamera(CameraDescription camera) async {
    if (_controller != null) {
      await _controller!.dispose();
    }

    _controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    await _controller!.initialize();
    debugPrint('Camera selected: ${camera.name}');
  }

  /// Get available cameras
  List<CameraDescription>? get cameras => _cameras;

  /// Get current camera controller
  CameraController? get controller => _controller;

  /// Check if camera is ready for capture
  bool get isReady => _controller != null && _controller!.value.isInitialized;

  /// Capture photo with full metadata extraction
  /// Optimized for <2 seconds capture time in quick mode
  Future<Photo> capturePhoto({
    required String equipmentId,
    String? revisionId,
    String? notes,
    bool quickMode = true,
  }) async {
    if (!isReady) {
      throw Exception('Camera not initialized');
    }

    _captureStopwatch.reset();
    _captureStopwatch.start();

    try {
      // Capture the photo
      final XFile image = await _controller!.takePicture();
      final captureTime = DateTime.now();

      debugPrint('Photo captured in ${_captureStopwatch.elapsedMilliseconds}ms');

      // Generate unique filename
      final fileName = '${_uuid.v4()}.jpg';

      // Get GPS location (with timeout for quick mode)
      Position? position;
      if (quickMode) {
        position = await _gpsService.getCurrentLocationQuick();
      } else {
        position = await _gpsService.getCurrentLocation();
      }

      // Read image bytes for hash calculation
      final imageBytes = await image.readAsBytes();

      // Calculate SHA-256 hash
      final digest = sha256.convert(imageBytes);
      final fileHash = digest.toString();

      // Save photo file
      final savedPath = await _fileService.savePhoto(imageBytes, fileName);

      // Extract EXIF metadata if not in quick mode
      Map<String, IfdTag>? exifData;
      if (!quickMode) {
        try {
          exifData = await readExifFromBytes(imageBytes);
        } catch (e) {
          debugPrint('EXIF extraction failed: $e');
        }
      }

      // Create Photo model
      final photo = Photo(
        equipmentId: equipmentId,
        revisionId: revisionId,
        fileName: fileName,
        fileHash: fileHash,
        latitude: position?.latitude,
        longitude: position?.longitude,
        capturedAt: captureTime,
        notes: notes,
        deviceId: _deviceId!,
        isSynced: false,
      );

      // Validate photo data
      if (!photo.isValid()) {
        await _fileService.deletePhoto(fileName);
        throw Exception('Invalid photo data');
      }

      // Save to database
      await _storageService.insertPhoto(photo);

      _captureStopwatch.stop();
      final totalTime = _captureStopwatch.elapsedMilliseconds;

      debugPrint('Photo capture completed in ${totalTime}ms');

      if (quickMode && totalTime > 2000) {
        debugPrint('Warning: Quick capture exceeded 2s target (${totalTime}ms)');
      }

      return photo;

    } catch (e) {
      _captureStopwatch.stop();
      debugPrint('Photo capture failed: $e');
      rethrow;
    }
  }

  /// Capture photo with automatic equipment assignment based on GPS
  Future<Photo> capturePhotoWithAutoAssignment({
    String? revisionId,
    String? notes,
    bool quickMode = true,
  }) async {
    // Get current location first
    final position = await _gpsService.getCurrentLocation();
    if (position == null) {
      throw Exception('Location required for auto-assignment');
    }

    // Find equipment within GPS boundaries
    final nearbyEquipment = await _gpsService.findEquipmentInBoundary(
      position.latitude,
      position.longitude,
    );

    String equipmentId;
    if (nearbyEquipment.isNotEmpty) {
      // Use the closest equipment
      equipmentId = nearbyEquipment.first.id;
      debugPrint('Auto-assigned to equipment: ${nearbyEquipment.first.name}');
    } else {
      // Use "Needs Assignment" folder
      equipmentId = 'needs-assignment';
      debugPrint('No nearby equipment found, using Needs Assignment folder');
    }

    return capturePhoto(
      equipmentId: equipmentId,
      revisionId: revisionId,
      notes: notes,
      quickMode: quickMode,
    );
  }

  /// Capture multiple photos in burst mode
  Future<List<Photo>> captureBurst({
    required String equipmentId,
    String? revisionId,
    String? notes,
    int count = 3,
    Duration interval = const Duration(milliseconds: 500),
  }) async {
    final photos = <Photo>[];

    for (int i = 0; i < count; i++) {
      if (i > 0) {
        await Future.delayed(interval);
      }

      final photo = await capturePhoto(
        equipmentId: equipmentId,
        revisionId: revisionId,
        notes: notes != null ? '$notes (${i + 1}/$count)' : null,
        quickMode: true,
      );

      photos.add(photo);
    }

    return photos;
  }

  /// Get photo with EXIF metadata
  Future<Map<String, dynamic>?> getPhotoMetadata(String fileName) async {
    try {
      final photoPath = await _fileService.getPhotoPath(fileName);
      final file = File(photoPath);

      if (!await file.exists()) {
        return null;
      }

      final bytes = await file.readAsBytes();
      final exifData = await readExifFromBytes(bytes);

      final metadata = <String, dynamic>{};

      // Extract useful EXIF tags
      if (exifData.containsKey('Image DateTime')) {
        metadata['dateTime'] = exifData['Image DateTime']!.printable;
      }

      if (exifData.containsKey('GPS GPSLatitude') &&
          exifData.containsKey('GPS GPSLongitude')) {
        metadata['gpsLatitude'] = exifData['GPS GPSLatitude']!.printable;
        metadata['gpsLongitude'] = exifData['GPS GPSLongitude']!.printable;
      }

      if (exifData.containsKey('Image Make')) {
        metadata['cameraMake'] = exifData['Image Make']!.printable;
      }

      if (exifData.containsKey('Image Model')) {
        metadata['cameraModel'] = exifData['Image Model']!.printable;
      }

      if (exifData.containsKey('EXIF ExposureTime')) {
        metadata['exposureTime'] = exifData['EXIF ExposureTime']!.printable;
      }

      if (exifData.containsKey('EXIF ISOSpeedRatings')) {
        metadata['iso'] = exifData['EXIF ISOSpeedRatings']!.printable;
      }

      return metadata;

    } catch (e) {
      debugPrint('Failed to read EXIF metadata: $e');
      return null;
    }
  }

  /// Check storage space before capture
  Future<bool> checkStorageSpace({int requiredMB = 100}) async {
    return await _fileService.hasStorageSpace(requiredMB: requiredMB);
  }

  /// Get capture performance statistics
  Map<String, dynamic> getPerformanceStats() {
    return {
      'lastCaptureTime': _captureStopwatch.elapsedMilliseconds,
      'isQuickModeCapable': _captureStopwatch.elapsedMilliseconds < 2000,
      'averageCaptureTime': _captureStopwatch.elapsedMilliseconds, // In real app, track average
    };
  }

  /// Initialize device ID for photo metadata
  Future<void> _initializeDeviceId() async {
    if (_deviceId != null) return;

    try {
      final deviceInfo = DeviceInfoPlugin();

      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        _deviceId = 'android-${androidInfo.id}';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        _deviceId = 'ios-${iosInfo.identifierForVendor}';
      } else {
        _deviceId = 'device-${_uuid.v4()}';
      }

    } catch (e) {
      _deviceId = 'device-${_uuid.v4()}';
      debugPrint('Failed to get device ID, using random: $e');
    }
  }

  /// Dispose camera resources
  Future<void> dispose() async {
    await _controller?.dispose();
    _controller = null;
    debugPrint('CameraService disposed');
  }

  /// Switch between front and back camera
  Future<void> switchCamera() async {
    if (_cameras == null || _cameras!.length < 2) {
      throw Exception('Multiple cameras not available');
    }

    final currentCamera = _controller?.description;
    CameraDescription? newCamera;

    for (final camera in _cameras!) {
      if (camera != currentCamera) {
        newCamera = camera;
        break;
      }
    }

    if (newCamera != null) {
      await selectCamera(newCamera);
    }
  }

  /// Get current camera info
  Map<String, dynamic>? getCameraInfo() {
    if (_controller?.description == null) return null;

    final camera = _controller!.description;
    return {
      'name': camera.name,
      'lensDirection': camera.lensDirection.toString(),
      'sensorOrientation': camera.sensorOrientation,
    };
  }

  /// Enable/disable flash
  Future<void> setFlashMode(FlashMode mode) async {
    if (_controller != null) {
      await _controller!.setFlashMode(mode);
    }
  }
}