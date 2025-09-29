import 'package:flutter/material.dart';
import 'dart:io';
import '../models/photo.dart';
import '../models/equipment.dart';
import '../services/storage_service.dart';
import '../services/file_service.dart';

// T055: Photo gallery screen with thumbnails
class GalleryScreen extends StatefulWidget {
  final Photo? initialPhoto;
  final Equipment? equipment;

  const GalleryScreen({
    Key? key,
    this.initialPhoto,
    this.equipment,
  }) : super(key: key);

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  final StorageService _storageService = StorageService();
  final FileService _fileService = FileService();

  List<Photo> _photos = [];
  bool _isLoading = true;
  bool _isSelectionMode = false;
  Set<String> _selectedPhotoIds = {};

  // View options
  int _gridColumns = 3;
  bool _showOnlyUnsynced = false;
  String _sortBy = 'date_desc'; // date_desc, date_asc, name

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<Photo> photos;

      if (widget.equipment != null) {
        // Load photos for specific equipment
        photos = await _storageService.getPhotosForEquipment(widget.equipment!.id);
      } else {
        // Load all photos or recent photos
        photos = await _storageService.getRecentPhotos(limit: 500);
      }

      // Apply filters
      if (_showOnlyUnsynced) {
        photos = photos.where((p) => !p.isSynced).toList();
      }

      // Apply sorting
      _sortPhotos(photos);

      setState(() {
        _photos = photos;
      });

