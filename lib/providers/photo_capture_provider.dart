import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../models/photo_session.dart';
import '../services/camera_service.dart';
import '../services/photo_storage_service.dart';

/// Camera status enum
enum CameraStatus {
  uninitialized, // Camera controller not yet created
  initializing, // Camera initialization in progress
  ready, // Camera ready for preview and capture
  permissionDenied, // User denied camera permission (FR-022)
  error, // Camera hardware or initialization error (FR-024)
}

/// Provider for managing photo capture session state
class PhotoCaptureProvider extends ChangeNotifier {
  final CameraService _cameraService = CameraService();
  final PhotoStorageService _storageService = PhotoStorageService();
  final _uuid = const Uuid();

  PhotoSession _session = PhotoSession(id: const Uuid().v4());
  CameraStatus _cameraStatus = CameraStatus.uninitialized;
  String? _errorMessage;
  bool _isInitializing = false;

  /// Current photo session
  PhotoSession get session => _session;

  /// Camera status
  CameraStatus get cameraStatus => _cameraStatus;

  /// Error message (if any)
  String? get errorMessage => _errorMessage;

  /// Is initializing
  bool get isInitializing => _isInitializing;

  /// Can capture photo (camera ready and not at limit)
  bool get canCapture =>
      _cameraStatus == CameraStatus.ready && !_session.isAtLimit;

  /// Has any photos
  bool get hasPhotos => _session.hasPhotos;

  /// Photo count
  int get photoCount => _session.photoCount;

  /// Is at 20 photo limit
  bool get isAtLimit => _session.isAtLimit;

  /// Get camera controller for preview
  get controller => _cameraService.controller;

  /// Initialize camera (FR-001, FR-021)
  Future<void> initializeCamera() async {
    _isInitializing = true;
    _cameraStatus = CameraStatus.initializing;
    notifyListeners();

    try {
      // Request camera permissions
      var status = await Permission.camera.status;

      // If permission not granted, request it
      if (!status.isGranted) {
        // Check if permanently denied (need to go to settings)
        if (status.isPermanentlyDenied) {
          _cameraStatus = CameraStatus.permissionDenied;
          _errorMessage =
              'Camera permission denied. Please enable in settings.';
          _isInitializing = false;
          notifyListeners();
          return;
        }

        // Request permission
        status = await Permission.camera.request();

        // Check result
        if (!status.isGranted) {
          _cameraStatus = CameraStatus.permissionDenied;
          _errorMessage = 'Camera permission required to capture photos';
          _isInitializing = false;
          notifyListeners();
          return;
        }
      }

      // Initialize camera
      await _cameraService.initialize();

      _cameraStatus = CameraStatus.ready;
      _errorMessage = null;
    } catch (e) {
      _cameraStatus = CameraStatus.error;
      _errorMessage = 'Camera initialization failed: ${e.toString()}';
    } finally {
      _isInitializing = false;
      notifyListeners();
    }
  }

  /// Capture photo (FR-005, FR-007, FR-008)
  Future<void> capturePhoto() async {
    if (!canCapture) return;

    try {
      // Take picture using existing camera service
      if (_cameraService.controller == null ||
          !_cameraService.controller!.value.isInitialized) {
        throw Exception('Camera not ready');
      }

      final xFile = await _cameraService.controller!.takePicture();

      // Save to temp storage
      final tempPhoto = await _storageService.saveTempPhoto(
        xFile,
        _session.photoCount,
      );

      // Add to session
      _session.addPhoto(tempPhoto);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Photo capture failed: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Delete photo (FR-010)
  Future<void> deletePhoto(String photoId) async {
    final photo = _session.photos.firstWhere((p) => p.id == photoId);
    await _storageService.deleteTempPhoto(photo.filePath);
    _session.removePhoto(photoId);
    notifyListeners();
  }

  /// Complete session (FR-013, FR-014, FR-015)
  void completeSession() {
    _session.complete();
    notifyListeners();
  }

  /// Cancel session (FR-018, FR-020)
  Future<void> cancelSession() async {
    await _storageService.clearSessionPhotos(_session.photos);
    _session.cancel();
    notifyListeners();
  }

  /// Save session state to SharedPreferences (FR-029)
  Future<void> saveSessionState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionJson = jsonEncode(_session.toJson());
      await prefs.setString('active_camera_session', sessionJson);
    } catch (e) {
      debugPrint('Failed to save session state: $e');
    }
  }

  /// Restore session state from SharedPreferences (FR-030)
  Future<void> restoreSessionState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionJson = prefs.getString('active_camera_session');

      if (sessionJson != null) {
        final sessionData = jsonDecode(sessionJson);
        _session = PhotoSession.fromJson(sessionData);

        // Regenerate thumbnails for restored photos
        for (int i = 0; i < _session.photos.length; i++) {
          final photo = _session.photos[i];
          if (photo.thumbnailData == null) {
            final thumbnail = await _storageService.regenerateThumbnail(
              photo.filePath,
            );
            _session.photos[i] = photo.copyWith(thumbnailData: thumbnail);
          }
        }

        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to restore session state: $e');
    }
  }

  /// Dispose camera resources
  Future<void> disposeCamera() async {
    await _cameraService.dispose();
  }

  /// Reset to new session
  void resetSession() {
    _session = PhotoSession(id: _uuid.v4());
    _errorMessage = null;
    notifyListeners();
  }
}
