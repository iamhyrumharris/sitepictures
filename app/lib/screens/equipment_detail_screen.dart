import 'package:flutter/material.dart';
import '../models/equipment.dart';
import '../models/photo.dart';
import '../models/revision.dart';
import '../services/storage_service.dart';
import '../services/file_service.dart';
import 'dart:io';

// T052: Equipment detail screen with timeline
class EquipmentDetailScreen extends StatefulWidget {
  final Equipment equipment;

  const EquipmentDetailScreen({Key? key, required this.equipment}) : super(key: key);

  @override
  State<EquipmentDetailScreen> createState() => _EquipmentDetailScreenState();
}

class _EquipmentDetailScreenState extends State<EquipmentDetailScreen> {
  final StorageService _storageService = StorageService();
  final FileService _fileService = FileService();

  List<Photo> _photos = [];
  List<Revision> _revisions = [];
  bool _isLoading = true;
  bool _isTimelineView = true;
  Revision? _selectedRevision;

  @override
  void initState() {
    super.initState();
    _loadEquipmentData();
  }

  Future<void> _loadEquipmentData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load photos and revisions for the equipment
      final photos = await _storageService.getPhotosForEquipment(widget.equipment.id);
      final revisions = await _storageService.getRevisionsForEquipment(widget.equipment.id);

      // Sort photos by capture date (newest first for grid, oldest first for timeline)
      photos.sort((a, b) => _isTimelineView
          ? a.capturedAt.compareTo(b.capturedAt)
          : b.capturedAt.compareTo(a.capturedAt));

