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
import 'screens/photo_viewer_screen.dart';
import 'screens/all_photos/all_photos_screen.dart';
import 'services/auth_service.dart';
import 'providers/needs_assigned_provider.dart';
import 'providers/import_flow_provider.dart';
import 'providers/all_photos_provider.dart';
import 'models/camera_context.dart';
import 'models/photo.dart';
import 'models/import_batch.dart';
import 'widgets/import_destination_picker.dart';
import 'widgets/import_progress_sheet.dart';

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
          } else if (location.startsWith('/all-photos')) {
            currentIndex = 1;
          } else if (location.startsWith('/settings')) {
            currentIndex = 2;
          }

          // Home screen uses default camera FAB for now
          // Add Client action is rendered inside the Clients section header
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

          // All Photos Screen
          GoRoute(
            path: '/all-photos',
            name: 'allPhotos',
            builder: (context, state) => const AllPhotosScreen(),
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

      // Photo viewer route (full screen, no bottom nav)
      GoRoute(
        path: '/photo-viewer',
        name: 'photoViewer',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final photos = extra?['photos'] as List<Photo>? ?? [];
          final initialIndex = extra?['initialIndex'] as int? ?? 0;

          return PhotoViewerScreen(photos: photos, initialIndex: initialIndex);
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
            child: CameraCapturePage(cameraContext: cameraContext),
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
  Future<void> _handleImport(BuildContext context) async {
    final importFlow = context.read<ImportFlowProvider>();
    final selection = await showImportDestinationPicker(
      context: context,
      entryPoint: ImportEntryPoint.home,
    );

    if (selection == null) {
      return;
    }

    importFlow.configure(
      entryPoint: ImportEntryPoint.home,
      defaultDestination: selection.destination,
      beforeAfterChoice: selection.beforeAfterChoice,
      navigatorKey: AppRouter.router.routerDelegate.navigatorKey,
      initialPermissionState: importFlow.permissionState,
    );

    final result = await showImportProgressSheet(
      context,
      provider: importFlow,
      onStart: () => importFlow.startImport(pickerContext: context),
    );

    if (!mounted) {
      return;
    }

    if (result != null) {
      try {
        await context.read<NeedsAssignedProvider>().loadGlobalNeedsAssigned();
      } catch (_) {
        // ignore load failures for now
      }
      try {
        await context.read<AllPhotosProvider>().refresh();
      } catch (_) {
        // ignore refresh failures
      }

      final batch = result.batch;
      final summary =
          '${batch.importedCount} imported, ${batch.duplicateCount} duplicate(s) skipped, ${batch.failedCount} failed';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(summary)));
    } else if (importFlow.errorMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(importFlow.errorMessage!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final needsAssignedProvider = context.watch<NeedsAssignedProvider>();

    // Calculate total items needing assignment
    final needsAssignedCount =
        needsAssignedProvider.globalPhotos.length +
        needsAssignedProvider.globalFolders.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ziatech'),
        backgroundColor: const Color(0xFF4A90E2),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_upload_outlined),
            tooltip: 'Import Photos',
            onPressed: () => _handleImport(context),
          ),
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
          // Search button
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/search'),
            tooltip: 'Search',
          ),
        ],
      ),
      body: const HomeScreen(),
    );
  }
}
