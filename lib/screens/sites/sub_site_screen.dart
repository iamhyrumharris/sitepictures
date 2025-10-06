import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../models/site.dart';
import '../../models/equipment.dart';
import '../../models/user.dart';
import '../../models/client.dart';
import '../../providers/app_state.dart';
import '../../providers/auth_state.dart';
import '../../providers/navigation_state.dart' as nav_state;
import '../../widgets/breadcrumb_navigation.dart';

/// SubSite screen showing only equipment (no further nesting)
/// Implements FR-006
class SubSiteScreen extends StatefulWidget {
  final String clientId;
  final String mainSiteId;
  final String subSiteId;

  const SubSiteScreen({
    Key? key,
    required this.clientId,
    required this.mainSiteId,
    required this.subSiteId,
  }) : super(key: key);

  @override
  State<SubSiteScreen> createState() => _SubSiteScreenState();
}

class _SubSiteScreenState extends State<SubSiteScreen> {
  Client? _client;
  MainSite? _mainSite;
  SubSite? _subSite;
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
      final mainSite = await appState.getMainSite(widget.mainSiteId);
      final subSite = await appState.getSubSite(widget.subSiteId);
      final equipment = await appState.getEquipmentForSubSite(widget.subSiteId);

      setState(() {
        _client = client;
        _mainSite = mainSite;
        _subSite = subSite;
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
          if (_client != null && _mainSite != null && _subSite != null)
            BreadcrumbNavigation(
              breadcrumbs: [
                nav_state.BreadcrumbItem(
                  id: widget.clientId,
                  title: _client!.name,
                  route: '/client/${widget.clientId}',
                ),
                nav_state.BreadcrumbItem(
                  id: widget.mainSiteId,
                  title: _mainSite!.name,
                  route: '/site/${widget.mainSiteId}',
                ),
                nav_state.BreadcrumbItem(
                  id: _subSite!.id,
                  title: _subSite!.name,
                  route: '/subsite/${_subSite!.id}',
                ),
              ],
              onTap: (index) {
                if (index < 2) {
                  int popCount = 2 - index;
                  for (int i = 0; i < popCount; i++) {
                    Navigator.pop(context);
                  }
                }
              },
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

    if (_equipment.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        itemCount: _equipment.length,
        itemBuilder: (context, index) => _buildEquipmentTile(_equipment[index]),
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
            Icon(
              Icons.precision_manufacturing,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No Equipment Yet',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Add equipment to this subsite',
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

  Widget? _buildFAB() {
    final authState = context.watch<AuthState>();
    if (authState.currentUser?.role != UserRole.admin &&
        authState.currentUser?.role != UserRole.technician) {
      return null;
    }

    return FloatingActionButton(
      heroTag: 'subsite_add_equipment_fab_${widget.subSiteId}',
      onPressed: _showAddEquipmentDialog,
      child: const Icon(Icons.add),
      tooltip: 'Add Equipment',
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
              decoration: const InputDecoration(labelText: 'Equipment Name'),
              maxLength: 100,
            ),
            TextField(
              controller: serialController,
              decoration: const InputDecoration(
                labelText: 'Serial Number (optional)',
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
                  subSiteId: widget.subSiteId,
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
