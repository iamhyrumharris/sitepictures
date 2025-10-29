import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/client.dart';
import '../../models/equipment.dart';
import '../../models/site.dart';
import '../../models/user.dart';
import '../../providers/app_state.dart';
import '../../providers/auth_state.dart';
import '../../providers/folder_provider.dart';
import '../../providers/navigation_state.dart' as nav_state;
import '../../widgets/breadcrumb_navigation.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/create_folder_dialog.dart';
import '../../services/recent_locations_service.dart';
import 'all_photos_tab.dart';
import 'folders_tab.dart';

class EquipmentScreen extends StatefulWidget {
  const EquipmentScreen({super.key, required this.equipmentId});

  final String equipmentId;

  @override
  State<EquipmentScreen> createState() => _EquipmentScreenState();
}

class _EquipmentScreenState extends State<EquipmentScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey _allPhotosKey = GlobalKey();
  Client? _client;
  MainSite? _mainSite;
  SubSite? _subSite;
  Equipment? _equipment;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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

      Client? client;
      MainSite? mainSite;
      SubSite? subSite;

      if (equipment != null) {
        if (equipment.clientId != null) {
          client = await appState.getClient(equipment.clientId!);
        } else if (equipment.mainSiteId != null) {
          mainSite = await appState.getMainSite(equipment.mainSiteId!);
          if (mainSite != null) {
            client = await appState.getClient(mainSite.clientId);
          }
        } else if (equipment.subSiteId != null) {
          subSite = await appState.getSubSite(equipment.subSiteId!);
          if (subSite != null) {
            if (subSite.mainSiteId != null) {
              mainSite = await appState.getMainSite(subSite.mainSiteId!);
              if (mainSite != null) {
                client = await appState.getClient(mainSite.clientId);
              }
            } else if (subSite.clientId != null) {
              client = await appState.getClient(subSite.clientId!);
            }
          }
        }
      }

      setState(() {
        _client = client;
        _mainSite = mainSite;
        _subSite = subSite;
        _equipment = equipment;
        _isLoading = false;
      });

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
        bottom: _equipment != null
            ? TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'All Photos'),
                  Tab(text: 'Folders'),
                ],
              )
            : null,
      ),
      body: Column(
        children: [
          if (_equipment != null) _buildBreadcrumb(),
          Expanded(child: _buildBody()),
        ],
      ),
      bottomNavigationBar: const BottomNav(currentIndex: -1),
      floatingActionButton: _buildFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildBreadcrumb() {
    final breadcrumbs = <nav_state.BreadcrumbItem>[];

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
        final popCount = breadcrumbs.length - 1 - index;
        for (var i = 0; i < popCount; i++) {
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

    if (_equipment == null) {
      return const Center(child: Text('Equipment not found'));
    }

    return TabBarView(
      controller: _tabController,
      children: [
        AllPhotosTab(key: _allPhotosKey, equipmentId: widget.equipmentId),
        FoldersTab(equipmentId: widget.equipmentId),
      ],
    );
  }

  Widget? _buildFAB() {
    final authState = context.watch<AuthState>();
    if (authState.currentUser?.role == UserRole.viewer) {
      return null;
    }

    if (_tabController.index == 0) {
      return FloatingActionButton(
        heroTag: 'equipment_camera_fab_${widget.equipmentId}',
        onPressed: _openQuickCapture,
        backgroundColor: const Color(0xFF10B981),
        child: const Icon(Icons.camera_alt),
        tooltip: 'Quick Capture',
      );
    }

    if (_tabController.index == 1) {
      return FloatingActionButton.extended(
        heroTag: 'create_folder_fab_${widget.equipmentId}',
        onPressed: _createFolder,
        backgroundColor: const Color(0xFF4A90E2),
        icon: const Icon(Icons.add),
        label: const Text('Create Folder'),
      );
    }

    return null;
  }

  Future<void> _createFolder() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => const CreateFolderDialog(),
    );

    if (result != null && mounted) {
      final appState = context.read<AppState>();
      final folderProvider = context.read<FolderProvider>();
      final authState = context.read<AuthState>();

      if (authState.currentUser != null) {
        appState.setCurrentUser(authState.currentUser);
      }

      final folder = await appState.createFolder(
        equipmentId: widget.equipmentId,
        workOrder: result,
      );

      if (folder != null) {
        await folderProvider.loadFolders(widget.equipmentId);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Folder created: ${folder.name}')),
          );
        }
      } else if (mounted) {
        final error = appState.errorMessage ?? 'Unknown error';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create folder: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _openQuickCapture() async {
    await context.push(
      '/camera-capture',
      extra: {
        'context': 'equipment-all-photos',
        'equipmentId': widget.equipmentId,
      },
    );

    if (mounted) {
      setState(() {});
    }
  }
}
