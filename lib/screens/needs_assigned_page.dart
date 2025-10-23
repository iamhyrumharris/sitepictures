import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/equipment.dart';
import '../models/photo.dart';
import '../models/photo_folder.dart';
import '../models/folder_photo.dart';
import '../providers/auth_state.dart';
import '../providers/equipment_navigator_provider.dart';
import '../screens/equipment_navigator_page.dart';
import '../services/database_service.dart';
import '../services/folder_service.dart';
import '../services/needs_assigned_move_service.dart';
import '../services/photo_storage_service.dart';
import '../widgets/create_folder_dialog.dart';
import '../widgets/needs_assigned_badge.dart';
import '../widgets/rename_folder_dialog.dart';

/// T016: Page to display global "Needs Assigned" photos and folders
/// Shows all Quick Save items (single photos and folders) from home camera
class NeedsAssignedPage extends StatefulWidget {
  const NeedsAssignedPage({Key? key}) : super(key: key);

  @override
  State<NeedsAssignedPage> createState() => _NeedsAssignedPageState();
}

class _NeedsAssignedPageState extends State<NeedsAssignedPage> {
  final DatabaseService _db = DatabaseService();
  List<Map<String, dynamic>> _folders = [];
  List<Photo> _standalonePhotos = [];
  bool _isLoading = true;
  String? _globalEquipmentId;
  _SelectionType? _selectionType;

  // Selection mode state
  bool _isSelectionMode = false;
  final Set<String> _selectedPhotoIds = {};
  final Set<String> _selectedFolderIds = {};

  int get _selectedCount =>
      _selectedPhotoIds.length + _selectedFolderIds.length;

  int get _totalSelectableItems => _standalonePhotos.length + _folders.length;

  bool get _hasSelection => _selectedCount > 0;

  bool get _hasFolderSelection => _selectedFolderIds.isNotEmpty;

  int get _totalItemsForSelection {
    switch (_selectionType) {
      case _SelectionType.photos:
        return _standalonePhotos.length;
      case _SelectionType.folders:
        return _folders.length;
      case null:
        return 0;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadNeedsAssigned();
  }

  Future<void> _loadNeedsAssigned() async {
    setState(() => _isLoading = true);

    try {
      final db = await _db.database;

      // Get global equipment ID
      final globalEquipment = await db.query(
        'equipment',
        columns: ['id'],
        where: 'client_id = ?',
        whereArgs: ['GLOBAL_NEEDS_ASSIGNED'],
        limit: 1,
      );

      if (globalEquipment.isEmpty) {
        setState(() {
          _isLoading = false;
          _globalEquipmentId = null;
          _folders = [];
          _standalonePhotos = [];
          _isSelectionMode = false;
          _selectedPhotoIds.clear();
          _selectedFolderIds.clear();
        });
        return;
      }

      final globalEquipmentId = globalEquipment.first['id'] as String;

      // Load folders (multi-photo Quick Saves)
      final folders = await db.query(
        'photo_folders',
        where: 'equipment_id = ? AND is_deleted = 0',
        whereArgs: [globalEquipmentId],
        orderBy: 'created_at DESC',
      );

      // Load standalone photos (single-photo Quick Saves)
      // These are photos NOT associated with any folder
      final folderPhotoIds = await db.query(
        'folder_photos',
        columns: ['photo_id'],
      );

      final excludeIds = folderPhotoIds
          .map((row) => row['photo_id'] as String)
          .toList();

      List<Map<String, dynamic>> standalonePhotoMaps;
      if (excludeIds.isEmpty) {
        standalonePhotoMaps = await db.query(
          'photos',
          where: 'equipment_id = ?',
          whereArgs: [globalEquipmentId],
          orderBy: 'timestamp DESC',
        );
      } else {
        final placeholders = List.filled(excludeIds.length, '?').join(',');
        standalonePhotoMaps = await db.query(
          'photos',
          where: 'equipment_id = ? AND id NOT IN ($placeholders)',
          whereArgs: [globalEquipmentId, ...excludeIds],
          orderBy: 'timestamp DESC',
        );
      }

      // Convert maps to Photo objects
      final standalonePhotos = standalonePhotoMaps
          .map((map) => Photo.fromMap(map))
          .toList();

      setState(() {
        _globalEquipmentId = globalEquipmentId;
        _folders = folders;
        _standalonePhotos = standalonePhotos;
        _isLoading = false;
        _selectedPhotoIds.removeWhere(
          (id) => !standalonePhotos.any((photo) => photo.id == id),
        );
        _selectedFolderIds.removeWhere(
          (id) => !folders.any((folder) => folder['id'] == id),
        );
        if (_selectedCount == 0) {
          _isSelectionMode = false;
          _selectionType = null;
        }
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _isSelectionMode ? _buildSelectionAppBar() : _buildNormalAppBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(),
      bottomNavigationBar: _isSelectionMode ? _buildSelectionActionBar() : null,
    );
  }

  PreferredSizeWidget _buildNormalAppBar() {
    return AppBar(
      title: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox),
          SizedBox(width: 8),
          Text('Needs Assigned'),
        ],
      ),
      actions: [
        if (_totalSelectableItems > 0)
          TextButton(
            onPressed: () => _enterSelectionMode(),
            child: const Text('Select', style: TextStyle(color: Colors.white)),
          ),
      ],
    );
  }