      setState(() {
        _photos = photos;
        _revisions = revisions;
      });
    } catch (e) {
      _showError('Failed to load equipment data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildTimeline() {
    if (_photos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo_library_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No photos yet',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _capturePhoto,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Take First Photo'),
            ),
          ],
        ),
      );
    }

    // Group photos by revision if available
    Map<String?, List<Photo>> photosByRevision = {};
    for (var photo in _photos) {
      photosByRevision.putIfAbsent(photo.revisionId, () => []).add(photo);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: photosByRevision.length,
      itemBuilder: (context, index) {
        final revisionId = photosByRevision.keys.elementAt(index);
        final revision = revisionId != null
            ? _revisions.firstWhere((r) => r.id == revisionId,
                orElse: () => Revision(
                      id: revisionId,
                      equipmentId: widget.equipment.id,
                      name: 'Unknown Revision',
                      createdAt: DateTime.now(),
                      createdBy: '',
                      isActive: true,
                    ))
            : null;
        final photos = photosByRevision[revisionId]!;

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (revision != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(4),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.history,
                        size: 20,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              revision.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            if (revision.description != null)
                              Text(
                                revision.description!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                          ],
                        ),
                      ),
                      Text(
                        _formatDate(revision.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),

              // Photo timeline items
              ...photos.map((photo) => _buildTimelineItem(photo)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimelineItem(Photo photo) {
    return InkWell(
      onTap: () => _viewPhoto(photo),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            FutureBuilder<File?>(
              future: _fileService.getPhotoFile(photo.fileName),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data != null) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      snapshot.data!,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  );
                } else {
                  return Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.image, color: Colors.grey),
                  );
                }
              },
            ),
            const SizedBox(width: 12),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatDateTime(photo.capturedAt),
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  if (photo.notes != null && photo.notes!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        photo.notes!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  if (photo.latitude != null && photo.longitude != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${photo.latitude!.toStringAsFixed(4)}, '
                            '${photo.longitude!.toStringAsFixed(4)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // Sync status
            Icon(
              photo.isSynced ? Icons.cloud_done : Icons.cloud_upload_outlined,
              size: 20,
              color: photo.isSynced ? Colors.green : Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoGrid() {
    if (_photos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo_library_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No photos yet',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _capturePhoto,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Take First Photo'),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: _photos.length,
      itemBuilder: (context, index) {
        final photo = _photos[index];
        return InkWell(
          onTap: () => _viewPhoto(photo),
          child: Stack(
            fit: StackFit.expand,
            children: [
              FutureBuilder<File?>(
                future: _fileService.getPhotoFile(photo.fileName),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data != null) {
                    return Image.file(
                      snapshot.data!,
                      fit: BoxFit.cover,
                    );
                  } else {
                    return Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.image, color: Colors.grey),
                    );
                  }
                },
              ),

              // Overlay indicators
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(
                    photo.isSynced ? Icons.cloud_done : Icons.cloud_upload_outlined,
                    size: 16,
                    color: photo.isSynced ? Colors.green : Colors.orange,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _capturePhoto() {
    Navigator.pushNamed(
      context,
      '/camera',
      arguments: widget.equipment,
    ).then((_) => _loadEquipmentData());
  }

  void _viewPhoto(Photo photo) {
    Navigator.pushNamed(
      context,
      '/photo-viewer',
      arguments: photo,
    );
  }

  void _createRevision() async {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Revision'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Revision Name',
                hintText: 'e.g., 2025-03 Upgrade',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                hintText: 'e.g., Replaced control panel',
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (result == true && nameController.text.isNotEmpty) {
      try {
        final revision = Revision(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          equipmentId: widget.equipment.id,
          name: nameController.text,
          description: descriptionController.text.isNotEmpty
              ? descriptionController.text
              : null,
          createdAt: DateTime.now(),
          createdBy: 'current_device_id', // TODO: Get actual device ID
          isActive: true,
        );

        await _storageService.createRevision(revision);
        _loadEquipmentData();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Revision created successfully')),
        );
      } catch (e) {
        _showError('Failed to create revision: $e');
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-'
           '${date.day.toString().padLeft(2, '0')}';
  }

  String _formatDateTime(DateTime date) {
    return '${_formatDate(date)} '
           '${date.hour.toString().padLeft(2, '0')}:'
           '${date.minute.toString().padLeft(2, '0')}';
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.equipment.name),
            if (widget.equipment.equipmentType != null)
              Text(
                widget.equipment.equipmentType!,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
              ),
          ],
        ),
        actions: [
          if (_photos.isNotEmpty)
            IconButton(
              icon: Icon(_isTimelineView ? Icons.grid_view : Icons.timeline),
              onPressed: () {
                setState(() {
                  _isTimelineView = !_isTimelineView;
                  if (_isTimelineView) {
                    _photos.sort((a, b) => a.capturedAt.compareTo(b.capturedAt));
                  } else {
                    _photos.sort((a, b) => b.capturedAt.compareTo(a.capturedAt));
                  }
                });
              },
              tooltip: _isTimelineView ? 'Grid View' : 'Timeline View',
            ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'revision':
                  _createRevision();
                  break;
                case 'info':
                  _showEquipmentInfo();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuMenuItem(
                value: 'revision',
                child: Text('Create Revision'),
              ),
              const PopupMenuItem(
                value: 'info',
                child: Text('Equipment Info'),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _isTimelineView ? _buildTimeline() : _buildPhotoGrid(),
      floatingActionButton: FloatingActionButton(
        onPressed: _capturePhoto,
        child: const Icon(Icons.camera_alt),
        tooltip: 'Take Photo',
      ),
    );
  }

  void _showEquipmentInfo() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Equipment Information',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Name', widget.equipment.name),
            if (widget.equipment.equipmentType != null)
              _buildInfoRow('Type', widget.equipment.equipmentType!),
            if (widget.equipment.manufacturer != null)
              _buildInfoRow('Manufacturer', widget.equipment.manufacturer!),
            if (widget.equipment.model != null)
              _buildInfoRow('Model', widget.equipment.model!),
            if (widget.equipment.serialNumber != null)
              _buildInfoRow('Serial Number', widget.equipment.serialNumber!),
            if (widget.equipment.tags.isNotEmpty)
              _buildInfoRow('Tags', widget.equipment.tags.join(', ')),
            _buildInfoRow('Photos', '${_photos.length}'),
            _buildInfoRow('Revisions', '${_revisions.length}'),
            _buildInfoRow('Created', _formatDate(widget.equipment.createdAt)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}