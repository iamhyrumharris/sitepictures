import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';
import '../services/camera_service.dart';
import '../services/gps_service.dart';
import '../services/storage_service.dart';
import '../models/photo.dart';
import '../models/equipment.dart';

// T050: Camera screen with quick capture
class CameraScreen extends StatefulWidget {
  final Equipment? preSelectedEquipment;

  const CameraScreen({Key? key, this.preSelectedEquipment}) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final CameraService _cameraService = CameraService();
  final GPSService _gpsService = GPSService();
  final StorageService _storageService = StorageService();

  CameraController? _controller;
  bool _isCapturing = false;
  bool _isFlashOn = false;
  Position? _currentPosition;
  Equipment? _selectedEquipment;
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedEquipment = widget.preSelectedEquipment;
    _initializeCamera();
    _getCurrentLocation();
  }

  Future<void> _initializeCamera() async {
    try {
      await _cameraService.initialize();
      _controller = _cameraService.controller;
      setState(() {});
    } catch (e) {
      _showError('Failed to initialize camera: $e');
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await _gpsService.getCurrentPosition();
      setState(() {
        _currentPosition = position;
      });
    } catch (e) {
      // GPS not available, continue without location
      debugPrint('GPS not available: $e');
    }
  }

  Future<void> _capturePhoto() async {
    if (_controller == null || !_controller!.value.isInitialized || _isCapturing) {
      return;
    }

    setState(() {
      _isCapturing = true;
    });

    final captureStartTime = DateTime.now();

    try {
      // Capture photo with metadata
      final photoData = await _cameraService.capturePhotoWithMetadata(
        equipment: _selectedEquipment,
        position: _currentPosition,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );

      // Save to local storage
      await _storageService.savePhoto(photoData);

      // Calculate capture time
      final captureTime = DateTime.now().difference(captureStartTime);

      // Ensure capture completes in <2 seconds (constitutional requirement)
      if (captureTime.inMilliseconds > 2000) {
        debugPrint('Warning: Photo capture took ${captureTime.inMilliseconds}ms');
      }

      // Show success feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_selectedEquipment != null
                ? 'Photo saved to ${_selectedEquipment!.name}'
                : 'Photo saved to "Needs Assignment"'),
            duration: const Duration(seconds: 2),
            action: SnackBarAction(
              label: 'View',
              onPressed: () => _navigateToGallery(photoData),
            ),
          ),
        );

        // Clear notes after capture
        _notesController.clear();
      }

    } catch (e) {
      _showError('Failed to capture photo: $e');
    } finally {
      setState(() {
        _isCapturing = false;
      });
    }
  }

  Future<void> _toggleFlash() async {
    if (_controller == null) return;

    try {
      if (_isFlashOn) {
        await _controller!.setFlashMode(FlashMode.off);
      } else {
        await _controller!.setFlashMode(FlashMode.torch);
      }
      setState(() {
        _isFlashOn = !_isFlashOn;
      });
    } catch (e) {
      _showError('Failed to toggle flash: $e');
    }
  }

  void _selectEquipment() async {
    // Navigate to equipment selection screen
    final selected = await Navigator.pushNamed(
      context,
      '/select-equipment',
    ) as Equipment?;

    if (selected != null) {
      setState(() {
        _selectedEquipment = selected;
      });
    }
  }

  void _navigateToGallery(Photo photo) {
    Navigator.pushNamed(
      context,
      '/gallery',
      arguments: {'initialPhoto': photo},
    );
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Camera preview
            if (_controller != null && _controller!.value.isInitialized)
              Positioned.fill(
                child: CameraPreview(_controller!),
              )
            else
              const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),

            // Top controls
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back button
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),

                    // Equipment selection
                    Expanded(
                      child: GestureDetector(
                        onTap: _selectEquipment,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.folder_outlined,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _selectedEquipment?.name ?? 'Needs Assignment',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const Icon(
                                Icons.arrow_drop_down,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Flash toggle
                    IconButton(
                      icon: Icon(
                        _isFlashOn ? Icons.flash_on : Icons.flash_off,
                        color: Colors.white,
                      ),
                      onPressed: _toggleFlash,
                    ),
                  ],
                ),
              ),
            ),

            // Bottom controls
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    // Notes input (collapsible)
                    if (_notesController.text.isNotEmpty || _selectedEquipment != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: TextField(
                          controller: _notesController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Add notes...',
                            hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.1),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          maxLines: 2,
                          textInputAction: TextInputAction.done,
                        ),
                      ),

                    // Capture controls
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Gallery button
                        IconButton(
                          icon: const Icon(
                            Icons.photo_library,
                            color: Colors.white,
                            size: 32,
                          ),
                          onPressed: () => Navigator.pushNamed(context, '/gallery'),
                        ),

                        // Capture button
                        GestureDetector(
                          onTap: _isCapturing ? null : _capturePhoto,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _isCapturing
                                  ? Colors.grey
                                  : Colors.white,
                              border: Border.all(
                                color: Colors.white,
                                width: 4,
                              ),
                            ),
                            child: _isCapturing
                                ? const Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.black,
                                      strokeWidth: 3,
                                    ),
                                  )
                                : null,
                          ),
                        ),

                        // Settings button
                        IconButton(
                          icon: const Icon(
                            Icons.settings,
                            color: Colors.white,
                            size: 32,
                          ),
                          onPressed: () => Navigator.pushNamed(context, '/settings'),
                        ),
                      ],
                    ),

                    // GPS indicator
                    if (_currentPosition != null)
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: Colors.green,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${_currentPosition!.latitude.toStringAsFixed(6)}, '
                              '${_currentPosition!.longitude.toStringAsFixed(6)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    _cameraService.dispose();
    _notesController.dispose();
    super.dispose();
  }
}