import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import '../providers/photo_capture_provider.dart';
import '../providers/equipment_navigator_provider.dart';
import '../widgets/camera_preview_overlay.dart';
import '../widgets/photo_thumbnail_strip.dart';
import '../widgets/capture_button.dart';
import '../widgets/context_aware_save_buttons.dart';
import '../widgets/save_progress_indicator.dart';
import '../models/folder_photo.dart';
import '../models/camera_context.dart';
import '../models/equipment.dart';
import '../services/folder_service.dart';
import '../services/quick_save_service.dart';
import '../services/photo_save_service.dart';
import '../services/database_service.dart';
import '../services/photo_storage_service.dart';
import '../screens/equipment_navigator_page.dart';

/// Main camera capture screen for work site photo documentation
/// Supports context-aware save button display based on launch context
class CameraCapturePage extends StatefulWidget {
  final CameraContext cameraContext;

  const CameraCapturePage({Key? key, required this.cameraContext})
    : super(key: key);

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

    // Initialize camera and set context
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _provider?.setCameraContext(widget.cameraContext);
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
          'You have ${provider.photoCount} unsaved photo(s). Discard them?',
        ),
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

    // Render context-aware save buttons based on camera context
    await showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
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
            ContextAwareSaveButtons(
              cameraContext: widget.cameraContext,
              onNext: () => _handleNext(context),
              onQuickSave: () => _handleQuickSave(context),
              onEquipmentSave: () => _handleEquipmentSave(context),
              onBeforeSave: () => _handleBeforeSave(context),
              onAfterSave: () => _handleAfterSave(context),
            ),
          ],
        ),
      ),
    );
  }

  /// T022-T023: Home context - Next button handler with equipment navigator
  Future<void> _handleNext(BuildContext context) async {
    final provider = Provider.of<PhotoCaptureProvider>(context, listen: false);

    // Validate that we have photos
    if (!provider.hasPhotos) {
      return;
    }

    // Close modal
    Navigator.of(context).pop();

    // Open equipment navigator in a separate provider context
    if (!mounted) return;
    final equipment = await Navigator.of(context).push<Equipment>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => ChangeNotifierProvider(
          create: (_) => EquipmentNavigatorProvider(),
          child: const EquipmentNavigatorPage(),
        ),
      ),
    );

    // If user cancelled navigation, preserve session
    if (equipment == null) {
      return;
    }

    // Initialize services for save
    final photoSaveService = PhotoSaveService(
      databaseService: DatabaseService(),
      storageService: PhotoStorageService(),
    );

    // Show loading dialog with progress indicator
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => SaveProgressDialog(
        progressStream: photoSaveService.progressStream,
        title: 'Saving to ${equipment.name}',
      ),
    );

    try {
      // Save photos to selected equipment
      final result = await photoSaveService.saveToEquipment(
        photos: provider.session.photos,
        equipment: equipment,
      );

      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      // Show result message
      if (!mounted) return;
      if (result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.getUserMessage()),
            backgroundColor: Colors.green,
          ),
        );

        // Complete session and return to home
        provider.completeSession();
        if (mounted) Navigator.of(context).pop();
      } else if (result.successfulCount > 0) {
        // Partial save
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.getUserMessage()),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 4),
          ),
        );

        provider.completeSession();
        if (mounted) Navigator.of(context).pop();
      } else {
        // Critical failure
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.error ?? 'Save failed'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );

        if (!result.sessionPreserved) {
          provider.completeSession();
          if (mounted) Navigator.of(context).pop();
        }
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      // Show error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Save failed: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      photoSaveService.dispose();
    }
  }

  /// T014-T015: Home context - Quick Save button handler
  Future<void> _handleQuickSave(BuildContext context) async {
    final provider = Provider.of<PhotoCaptureProvider>(context, listen: false);

    // Validate that we have photos
    if (!provider.hasPhotos) {
      return;
    }

    // Close modal
    Navigator.of(context).pop();

    // Initialize Quick Save service
    final quickSaveService = QuickSaveService(
      databaseService: DatabaseService(),
      storageService: PhotoStorageService(),
    );

    // Show loading dialog
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      ),
    );

    try {
      // Execute Quick Save
      final result = await quickSaveService.quickSave(provider.session.photos);

      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      // Show result message
      if (!mounted) return;
      if (result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.getUserMessage()),
            backgroundColor: Colors.green,
          ),
        );

        // Complete session and return to home
        provider.completeSession();
        if (mounted) Navigator.of(context).pop();
      } else if (result.successfulCount > 0) {
        // Partial save
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.getUserMessage()),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 4),
          ),
        );

        provider.completeSession();
        if (mounted) Navigator.of(context).pop();
      } else {
        // Critical failure with session preserved
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.error ?? 'Save failed'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );

        if (!result.sessionPreserved) {
          provider.completeSession();
          if (mounted) Navigator.of(context).pop();
        }
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      // Show error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Quick Save failed: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  /// T011: Equipment all photos context - Mock save handler
  void _handleEquipmentSave(BuildContext context) {
    // Close modal
    Navigator.of(context).pop();

    // Show placeholder message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Equipment photo save coming soon!\n'
          'Photos captured in this session will be available in the gallery.',
        ),
        duration: Duration(seconds: 3),
        backgroundColor: Colors.blue,
      ),
    );

    // Return to previous screen
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  /// T012: Equipment before context - Mock save handler
  void _handleBeforeSave(BuildContext context) {
    // Close modal
    Navigator.of(context).pop();

    // Show placeholder message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Before/After categorization coming soon!'),
        duration: Duration(seconds: 3),
        backgroundColor: Colors.orange,
      ),
    );

    // Return to previous screen
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  /// T013: Equipment after context - Mock save handler
  void _handleAfterSave(BuildContext context) {
    // Close modal
    Navigator.of(context).pop();

    // Show placeholder message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Before/After categorization coming soon!'),
        duration: Duration(seconds: 3),
        backgroundColor: Colors.green,
      ),
    );

    // Return to previous screen
    if (mounted) {
      Navigator.of(context).pop();
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
              Positioned.fill(child: CameraPreview(controller)),

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
