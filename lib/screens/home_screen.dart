import 'package:flutter/material.dart';
import '../routes/app_routes.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FieldPhoto Pro'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              AppRoutes.navigateToSearch(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () {
              // Trigger sync
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              AppRoutes.navigateToSettings(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Sync status indicator
          Container(
            height: 40,
            color: Colors.grey[200],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.cloud_off, size: 20),
                SizedBox(width: 8),
                Text('Offline Mode'),
              ],
            ),
          ),
          // Main menu options
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.all(16),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _MenuCard(
                  icon: Icons.camera,
                  label: 'Quick Capture',
                  onTap: () {
                    AppRoutes.navigateToCamera(context);
                  },
                ),
                _MenuCard(
                  icon: Icons.folder,
                  label: 'Equipment',
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.navigation);
                  },
                ),
                _MenuCard(
                  icon: Icons.assignment_late,
                  label: 'Needs Assignment',
                  onTap: () {
                    AppRoutes.navigateToNeedsAssignment(context);
                  },
                ),
                _MenuCard(
                  icon: Icons.location_on,
                  label: 'GPS Boundaries',
                  onTap: () {
                    AppRoutes.navigateToNavigation(context, showBoundariesOnly: true);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          AppRoutes.navigateToCamera(context);
        },
        icon: const Icon(Icons.camera_alt),
        label: const Text('Capture'),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}