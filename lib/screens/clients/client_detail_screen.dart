import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../models/client.dart';
import '../../models/site.dart';
import '../../models/user.dart';
import '../../providers/app_state.dart';
import '../../providers/auth_state.dart';
import '../../providers/navigation_state.dart' as nav_state;
import '../../widgets/breadcrumb_navigation.dart';
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

      setState(() {
        _client = client;
        _sites = sites;
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
      floatingActionButton: _buildFAB(),
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

    if (_sites.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        itemCount: _sites.length,
        itemBuilder: (context, index) {
          return _buildSiteTile(_sites[index]);
        },
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
              onPressed: _showAddSiteDialog,
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

  Widget? _buildFAB() {
    final authState = context.watch<AuthState>();
    final user = authState.currentUser;

    // Only show FAB for admin and technician roles
    if (user?.role != UserRole.admin && user?.role != UserRole.technician) {
      return null;
    }

    return FloatingActionButton(
      heroTag: 'client_add_site_fab_${widget.clientId}',
      onPressed: _showAddSiteDialog,
      child: const Icon(Icons.add),
      tooltip: 'Add Main Site',
    );
  }

  void _showAddSiteDialog() {
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
}
