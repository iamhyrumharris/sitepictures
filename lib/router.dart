import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/clients/client_detail_screen.dart';
import 'screens/sites/main_site_screen.dart';
import 'screens/sites/sub_site_screen.dart';
import 'screens/equipment/equipment_screen.dart';
import 'screens/camera/camera_screen.dart';
import 'screens/camera/carousel_view.dart';
import 'screens/camera_capture_page.dart';
import 'screens/settings/settings_screen.dart';
import 'providers/photo_capture_provider.dart';
import 'screens/search/search_screen.dart';
import 'screens/shell_scaffold.dart';
import 'screens/equipment/folder_detail_screen.dart';
import 'screens/needs_assigned_page.dart';
import 'services/auth_service.dart';
import 'services/database_service.dart';
import 'providers/auth_state.dart';
import 'providers/sync_state.dart';
import 'providers/needs_assigned_provider.dart';
import 'models/client.dart';
import 'models/camera_context.dart';

class AppRouter {
  static final AuthService _authService = AuthService();

  static final router = GoRouter(
    initialLocation: '/login',
    // Deep linking configuration
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isAuthenticated = _authService.isAuthenticated;
      final isLoggingIn = state.matchedLocation == '/login';

      if (!isAuthenticated && !isLoggingIn) {
        return '/login';
      }

      if (isAuthenticated && isLoggingIn) {
        return '/home';
      }

      return null;
    },
    routes: [
      // Auth routes (without shell)
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),

