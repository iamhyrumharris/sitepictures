import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import '../providers/photo_capture_provider.dart';
import '../widgets/camera_preview_overlay.dart';
import '../widgets/photo_thumbnail_strip.dart';
import '../widgets/capture_button.dart';

/// Main camera capture screen for work site photo documentation
class CameraCapturePage extends StatefulWidget {
  const CameraCapturePage({Key? key}) : super(key: key);

  @override
  State<CameraCapturePage> createState() => _CameraCapturePageState();
}

class _CameraCapturePageState extends State<CameraCapturePage>
    with WidgetsBindingObserver {
  PhotoCaptureProvider? _provider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Initialize camera
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _provider?.initializeCamera();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Save provider reference for safe access in dispose()
    _provider = Provider.of<PhotoCaptureProvider>(context, listen: false);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _provider?.disposeCamera();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_provider == null) return;

    switch (state) {
      case AppLifecycleState.paused:
        // Save session and dispose camera when app backgrounded (FR-029)
        _provider!.saveSessionState();
        _provider!.disposeCamera();
        break;
      case AppLifecycleState.resumed:
        // Restore session and reinitialize camera when app resumed (FR-030)
        _provider!.restoreSessionState();
        _provider!.initializeCamera();
        break;
      default:
        break;
    }
  }

  Future<void> _handleCancel(BuildContext context) async {
    final provider = Provider.of<PhotoCaptureProvider>(context, listen: false);

    // FR-019: No confirmation if no photos
    if (!provider.hasPhotos) {
      if (mounted) Navigator.of(context).pop();
      return;
    }

    // FR-018: Show confirmation if photos exist
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard Photos?'),
        content: Text(
            'You have ${provider.photoCount} unsaved photo(s). Discard them?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Discard'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await provider.cancelSession();
      if (mounted) Navigator.of(context).pop();
    }
  }

  Future<void> _handleDone(BuildContext context) async {
    final provider = Provider.of<PhotoCaptureProvider>(context, listen: false);

    // FR-013: Show modal with Next and Quick Save buttons
    final result = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        height: 200,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Save Photos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            // FR-014: Next button
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop('next'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Next', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 12),
            // FR-015: Quick Save button
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop('quick_save'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Quick Save', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      provider.completeSession();
      // FR-016, FR-017: Placeholder - return photos to caller
      if (mounted) {
        Navigator.of(context).pop(provider.session.photos);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Consumer<PhotoCaptureProvider>(
        builder: (context, provider, child) {
          // Show error state if permission denied or camera error (FR-022, FR-024)
          if (provider.cameraStatus == CameraStatus.permissionDenied ||
              provider.cameraStatus == CameraStatus.error) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      provider.cameraStatus == CameraStatus.permissionDenied
                          ? Icons.camera_alt_outlined
                          : Icons.error_outline,
                      size: 64,
                      color: Colors.white70,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      provider.errorMessage ?? 'Camera unavailable',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    if (provider.cameraStatus == CameraStatus.permissionDenied)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: ElevatedButton(
                          onPressed: () => openAppSettings(),
                          child: const Text('Open Settings'),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }

          // Show loading while initializing
          if (provider.isInitializing ||
              provider.cameraStatus == CameraStatus.uninitialized) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          // Camera ready - show preview (FR-001)
          final controller = provider.controller;
          if (controller == null || !controller.value.isInitialized) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          return Stack(
            children: [
              // FR-006: Camera preview as bottom layer
              Positioned.fill(
                child: CameraPreview(controller),
              ),

              // FR-002, FR-003: Top overlay with Cancel and Done
              CameraPreviewOverlay(
                onCancel: () => _handleCancel(context),
                onDone: () => _handleDone(context),
              ),

              // Bottom controls: thumbnails and capture button
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  color: Colors.black54,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // FR-007: Photo thumbnail strip
                      if (provider.hasPhotos)
                        PhotoThumbnailStrip(
                          photos: provider.session.photos,
                          onDeletePhoto: (photoId) =>
                              provider.deletePhoto(photoId),
                        ),
                      const SizedBox(height: 16),
                      // FR-004, FR-005: Capture button
                      CaptureButton(
                        onPressed: provider.canCapture
                            ? () => provider.capturePhoto()
                            : null,
                        isDisabled: provider.isAtLimit,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
