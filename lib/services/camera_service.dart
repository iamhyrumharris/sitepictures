import 'dart:io';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import 'package:crypto/crypto.dart';
import 'package:geolocator/geolocator.dart';
import '../models/photo.dart';
import '../models/sync_package.dart';
import 'database/database_helper.dart';

class CameraService {
  static final CameraService _instance = CameraService._internal();
  factory CameraService() => _instance;
  CameraService._internal();

  List<CameraDescription>? _cameras;
  CameraController? _controller;
  final _uuid = const Uuid();
  final _dbHelper = DatabaseHelper.instance;

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
    String? revisionId,
    String? notes,
  }) async {
    if (_controller == null || !_controller!.value.isInitialized) {
      throw Exception('Camera not initialized');
    }

    // Capture the photo
    final XFile image = await _controller!.takePicture();

    // Get GPS location
    Position? position;
    try {
      if (await Geolocator.isLocationServiceEnabled()) {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 5),
        );
      }
    } catch (e) {
      // GPS failed, continue without location
      // GPS error: $e - logged silently
    }

    // Generate unique filename
    final fileName = '${_uuid.v4()}.jpg';

    // Get app directory for photos
    final appDir = await getApplicationDocumentsDirectory();
    final photosDir = Directory(path.join(appDir.path, 'photos'));
    if (!await photosDir.exists()) {
      await photosDir.create(recursive: true);
    }

    // Save photo to app directory
    final savedPath = path.join(photosDir.path, fileName);
    await image.saveTo(savedPath);

    // Calculate file hash
    final bytes = await File(savedPath).readAsBytes();
    final digest = sha256.convert(bytes);
    final fileHash = digest.toString();

    // Get device ID (stored in preferences or generated on first run)
    final deviceId = await _getDeviceId();

    // Create Photo model
    final photo = Photo(
      equipmentId: equipmentId,
      revisionId: revisionId,
      fileName: fileName,
      fileHash: fileHash,
      latitude: position?.latitude,
      longitude: position?.longitude,
      capturedAt: DateTime.now(),
      notes: notes,
      deviceId: deviceId,
      isSynced: false,
    );

    // Validate before saving
    if (!photo.isValid()) {
      throw Exception('Invalid photo data');
    }

    // Save to database
    await _dbHelper.insertPhoto(photo.toMap());

    // Create sync package for offline sync
    final syncPackage = SyncPackage(
      entityType: EntityType.photo,
      entityId: photo.id,
      operation: Operation.create,
      data: photo.toMap(),
      timestamp: DateTime.now(),
      deviceId: deviceId,
    );

    await _dbHelper.insertSyncPackage(syncPackage.toMap());

    // Add to search index if notes exist
    if (notes != null && notes.isNotEmpty) {
      await _dbHelper.addToSearchIndex('Photo', photo.id, notes);
    }

    return photo;
  }

  Future<String> _getDeviceId() async {
    // In production, this would be stored in secure storage
    // and generated once on first app launch
    return 'device-${_uuid.v4()}';
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

  // Check storage space
  Future<bool> hasStorageSpace({int requiredMB = 100}) async {
    // Implementation would check available storage
    // For now, return true
    return true;
  }
}