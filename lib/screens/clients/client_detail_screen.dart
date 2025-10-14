import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../models/client.dart';
import '../../models/site.dart';
import '../../models/equipment.dart';
import '../../models/user.dart';
import '../../models/fab_menu_item.dart';
import '../../providers/app_state.dart';
import '../../providers/auth_state.dart';
import '../../providers/navigation_state.dart' as nav_state;
import '../../widgets/breadcrumb_navigation.dart';
import '../../widgets/expandable_fab.dart';
import '../../widgets/bottom_nav.dart';
import '../../services/recent_locations_service.dart';

/// Client detail screen showing main sites
/// Implements FR-004, FR-005
class ClientDetailScreen extends StatefulWidget {
  final String clientId;

  const ClientDetailScreen({Key? key, required this.clientId})
    : super(key: key);

  @override
  State<ClientDetailScreen> createState() => _ClientDetailScreenState();
}

class _ClientDetailScreenState extends State<ClientDetailScreen> {
  Client? _client;
  List<MainSite> _sites = [];
  List<SubSite> _subSites = [];
  List<Equipment> _equipment = [];
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
      final client = await appState.getClient(widget.clientId);
      final sites = await appState.getMainSites(widget.clientId);
      final subSites = await appState.getSubSitesForClient(widget.clientId);
      final equipment = await appState.getEquipmentForClient(widget.clientId);

      setState(() {
        _client = client;
        _sites = sites;
        _subSites = subSites;
        _equipment = equipment;
        _isLoading = false;
      });

      // Track this location visit
      if (client != null && authState.currentUser != null) {
        final recentLocationsService = RecentLocationsService();
        await recentLocationsService.trackLocation(
          userId: authState.currentUser!.id,
          displayName: client.name,
          navigationPath: client.name,
          clientId: client.id,
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
          if (_client != null)
            BreadcrumbNavigation(
              breadcrumbs: [
                nav_state.BreadcrumbItem(
                  id: _client!.id,
                  title: _client!.name,
                  route: '/client/${_client!.id}',
                ),
              ],
              onTap: (index) => Navigator.pop(context),
            ),
          Expanded(child: _buildBody()),
        ],
      ),
      bottomNavigationBar: const BottomNav(currentIndex: -1),
      floatingActionButton: _buildFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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

    if (_sites.isEmpty && _subSites.isEmpty && _equipment.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        children: [
          if (_sites.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Main Sites',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            ..._sites.map((site) => _buildSiteTile(site)),
          ],
          if (_subSites.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'SubSites',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            ..._subSites.map((subSite) => _buildSubSiteTile(subSite)),
          ],
          if (_equipment.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Equipment',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            ..._equipment.map((equip) => _buildEquipmentTile(equip)),
          ],
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
            Icon(Icons.location_city, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No Main Sites Yet',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first main site to get started',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _showAddMainSiteDialog,
              icon: const Icon(Icons.add),
              label: const Text('Add Main Site'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSiteTile(MainSite site) {
    return ListTile(
      leading: const Icon(Icons.location_city, size: 40),
      title: Text(site.name),
      subtitle: site.address != null ? Text(site.address!) : null,
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        context.push('/site/${site.id}?clientId=${widget.clientId}');
      },
    );
  }

  Widget _buildSubSiteTile(SubSite subSite) {
    return ListTile(
      leading: const Icon(Icons.folder, size: 40, color: Colors.orange),
      title: Text(subSite.name),
      subtitle: subSite.description != null ? Text(subSite.description!) : null,
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        // Navigate to subsite - note: no mainSiteId since this belongs to client
        context.push('/subsite/${subSite.id}?clientId=${widget.clientId}');
      },
    );
  }

  Widget _buildEquipmentTile(Equipment equipment) {
    return ListTile(
      leading: const Icon(
        Icons.precision_manufacturing,
        size: 40,
        color: Colors.blue,
      ),
      title: Text(equipment.name),
      subtitle: equipment.serialNumber != null
          ? Text('S/N: ${equipment.serialNumber}')
          : null,
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        context.push('/equipment/${equipment.id}');
      },
    );
  }

  /// T018, T024: Build expandable FAB with permission check
  Widget? _buildFAB() {
    final authState = context.watch<AuthState>();
    final user = authState.currentUser;

    // T024: Only show FAB for admin and technician roles (hide for viewer)
    if (user?.role == UserRole.viewer) {
      return null;
    }

    // T023: Use ExpandableFAB with menu items
    return ExpandableFAB(
      heroTag: 'client_fab_${widget.clientId}',
      menuItems: _getFABMenuItems(),
    );
  }

  /// T019: Get FAB menu items (3 items for client page)
  List<FABMenuItem> _getFABMenuItems() {
    return [
      FABMenuItem(
        label: 'Add Main Site',
        icon: Icons.location_city,
        onTap: _showAddMainSiteDialog,
        backgroundColor: Colors.blue,
      ),
      FABMenuItem(
        label: 'Add SubSite',
        icon: Icons.folder,
        onTap: _showAddSubSiteDialog,
        backgroundColor: Colors.orange,
      ),
      FABMenuItem(
        label: 'Add Equipment',
        icon: Icons.precision_manufacturing,
        onTap: _showAddEquipmentDialog,
        backgroundColor: Colors.purple,
      ),
    ];
  }

  /// T020: Show main site creation dialog
  void _showAddMainSiteDialog() {
    final nameController = TextEditingController();
    final addressController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Main Site'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Site Name',
                hintText: 'Enter site name',
              ),
              maxLength: 100,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(
                labelText: 'Address (optional)',
                hintText: 'Enter address',
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a site name')),
                );
                return;
              }

              try {
                final appState = context.read<AppState>();
                await appState.createMainSite(
                  widget.clientId,
                  nameController.text.trim(),
                  addressController.text.trim().isEmpty
                      ? null
                      : addressController.text.trim(),
                );

                Navigator.pop(context);
                await _loadData();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Main site created successfully'),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  /// T021: Show subsite creation dialog
  void _showAddSubSiteDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add SubSite'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'SubSite Name',
                hintText: 'Enter subsite name',
              ),
              maxLength: 100,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                hintText: 'Enter description',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a subsite name')),
                );
                return;
              }

              try {
                final appState = context.read<AppState>();
                await appState.createSubSite(
                  nameController.text.trim(),
                  descriptionController.text.trim().isEmpty
                      ? null
                      : descriptionController.text.trim(),
                  clientId: widget.clientId,
                );

                Navigator.pop(context);
                await _loadData();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('SubSite created successfully')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  /// T022: Show equipment creation dialog
  void _showAddEquipmentDialog() {
    final nameController = TextEditingController();
    final serialController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Equipment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Equipment Name',
                hintText: 'Enter equipment name',
              ),
              maxLength: 100,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: serialController,
              decoration: const InputDecoration(
                labelText: 'Serial Number (optional)',
                hintText: 'Enter serial number',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter equipment name')),
                );
                return;
              }

              try {
                final appState = context.read<AppState>();
                await appState.createEquipment(
                  nameController.text.trim(),
                  clientId: widget.clientId,
                  serialNumber: serialController.text.trim().isEmpty
                      ? null
                      : serialController.text.trim(),
                );

                Navigator.pop(context);
                await _loadData();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Equipment created successfully'),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
