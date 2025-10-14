import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../widgets/needs_assigned_badge.dart';

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
  List<Map<String, dynamic>> _standalonePhotos = [];
  bool _isLoading = true;

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

      List<Map<String, dynamic>> standalonePhotos;
      if (excludeIds.isEmpty) {
        standalonePhotos = await db.query(
          'photos',
          where: 'equipment_id = ?',
          whereArgs: [globalEquipmentId],
          orderBy: 'timestamp DESC',
        );
      } else {
        final placeholders = List.filled(excludeIds.length, '?').join(',');
        standalonePhotos = await db.query(
          'photos',
          where: 'equipment_id = ? AND id NOT IN ($placeholders)',
          whereArgs: [globalEquipmentId, ...excludeIds],
          orderBy: 'timestamp DESC',
        );
      }

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
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox),
            SizedBox(width: 8),
            Text('Needs Assigned'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(),
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
              'Photos (${_standalonePhotos.length})',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 8),
            ..._standalonePhotos.map((photo) => _buildPhotoCard(photo)),
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

  Widget _buildPhotoCard(Map<String, dynamic> photo) {
    final timestamp = DateTime.parse(photo['timestamp'] as String);
    final filePath = photo['file_path'] as String;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.photo, color: Colors.green),
        title: Text('Image - ${_formatDate(timestamp)}'),
        subtitle: Text('Captured ${_formatTime(timestamp)}'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // TODO: Navigate to photo detail page
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Photo detail view coming soon'),
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
