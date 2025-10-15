import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../models/photo.dart';
import '../../providers/app_state.dart';
import '../../widgets/folder_badge.dart';
import '../../widgets/photo_delete_dialog.dart';
import '../../services/database_service.dart';
import 'dart:io';

class AllPhotosTab extends StatefulWidget {
  final String equipmentId;

  const AllPhotosTab({super.key, required this.equipmentId});

  @override
  State<AllPhotosTab> createState() => _AllPhotosTabState();
}

class _AllPhotosTabState extends State<AllPhotosTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  List<Photo> _photos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Defer loading until after the first frame to avoid calling setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPhotos();
    });
  }

  Future<void> _loadPhotos() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    final appState = context.read<AppState>();
    final photos = await appState.getPhotosWithFolderInfo(widget.equipmentId);

    if (mounted) {
      setState(() {
        _photos = photos;
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshPhotos() async {
    await _loadPhotos();
  }

  Future<void> _deletePhoto(Photo photo) async {
    bool confirmed = false;

    await showDialog(
      context: context,
      builder: (context) => PhotoDeleteDialog(
        photoId: photo.id,
        onConfirm: () {
          confirmed = true;
        },
      ),
    );

    if (confirmed) {
      try {
        final dbService = DatabaseService();
        final db = await dbService.database;

        // Delete photo record from database
        await db.delete('photos', where: 'id = ?', whereArgs: [photo.id]);

        // Delete photo files from storage
        try {
          final photoFile = File(photo.filePath);
          if (await photoFile.exists()) {
            await photoFile.delete();
          }

          if (photo.thumbnailPath != null) {
            final thumbnailFile = File(photo.thumbnailPath!);
            if (await thumbnailFile.exists()) {
              await thumbnailFile.delete();
            }
          }
        } catch (e) {
          debugPrint('Error deleting photo files: $e');
        }

        // Refresh the photos list
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
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

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

    return RefreshIndicator(
      onRefresh: _refreshPhotos,
      child: GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 1,
        ),
        itemCount: _photos.length,
        itemBuilder: (context, index) {
          final photo = _photos[index];
          return _buildPhotoTile(photo);
        },
      ),
    );
  }

  Widget _buildPhotoTile(Photo photo) {
    final photoIndex = _photos.indexOf(photo);

    return GestureDetector(
      onTap: () {
        // Navigate to photo viewer with all photos
        context.push('/photo-viewer', extra: {
          'photos': _photos,
          'initialIndex': photoIndex,
        });
      },
      onLongPress: () {
        _showPhotoContextMenu(photo);
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Photo thumbnail
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: _buildPhotoImage(photo),
            ),
          ),

          // Folder badge if photo is in a folder
          if (photo.folderId != null && photo.folderName != null)
            FolderBadge(folderName: photo.folderName!),
        ],
      ),
    );
  }

  Widget _buildPhotoImage(Photo photo) {
    // Try thumbnail first, then fall back to full photo
    final imagePath = photo.thumbnailPath ?? photo.filePath;

    return Image.file(
      File(imagePath),
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return const Icon(Icons.image, size: 40, color: Colors.grey);
      },
    );
  }

  void _showPhotoContextMenu(Photo photo) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Photo'),
              onTap: () {
                Navigator.pop(context);
                _deletePhoto(photo);
              },
            ),
          ],
        ),
      ),
    );
  }
}