      // If initial photo provided, scroll to it
      if (widget.initialPhoto != null) {
        _scrollToPhoto(widget.initialPhoto!);
      }

    } catch (e) {
      _showError('Failed to load photos: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _sortPhotos(List<Photo> photos) {
    switch (_sortBy) {
      case 'date_asc':
        photos.sort((a, b) => a.capturedAt.compareTo(b.capturedAt));
        break;
      case 'date_desc':
        photos.sort((a, b) => b.capturedAt.compareTo(a.capturedAt));
        break;
      case 'name':
        photos.sort((a, b) => (a.notes ?? a.id).compareTo(b.notes ?? b.id));
        break;
    }
  }

  void _scrollToPhoto(Photo photo) {
    // TODO: Implement scroll to specific photo
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedPhotoIds.clear();
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
    });
  }

  void _selectAll() {
    setState(() {
      _selectedPhotoIds = _photos.map((p) => p.id).toSet();
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedPhotoIds.clear();
    });
  }

  Future<void> _deleteSelectedPhotos() async {
    final count = _selectedPhotoIds.length;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Photos'),
        content: Text('Are you sure you want to delete $count photo${count > 1 ? 's' : ''}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        for (final photoId in _selectedPhotoIds) {
          await _storageService.deletePhoto(photoId);
        }

        _showSuccess('Deleted $count photo${count > 1 ? 's' : ''}');
        _toggleSelectionMode();
        _loadPhotos();

      } catch (e) {
        _showError('Failed to delete photos: $e');
      }
    }
  }

  Future<void> _assignSelectedPhotos() async {
    // Navigate to equipment selection
    final equipment = await Navigator.pushNamed(
      context,
      '/select-equipment',
    ) as Equipment?;

    if (equipment != null) {
      try {
        for (final photoId in _selectedPhotoIds) {
          await _storageService.assignPhotoToEquipment(photoId, equipment.id);
        }

        _showSuccess('Assigned ${_selectedPhotoIds.length} photos to ${equipment.name}');
        _toggleSelectionMode();
        _loadPhotos();

      } catch (e) {
        _showError('Failed to assign photos: $e');
      }
    }
  }

  Widget _buildPhotoGrid() {
    if (_photos.isEmpty) {
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
              _showOnlyUnsynced ? 'No unsynced photos' : 'No photos yet',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/camera'),
              icon: const Icon(Icons.camera_alt),
              label: const Text('Take Photo'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPhotos,
      child: GridView.builder(
        padding: const EdgeInsets.all(4),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _gridColumns,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemCount: _photos.length,
        itemBuilder: (context, index) {
          final photo = _photos[index];
          final isSelected = _selectedPhotoIds.contains(photo.id);

          return GestureDetector(
            onTap: () {
              if (_isSelectionMode) {
                _togglePhotoSelection(photo.id);
              } else {
                _viewPhoto(photo);
              }
            },
            onLongPress: () {
              if (!_isSelectionMode) {
                _toggleSelectionMode();
                _togglePhotoSelection(photo.id);
              }
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Photo thumbnail
                Hero(
                  tag: 'photo-${photo.id}',
                  child: FutureBuilder<File?>(
                    future: _fileService.getThumbnail(photo.fileName),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data != null) {
                        return Image.file(
                          snapshot.data!,
                          fit: BoxFit.cover,
                        );
                      } else {
                        return Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      }
                    },
                  ),
                ),

                // Selection overlay
                if (_isSelectionMode)
                  Positioned.fill(
                    child: Container(
                      color: isSelected
                          ? Theme.of(context).primaryColor.withOpacity(0.3)
                          : Colors.transparent,
                      child: Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected
                                  ? Theme.of(context).primaryColor
                                  : Colors.white.withOpacity(0.8),
                              border: Border.all(
                                color: isSelected
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey,
                                width: 2,
                              ),
                            ),
                            child: isSelected
                                ? const Icon(
                                    Icons.check,
                                    size: 16,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                        ),
                      ),
                    ),
                  ),

                // Status indicators
                if (!_isSelectionMode)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!photo.isSynced)
                            const Icon(
                              Icons.cloud_upload_outlined,
                              size: 16,
                              color: Colors.orange,
                            ),
                          if (photo.notes != null && photo.notes!.isNotEmpty)
                            const Icon(
                              Icons.note,
                              size: 16,
                              color: Colors.white,
                            ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _viewPhoto(Photo photo) {
    Navigator.pushNamed(
      context,
      '/photo-viewer',
      arguments: photo,
    );
  }

  void _showViewOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'View Options',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            // Grid size
            ListTile(
              leading: const Icon(Icons.grid_view),
              title: const Text('Grid Size'),
              trailing: DropdownButton<int>(
                value: _gridColumns,
                items: [2, 3, 4, 5].map((cols) {
                  return DropdownMenuItem(
                    value: cols,
                    child: Text('$cols columns'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _gridColumns = value!;
                  });
                  Navigator.pop(context);
                },
              ),
            ),

            // Sort order
            ListTile(
              leading: const Icon(Icons.sort),
              title: const Text('Sort By'),
              trailing: DropdownButton<String>(
                value: _sortBy,
                items: const [
                  DropdownMenuItem(
                    value: 'date_desc',
                    child: Text('Newest First'),
                  ),
                  DropdownMenuItem(
                    value: 'date_asc',
                    child: Text('Oldest First'),
                  ),
                  DropdownMenuItem(
                    value: 'name',
                    child: Text('Name'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _sortBy = value!;
                  });
                  _loadPhotos();
                  Navigator.pop(context);
                },
              ),
            ),

            // Filter unsynced
            SwitchListTile(
              secondary: const Icon(Icons.cloud_off),
              title: const Text('Show Only Unsynced'),
              value: _showOnlyUnsynced,
              onChanged: (value) {
                setState(() {
                  _showOnlyUnsynced = value;
                });
                _loadPhotos();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.equipment != null
        ? widget.equipment!.name
        : 'Photo Gallery';

    return Scaffold(
      appBar: AppBar(
        title: Text(_isSelectionMode
            ? '${_selectedPhotoIds.length} selected'
            : title),
        leading: _isSelectionMode
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: _toggleSelectionMode,
              )
            : null,
        actions: [
          if (_isSelectionMode) ...[
            if (_selectedPhotoIds.length < _photos.length)
              TextButton(
                onPressed: _selectAll,
                child: const Text('Select All'),
              )
            else
              TextButton(
                onPressed: _clearSelection,
                child: const Text('Clear'),
              ),
          ] else ...[
            if (_photos.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.select_all),
                onPressed: _toggleSelectionMode,
                tooltip: 'Select',
              ),
            IconButton(
              icon: const Icon(Icons.tune),
              onPressed: _showViewOptions,
              tooltip: 'View Options',
            ),
          ],
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildPhotoGrid(),
      bottomNavigationBar: _isSelectionMode && _selectedPhotoIds.isNotEmpty
          ? BottomAppBar(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    icon: const Icon(Icons.folder),
                    onPressed: _assignSelectedPhotos,
                    tooltip: 'Assign to Equipment',
                  ),
                  IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: () {
                      // TODO: Implement share
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Share coming soon')),
                      );
                    },
                    tooltip: 'Share',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: _deleteSelectedPhotos,
                    tooltip: 'Delete',
                  ),
                ],
              ),
            )
          : null,
    );
  }
}