  PreferredSizeWidget _buildSelectionAppBar() {
    final selectedCount = _selectedCount;
    final totalForSelection = _totalItemsForSelection;
    final selectAllEnabled = _selectionType != null && totalForSelection > 0;
    final isAllSelected =
        selectAllEnabled && selectedCount == totalForSelection;

    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: _exitSelectionMode,
      ),
      title: Text('$selectedCount selected'),
      actions: [
        if (_totalSelectableItems > 0)
          TextButton(
            onPressed: selectAllEnabled
                ? (isAllSelected ? _clearSelection : _selectAllItems)
                : null,
            child: Text(
              isAllSelected ? 'Deselect All' : 'Select All',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: (_selectedPhotoIds.isEmpty || _hasFolderSelection)
              ? null
              : _bulkDeletePhotos,
        ),
      ],
    );
  }

  Widget _buildSelectionActionBar() {
    final theme = Theme.of(context);
    final moveEnabled = _hasSelection;
    final deleteEnabled = _selectedPhotoIds.isNotEmpty && !_hasFolderSelection;
    final isFolderSelection = _selectionType == _SelectionType.folders;
    final renameEnabled = isFolderSelection && _selectedFolderIds.length == 1;

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
                onPressed: moveEnabled ? _handleMoveSelected : null,
                icon: const Icon(Icons.drive_file_move),
                label: Text(
                  'Move (${_selectedCount})',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: isFolderSelection
                  ? OutlinedButton.icon(
                      onPressed:
                          renameEnabled ? _renameSelectedFolder : null,
                      icon: const Icon(Icons.edit),
                      label: const Text('Rename'),
                    )
                  : OutlinedButton.icon(
                      onPressed: deleteEnabled ? _bulkDeletePhotos : null,
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Delete'),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final totalItems = _folders.length + _standalonePhotos.length;

    if (totalItems == 0) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No photos need assignment',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Use Quick Save from the camera to add photos here',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadNeedsAssigned,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Global badge at top
          const NeedsAssignedBadge(isGlobal: true),
          const SizedBox(height: 16),

          // Summary
          Text(
            '$totalItems item${totalItems != 1 ? 's' : ''}',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Folders
          if (_folders.isNotEmpty) ...[
            Text(
              'Folders (${_folders.length})',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            ..._folders.map((folder) => _buildFolderCard(folder)),
            const SizedBox(height: 16),
          ],

          // Standalone photos
          if (_standalonePhotos.isNotEmpty) ...[
            Text(
              'Individual Photos (${_standalonePhotos.length})',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1,
              ),
              itemCount: _standalonePhotos.length,
              itemBuilder: (context, index) {
                return _buildPhotoTile(_standalonePhotos[index]);
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFolderCard(Map<String, dynamic> folder) {
    final name = folder['name'] as String;
    final createdAt = DateTime.parse(folder['created_at'] as String);
    final folderId = folder['id'] as String?;
    final isSelected =
        folderId != null && _selectedFolderIds.contains(folderId);

    if (folderId == null) {
      return const SizedBox.shrink();
    }

    void handleTap() async {
      if (_isSelectionMode) {
        _toggleFolderSelection(folderId);
        return;
      }

      final equipmentId = _globalEquipmentId;
      if (equipmentId == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to open folder right now.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      await context.push('/equipment/$equipmentId/folder/$folderId');
      if (mounted) {
        await _loadNeedsAssigned();
      }
    }

    return GestureDetector(
      onTap: handleTap,
      onLongPress: () {
        if (!_isSelectionMode) {
          _enterSelectionMode(initialFolderId: folderId);
        }
      },
      child: Stack(
        children: [
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.transparent,
                width: 2,
              ),
            ),
            child: ListTile(
              leading: const Icon(Icons.folder, color: Colors.blue),
              title: Text(name),
              subtitle: Text('Created ${_formatDate(createdAt)}'),
              trailing: _isSelectionMode
                  ? null
                  : const Icon(Icons.chevron_right),
            ),
          ),
          if (isSelected)
            Positioned.fill(
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          if (isSelected)
            Positioned(
              top: 12,
              right: 24,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 18),
              ),
            ),
          if (_isSelectionMode && !isSelected)
            Positioned(
              top: 12,
              right: 24,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.8),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey, width: 2),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPhotoTile(Photo photo) {
    final isSelected = _selectedPhotoIds.contains(photo.id);
    final photoIndex = _standalonePhotos.indexOf(photo);

    return GestureDetector(
      onTap: () {
        if (_isSelectionMode) {
          _togglePhotoSelection(photo.id);
        } else {
          // Navigate to photo viewer with standalone photos
          context.push(
            '/photo-viewer',
            extra: {'photos': _standalonePhotos, 'initialIndex': photoIndex},
          );
        }
      },
      onLongPress: () {
        if (!_isSelectionMode) {
          // Enter selection mode with this photo selected
          _enterSelectionMode(initialPhotoId: photo.id);
        }
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Photo container
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
              border: isSelected
                  ? Border.all(color: Colors.blue, width: 3)
                  : null,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: _buildPhotoImage(photo),
            ),
          ),

          // Selection overlay
          if (isSelected)
            Container(
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
            ),

          // Checkmark indicator
          if (isSelected)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 18),
              ),
            ),

          // Selection mode indicator (empty circle when not selected)
          if (_isSelectionMode && !isSelected)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.8),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey, width: 2),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPhotoImage(Photo photo) {
    // Try to load thumbnail first, fall back to full image
    final imagePath = photo.thumbnailPath ?? photo.filePath;
    final localFile = PhotoStorageService.tryResolveLocalFile(imagePath);
    final remoteUrl = photo.remoteUrl;

    if (localFile != null) {
      return FutureBuilder<bool>(
        future: localFile.exists(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            );
          }

          if (snapshot.hasData && snapshot.data == true) {
            return Image.file(
              localFile,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildPlaceholder();
              },
            );
          }

          return _buildRemoteOrPlaceholder(remoteUrl);
        },
      );
    }

    return _buildRemoteOrPlaceholder(remoteUrl);
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[300],
      child: const Center(
        child: Icon(Icons.image, size: 40, color: Colors.grey),
      ),
    );
  }

  Widget _buildRemoteOrPlaceholder(String? remoteUrl) {
    if (remoteUrl != null && remoteUrl.isNotEmpty) {
      return Image.network(
        remoteUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, _, __) => _buildPlaceholder(),
      );
    }
    return _buildPlaceholder();
  }

  // Selection mode methods
  void _enterSelectionMode({String? initialPhotoId, String? initialFolderId}) {
    setState(() {
      if (!_isSelectionMode) {
        _selectedPhotoIds.clear();
        _selectedFolderIds.clear();
        _selectionType = null;
      }
      _isSelectionMode = true;

      if (initialPhotoId != null) {
        _selectionType = _SelectionType.photos;
        _selectedPhotoIds.add(initialPhotoId);
      } else if (initialFolderId != null) {
        _selectionType = _SelectionType.folders;
        _selectedFolderIds.add(initialFolderId);
      }
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectionType = null;
      _selectedPhotoIds.clear();
      _selectedFolderIds.clear();
    });
  }

  void _togglePhotoSelection(String photoId) {
    if (_selectionType == _SelectionType.folders) {
      _showSelectionTypeError();
      return;
    }

    setState(() {
      _selectionType ??= _SelectionType.photos;
      if (_selectedPhotoIds.contains(photoId)) {
        _selectedPhotoIds.remove(photoId);
      } else {
        _selectedPhotoIds.add(photoId);
      }

      if (_selectedCount == 0) {
        _isSelectionMode = false;
        _selectionType = null;
      }
    });
  }

  void _toggleFolderSelection(String folderId) {
    if (_selectionType == _SelectionType.photos) {
      _showSelectionTypeError();
      return;
    }

    setState(() {
      _selectionType ??= _SelectionType.folders;
      if (_selectedFolderIds.contains(folderId)) {
        _selectedFolderIds.remove(folderId);
      } else {
        _selectedFolderIds.add(folderId);
      }

      if (_selectedCount == 0) {
        _isSelectionMode = false;
        _selectionType = null;
      }
    });
  }

  void _selectAllItems() {
    if (_selectionType == null) {
      return;
    }

    setState(() {
      if (_selectionType == _SelectionType.photos) {
        _selectedPhotoIds
          ..clear()
          ..addAll(_standalonePhotos.map((photo) => photo.id));
        _selectedFolderIds.clear();
      } else {
        _selectedFolderIds
          ..clear()
          ..addAll(_folders.map((folder) => folder['id']).whereType<String>());
        _selectedPhotoIds.clear();
      }
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedPhotoIds.clear();
      _selectedFolderIds.clear();
      _selectionType = null;
      _isSelectionMode = false;
    });
  }

  void _showSelectionTypeError() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Select photos or folders, not both.'),
          duration: Duration(seconds: 1),
        ),
      );
  }

  Future<void> _handleMoveSelected() async {
    if (!_hasSelection) {
      return;
    }

    final sourceEquipmentId = _globalEquipmentId;
    if (sourceEquipmentId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Global Needs Assigned storage is unavailable.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final isFolderSelection = _selectionType == _SelectionType.folders;
    final selectedPhotoIds = _selectedPhotoIds.toList();
    final selectedFolderIds = isFolderSelection
        ? _selectedFolderIds.toList()
        : <String>[];

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

    final moveService = NeedsAssignedMoveService();

    if (isFolderSelection) {
      await _handleFolderMove(
        equipment: equipment,
        selectedFolderIds: selectedFolderIds,
        sourceEquipmentId: sourceEquipmentId,
        moveService: moveService,
      );
      return;
    }

    final moveOption = await _showMoveOptions(
      context,
      equipment,
      allowGeneralPhotos: true,
    );
    if (moveOption == null) {
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

        if (!mounted) {
          return;
        }

        if (category == null) {
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

        if (!mounted) {
          return;
        }

        if (targetFolder == null) {
          return;
        }

        category = await _promptBeforeAfterSelection(
          context: context,
          title: 'Move photos to Before or After?',
          message:
              'Choose the section in ${targetFolder.name} for these photos.',
        );

        if (!mounted) {
          return;
        }

        if (category == null) {
          return;
        }
        break;

      case _MoveOption.generalPhotos:
        break;
    }

    final rootNavigator = Navigator.of(context, rootNavigator: true);
    var progressOpen = false;

    void closeProgressDialog() {
      if (progressOpen && rootNavigator.canPop()) {
        rootNavigator.pop();
        progressOpen = false;
      }
    }

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) =>
          const Center(child: CircularProgressIndicator(color: Colors.white)),
    );
    progressOpen = true;

    try {
      final summary = await moveService.moveItems(
        photoIds: selectedPhotoIds,
        folderIds: selectedFolderIds,
        sourceEquipmentId: sourceEquipmentId,
        targetEquipmentId: equipment.id,
        targetFolderId: targetFolder?.id,
        targetCategory: category,
      );

      closeProgressDialog();

      if (!mounted) {
        return;
      }

      if (!summary.hasChanges) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Nothing to move. Items may have already been reassigned.',
            ),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      _exitSelectionMode();
      await _loadNeedsAssigned();

      if (!mounted) {
        return;
      }

      final movedCount = summary.movedPhotoIds.length;
      final movedCountLabel = movedCount == 1
          ? '1 photo'
          : '$movedCount photos';
      final destinationName = targetFolder?.name ?? '${equipment.name} Photos';
      final destinationRoute = targetFolder != null
          ? '/equipment/${equipment.id}/folder/${targetFolder.id}'
          : '/equipment/${equipment.id}';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$movedCountLabel -> $destinationName'),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: 'Open',
            onPressed: () {
              GoRouter.of(context).push(destinationRoute);
            },
            textColor: Colors.white,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      closeProgressDialog();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Move failed: $e'), backgroundColor: Colors.red),
      );
    } finally {
      closeProgressDialog();
    }
  }

  Future<void> _handleFolderMove({
    required Equipment equipment,
    required List<String> selectedFolderIds,
    required String sourceEquipmentId,
    required NeedsAssignedMoveService moveService,
  }) async {
    if (selectedFolderIds.isEmpty) {
      return;
    }

    final folderOption = await _showFolderMoveOptions(
      context,
      equipment,
      folderCount: selectedFolderIds.length,
    );
    if (folderOption == null) {
      return;
    }

    PhotoFolder? targetFolder;
    final folderService = FolderService();

    if (folderOption == _FolderMoveOption.mergeIntoExisting) {
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
    }

    final rootNavigator = Navigator.of(context, rootNavigator: true);
    var progressOpen = false;

    void closeProgressDialog() {
      if (progressOpen && rootNavigator.canPop()) {
        rootNavigator.pop();
        progressOpen = false;
      }
    }

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) =>
          const Center(child: CircularProgressIndicator(color: Colors.white)),
    );
    progressOpen = true;

    try {
      NeedsAssignedMoveSummary summary;

      switch (folderOption) {
        case _FolderMoveOption.moveFolder:
          summary = await moveService.moveFoldersToEquipment(
            folderIds: selectedFolderIds,
            sourceEquipmentId: sourceEquipmentId,
            targetEquipmentId: equipment.id,
          );
          break;
        case _FolderMoveOption.mergeIntoExisting:
          summary = await moveService.mergeFoldersIntoExisting(
            folderIds: selectedFolderIds,
            sourceEquipmentId: sourceEquipmentId,
            targetFolderId: targetFolder!.id,
            targetEquipmentId: equipment.id,
          );
          break;
      }

      closeProgressDialog();

      if (!mounted) {
        return;
      }

      if (!summary.hasChanges) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Nothing to move. Items may have already been reassigned.',
            ),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      _exitSelectionMode();
      await _loadNeedsAssigned();

      if (!mounted) {
        return;
      }

      switch (folderOption) {
        case _FolderMoveOption.moveFolder:
          final folderCount = selectedFolderIds.length;
          final label = folderCount == 1 ? 'folder' : 'folders';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$folderCount $label -> ${equipment.name}'),
              backgroundColor: Colors.green,
              action: SnackBarAction(
                label: 'Open',
                onPressed: () {
                  GoRouter.of(context).push('/equipment/${equipment.id}');
                },
                textColor: Colors.white,
              ),
            ),
          );
          break;
        case _FolderMoveOption.mergeIntoExisting:
          final movedCount = summary.movedPhotoIds.length;
          final movedLabel = movedCount == 1 ? 'photo' : 'photos';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$movedCount $movedLabel -> ${targetFolder!.name}'),
              backgroundColor: Colors.green,
              action: SnackBarAction(
                label: 'Open',
                onPressed: () {
                  GoRouter.of(context).push(
                    '/equipment/${equipment.id}/folder/${targetFolder!.id}',
                  );
                },
                textColor: Colors.white,
              ),
            ),
          );
          break;
      }
    } catch (e) {
      if (mounted) {
        closeProgressDialog();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Move failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      closeProgressDialog();
    }
  }

  Future<void> _renameSelectedFolder() async {
    if (_selectionType != _SelectionType.folders ||
        _selectedFolderIds.length != 1) {
      return;
    }

    final folderId = _selectedFolderIds.first;
    final Map<String, dynamic> folder = _folders.firstWhere(
      (element) => element['id'] == folderId,
      orElse: () => <String, dynamic>{},
    );

    final currentName = (folder['name'] as String?)?.trim() ?? '';
    if (currentName.isEmpty) {
      return;
    }

    final newName = await showDialog<String>(
      context: context,
      builder: (context) => RenameFolderDialog(initialName: currentName),
    );

    if (newName == null) {
      return;
    }

    final trimmedName = newName.trim();
    if (trimmedName.isEmpty || trimmedName == currentName) {
      return;
    }

    try {
      final folderService = FolderService();
      await folderService.renameFolder(
        folderId: folderId,
        newName: trimmedName,
      );

      _exitSelectionMode();
      await _loadNeedsAssigned();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Folder renamed')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to rename folder: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _bulkDeletePhotos() async {
    if (_selectedPhotoIds.isEmpty) return;

    final count = _selectedPhotoIds.length;

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Photos'),
        content: Text('Delete $count photo${count != 1 ? 's' : ''}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final db = await _db.database;
      int deletedCount = 0;

      // Delete each selected photo
      for (final photoId in _selectedPhotoIds) {
        final photo = _standalonePhotos.firstWhere((p) => p.id == photoId);

        // Delete from database
        await db.delete('photos', where: 'id = ?', whereArgs: [photo.id]);

        // Delete files
        try {
          final photoFile = PhotoStorageService.tryResolveLocalFile(
            photo.filePath,
          );
          if (photoFile != null && await photoFile.exists()) {
            await photoFile.delete();
          }

          if (photo.thumbnailPath != null) {
            final thumbnailFile = PhotoStorageService.tryResolveLocalFile(
              photo.thumbnailPath!,
            );
            if (thumbnailFile != null && await thumbnailFile.exists()) {
              await thumbnailFile.delete();
            }
          }
        } catch (e) {
          debugPrint('Error deleting photo files: $e');
        }

        deletedCount++;
      }

      // Exit selection mode and refresh
      _exitSelectionMode();
      await _loadNeedsAssigned();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$deletedCount photo${deletedCount != 1 ? 's' : ''} deleted',
            ),
            duration: const Duration(seconds: 2),
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
    }
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
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
                  'Make a new folder and place photos in Before or After.',
                ),
                onTap: () =>
                    Navigator.of(sheetContext).pop(_MoveOption.createFolder),
              ),
              ListTile(
                leading: const Icon(Icons.folder),
                title: const Text('Add to Existing Folder'),
                subtitle: const Text('Choose a folder under this equipment.'),
                onTap: () =>
                    Navigator.of(sheetContext).pop(_MoveOption.existingFolder),
              ),
              if (allowGeneralPhotos)
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Add to General Photos'),
                  subtitle: const Text(
                    'Move into the Photos tab for this equipment.',
                  ),
                  onTap: () =>
                      Navigator.of(sheetContext).pop(_MoveOption.generalPhotos),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<_FolderMoveOption?> _showFolderMoveOptions(
    BuildContext context,
    Equipment equipment, {
    required int folderCount,
  }) {
    return showModalBottomSheet<_FolderMoveOption>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Move ${folderCount > 1 ? 'folders' : 'folder'} to ${equipment.name}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.drive_file_move_outline),
                title: const Text('Move Folder to Equipment'),
                subtitle: const Text(
                  'Keep the folder intact under this equipment.',
                ),
                onTap: () => Navigator.of(
                  sheetContext,
                ).pop(_FolderMoveOption.moveFolder),
              ),
              ListTile(
                leading: const Icon(Icons.folder_copy),
                title: const Text("Add Folder's Images to Existing Folder"),
                subtitle: const Text(
                  'Merge photos into a folder on this equipment.',
                ),
                onTap: () => Navigator.of(
                  sheetContext,
                ).pop(_FolderMoveOption.mergeIntoExisting),
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
            onPressed: () => Navigator.of(dialogContext).pop(BeforeAfter.after),
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
}

enum _SelectionType { photos, folders }

enum _MoveOption { createFolder, existingFolder, generalPhotos }

enum _FolderMoveOption { moveFolder, mergeIntoExisting }
