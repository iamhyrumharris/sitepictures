import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../models/photo.dart';
import '../../models/folder_photo.dart';
import '../../providers/folder_provider.dart';
import '../../widgets/photo_delete_dialog.dart';
import '../../widgets/bottom_nav.dart';
import '../../services/database_service.dart';
import '../../services/photo_storage_service.dart';

class FolderDetailScreen extends StatefulWidget {
  final String equipmentId;
  final String folderId;

  const FolderDetailScreen({
    super.key,
    required this.equipmentId,
    required this.folderId,
  });

  @override
  State<FolderDetailScreen> createState() => _FolderDetailScreenState();
}

class _FolderDetailScreenState extends State<FolderDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _activeTabIndex = 0;
  List<Photo> _beforePhotos = [];
  List<Photo> _afterPhotos = [];
  bool _isLoading = true;
  String _folderName = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _activeTabIndex = _tabController.index;
    _tabController.addListener(_handleTabChange);
    // Defer loading until after the first frame to avoid calling setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPhotos();
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      // Ignore intermediate values while the controller animates between tabs.
      return;
    }

    // Track the active tab so camera saves to the matching before/after category.
    _activeTabIndex = _tabController.index;
  }

  Future<void> _loadPhotos() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    final folderProvider = context.read<FolderProvider>();

    // Load before and after photos
    final beforePhotos = await folderProvider.getBeforePhotos(widget.folderId);
    final afterPhotos = await folderProvider.getAfterPhotos(widget.folderId);

    if (mounted) {
      setState(() {
        _beforePhotos = beforePhotos;
        _afterPhotos = afterPhotos;
        _isLoading = false;
      });
    }
  }

  void _capturePhotos() async {
    final currentTab = _activeTabIndex;
    final beforeAfter = currentTab == 0
        ? BeforeAfter.before
        : BeforeAfter.after;

    // T040-T041: Navigate to camera with before/after context
    final contextStr = currentTab == 0 ? 'equipment-before' : 'equipment-after';
    final result = await context.push(
      '/camera-capture',
      extra: {
        'context': contextStr,
        'folderId': widget.folderId,
        'equipmentId': widget.equipmentId, // Add equipmentId for fallback save
        'beforeAfter': beforeAfter.name,
      },
    );

    // T045: Refresh Before/After photo lists to show newly saved photos
    if (mounted) {
      await _loadPhotos();

      // T047: Update folder photo count in Folders tab list
      // (This would be handled by FolderProvider reloading folder metadata)
    }
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

        // Delete photo record from database (CASCADE will remove folder_photos entry)
        await db.delete('photos', where: 'id = ?', whereArgs: [photo.id]);

        // Delete photo files from storage
        try {
          final photoFile = PhotoStorageService.tryResolveLocalFile(photo.filePath);
          if (photoFile != null && await photoFile.exists()) {
            await photoFile.delete();
          }

          if (photo.thumbnailPath != null) {
            final thumbnailFile =
                PhotoStorageService.tryResolveLocalFile(photo.thumbnailPath!);
            if (thumbnailFile != null && await thumbnailFile.exists()) {
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
    return Scaffold(
      appBar: AppBar(
        title: Text(_folderName.isEmpty ? 'Folder' : _folderName),
        bottom: TabBar(
          controller: _tabController,
          onTap: (index) {
            _activeTabIndex = index;
          },
          tabs: [
            Tab(text: 'Before (${_beforePhotos.length})'),
            Tab(text: 'After (${_afterPhotos.length})'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _BeforeAfterPhotoTab(
                  photos: _beforePhotos,
                  label: 'before',
                  onDeletePhoto: _deletePhoto,
                ),
                _BeforeAfterPhotoTab(
                  photos: _afterPhotos,
                  label: 'after',
                  onDeletePhoto: _deletePhoto,
                ),
              ],
            ),
      bottomNavigationBar: const BottomNav(currentIndex: -1),
      floatingActionButton: FloatingActionButton(
        onPressed: _capturePhotos,
        child: const Icon(Icons.camera_alt),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class _BeforeAfterPhotoTab extends StatefulWidget {
  final List<Photo> photos;
  final String label;
  final Function(Photo) onDeletePhoto;

  const _BeforeAfterPhotoTab({
    required this.photos,
    required this.label,
    required this.onDeletePhoto,
  });

  @override
  State<_BeforeAfterPhotoTab> createState() => _BeforeAfterPhotoTabState();
}

class _BeforeAfterPhotoTabState extends State<_BeforeAfterPhotoTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    if (widget.photos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No ${widget.label} photos',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap camera to capture',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: widget.photos.length,
      itemBuilder: (context, index) {
        final photo = widget.photos[index];
        return _buildPhotoTile(photo);
      },
    );
  }

  Widget _buildPhotoTile(Photo photo) {
    final photoIndex = widget.photos.indexOf(photo);

    return GestureDetector(
      onTap: () {
        // Navigate to photo viewer with photos from current tab
        context.push('/photo-viewer', extra: {
          'photos': widget.photos,
          'initialIndex': photoIndex,
        });
      },
      onLongPress: () {
        _showPhotoContextMenu(photo);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: _buildPhotoImage(photo),
        ),
      ),
    );
  }

  Widget _buildPhotoImage(Photo photo) {
    // Try thumbnail first, then fall back to full photo
    final imagePath = photo.thumbnailPath ?? photo.filePath;

    final localFile = PhotoStorageService.tryResolveLocalFile(imagePath);

    if (localFile != null) {
      return Image.file(
        localFile,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.image, size: 40, color: Colors.grey);
        },
      );
    }

    if (photo.remoteUrl != null && photo.remoteUrl!.isNotEmpty) {
      return Image.network(
        photo.remoteUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, _, __) =>
            const Icon(Icons.image, size: 40, color: Colors.grey),
      );
    }

    return const Icon(Icons.image, size: 40, color: Colors.grey);
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
                widget.onDeletePhoto(photo);
              },
            ),
          ],
        ),
      ),
    );
  }
}
