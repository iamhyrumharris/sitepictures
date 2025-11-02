import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/equipment.dart';
import '../../models/folder_photo.dart';
import '../../models/photo.dart';
import '../../models/photo_folder.dart';
import '../../providers/app_state.dart';
import '../../providers/auth_state.dart';
import '../../providers/equipment_navigator_provider.dart';
import '../../screens/equipment_navigator_page.dart';
import '../../services/database_service.dart';
import '../../services/folder_service.dart';
import '../../services/needs_assigned_move_service.dart';
import '../../services/photo_storage_service.dart';
import '../../widgets/create_folder_dialog.dart';
import '../../widgets/fab_visibility_scope.dart';
import '../../widgets/photo_delete_dialog.dart';
import '../../widgets/photo_grid_tile.dart';

class AllPhotosTab extends StatefulWidget {
  const AllPhotosTab({super.key, required this.equipmentId});

  final String equipmentId;

  @override
  State<AllPhotosTab> createState() => AllPhotosTabState();
}

class AllPhotosTabState extends State<AllPhotosTab>
    with AutomaticKeepAliveClientMixin {
  final Set<String> _selectedPhotoIds = <String>{};
  List<Photo> _photos = <Photo>[];
  bool _isLoading = true;
  bool _isSelectionMode = false;
  bool _isPerformingAction = false;
  FabVisibilityController? _fabController;

  @override
  bool get wantKeepAlive => true;

  int get _selectedCount => _selectedPhotoIds.length;

  bool get _hasSelection => _selectedPhotoIds.isNotEmpty;

  bool get _isAllSelected =>
      _photos.isNotEmpty && _selectedPhotoIds.length == _photos.length;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPhotos();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = FabVisibilityScope.maybeOf(context);
    if (!identical(controller, _fabController)) {
      _fabController?.show();
      _fabController = controller;
    }
  }

  @override
  void dispose() {
    _fabController?.show();
    super.dispose();
  }

  Future<void> _loadPhotos() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    final appState = context.read<AppState>();
    final photos = await appState.getPhotosWithFolderInfo(widget.equipmentId);

    if (!mounted) {
      return;
    }

    setState(() {
      _photos = photos;
      _isLoading = false;
      _selectedPhotoIds.removeWhere(
        (id) => !_photos.any((photo) => photo.id == id),
      );
      if (_selectedPhotoIds.isEmpty) {
        _isSelectionMode = false;
      }
    });
  }

  Future<void> reload() => _loadPhotos();

  Future<void> _refreshPhotos() => _loadPhotos();

  Future<void> _deletePhoto(Photo photo) async {
    if (_isPerformingAction) {
      return;
    }

    var confirmed = false;
    await showDialog(
      context: context,
      builder: (context) => PhotoDeleteDialog(
        photoId: photo.id,
        onConfirm: () => confirmed = true,
      ),
    );

    if (!confirmed) {
      return;
    }

    setState(() {
      _isPerformingAction = true;
    });

    final dbService = DatabaseService();
    try {
      final db = await dbService.database;
      await db.delete('photos', where: 'id = ?', whereArgs: [photo.id]);

      try {
        final photoFile =
            PhotoStorageService.tryResolveLocalFile(photo.filePath);
        if (await photoFile?.exists() == true) {
          await photoFile!.delete();
        }

        if (photo.thumbnailPath != null) {
          final thumbFile =
              PhotoStorageService.tryResolveLocalFile(photo.thumbnailPath!);
          if (await thumbFile?.exists() == true) {
            await thumbFile!.delete();
          }
        }
      } catch (e) {
        debugPrint('Error deleting photo files: $e');
      }

      if (_isSelectionMode) {
        _exitSelectionMode();
      }
      await _loadPhotos();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo deleted'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting photo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPerformingAction = false;
        });
      }
    }
  }

  void _enterSelectionMode({String? initialPhotoId}) {
    if (_isSelectionMode && initialPhotoId == null) {
      return;
    }
    setState(() {
      _isSelectionMode = true;
      if (initialPhotoId != null) {
        _selectedPhotoIds.add(initialPhotoId);
      }
    });
  }

  void _togglePhotoSelection(String photoId) {
    setState(() {
      if (_selectedPhotoIds.contains(photoId)) {
        _selectedPhotoIds.remove(photoId);
      } else {
        _selectedPhotoIds.add(photoId);
      }
      if (_selectedPhotoIds.isEmpty) {
        _isSelectionMode = false;
      }
    });
  }

  void _selectAll() {
    setState(() {
      _isSelectionMode = true;
      _selectedPhotoIds
        ..clear()
        ..addAll(_photos.map((photo) => photo.id));
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedPhotoIds.clear();
      _isSelectionMode = false;
    });
  }

  void _exitSelectionMode() {
    if (!_isSelectionMode && _selectedPhotoIds.isEmpty) {
      return;
    }
    setState(() {
      _isSelectionMode = false;
      _selectedPhotoIds.clear();
    });
  }

  void _handlePhotoTap(Photo photo, int index) {
    if (_isSelectionMode) {
      _togglePhotoSelection(photo.id);
      return;
    }

    context.push(
      '/photo-viewer',
      extra: {'photos': _photos, 'initialIndex': index},
    );
  }

  void _showPhotoContextMenu(Photo photo) {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.check_circle_outline),
              title: const Text('Select Photos'),
              onTap: () {
                Navigator.of(sheetContext).pop();
                _enterSelectionMode(initialPhotoId: photo.id);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Photo'),
              onTap: () {
                Navigator.of(sheetContext).pop();
                _deletePhoto(photo);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _handlePhotoLongPress(Photo photo) {
    if (_isSelectionMode) {
      _togglePhotoSelection(photo.id);
      return;
    }
    _showPhotoContextMenu(photo);
  }

  Future<void> _handleMoveSelected() async {
    if (!_hasSelection || _isPerformingAction) {
      return;
    }

    final selectedPhotos = _photos
        .where((photo) => _selectedPhotoIds.contains(photo.id))
        .toList(growable: false);

    if (selectedPhotos.isEmpty) {
      _exitSelectionMode();
      return;
    }

    final equipment = await Navigator.of(context).push<Equipment>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (navigatorContext) => ChangeNotifierProvider(
          create: (_) => EquipmentNavigatorProvider(),
          child: const EquipmentNavigatorPage(),
        ),
      ),
    );

    if (!mounted || equipment == null) {
      return;
    }

    final moveOption = await _showMoveOptions(
      context,
      equipment,
      allowGeneralPhotos: true,
    );

    if (!mounted || moveOption == null) {
      return;
    }

    final folderService = FolderService();
    PhotoFolder? targetFolder;
    BeforeAfter? category;

    switch (moveOption) {
      case _MoveOption.createFolder:
        final workOrder = await showDialog<String>(
          context: context,
          builder: (dialogContext) => const CreateFolderDialog(),
        );

        if (!mounted || workOrder == null || workOrder.trim().isEmpty) {
          return;
        }

        category = await _promptBeforeAfterSelection(
          context: context,
          title: 'Move photos to Before or After?',
          message: 'Choose the section for these photos in the new folder.',
        );

        if (!mounted || category == null) {
          return;
        }

        final authState = context.read<AuthState>();
        final currentUser = authState.currentUser;

        if (currentUser == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No user signed in. Please sign in and try again.'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        try {
          targetFolder = await folderService.createFolder(
            equipmentId: equipment.id,
            workOrder: workOrder.trim(),
            createdBy: currentUser.id,
          );
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to create folder: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
        break;

      case _MoveOption.existingFolder:
        List<PhotoFolder> folders;
        try {
          folders = await folderService.getFolders(equipment.id);
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to load folders: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        if (folders.isEmpty) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No folders available on this equipment yet.'),
                backgroundColor: Colors.orange,
              ),
            );
          }
          return;
        }

        targetFolder = await _promptExistingFolderSelection(
          context: context,
          folders: folders,
        );

        if (!mounted || targetFolder == null) {
          return;
        }

        category = await _promptBeforeAfterSelection(
          context: context,
          title: 'Move photos to Before or After?',
          message:
              'Choose the section in ${targetFolder.name} for these photos.',
        );

        if (!mounted || category == null) {
          return;
        }
        break;

      case _MoveOption.generalPhotos:
        break;
    }

    setState(() {
      _isPerformingAction = true;
    });

    final moveService = NeedsAssignedMoveService();
    final rootNavigator = Navigator.of(context, rootNavigator: true);
    var progressOpen = false;

    void closeProgress() {
      if (progressOpen && rootNavigator.canPop()) {
        rootNavigator.pop();
        progressOpen = false;
      }
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
    progressOpen = true;

    try {
      final summary = await moveService.reassignPhotos(
        photoIds: selectedPhotos.map((photo) => photo.id).toList(),
        targetEquipmentId: equipment.id,
        targetFolderId: targetFolder?.id,
        targetCategory: category,
      );

      closeProgress();

      if (!mounted) {
        return;
      }

      if (!summary.hasChanges) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Nothing to move. Photos may have already been reassigned.',
            ),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        _exitSelectionMode();
        await _loadPhotos();

        if (!mounted) {
          return;
        }

        final movedCount = summary.movedPhotoIds.length;
        final label = movedCount == 1 ? 'photo' : 'photos';
        final targetName =
            targetFolder != null ? targetFolder.name : equipment.name;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$movedCount $label -> $targetName'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'Open',
              onPressed: () {
                final router = GoRouter.of(context);
                if (targetFolder != null) {
                  router.push(
                    '/equipment/${equipment.id}/folder/${targetFolder.id}',
                  );
                } else {
                  router.push('/equipment/${equipment.id}');
                }
              },
              textColor: Colors.white,
            ),
          ),
        );
      }
    } catch (e) {
      closeProgress();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Move failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      closeProgress();
      if (mounted) {
        setState(() {
          _isPerformingAction = false;
        });
      }
    }
  }

  Future<void> _deleteSelectedPhotos() async {
    if (!_hasSelection || _isPerformingAction) {
      return;
    }

    final selectedPhotos = _photos
        .where((photo) => _selectedPhotoIds.contains(photo.id))
        .toList(growable: false);

    if (selectedPhotos.isEmpty) {
      _exitSelectionMode();
      return;
    }

    final count = selectedPhotos.length;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Photos'),
        content: Text('Delete $count photo${count == 1 ? '' : 's'}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    setState(() {
      _isPerformingAction = true;
    });

    final dbService = DatabaseService();
    final photoIds = selectedPhotos.map((photo) => photo.id).toList();

    try {
      final db = await dbService.database;
      await db.transaction((txn) async {
        final placeholders = List.filled(photoIds.length, '?').join(',');
        await txn.rawDelete(
          'DELETE FROM photos WHERE id IN ($placeholders)',
          photoIds,
        );
      });

      for (final photo in selectedPhotos) {
        try {
          final photoFile =
              PhotoStorageService.tryResolveLocalFile(photo.filePath);
          await photoFile?.delete();
        } catch (_) {
          // Ignore file deletion issues
        }

        if (photo.thumbnailPath != null) {
          try {
            final thumbFile = PhotoStorageService.tryResolveLocalFile(
              photo.thumbnailPath!,
            );
            await thumbFile?.delete();
          } catch (_) {
            // Ignore thumbnail deletion issues
          }
        }
      }

      _exitSelectionMode();
      await _loadPhotos();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$count photo${count == 1 ? '' : 's'} deleted',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting photos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPerformingAction = false;
        });
      }
    }
  }

  Widget _buildHeader() {
    if (_photos.isEmpty) {
      return const SizedBox.shrink();
    }

    if (_isSelectionMode) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: 'Exit selection',
              onPressed: _isPerformingAction ? null : _exitSelectionMode,
            ),
            Text(
              '$_selectedCount selected',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Spacer(),
            TextButton(
              onPressed: _isPerformingAction
                  ? null
                  : (_isAllSelected ? _clearSelection : _selectAll),
              child: Text(_isAllSelected ? 'Deselect All' : 'Select All'),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          Text(
            'Photos (${_photos.length})',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const Spacer(),
          TextButton(
            onPressed: _isPerformingAction ? null : _enterSelectionMode,
            child: const Text('Select'),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionActionBar() {
    final theme = Theme.of(context);
    final canAct = _hasSelection && !_isPerformingAction;

    return Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        top: false,
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: canAct ? _handleMoveSelected : null,
                  icon: const Icon(Icons.drive_file_move),
                  label: Text(
                    'Move (${_selectedCount})',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: canAct ? _deleteSelectedPhotos : null,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Delete'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    _updateFabVisibility();

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_photos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'No Photos Yet',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the camera button to capture photos',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    final grid = RefreshIndicator(
      onRefresh: _refreshPhotos,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _buildHeader()),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 3,
                mainAxisSpacing: 3,
                childAspectRatio: 1,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final photo = _photos[index];
                  return PhotoGridTile(
                    photo: photo,
                    onTap: () => _handlePhotoTap(photo, index),
                    onLongPress: () => _handlePhotoLongPress(photo),
                    isSelected: _selectedPhotoIds.contains(photo.id),
                    showSelectionState: _isSelectionMode,
                  );
                },
                childCount: _photos.length,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(height: _isSelectionMode ? 120 : 32),
          ),
        ],
      ),
    );

    return Stack(
      children: [
        grid,
        if (_isSelectionMode) _buildSelectionActionBar(),
      ],
    );
  }

  Future<_MoveOption?> _showMoveOptions(
    BuildContext context,
    Equipment equipment, {
    required bool allowGeneralPhotos,
  }) {
    return showModalBottomSheet<_MoveOption>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Move to ${equipment.name}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.create_new_folder),
                title: const Text('Create New Folder'),
                subtitle: const Text(
                  'Make a new folder and place these photos inside.',
                ),
                onTap: () {
                  Navigator.of(sheetContext).pop(_MoveOption.createFolder);
                },
              ),
              ListTile(
                leading: const Icon(Icons.folder_shared),
                title: const Text('Existing Folder'),
                subtitle: const Text(
                  'Move into an existing folder on this equipment.',
                ),
                onTap: () {
                  Navigator.of(sheetContext).pop(_MoveOption.existingFolder);
                },
              ),
              if (allowGeneralPhotos)
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: const Text('Equipment Photos'),
                  subtitle: const Text(
                    'Move into the Photos tab for this equipment.',
                  ),
                  onTap: () {
                    Navigator.of(sheetContext).pop(_MoveOption.generalPhotos);
                  },
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
              padding: const EdgeInsets.only(
                left: 24,
                right: 24,
                bottom: 12,
              ),
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

  void _updateFabVisibility() {
    final controller = _fabController;
    if (controller == null) {
      return;
    }
    final shouldHide = _isSelectionMode || _isPerformingAction;
    controller.setVisible(!shouldHide);
  }
}

enum _MoveOption { createFolder, existingFolder, generalPhotos }
