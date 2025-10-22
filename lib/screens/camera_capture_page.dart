import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import '../providers/auth_state.dart';
import '../providers/photo_capture_provider.dart';
import '../providers/equipment_navigator_provider.dart';
import '../providers/all_photos_provider.dart';
import '../widgets/camera_preview_overlay.dart';
import '../widgets/photo_thumbnail_strip.dart';
import '../widgets/capture_button.dart';
import '../widgets/context_aware_save_buttons.dart';
import '../widgets/save_progress_indicator.dart';
import '../widgets/create_folder_dialog.dart';
import '../models/folder_photo.dart';
import '../models/photo_folder.dart';
import '../models/camera_context.dart';
import '../models/equipment.dart';
import '../models/save_result.dart';
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
    // Capture outer context before modal to avoid context scope issues
    final outerContext = context;

    // Render context-aware save buttons based on camera context
    await showModalBottomSheet(
      context: context,
      builder: (modalContext) => Container(
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
              onNext: () => _handleNext(outerContext),
              onQuickSave: () => _handleQuickSave(outerContext),
              onEquipmentSave: () => _handleEquipmentSave(outerContext),
              onBeforeSave: () => _handleBeforeSave(outerContext),
              onAfterSave: () => _handleAfterSave(outerContext),
            ),
          ],
        ),
      ),
    );
  }

  /// T022-T023: Home context - Next button handler with equipment navigator
  Future<void> _handleNext(BuildContext context) async {
    if (_provider == null || !_provider!.hasPhotos) {
      return;
    }

    Navigator.of(context).pop();

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

    if (equipment == null) {
      return;
    }

    if (!mounted) return;
    final option = await _showNextSaveOptions(context, equipment);

    if (option == null) {
      return;
    }

    switch (option) {
      case _NextSaveOption.createFolder:
        await _handleCreateNewFolderOption(context, equipment);
        break;
      case _NextSaveOption.existingFolder:
        await _handleAddToExistingFolderOption(context, equipment);
        break;
    }
  }

  Future<void> _handleCreateNewFolderOption(
    BuildContext context,
    Equipment equipment,
  ) async {
    final workOrder = await showDialog<String>(
      context: context,
      builder: (dialogContext) => const CreateFolderDialog(),
    );

    if (workOrder == null || workOrder.trim().isEmpty) {
      return;
    }

    if (!mounted) return;
    final category = await _promptBeforeAfterSelection(
      context: context,
      title: 'Save photos to Before or After?',
      message:
          'Folders support Before and After sections. Choose where these photos belong.',
    );

    if (category == null) {
      return;
    }

    final authState = context.read<AuthState>();
    final currentUser = authState.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No user is signed in. Please sign in and try again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final folderService = FolderService();
    PhotoFolder folder;

    try {
      folder = await folderService.createFolder(
        equipmentId: equipment.id,
        workOrder: workOrder.trim(),
        createdBy: currentUser.id,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create folder: $e'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!mounted) return;
    await _performSaveOperation(
      context: context,
      progressTitle: 'Saving to ${folder.name} '
          '(${category == BeforeAfter.before ? 'Before' : 'After'})',
      saveOperation: (service) => service.saveToFolder(
        photos: _provider!.session.photos,
        folder: folder,
        category: category,
      ),
    );
  }

  Future<void> _handleAddToExistingFolderOption(
    BuildContext context,
    Equipment equipment,
  ) async {
    final folderService = FolderService();
    List<PhotoFolder> folders;

    try {
      folders = await folderService.getFolders(equipment.id);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load folders: $e'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (folders.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No folders available on this equipment yet.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (!mounted) return;
    final folder = await _promptExistingFolderSelection(
      context: context,
      folders: folders,
    );

    if (folder == null) {
      return;
    }

    if (!mounted) return;
    final category = await _promptBeforeAfterSelection(
      context: context,
      title: 'Add photos to Before or After?',
      message: 'Choose the section in ${folder.name} for these photos.',
    );

    if (category == null) {
      return;
    }

    if (!mounted) return;
    await _performSaveOperation(
      context: context,
      progressTitle: 'Saving to ${folder.name} '
          '(${category == BeforeAfter.before ? 'Before' : 'After'})',
      saveOperation: (service) => service.saveToFolder(
        photos: _provider!.session.photos,
        folder: folder,
        category: category,
      ),
    );
  }

  Future<void> _performSaveOperation({
    required BuildContext context,
    required String progressTitle,
    required Future<SaveResult> Function(PhotoSaveService service) saveOperation,
  }) async {
    final photoSaveService = PhotoSaveService(
      databaseService: DatabaseService(),
      storageService: PhotoStorageService(),
      allPhotosProvider: context.read<AllPhotosProvider>(),
    );

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => SaveProgressDialog(
        progressStream: photoSaveService.progressStream,
        title: progressTitle,
      ),
    );

    try {
      final result = await saveOperation(photoSaveService);

      if (mounted) {
        Navigator.of(context).pop();
      }

      if (!mounted) {
        return;
      }

      _processSaveResult(result);
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Save failed: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      photoSaveService.dispose();
    }
  }

  void _processSaveResult(SaveResult result) {
    if (!mounted) {
      return;
    }

    if (result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.getUserMessage()),
          backgroundColor: Colors.green,
        ),
      );

      _provider!.completeSession();
      Navigator.of(context).pop();
    } else if (result.successfulCount > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.getUserMessage()),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 4),
        ),
      );

      _provider!.completeSession();
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.error ?? 'Save failed'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );

      if (!result.sessionPreserved) {
        _provider!.completeSession();
        Navigator.of(context).pop();
      }
    }
  }

  Future<_NextSaveOption?> _showNextSaveOptions(
    BuildContext context,
    Equipment equipment,
  ) {
    return showModalBottomSheet<_NextSaveOption>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Save to ${equipment.name}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.create_new_folder),
                title: const Text('Create New Folder'),
                subtitle: const Text(
                  'Make a new folder and add photos to Before or After.',
                ),
                onTap: () =>
                    Navigator.of(sheetContext).pop(_NextSaveOption.createFolder),
              ),
              ListTile(
                leading: const Icon(Icons.folder),
                title: const Text('Add to Existing Folder'),
                subtitle: const Text('Choose a folder under this equipment.'),
                onTap: () =>
                    Navigator.of(sheetContext).pop(_NextSaveOption.existingFolder),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<BeforeAfter?> _promptBeforeAfterSelection({
    required BuildContext context,
    required String title,
    String? message,
  }) {
    return showDialog<BeforeAfter>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: Text(title),
        children: [
          if (message != null)
            Padding(
              padding: const EdgeInsets.only(left: 24, right: 24, bottom: 12),
              child: Text(
                message,
                style: Theme.of(dialogContext).textTheme.bodyMedium,
              ),
            ),
          SimpleDialogOption(
            onPressed: () =>
                Navigator.of(dialogContext).pop(BeforeAfter.before),
            child: const Text('Before'),
          ),
          SimpleDialogOption(
            onPressed: () =>
                Navigator.of(dialogContext).pop(BeforeAfter.after),
            child: const Text('After'),
          ),
        ],
      ),
    );
  }

  Future<PhotoFolder?> _promptExistingFolderSelection({
    required BuildContext context,
    required List<PhotoFolder> folders,
  }) {
    return showDialog<PhotoFolder>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Select Folder'),
        content: SizedBox(
          width: double.maxFinite,
          height: 260,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: folders.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (itemContext, index) {
              final folder = folders[index];
              return ListTile(
                title: Text(folder.name),
                onTap: () => Navigator.of(dialogContext).pop(folder),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  /// T014-T015: Home context - Quick Save button handler
  Future<void> _handleQuickSave(BuildContext context) async {
    // Use class-level provider reference instead of context to avoid modal scope issues
    if (_provider == null || !_provider!.hasPhotos) {
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
      builder: (context) =>
          const Center(child: CircularProgressIndicator(color: Colors.white)),
    );

    try {
      // Execute Quick Save
      final result = await quickSaveService.quickSave(
        _provider!.session.photos,
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
        _provider!.completeSession();
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

        _provider!.completeSession();
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
          _provider!.completeSession();
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

  /// T032-T034: Equipment context - Direct save to equipment's All Photos
  Future<void> _handleEquipmentSave(BuildContext context) async {
    // Use class-level provider reference instead of context to avoid modal scope issues
    if (_provider == null || !_provider!.hasPhotos) {
      return;
    }

    // Validate equipment ID exists in context
    if (widget.cameraContext.equipmentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Equipment ID missing from context'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Close modal
    Navigator.of(context).pop();

    // Fetch equipment from database
    final db = await DatabaseService().database;
    final equipmentMaps = await db.query(
      'equipment',
      where: 'id = ?',
      whereArgs: [widget.cameraContext.equipmentId],
    );

    if (equipmentMaps.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Equipment not found'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final equipment = Equipment.fromMap(equipmentMaps.first);

    // Initialize save service
    final photoSaveService = PhotoSaveService(
      databaseService: DatabaseService(),
      storageService: PhotoStorageService(),
      allPhotosProvider: context.read<AllPhotosProvider>(),
    );

    // Show loading dialog with progress indicator (FR-057)
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
      // T034: Save photos directly to equipment (no folder association)
      final result = await photoSaveService.saveToEquipment(
        photos: _provider!.session.photos,
        equipment: equipment,
      );

      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      // T035: Show result message with photo count (FR-058, FR-059)
      if (!mounted) return;
      if (result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.getUserMessage()),
            backgroundColor: Colors.green,
          ),
        );

        // Complete session and return to equipment's All Photos tab (T036)
        _provider!.completeSession();
        if (mounted) Navigator.of(context).pop();
      } else if (result.successfulCount > 0) {
        // Partial save (FR-055b)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.getUserMessage()),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 4),
          ),
        );

        _provider!.completeSession();
        if (mounted) Navigator.of(context).pop();
      } else {
        // Critical failure (FR-055c)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.error ?? 'Save failed'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );

        // Only close if session not preserved for retry
        if (!result.sessionPreserved) {
          _provider!.completeSession();
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

  /// T039, T042: Folder Before context - Direct save to folder's Before section
  Future<void> _handleBeforeSave(BuildContext context) async {
    await _handleFolderSave(context, BeforeAfter.before);
  }

  /// T039, T042: Folder After context - Direct save to folder's After section
  Future<void> _handleAfterSave(BuildContext context) async {
    await _handleFolderSave(context, BeforeAfter.after);
  }

  /// T042: Generic folder save handler for before/after categorization
  Future<void> _handleFolderSave(
    BuildContext context,
    BeforeAfter category,
  ) async {
    // Use class-level provider reference instead of context to avoid modal scope issues
    if (_provider == null || !_provider!.hasPhotos) {
      return;
    }

    // Validate folder ID exists in context
    if (widget.cameraContext.folderId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Folder ID missing from context'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Close modal
    Navigator.of(context).pop();

    // Fetch folder from database
    final db = await DatabaseService().database;
    final folderMaps = await db.query(
      'photo_folders',
      where: 'id = ? AND is_deleted = 0',
      whereArgs: [widget.cameraContext.folderId],
    );

    // T046: Detect folder deletion during capture session
    if (folderMaps.isEmpty) {
      if (!mounted) return;

      // Show error and offer alternative save options
      final shouldSaveToEquipment = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Folder Deleted'),
          content: const Text(
            'The folder was deleted while you were capturing photos. '
            'Would you like to save these photos to the equipment\'s All Photos instead?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Save to Equipment'),
            ),
          ],
        ),
      );

      if (shouldSaveToEquipment == true &&
          widget.cameraContext.equipmentId != null) {
        // Fallback: save to equipment's All Photos
        return _handleEquipmentSave(context);
      }
      return;
    }

    final folder = PhotoFolder.fromMap(folderMaps.first);
    final categoryStr = category == BeforeAfter.before ? 'Before' : 'After';

    // Initialize save service
    final photoSaveService = PhotoSaveService(
      databaseService: DatabaseService(),
      storageService: PhotoStorageService(),
      allPhotosProvider: context.read<AllPhotosProvider>(),
    );

    // Show loading dialog with progress indicator (FR-057)
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => SaveProgressDialog(
        progressStream: photoSaveService.progressStream,
        title: 'Saving to $categoryStr',
      ),
    );

    try {
      // T042: Save photos to folder with before/after categorization
      final result = await photoSaveService.saveToFolder(
        photos: _provider!.session.photos,
        folder: folder,
        category: category,
      );

      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      // T043: Show result message with category (e.g., "2 photos saved to Before")
      if (!mounted) return;
      if (result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${result.successfulCount} ${result.successfulCount == 1 ? 'photo' : 'photos'} saved to $categoryStr',
            ),
            backgroundColor: Colors.green,
          ),
        );

        // Complete session and return to folder tab (T044)
        _provider!.completeSession();
        if (mounted) Navigator.of(context).pop();
      } else if (result.successfulCount > 0) {
        // Partial save (FR-055b)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${result.successfulCount} of ${result.successfulCount + result.failedCount} photos saved to $categoryStr',
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 4),
          ),
        );

        _provider!.completeSession();
        if (mounted) Navigator.of(context).pop();
      } else {
        // Critical failure (FR-055c)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.error ?? 'Save failed'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );

        // Only close if session not preserved for retry
        if (!result.sessionPreserved) {
          _provider!.completeSession();
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

enum _NextSaveOption {
  createFolder,
  existingFolder,
}