      // Main shell with bottom nav and contextual FAB
      ShellRoute(
        builder: (context, state, child) {
          // Determine current index based on location
          int currentIndex = 0;
          final location = state.matchedLocation;
          if (location.startsWith('/home')) {
            currentIndex = 0;
          } else if (location.startsWith('/map')) {
            currentIndex = 1;
          } else if (location.startsWith('/settings')) {
            currentIndex = 2;
          }

          // Home screen uses default camera FAB for now
          // (Add Client moved to AppBar or will be handled differently)
          return ShellScaffold(currentIndex: currentIndex, child: child);
        },
        routes: [
          // Home route (now inside shell for consistent navigation)
          GoRoute(
            path: '/home',
            name: 'home',
            builder: (context, state) => const _HomeScreenContent(),
          ),

          // Search (accessible via header button, no bottom nav item)
          GoRoute(
            path: '/search',
            name: 'search',
            builder: (context, state) => const SearchScreen(),
          ),

          // T017: Needs Assigned page (accessible via header button)
          GoRoute(
            path: '/needs-assigned',
            name: 'needsAssigned',
            builder: (context, state) => const NeedsAssignedPage(),
          ),

          // Map
          GoRoute(
            path: '/map',
            name: 'map',
            builder: (context, state) => Scaffold(
              appBar: AppBar(
                title: const Text('Map'),
                backgroundColor: const Color(0xFF4A90E2),
              ),
              body: const Center(child: Text('Map view - Coming soon')),
            ),
          ),

          // Settings
          GoRoute(
            path: '/settings',
            name: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),

      // Detail screens (outside shell - no bottom nav, custom FABs)
      // Client routes
      GoRoute(
        path: '/client/:clientId',
        name: 'client',
        redirect: (context, state) {
          final clientId = state.pathParameters['clientId']!;
          // Redirect global "Needs Assigned" to its dedicated page
          if (clientId == 'GLOBAL_NEEDS_ASSIGNED') {
            return '/needs-assigned';
          }
          return null;
        },
        builder: (context, state) {
          final clientId = state.pathParameters['clientId']!;
          return ClientDetailScreen(clientId: clientId);
        },
      ),

      // Main site routes
      GoRoute(
        path: '/site/:siteId',
        name: 'mainSite',
        builder: (context, state) {
          final siteId = state.pathParameters['siteId']!;
          final clientId = state.uri.queryParameters['clientId'] ?? '';
          return MainSiteScreen(clientId: clientId, siteId: siteId);
        },
      ),

      // SubSite routes
      GoRoute(
        path: '/subsite/:subSiteId',
        name: 'subSite',
        builder: (context, state) {
          final subSiteId = state.pathParameters['subSiteId']!;
          final clientId = state.uri.queryParameters['clientId'] ?? '';
          final mainSiteId = state.uri.queryParameters['mainSiteId'] ?? '';
          return SubSiteScreen(
            clientId: clientId,
            mainSiteId: mainSiteId,
            subSiteId: subSiteId,
          );
        },
      ),

      // Equipment routes
      GoRoute(
        path: '/equipment/:equipmentId',
        name: 'equipment',
        builder: (context, state) {
          final equipmentId = state.pathParameters['equipmentId']!;
          return EquipmentScreen(equipmentId: equipmentId);
        },
      ),

      // Folder detail routes
      GoRoute(
        path: '/equipment/:equipmentId/folder/:folderId',
        name: 'folderDetail',
        builder: (context, state) {
          final equipmentId = state.pathParameters['equipmentId']!;
          final folderId = state.pathParameters['folderId']!;
          return FolderDetailScreen(
            equipmentId: equipmentId,
            folderId: folderId,
          );
        },
      ),

      // Camera and carousel routes (full screen, no bottom nav)
      GoRoute(
        path: '/camera/:equipmentId',
        name: 'camera',
        builder: (context, state) {
          final equipmentId = state.pathParameters['equipmentId']!;
          return CameraScreen(equipmentId: equipmentId);
        },
      ),

      GoRoute(
        path: '/carousel',
        name: 'carousel',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final photos = extra?['photos'] as List<String>? ?? [];
          final equipmentId = extra?['equipmentId'] as String? ?? '';

          return PhotoCarouselView(
            photoPaths: photos,
            equipmentId: equipmentId,
            onSave: (index) async {
              // Save logic handled by carousel
            },
          );
        },
      ),

      // Camera capture page (new field-optimized photo capture)
      GoRoute(
        path: '/camera-capture',
        name: 'cameraCapture',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final cameraContext = CameraContext.fromMap(extra ?? {});

          return ChangeNotifierProvider(
            create: (_) => PhotoCaptureProvider(),
            child: CameraCapturePage(
              cameraContext: cameraContext,
            ),
          );
        },
      ),
    ],
    // Error handling for unknown routes
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(
        title: const Text('Page Not Found'),
        backgroundColor: const Color(0xFF4A90E2),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text('Page not found'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Content for HomeScreen that provides app bar and FAB
/// Bottom nav is now provided by ShellScaffold
class _HomeScreenContent extends StatefulWidget {
  const _HomeScreenContent();

  @override
  State<_HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<_HomeScreenContent> {
  final DatabaseService _dbService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthState>();
    final syncState = context.watch<SyncState>();
    final needsAssignedProvider = context.watch<NeedsAssignedProvider>();

    // Calculate total items needing assignment
    final needsAssignedCount = needsAssignedProvider.globalPhotos.length +
                                needsAssignedProvider.globalFolders.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ziatech'),
        backgroundColor: const Color(0xFF4A90E2),
        actions: [
          // T017: Needs Assigned button with badge indicator
          Badge(
            label: const Text('!'),
            isLabelVisible: needsAssignedCount > 0,
            child: IconButton(
              icon: const Icon(Icons.inbox),
              onPressed: () => context.push('/needs-assigned'),
              tooltip: 'Needs Assigned',
            ),
          ),
          // Add Client button (moved from FAB to avoid conflict with camera FAB)
          if (authState.hasPermission('create'))
            IconButton(
              icon: const Icon(Icons.person_add),
              onPressed: () => _showAddClientDialog(context),
              tooltip: 'Add Client',
            ),
          // Search button
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
              const PopupMenuItem<String>(
                value: 'logout',
                child: Text('Logout'),
              ),
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
      ),
      body: const HomeScreen(),
    );
  }

  void _showAddClientDialog(BuildContext context) {
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
                final userId = authState.currentUser?.id ?? 'system';
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

                // Force rebuild to show new client
                if (mounted) {
                  setState(() {});
                }
              } catch (e) {
                navigator.pop();
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text('Failed to create client: $e'),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 3),
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
