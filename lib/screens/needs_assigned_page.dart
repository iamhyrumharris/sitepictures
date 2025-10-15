import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';
import '../services/database_service.dart';
import '../widgets/needs_assigned_badge.dart';
import '../models/photo.dart';

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

  // Selection mode state
  bool _isSelectionMode = false;
  final Set<String> _selectedPhotoIds = {};

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
        setState(() => _isLoading = false);
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

      final excludeIds = folderPhotoIds.map((row) => row['photo_id'] as String).toList();

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
      final standalonePhotos = standalonePhotoMaps.map((map) => Photo.fromMap(map)).toList();

      setState(() {
        _folders = folders;
        _standalonePhotos = standalonePhotos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load: $e')),
        );
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
        if (_standalonePhotos.isNotEmpty)
          TextButton(
            onPressed: () => _enterSelectionMode(),
            child: const Text(
              'Select',
              style: TextStyle(color: Colors.white),
            ),
          ),
      ],
    );
  }

  PreferredSizeWidget _buildSelectionAppBar() {
    final selectedCount = _selectedPhotoIds.length;

    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: _exitSelectionMode,
      ),
      title: Text('$selectedCount selected'),
      actions: [
        if (_standalonePhotos.isNotEmpty)
          TextButton(
            onPressed: selectedCount == _standalonePhotos.length
                ? _deselectAllPhotos
                : _selectAllPhotos,
            child: Text(
              selectedCount == _standalonePhotos.length ? 'Deselect All' : 'Select All',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: _selectedPhotoIds.isEmpty ? null : _bulkDeletePhotos,
        ),
      ],
    );
  }

  Widget _buildContent() {
    final totalItems = _folders.length + _standalonePhotos.length;

    if (totalItems == 0) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No photos need assignment',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Use Quick Save from the camera to add photos here',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
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
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),

          // Folders
          if (_folders.isNotEmpty) ...[
            Text(
              'Folders (${_folders.length})',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 8),
            ..._folders.map((folder) => _buildFolderCard(folder)),
            const SizedBox(height: 16),
          ],

          // Standalone photos
          if (_standalonePhotos.isNotEmpty) ...[
            Text(
              'Individual Photos (${_standalonePhotos.length})',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.grey[600],
                  ),
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

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.folder, color: Colors.blue),
        title: Text(name),
        subtitle: Text('Created ${_formatDate(createdAt)}'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // TODO: Navigate to folder detail page
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Folder detail view coming soon'),
            ),
          );
        },
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
          context.push('/photo-viewer', extra: {
            'photos': _standalonePhotos,
            'initialIndex': photoIndex,
          });
        }
      },
      onLongPress: () {
        if (!_isSelectionMode) {
          // Enter selection mode with this photo selected
          _enterSelectionMode(photo.id);
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
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 18,
                ),
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
    final imageFile = File(imagePath);

    return FutureBuilder<bool>(
      future: imageFile.exists(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          );
        }

        if (snapshot.hasData && snapshot.data == true) {
          return Image.file(
            imageFile,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildPlaceholder();
            },
          );
        }

        return _buildPlaceholder();
      },
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[300],
      child: const Center(
        child: Icon(Icons.image, size: 40, color: Colors.grey),
      ),
    );
  }


  // Selection mode methods
  void _enterSelectionMode([String? initialPhotoId]) {
    setState(() {
      _isSelectionMode = true;
      _selectedPhotoIds.clear();
      if (initialPhotoId != null) {
        _selectedPhotoIds.add(initialPhotoId);
      }
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedPhotoIds.clear();
    });
  }

  void _togglePhotoSelection(String photoId) {
    setState(() {
      if (_selectedPhotoIds.contains(photoId)) {
        _selectedPhotoIds.remove(photoId);
        // Exit selection mode if no photos selected
        if (_selectedPhotoIds.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedPhotoIds.add(photoId);
      }
    });
  }

  void _selectAllPhotos() {
    setState(() {
      _selectedPhotoIds.clear();
      _selectedPhotoIds.addAll(_standalonePhotos.map((photo) => photo.id));
    });
  }

  void _deselectAllPhotos() {
    setState(() {
      _selectedPhotoIds.clear();
      _isSelectionMode = false;
    });
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

        deletedCount++;
      }

      // Exit selection mode and refresh
      _exitSelectionMode();
      await _loadNeedsAssigned();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$deletedCount photo${deletedCount != 1 ? 's' : ''} deleted'),
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
}
