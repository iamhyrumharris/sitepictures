import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../models/equipment.dart';
import '../../models/photo_folder.dart';
import '../../providers/folder_provider.dart';
import '../../providers/equipment_navigator_provider.dart';
import '../../services/needs_assigned_move_service.dart';
import '../../widgets/delete_folder_dialog.dart';
import '../../widgets/rename_folder_dialog.dart';
import '../equipment_navigator_page.dart';

class FoldersTab extends StatefulWidget {
  final String equipmentId;

  const FoldersTab({super.key, required this.equipmentId});

  @override
  State<FoldersTab> createState() => _FoldersTabState();
}

class _FoldersTabState extends State<FoldersTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Defer loading until after the first frame to avoid calling setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFolders();
    });
  }

  Future<void> _loadFolders() async {
    if (!mounted) return;
    final folderProvider = context.read<FolderProvider>();
    await folderProvider.loadFolders(widget.equipmentId);
  }

  Future<void> _deleteFolder(PhotoFolder folder, int photoCount) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => DeleteFolderDialog(
        folderName: folder.name,
        photoCount: photoCount,
        onConfirm: (deletePhotos) => deletePhotos,
      ),
    );

    if (result != null && mounted) {
      final folderProvider = context.read<FolderProvider>();

      final success = await folderProvider.deleteFolder(
        folderId: folder.id,
        equipmentId: widget.equipmentId,
        deletePhotos: result,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Folder deleted')));
      }
    }
  }

  void _showFolderOptions(PhotoFolder folder, int photoCount) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.drive_file_move),
              title: const Text('Move Folder'),
              onTap: () {
                Navigator.of(context).pop();
                _moveFolder(folder);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Rename Folder'),
              onTap: () {
                Navigator.of(context).pop();
                _renameFolder(folder);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Delete Folder'),
              onTap: () {
                Navigator.of(context).pop();
                _deleteFolder(folder, photoCount);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _renameFolder(PhotoFolder folder) async {
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => RenameFolderDialog(initialName: folder.name),
    );

    if (newName == null) {
      return;
    }

    final trimmedName = newName.trim();
    if (trimmedName.isEmpty || trimmedName == folder.name) {
      return;
    }

    final folderProvider = context.read<FolderProvider>();
    final success = await folderProvider.renameFolder(
      folderId: folder.id,
      equipmentId: widget.equipmentId,
      newName: trimmedName,
    );

    if (!mounted) {
      return;
    }

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Folder renamed')),
      );
      return;
    }

    final error = folderProvider.errorMessage;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to rename folder'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _moveFolder(PhotoFolder folder) async {
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

    if (equipment.id == widget.equipmentId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Folder is already on this equipment.'),
        ),
      );
      return;
    }

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
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
    progressOpen = true;

    try {
      final moveService = NeedsAssignedMoveService();
      final summary = await moveService.moveFoldersToEquipment(
        folderIds: [folder.id],
        sourceEquipmentId: widget.equipmentId,
        targetEquipmentId: equipment.id,
      );

      closeProgress();

      if (!mounted) {
        return;
      }

      final folderProvider = context.read<FolderProvider>();
      await folderProvider.loadFolders(widget.equipmentId);

      if (summary.hasChanges) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Folder moved to ${equipment.name}'),
            action: SnackBarAction(
              label: 'Open',
              onPressed: () {
                GoRouter.of(context).push('/equipment/${equipment.id}');
              },
              textColor: Colors.white,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No changes were made to the folder location.'),
          ),
        );
      }
    } catch (e) {
      closeProgress();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to move folder: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      closeProgress();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    return Consumer<FolderProvider>(
      builder: (context, folderProvider, child) {
        if (folderProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final folders = folderProvider.folders;

        if (folders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.folder_outlined, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                const Text(
                  'No Folders Yet',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap "Create Folder" to organize photos',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: folders.length,
          itemBuilder: (context, index) {
            final folder = folders[index];
            return _buildFolderTile(folder, folderProvider);
          },
        );
      },
    );
  }

  Widget _buildFolderTile(PhotoFolder folder, FolderProvider folderProvider) {
    return FutureBuilder<Map<String, int>>(
      future: folderProvider.getPhotoCountsForFolder(folder.id),
      builder: (context, snapshot) {
        final photoCount = snapshot.hasData
            ? (snapshot.data!['before']! + snapshot.data!['after']!)
            : 0;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            leading: const Icon(Icons.folder, size: 40),
            title: Text(
              folder.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '$photoCount ${photoCount == 1 ? 'photo' : 'photos'}',
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _deleteFolder(folder, photoCount),
            ),
            onTap: () {
              context.push(
                '/equipment/${widget.equipmentId}/folder/${folder.id}',
              );
            },
            onLongPress: () => _showFolderOptions(folder, photoCount),
          ),
        );
      },
    );
  }
}
