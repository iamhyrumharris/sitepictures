import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../models/site.dart';
import '../../models/equipment.dart';
import '../../models/user.dart';
import '../../models/client.dart';
import '../../models/fab_menu_item.dart';
import '../../providers/app_state.dart';
import '../../providers/auth_state.dart';
import '../../providers/navigation_state.dart' as nav_state;
import '../../widgets/breadcrumb_navigation.dart';
import '../../widgets/expandable_fab.dart';
import '../../widgets/bottom_nav.dart';

/// Main site screen showing subsites and equipment
/// Implements FR-005, FR-006
class MainSiteScreen extends StatefulWidget {
  final String clientId;
  final String siteId;

  const MainSiteScreen({Key? key, required this.clientId, required this.siteId})
    : super(key: key);

  @override
  State<MainSiteScreen> createState() => _MainSiteScreenState();
}

class _MainSiteScreenState extends State<MainSiteScreen> {
  Client? _client;
  MainSite? _site;
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
      final client = await appState.getClient(widget.clientId);
      final site = await appState.getMainSite(widget.siteId);
      final subSites = await appState.getSubSites(widget.siteId);
      final equipment = await appState.getEquipmentForMainSite(widget.siteId);

      setState(() {
        _client = client;
        _site = site;
        _subSites = subSites;
        _equipment = equipment;
        _isLoading = false;
      });
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
          if (_client != null && _site != null)
            BreadcrumbNavigation(
              breadcrumbs: [
                nav_state.BreadcrumbItem(
                  id: widget.clientId,
                  title: _client!.name,
                  route: '/client/${widget.clientId}',
                ),
                nav_state.BreadcrumbItem(
                  id: _site!.id,
                  title: _site!.name,
                  route: '/site/${_site!.id}',
                ),
              ],
              onTap: (index) {
                if (index == 0) Navigator.pop(context);
              },
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

    if (_subSites.isEmpty && _equipment.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        children: [
          if (_subSites.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'SubSites',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            ..._subSites.map((subSite) => _buildSubSiteTile(subSite)),
          ],
          if (_equipment.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Equipment',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
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
            Icon(Icons.folder_open, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No SubSites or Equipment Yet',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Add subsites or equipment to organize this site',
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

  Widget _buildSubSiteTile(SubSite subSite) {
    return ListTile(
      leading: const Icon(Icons.folder, size: 40, color: Colors.orange),
      title: Text(subSite.name),
      subtitle: subSite.description != null ? Text(subSite.description!) : null,
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        context.push(
          '/subsite/${subSite.id}?clientId=${widget.clientId}&mainSiteId=${widget.siteId}',
        );
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

  /// T025, T030: Build expandable FAB with permission check
  Widget? _buildFAB() {
    final authState = context.watch<AuthState>();
    final user = authState.currentUser;

    // T030: Only show FAB for admin and technician roles (hide for viewer)
    if (user?.role == UserRole.viewer) {
      return null;
    }

    // T029: Use ExpandableFAB with menu items
    return ExpandableFAB(
      heroTag: 'mainsite_fab_${widget.siteId}',
      menuItems: _getFABMenuItems(),
    );
  }

  /// T026: Get FAB menu items (2 items for main site page)
  List<FABMenuItem> _getFABMenuItems() {
    return [
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
                  mainSiteId: widget.siteId,
                );

                Navigator.pop(context);
                await _loadData();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('SubSite created successfully')),
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
                  mainSiteId: widget.siteId,
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
}
