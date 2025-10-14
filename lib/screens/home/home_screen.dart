import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_state.dart';
import '../../providers/sync_state.dart';
import '../../models/client.dart';
import '../../models/recent_location.dart';
import '../../services/database_service.dart';
import '../../widgets/client_list_tile.dart';
import '../../widgets/recent_location_card.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/error_message.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseService _dbService = DatabaseService();
  List<Client>? _clients;
  List<RecentLocation>? _recentLocations;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final db = await _dbService.database;
      final authState = context.read<AuthState>();
      final userId = authState.currentUser?.id;

      // Load clients (exclude system clients like GLOBAL_NEEDS_ASSIGNED)
      final clientResults = await db.query(
        'clients',
        where: 'is_active = ?',
        whereArgs: [1],
        orderBy: 'name ASC',
      );
      _clients = clientResults
          .map((map) => Client.fromMap(map))
          .where((client) => !client.isSystem)
          .toList();

      // Load recent locations
      if (userId != null) {
        final recentResults = await db.query(
          'recent_locations',
          where: 'user_id = ?',
          whereArgs: [userId],
          orderBy: 'accessed_at DESC',
          limit: 10,
        );
        _recentLocations = recentResults
            .map((map) => RecentLocation.fromMap(map))
            .toList();
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final authState = context.watch<AuthState>();
    final syncState = context.watch<SyncState>();

    return AppBar(
      title: const Text('Ziatech'),
      backgroundColor: const Color(0xFF4A90E2),
      actions: [
        // Search button (FR-012)
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () => context.push('/search'),
          tooltip: 'Search',
        ),
        // Sync status
        if (syncState.pendingCount > 0)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Center(
              child: Badge(
                label: Text('${syncState.pendingCount}'),
                child: IconButton(
                  icon: const Icon(Icons.cloud_upload),
                  onPressed: () => syncState.syncAll(),
                ),
              ),
            ),
          ),
        // User menu
        PopupMenuButton<String>(
          icon: const Icon(Icons.account_circle),
          itemBuilder: (context) => <PopupMenuEntry<String>>[
            PopupMenuItem<String>(
              enabled: false,
              child: Text(authState.currentUser?.name ?? 'User'),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem<String>(
              value: 'settings',
              child: Text('Settings'),
            ),
            const PopupMenuItem<String>(value: 'logout', child: Text('Logout')),
          ],
          onSelected: (value) async {
            if (value == 'settings') {
              context.push('/settings');
            } else if (value == 'logout') {
              await authState.logout();
              if (context.mounted) {
                context.go('/login');
              }
            }
          },
        ),
      ],
    );
  }

  Widget? _buildFloatingActionButton(BuildContext context) {
    final authState = context.watch<AuthState>();

    return authState.hasPermission('create')
        ? FloatingActionButton.extended(
            heroTag: 'home_add_client_fab',
            onPressed: () => _showAddClientDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Add Client'),
            backgroundColor: Colors.blue[700],
          )
        : null;
  }

  @override
  Widget build(BuildContext context) {
    return _buildBody();
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingIndicator(message: 'Loading...');
    }

    if (_error != null) {
      return ErrorMessage(message: _error!, onRetry: _loadData);
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SafeArea(
          top: false,
          bottom: true,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 140),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Recent locations section
                if (_recentLocations != null &&
                    _recentLocations!.isNotEmpty) ...[
                  _buildSectionHeader('Recent'),
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      itemCount: _recentLocations!.length,
                      itemBuilder: (context, index) {
                        final location = _recentLocations![index];
                        return SizedBox(
                          width: 200,
                          child: RecentLocationCard(
                            location: location,
                            onTap: () => _navigateToLocation(location),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Clients section
                _buildSectionHeader('Clients'),
                if (_clients == null || _clients!.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.business, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'Add Your First Client',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _clients!.length,
                    itemBuilder: (context, index) {
                      final client = _clients![index];
                      return ClientListTile(
                        client: client,
                        onTap: () => _navigateToClient(client),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _navigateToLocation(RecentLocation location) {
    // Navigate to the specific location based on type (FR-001)
    if (location.equipmentId != null) {
      // Navigate to equipment screen
      context.push('/equipment/${location.equipmentId}');
    } else if (location.subSiteId != null) {
      // Navigate to subsite screen
      context.push(
        '/subsite/${location.subSiteId}?clientId=${location.clientId}&mainSiteId=${location.mainSiteId}',
      );
    } else if (location.mainSiteId != null) {
      // Navigate to main site screen
      context.push(
        '/site/${location.mainSiteId}?clientId=${location.clientId}',
      );
    } else if (location.clientId != null) {
      // Navigate to client detail screen
      context.push('/client/${location.clientId}');
    }
  }

  void _navigateToClient(Client client) {
    context.push('/client/${client.id}');
  }

  void _showAddClientDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Client'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Client Name',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a client name')),
                );
                return;
              }

              final navigator = Navigator.of(context);
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              final authState = context.read<AuthState>();

              try {
                // Get current user ID or use system default
                final userId = authState.currentUser?.id ?? 'system';

                // Create client
                final client = Client(
                  name: name,
                  description: descriptionController.text.trim().isEmpty
                      ? null
                      : descriptionController.text.trim(),
                  createdBy: userId,
                );

                final db = await _dbService.database;
                await db.insert('clients', client.toMap());

                navigator.pop();
                scaffoldMessenger.showSnackBar(
                  const SnackBar(
                    content: Text('Client created successfully'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );

                // Reload data to show new client
                _loadData();
              } catch (e) {
                navigator.pop();
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text('Failed to create client: $e'),
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 3),
                  ),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
