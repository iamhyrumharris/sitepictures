import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../models/equipment.dart';
import '../../models/photo.dart';
import '../../models/user.dart';
import '../../models/client.dart';
import '../../models/site.dart';
import '../../providers/app_state.dart';
import '../../providers/auth_state.dart';
import '../../providers/navigation_state.dart' as nav_state;
import '../../widgets/breadcrumb_navigation.dart';
import '../../services/recent_locations_service.dart';

/// Equipment screen showing photos
/// Implements FR-007, FR-009
class EquipmentScreen extends StatefulWidget {
  final String equipmentId;

  const EquipmentScreen({Key? key, required this.equipmentId})
    : super(key: key);

  @override
  State<EquipmentScreen> createState() => _EquipmentScreenState();
}

class _EquipmentScreenState extends State<EquipmentScreen> {
  Client? _client;
  MainSite? _mainSite;
  SubSite? _subSite;
  Equipment? _equipment;
  List<Photo> _photos = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final appState = context.read<AppState>();
      final authState = context.read<AuthState>();
      final equipment = await appState.getEquipment(widget.equipmentId);
      final photos = await appState.getPhotos(widget.equipmentId);

      // Load hierarchy based on equipment location
      Client? client;
      MainSite? mainSite;
      SubSite? subSite;

      if (equipment != null) {
        if (equipment.mainSiteId != null) {
          mainSite = await appState.getMainSite(equipment.mainSiteId!);
          if (mainSite != null) {
            client = await appState.getClient(mainSite.clientId);
          }
        } else if (equipment.subSiteId != null) {
          subSite = await appState.getSubSite(equipment.subSiteId!);
          if (subSite != null) {
            mainSite = await appState.getMainSite(subSite.mainSiteId);
            if (mainSite != null) {
              client = await appState.getClient(mainSite.clientId);
            }
          }
        }
      }

      setState(() {
        _client = client;
        _mainSite = mainSite;
        _subSite = subSite;
        _equipment = equipment;
        _photos = photos;
        _isLoading = false;
      });

      // Track this location visit with actual names
      if (equipment != null && authState.currentUser != null) {
        final pathParts = <String>[];
        if (client != null) pathParts.add(client.name);
        if (mainSite != null) pathParts.add(mainSite.name);
        if (subSite != null) pathParts.add(subSite.name);
        pathParts.add(equipment.name);

        final recentLocationsService = RecentLocationsService();
        await recentLocationsService.trackLocation(
          userId: authState.currentUser!.id,
          displayName: equipment.name,
          navigationPath: pathParts.join(' > '),
          equipmentId: equipment.id,
          mainSiteId: equipment.mainSiteId,
          subSiteId: equipment.subSiteId,
        );
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Site Pictures'),
        backgroundColor: const Color(0xFF4A90E2),
      ),
      body: Column(
        children: [
          if (_equipment != null) _buildBreadcrumb(),
          Expanded(child: _buildBody()),
        ],
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildBreadcrumb() {
    final breadcrumbs = <nav_state.BreadcrumbItem>[];

    // Build breadcrumb from actual hierarchy
    if (_client != null) {
      breadcrumbs.add(
        nav_state.BreadcrumbItem(
          id: _client!.id,
          title: _client!.name,
          route: '/client/${_client!.id}',
        ),
      );
    }

    if (_mainSite != null) {
      breadcrumbs.add(
        nav_state.BreadcrumbItem(
          id: _mainSite!.id,
          title: _mainSite!.name,
          route: '/site/${_mainSite!.id}',
        ),
      );
    }

    if (_subSite != null) {
      breadcrumbs.add(
        nav_state.BreadcrumbItem(
          id: _subSite!.id,
          title: _subSite!.name,
          route: '/subsite/${_subSite!.id}',
        ),
      );
    }

    if (_equipment != null) {
      breadcrumbs.add(
        nav_state.BreadcrumbItem(
          id: _equipment!.id,
          title: _equipment!.name,
          route: '/equipment/${_equipment!.id}',
        ),
      );
    }

    return BreadcrumbNavigation(
      breadcrumbs: breadcrumbs,
      onTap: (index) {
        // Navigate back based on breadcrumb level
        int popCount = breadcrumbs.length - 1 - index;
        for (int i = 0; i < popCount; i++) {
          Navigator.pop(context);
        }
      },
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
            const SizedBox(height: 16),
            Text('Error: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadData, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_photos.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        // FR-021: Photo count warning
        if (_photos.length >= 90) _buildPhotoLimitWarning(),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadData,
            child: GridView.builder(
              padding: const EdgeInsets.all(8.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              itemCount: _photos.length,
              itemBuilder: (context, index) =>
                  _buildPhotoTile(_photos[index], index),
            ),
          ),
        ),
      ],
    );
  }

  // FR-021: Photo limit warning banner
  Widget _buildPhotoLimitWarning() {
    final count = _photos.length;
    final isAtLimit = count >= 100;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12.0),
      color: isAtLimit ? Colors.red[100] : Colors.orange[100],
      child: Row(
        children: [
          Icon(
            isAtLimit ? Icons.error : Icons.warning,
            color: isAtLimit ? Colors.red[900] : Colors.orange[900],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isAtLimit
                  ? 'Photo limit reached (100/100). Cannot capture more photos.'
                  : 'Warning: $count/100 photos. Approaching limit.',
              style: TextStyle(
                color: isAtLimit ? Colors.red[900] : Colors.orange[900],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo_camera, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No Photos Yet',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the camera button to capture photos',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoTile(Photo photo, int index) {
    return GestureDetector(
      onTap: () => _openCarousel(index),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // TODO: Load actual image from photo.filePath
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: const Icon(Icons.image, size: 48, color: Colors.grey),
          ),
          if (!photo.isSynced)
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.all(4.0),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: const Icon(
                  Icons.cloud_off,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _openCarousel(int initialIndex) {
    final photoPaths = _photos.map((p) => p.filePath).toList();
    context.push(
      '/carousel',
      extra: {
        'photos': photoPaths,
        'initialIndex': initialIndex,
        'equipmentId': widget.equipmentId,
      },
    );
  }

  Widget? _buildFAB() {
    final authState = context.watch<AuthState>();
    if (authState.currentUser?.role == UserRole.viewer) {
      return null;
    }

    return FloatingActionButton(
      heroTag: 'equipment_camera_fab_${widget.equipmentId}',
      onPressed: _openCamera,
      backgroundColor: const Color(0xFF4A90E2),
      child: const Icon(Icons.camera_alt),
      tooltip: 'Capture Photo',
    );
  }

  void _openCamera() {
    context.push('/camera/${widget.equipmentId}');
  }
}
