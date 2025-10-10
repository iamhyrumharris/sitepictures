import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../services/camera_service.dart';
import '../../providers/auth_state.dart';

/// Camera screen for photo capture
/// Implements FR-007, FR-008, FR-019
class CameraScreen extends StatefulWidget {
  final String equipmentId;

  const CameraScreen({Key? key, required this.equipmentId}) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _cameraController;
  List<String> _capturedPhotoPaths = [];
  bool _isInitializing = true;
  bool _isCapturing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameraService = CameraService();
      await cameraService.initialize();

      if (!mounted) return;

      setState(() {
        _cameraController = cameraService.controller;
        _isInitializing = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isInitializing = false;
      });
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Capture Photo'),
        backgroundColor: Colors.black,
        actions: [
          if (_capturedPhotoPaths.isNotEmpty)
            TextButton(
              onPressed: _viewCarousel,
              child: Text(
                'View (${_capturedPhotoPaths.length})',
                style: const TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: _buildControls(),
    );
  }

  Widget _buildBody() {
    if (_isInitializing) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Camera Error',
                style: const TextStyle(color: Colors.white, fontSize: 20),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                style: const TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _error = null;
                    _isInitializing = true;
                  });
                  _initializeCamera();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        CameraPreview(_cameraController!),
        if (_isCapturing)
          Container(
            color: Colors.white.withOpacity(0.3),
            child: const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          ),
      ],
    );
  }

  Widget _buildControls() {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Gallery button
          IconButton(
            onPressed: _capturedPhotoPaths.isEmpty ? null : _viewCarousel,
            icon: Icon(
              Icons.photo_library,
              color: _capturedPhotoPaths.isEmpty ? Colors.grey : Colors.white,
              size: 32,
            ),
            tooltip: 'View captured photos',
          ),
          // Capture button
          GestureDetector(
            onTap: _isCapturing ? null : _capturePhoto,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
                color: _isCapturing ? Colors.grey : Colors.transparent,
              ),
              child: _isCapturing
                  ? const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    )
                  : const Icon(Icons.camera, color: Colors.white, size: 36),
            ),
          ),
          // Done button
          IconButton(
            onPressed: _capturedPhotoPaths.isEmpty ? null : _finishCapture,
            icon: Icon(
              Icons.check,
              color: _capturedPhotoPaths.isEmpty ? Colors.grey : Colors.green,
              size: 32,
            ),
            tooltip: 'Finish and save',
          ),
        ],
      ),
    );
  }

  Future<void> _capturePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    setState(() => _isCapturing = true);

    try {
      final cameraService = CameraService();

      // FR-010c: Check storage space before capture
      final hasStorage = await cameraService.hasStorageSpace(requiredMB: 10);
      if (!hasStorage) {
        if (!mounted) return;
        setState(() => _isCapturing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Storage Full - Free up space to continue'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }

      // FR-020, FR-021: Check photo limit before capture
      final limitCheck = await cameraService.checkPhotoLimit(
        widget.equipmentId,
      );

      if (limitCheck['atLimit'] == true) {
        if (!mounted) return;
        setState(() => _isCapturing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo limit reached for this equipment'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }

      if (limitCheck['showWarning'] == true) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Warning: ${limitCheck['count']}/100 photos. Approaching limit.',
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 2),
          ),
        );
      }

      final authState = context.read<AuthState>();
      final currentUserId = authState.currentUser?.id ?? 'unknown';

      // Capture photo - service handles GPS internally
      final photo = await cameraService.capturePhoto(
        equipmentId: widget.equipmentId,
        capturedBy: currentUserId,
      );

      if (!mounted) return;

      setState(() {
        _capturedPhotoPaths.add(photo.filePath);
        _isCapturing = false;
      });

      // Show success feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Photo captured (${_capturedPhotoPaths.length})'),
          duration: const Duration(seconds: 1),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() => _isCapturing = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _viewCarousel() {
    context.push(
      '/carousel',
      extra: {
        'photos': _capturedPhotoPaths,
        'initialIndex': 0,
        'equipmentId': widget.equipmentId,
      },
    );
  }

  Future<void> _quickSave(int index) async {
    // Individual photo save logic
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Photo saved')));
  }

  void _finishCapture() {
    if (_capturedPhotoPaths.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save Photos'),
        content: Text(
          'Save ${_capturedPhotoPaths.length} photo(s) to equipment?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Return to equipment screen
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${_capturedPhotoPaths.length} photos saved'),
                ),
              );
            },
            child: const Text('Save All'),
          ),
        ],
      ),
    );
  }
}
