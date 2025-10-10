import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../models/photo_folder.dart';
import '../../providers/folder_provider.dart';
import '../../widgets/delete_folder_dialog.dart';

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
          ),
        );
      },
    );
  }
}
