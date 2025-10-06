import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/client.dart';
import '../../../models/user.dart';
import '../../../providers/app_state.dart';
import '../../../widgets/client_list_tile.dart';

/// Clients list section widget for home screen
/// Displays all active clients
class ClientsSection extends StatelessWidget {
  const ClientsSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        // Key change: Create a new future each time appState notifies listeners
        // This ensures FutureBuilder rebuilds when data changes
        return FutureBuilder<List<Client>>(
          key: ValueKey(appState.hashCode),
          future: appState.getClients(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return _buildErrorState(context, snapshot.error.toString());
            }

            final clients = snapshot.data ?? [];

            if (clients.isEmpty) {
              return _buildEmptyState(context);
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Clients',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      if (appState.currentUser?.role == UserRole.admin ||
                          appState.currentUser?.role == UserRole.technician)
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () => _showAddClientDialog(context),
                          tooltip: 'Add New Client',
                        ),
                    ],
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: clients.length,
                  itemBuilder: (context, index) {
                    return ClientListTile(
                      client: clients[index],
                      onTap: () => _navigateToClient(context, clients[index]),
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Icon(
            Icons.business,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Clients Yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first client to get started',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _showAddClientDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Add New Client'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Error Loading Clients',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.red[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _navigateToClient(BuildContext context, Client client) {
    // Navigate to client detail screen
    // Navigator.pushNamed(context, '/client/${client.id}');
  }

  void _showAddClientDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Client'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Client Name',
                hintText: 'Enter client name',
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
              maxLength: 500,
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
                  const SnackBar(content: Text('Please enter a client name')),
                );
                return;
              }

              // Create client
              final appState = context.read<AppState>();
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              final navigator = Navigator.of(context);

              try {
                await appState.createClient(
                  nameController.text.trim(),
                  descriptionController.text.trim().isEmpty
                      ? null
                      : descriptionController.text.trim(),
                );

                navigator.pop();
                scaffoldMessenger.showSnackBar(
                  const SnackBar(
                    content: Text('Client created successfully'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
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
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
