import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/equipment_navigator_provider.dart';
import '../models/equipment.dart';
import '../models/equipment_navigation_node.dart';
import '../services/database_service.dart';

/// T020: Equipment Navigator Page with hierarchical list navigation
/// Allows users to navigate Client → Site → Equipment hierarchy
/// and select equipment for saving photos
class EquipmentNavigatorPage extends StatefulWidget {
  const EquipmentNavigatorPage({Key? key}) : super(key: key);

  @override
  State<EquipmentNavigatorPage> createState() => _EquipmentNavigatorPageState();
}

class _EquipmentNavigatorPageState extends State<EquipmentNavigatorPage> {
  @override
  void initState() {
    super.initState();
    // Initialize navigator on page load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EquipmentNavigatorProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EquipmentNavigatorProvider>(
      builder: (context, provider, child) {
        return WillPopScope(
          onWillPop: () async {
            // T025: Handle back button - navigate back in hierarchy if not at root
            if (provider.navigationPath.isNotEmpty) {
              provider.navigateBack();
              return false; // Prevent page pop
            }
            return true; // Allow page pop if at root
          },
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Select Equipment'),
              leading: provider.navigationPath.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => provider.navigateBack(),
                    )
                  : IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
            ),
            body: _buildBody(provider),
          ),
        );
      },
    );
  }

  Widget _buildBody(EquipmentNavigatorProvider provider) {
    // Show loading indicator
    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Show error message
    if (provider.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              provider.errorMessage!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => provider.initialize(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // T024: Show empty state if no children
    if (provider.currentChildren.isEmpty) {
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
              provider.navigationPath.isEmpty
                  ? 'No clients found'
                  : 'No items found',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              provider.navigationPath.isEmpty
                  ? 'Create a client to get started'
                  : 'This location has no sites or equipment',
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

    // Show navigation tree
    return Column(
      children: [
        // Breadcrumb navigation
        if (provider.navigationPath.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.grey[200],
            child: _buildBreadcrumbs(provider),
          ),

        // List of children
        Expanded(
          child: ListView.builder(
            itemCount: provider.currentChildren.length,
            itemBuilder: (context, index) {
              final node = provider.currentChildren[index];
              return _buildNodeTile(context, provider, node);
            },
          ),
        ),
      ],
    );
  }

  /// Build breadcrumb navigation trail
  Widget _buildBreadcrumbs(EquipmentNavigatorProvider provider) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          const Icon(Icons.home, size: 16, color: Colors.grey),
          for (int i = 0; i < provider.navigationPath.length; i++) ...[
            const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
            Text(
              provider.navigationPath[i].name,
              style: TextStyle(
                fontSize: 14,
                color: i == provider.navigationPath.length - 1
                    ? Colors.black
                    : Colors.grey[700],
                fontWeight: i == provider.navigationPath.length - 1
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Build a single navigation node tile
  Widget _buildNodeTile(
    BuildContext context,
    EquipmentNavigatorProvider provider,
    EquipmentNavigationNode node,
  ) {
    final icon = _getIconForNodeType(node.type);
    final color = _getColorForNodeType(node.type);

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(node.name),
      subtitle: Text(_getNodeTypeLabel(node.type)),
      trailing: node.isSelectable
          ? const Icon(Icons.check_circle_outline, color: Colors.green)
          : const Icon(Icons.chevron_right),
      onTap: () => _handleNodeTap(context, provider, node),
    );
  }

  /// Handle tap on a navigation node
  Future<void> _handleNodeTap(
    BuildContext context,
    EquipmentNavigatorProvider provider,
    EquipmentNavigationNode node,
  ) async {
    if (node.isSelectable) {
      // T023: Equipment node - load and select equipment
      await _handleEquipmentSelection(context, provider, node);
    } else {
      // Client/site node - navigate in
      await provider.navigateInto(node);
    }
  }

  /// Handle equipment selection
  Future<void> _handleEquipmentSelection(
    BuildContext context,
    EquipmentNavigatorProvider provider,
    EquipmentNavigationNode node,
  ) async {
    try {
      // Load full equipment details from database
      final db = DatabaseService();
      final database = await db.database;

      final equipmentMaps = await database.query(
        'equipment',
        where: 'id = ?',
        whereArgs: [node.id],
      );

      if (equipmentMaps.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Equipment not found')),
          );
        }
        return;
      }

      final equipment = Equipment.fromMap(equipmentMaps.first);

      // Set selection in provider
      provider.selectEquipment(equipment);

      // Return equipment to caller
      if (mounted) {
        Navigator.of(context).pop(equipment);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load equipment: $e')),
        );
      }
    }
  }

  /// Get icon for node type
  IconData _getIconForNodeType(NavigationNodeType type) {
    switch (type) {
      case NavigationNodeType.client:
        return Icons.business;
      case NavigationNodeType.mainSite:
        return Icons.location_city;
      case NavigationNodeType.subSite:
        return Icons.place;
      case NavigationNodeType.equipment:
        return Icons.precision_manufacturing;
    }
  }

  /// Get color for node type
  Color _getColorForNodeType(NavigationNodeType type) {
    switch (type) {
      case NavigationNodeType.client:
        return Colors.blue;
      case NavigationNodeType.mainSite:
        return Colors.purple;
      case NavigationNodeType.subSite:
        return Colors.orange;
      case NavigationNodeType.equipment:
        return Colors.green;
    }
  }

  /// Get label for node type
  String _getNodeTypeLabel(NavigationNodeType type) {
    switch (type) {
      case NavigationNodeType.client:
        return 'Client';
      case NavigationNodeType.mainSite:
        return 'Main Site';
      case NavigationNodeType.subSite:
        return 'Sub Site';
      case NavigationNodeType.equipment:
        return 'Equipment';
    }
  }
}
