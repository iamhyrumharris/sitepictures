import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../models/user.dart';
import '../../providers/auth_state.dart';
import '../../providers/sync_state.dart';

/// Settings screen
/// Implements FR-013, FR-018
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthState>();
    final syncState = context.watch<SyncState>();
    final user = authState.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: const Color(0xFF4A90E2),
      ),
      body: ListView(
        children: [
          // User profile section
          if (user != null) ...[
            ListTile(
              leading: CircleAvatar(
                backgroundColor: const Color(0xFF4A90E2),
                child: Text(
                  user.name[0].toUpperCase(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              title: Text(user.name),
              subtitle: Text('${user.email}\nRole: ${user.role.toString().split('.').last}'),
              isThreeLine: true,
            ),
            const Divider(),
          ],

          // Sync status section
          ListTile(
            leading: Icon(
              syncState.isSyncing
                  ? Icons.sync
                  : syncState.pendingItems > 0
                      ? Icons.cloud_off
                      : Icons.cloud_done,
              color: syncState.isSyncing
                  ? Colors.blue
                  : syncState.pendingItems > 0
                      ? Colors.orange
                      : Colors.green,
            ),
            title: const Text('Sync Status'),
            subtitle: Text(
              syncState.isSyncing
                  ? 'Syncing...'
                  : syncState.pendingItems > 0
                      ? '${syncState.pendingItems} items pending'
                      : 'All synced',
            ),
            trailing: syncState.pendingItems > 0
                ? TextButton(
                    onPressed: () => syncState.manualSync(),
                    child: const Text('Sync Now'),
                  )
                : null,
          ),
          const Divider(),

          // Settings options
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            trailing: Switch(
              value: true, // TODO: Connect to actual setting
              onChanged: (value) {
                // TODO: Update notification setting
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.location_on),
            title: const Text('Location Services'),
            subtitle: const Text('Required for photo capture'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Navigate to location settings
            },
          ),
          ListTile(
            leading: const Icon(Icons.storage),
            title: const Text('Storage'),
            subtitle: const Text('Manage local photo storage'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Navigate to storage settings
            },
          ),
          const Divider(),

          // Admin-only options
          if (user?.role == UserRole.admin) ...[
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Administration',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Manage Users'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // TODO: Implement manage users route
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('User management coming soon')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.analytics),
              title: const Text('Analytics'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // TODO: Navigate to analytics
              },
            ),
            const Divider(),
          ],

          // About section
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Site Pictures',
                applicationVersion: '1.0.0',
                applicationIcon: const FlutterLogo(size: 48),
                children: [
                  const Text('Industrial site photo documentation app'),
                  const SizedBox(height: 8),
                  const Text('© 2025 Ziatech'),
                ],
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Help & Support'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Navigate to help
            },
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Navigate to privacy policy
            },
          ),
          const Divider(),

          // Logout
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () => _showLogoutDialog(context),
          ),

          // Version info
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                'Version 1.0.0',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final authState = context.read<AuthState>();
              await authState.logout();
              if (context.mounted) {
                Navigator.pop(context); // Close dialog
                context.go('/login');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
