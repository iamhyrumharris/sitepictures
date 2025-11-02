import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../models/equipment.dart';
import '../../models/user.dart';
import '../../models/client.dart';
import '../../models/site.dart';
import '../../providers/app_state.dart';
import '../../providers/auth_state.dart';
import '../../providers/navigation_state.dart' as nav_state;
import '../../providers/folder_provider.dart';
import '../../widgets/breadcrumb_navigation.dart';
import '../../widgets/create_folder_dialog.dart';
import '../../widgets/bottom_nav.dart';
import '../../services/recent_locations_service.dart';
import 'all_photos_tab.dart';
import 'folders_tab.dart';
import '../../widgets/fab_visibility_scope.dart';

/// Equipment screen showing photos
/// Implements FR-001, FR-002 (tab navigation), FR-007, FR-009
class EquipmentScreen extends StatefulWidget {
  final String equipmentId;

  const EquipmentScreen({Key? key, required this.equipmentId})
    : super(key: key);

  @override
  State<EquipmentScreen> createState() => _EquipmentScreenState();
}

class _EquipmentScreenState extends State<EquipmentScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey _allPhotosKey = GlobalKey();
  late final FabVisibilityController _fabVisibilityController;
  Client? _client;
  MainSite? _mainSite;
  SubSite? _subSite;
  Equipment? _equipment;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fabVisibilityController = FabVisibilityController()
      ..addListener(_handleFabVisibilityChanged);
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // Rebuild to update FAB visibility
    });
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fabVisibilityController
      ..removeListener(_handleFabVisibilityChanged)
      ..dispose();
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

      // Load hierarchy based on equipment location
      Client? client;
      MainSite? mainSite;
      SubSite? subSite;

      if (equipment != null) {
        if (equipment.clientId != null) {
          // Equipment belongs directly to a client
          client = await appState.getClient(equipment.clientId!);
        } else if (equipment.mainSiteId != null) {
          // Equipment belongs to a main site
          mainSite = await appState.getMainSite(equipment.mainSiteId!);
          if (mainSite != null) {
            client = await appState.getClient(mainSite.clientId);
          }
        } else if (equipment.subSiteId != null) {
          // Equipment belongs to a subsite
          subSite = await appState.getSubSite(equipment.subSiteId!);
          if (subSite != null) {
            // SubSite can belong to client, mainSite, or parent subsite
            if (subSite.mainSiteId != null) {
              mainSite = await appState.getMainSite(subSite.mainSiteId!);
              if (mainSite != null) {
                client = await appState.getClient(mainSite.clientId);
              }
            } else if (subSite.clientId != null) {
              client = await appState.getClient(subSite.clientId!);
            }
            // Note: We're not traversing parent subsites for breadcrumbs
            // as that would require recursive lookups
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
    final fab = _fabVisibilityController.isVisible ? _buildFAB() : null;

    return FabVisibilityScope(
      controller: _fabVisibilityController,
      child: Scaffold(
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
        floatingActionButton: fab,
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
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

  Future<void> _createFolder() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => const CreateFolderDialog(),
    );

    if (result != null && mounted) {
      debugPrint('Creating folder with work order: $result');

      final appState = context.read<AppState>();
      final folderProvider = context.read<FolderProvider>();
      final authState = context.read<AuthState>();

      // Ensure AppState has the current user
      if (authState.currentUser != null) {
        appState.setCurrentUser(authState.currentUser);
        debugPrint('Set current user in AppState: ${authState.currentUser!.email}');
      } else {
        debugPrint('ERROR: No current user in AuthState!');
      }

      final folder = await appState.createFolder(
        equipmentId: widget.equipmentId,
        workOrder: result,
      );

      debugPrint('Folder created: ${folder?.id} - ${folder?.name}');

      if (folder != null) {
        // Reload folders in the provider
        await folderProvider.loadFolders(widget.equipmentId);

        debugPrint('Folders reloaded: ${folderProvider.folders.length} folders');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Folder created: ${folder.name}')),
          );
        }
      } else if (mounted) {
        final error = appState.errorMessage ?? 'Unknown error';
        debugPrint('Failed to create folder: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create folder: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget? _buildFAB() {
    final authState = context.watch<AuthState>();
    if (authState.currentUser?.role == UserRole.viewer) {
      return null;
    }

    // Show different FAB based on active tab
    if (_tabController.index == 0) {
      // All Photos tab - show camera FAB
      return FloatingActionButton(
        heroTag: 'equipment_camera_fab_${widget.equipmentId}',
        onPressed: _openQuickCapture,
        backgroundColor: const Color(0xFF10B981),
        child: const Icon(Icons.camera_alt),
        tooltip: 'Quick Capture',
      );
    } else if (_tabController.index == 1) {
      // Folders tab - show create folder FAB
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

  void _handleFabVisibilityChanged() {
    if (!mounted) return;

    // Avoid setState during build; schedule if we're mid-frame.
    if (SchedulerBinding.instance.schedulerPhase == SchedulerPhase.idle) {
      setState(() {});
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  void _openQuickCapture() async {
    // T033: Launch camera with equipment all photos context
    await context.push('/camera-capture', extra: {
      'context': 'equipment-all-photos',
      'equipmentId': widget.equipmentId,
    });

    // T037: Force rebuild to refresh All Photos list
    if (mounted) {
      final state = _allPhotosKey.currentState;
      if (state is AllPhotosTabState) {
        await state.reload();
      }
      setState(() {});
    }
  }
}
