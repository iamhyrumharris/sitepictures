import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/equipment.dart';
import '../../models/folder_photo.dart';
import '../../models/import_batch.dart';
import '../../models/photo.dart';
import '../../models/photo_folder.dart';
import '../../providers/all_photos_provider.dart';
import '../../providers/auth_state.dart';
import '../../providers/equipment_navigator_provider.dart';
import '../../providers/import_flow_provider.dart';
import '../../providers/needs_assigned_provider.dart';
import '../../screens/equipment_navigator_page.dart';
import '../../services/database_service.dart';
import '../../services/folder_service.dart';
import '../../services/needs_assigned_move_service.dart';
import '../../services/photo_storage_service.dart';
import '../../widgets/create_folder_dialog.dart';
import '../../widgets/fab_visibility_scope.dart';
import '../../widgets/import_destination_picker.dart';
import '../../widgets/import_progress_sheet.dart';
import '../../widgets/photo_grid_tile.dart';
import '../../router.dart';

class AllPhotosScreen extends StatefulWidget {
  const AllPhotosScreen({super.key});

  @override
  State<AllPhotosScreen> createState() => _AllPhotosScreenState();
}

class _AllPhotosScreenState extends State<AllPhotosScreen>
    with AutomaticKeepAliveClientMixin {
  late final ScrollController _scrollController;
  bool _isSelectionMode = false;
  bool _isPerformingAction = false;
  final Set<String> _selectedPhotoIds = <String>{};
  FabVisibilityController? _fabController;

  Future<void> _handleImport(BuildContext context) async {
    final importFlow = context.read<ImportFlowProvider>();
    final selection = await showImportDestinationPicker(
      context: context,
      entryPoint: ImportEntryPoint.allPhotos,
    );

    if (selection == null) {
      return;
    }

    importFlow.configure(
      entryPoint: ImportEntryPoint.allPhotos,
      defaultDestination: selection.destination,
      beforeAfterChoice: selection.beforeAfterChoice,
      navigatorKey: AppRouter.router.routerDelegate.navigatorKey,
      initialPermissionState: importFlow.permissionState,
    );

    final result = await showImportProgressSheet(
      context,
      provider: importFlow,
      onStart: () => importFlow.startImport(pickerContext: context),
    );

    if (!mounted) {
      return;
    }

    if (result != null) {
      try {
        await context.read<NeedsAssignedProvider>().loadGlobalNeedsAssigned();
      } catch (_) {}
      try {
        await context.read<AllPhotosProvider>().refresh();
      } catch (_) {}

      final batch = result.batch;
      final summary =
          '${batch.importedCount} imported, ${batch.duplicateCount} duplicate(s) skipped, ${batch.failedCount} failed';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(summary)));
    } else if (importFlow.errorMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(importFlow.errorMessage!)));
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_handleScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final provider = context.read<AllPhotosProvider>();
      provider.loadInitial();
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
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    _fabController?.show();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  int get _selectedCount => _selectedPhotoIds.length;

  bool get _hasSelection => _selectedPhotoIds.isNotEmpty;

  void _handleScroll() {
    if (!mounted) return;
    final provider = context.read<AllPhotosProvider>();
    if (!provider.hasMore ||
        provider.isLoadingMore ||
        provider.isLoading ||
        provider.isRefreshing) {
      return;
    }
    if (!_scrollController.hasClients) {
      return;
    }
    final position = _scrollController.position;
    if (position.extentAfter < 320) {
      provider.loadMore();
    }
  }

  void _syncSelectionWithPhotos(List<Photo> photos) {
    if (!_isSelectionMode || _selectedPhotoIds.isEmpty) {
      return;
    }
    final availableIds = photos.map((photo) => photo.id).toSet();
    final removed = _selectedPhotoIds
        .where((id) => !availableIds.contains(id))
        .toList(growable: false);
    if (removed.isEmpty) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _selectedPhotoIds.removeWhere((id) => !availableIds.contains(id));
        if (_selectedPhotoIds.isEmpty) {
          _isSelectionMode = false;
        }
      });
    });
  }

  void _enterSelectionMode({String? initialPhotoId}) {
    if (_isSelectionMode && initialPhotoId == null) {
      return;
    }
    if (!mounted) return;
    setState(() {
      _isSelectionMode = true;
      if (initialPhotoId != null) {
        _selectedPhotoIds.add(initialPhotoId);
      }
    });
  }

  void _togglePhotoSelection(String photoId) {
    if (!mounted) return;
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

  void _selectAll(AllPhotosProvider provider) {
    if (!mounted) return;
    setState(() {
      _isSelectionMode = true;
      _selectedPhotoIds
        ..clear()
        ..addAll(provider.photos.map((photo) => photo.id));
    });
  }

  void _clearSelection() {
    if (!mounted) return;
    setState(() {
      _selectedPhotoIds.clear();
      _isSelectionMode = false;
    });
  }

  void _exitSelectionMode() {
    if (!_isSelectionMode && _selectedPhotoIds.isEmpty) {
      return;
    }
    if (!mounted) return;
    setState(() {
      _isSelectionMode = false;
      _selectedPhotoIds.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    _updateFabVisibility();
    return Consumer<AllPhotosProvider>(
      builder: (context, provider, _) {
        _syncSelectionWithPhotos(provider.photos);
        return Scaffold(
          appBar: _isSelectionMode
              ? _buildSelectionAppBar(provider)
              : _buildNormalAppBar(provider),
          body: _buildBody(provider),
          bottomNavigationBar:
              _isSelectionMode ? _buildSelectionActionBar(provider) : null,
        );
      },
    );
  }

  PreferredSizeWidget _buildNormalAppBar(AllPhotosProvider provider) {
    final isBusy = provider.isLoading || provider.isRefreshing;
    final hasPhotos = provider.photos.isNotEmpty;
    return AppBar(
      title: const Text('All Photos'),
      actions: [
        IconButton(
          tooltip: 'Import Photos',
          icon: const Icon(Icons.file_upload_outlined),
          onPressed:
              _isPerformingAction ? null : () => _handleImport(context),
        ),
        IconButton(
          tooltip: 'Refresh',
          icon: const Icon(Icons.refresh),
          onPressed: isBusy ? null : provider.refresh,
        ),
        if (hasPhotos)
          TextButton(
            onPressed:
                _isPerformingAction ? null : () => _enterSelectionMode(),
            child: const Text(
              'Select',
              style: TextStyle(color: Colors.white),
            ),
          ),
      ],
    );
  }

  PreferredSizeWidget _buildSelectionAppBar(AllPhotosProvider provider) {
    final total = provider.photos.length;
    final selectedCount = _selectedCount;
    final isAllSelected = total > 0 && selectedCount == total;

    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: _isPerformingAction ? null : _exitSelectionMode,
      ),
      title: Text('$selectedCount selected'),
      actions: [
        if (total > 0)
          TextButton(
            onPressed: _isPerformingAction
                ? null
                : (isAllSelected
                    ? _clearSelection
                    : () => _selectAll(provider)),
            child: Text(
              isAllSelected ? 'Deselect All' : 'Select All',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: (_hasSelection && !_isPerformingAction)
              ? () => _deleteSelectedPhotos(provider)
              : null,
        ),
      ],
    );
  }

  Widget _buildBody(AllPhotosProvider provider) {
    if (provider.isLoading && provider.photos.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null && provider.photos.isEmpty) {
      return _ErrorState(
        message: provider.error!,
        onRetry: () => provider.loadInitial(force: true),
      );
    }

    if (provider.photos.isEmpty) {
      return const _EmptyState();
    }

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: provider.refresh,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              if (provider.error != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: _ErrorBanner(message: provider.error!),
                  ),
                ),
              SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 3,
                  crossAxisSpacing: 3,
                  childAspectRatio: 1,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final photo = provider.photos[index];
                    return PhotoGridTile(
                      photo: photo,
                      cornerRadius: 0,
                      onTap: () =>
                          _handlePhotoTap(photo, index, provider.photos),
                      onLongPress: () => _handlePhotoLongPress(photo),
                      isSelected: _selectedPhotoIds.contains(photo.id),
                      showSelectionState: _isSelectionMode,
                    );
                  },
                  childCount: provider.photos.length,
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: provider.isLoadingMore
                        ? const SizedBox(
                            width: 32,
                            height: 32,
                            child: CircularProgressIndicator(),
                          )
                        : (provider.hasMore
                            ? const SizedBox.shrink()
                            : const Text(
                                'Showing latest photos',
                                style: TextStyle(color: Colors.grey),
                              )),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (provider.isRefreshing)
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: LinearProgressIndicator(),
          ),
      ],
    );
  }

  Widget _buildSelectionActionBar(AllPhotosProvider provider) {
    final theme = Theme.of(context);
    final canAct = _hasSelection && !_isPerformingAction;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: canAct ? () => _handleMoveSelected(provider) : null,
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
                onPressed:
                    canAct ? () => _deleteSelectedPhotos(provider) : null,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Delete'),
              ),
            ),
          ],
        ),
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

  void _handlePhotoTap(Photo photo, int index, List<Photo> photos) {
    if (_isSelectionMode) {
      _togglePhotoSelection(photo.id);
      return;
    }
    _openPhotoViewer(index, photos);
  }

  void _handlePhotoLongPress(Photo photo) {
    if (_isSelectionMode) {
      _togglePhotoSelection(photo.id);
      return;
    }
    _enterSelectionMode(initialPhotoId: photo.id);
  }

  Future<void> _handleMoveSelected(AllPhotosProvider provider) async {
    if (!_hasSelection || _isPerformingAction) {
      return;
    }

    final selectedPhotos = provider.photos
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

        if (!mounted) {
          return;
        }

        if (workOrder == null || workOrder.trim().isEmpty) {
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
        return;
      }

      _exitSelectionMode();
      await provider.refresh();

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

  Future<void> _deleteSelectedPhotos(AllPhotosProvider provider) async {
    if (!_hasSelection || _isPerformingAction) {
      return;
    }

    final selectedPhotos = provider.photos
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

      for (final id in photoIds) {
        provider.removePhoto(id);
      }

      _exitSelectionMode();

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

  void _openPhotoViewer(int index, List<Photo> photos) {
    context.push(
      '/photo-viewer',
      extra: {'photos': photos, 'initialIndex': index},
    );
  }
}

enum _MoveOption { createFolder, existingFolder, generalPhotos }

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.photo_library_outlined, size: 72, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'No photos yet',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Capture new photos to populate the gallery.',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Unable to load photos',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.red[50],
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: const TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }
}
