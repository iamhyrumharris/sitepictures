import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_state.dart';
import 'providers/auth_state.dart';
import 'providers/navigation_state.dart';
import 'providers/sync_state.dart';
import 'providers/all_photos_provider.dart';
import 'providers/folder_provider.dart';
import 'providers/needs_assigned_provider.dart';
import 'services/database_service.dart';
import 'services/auth_service.dart';
import 'services/background_sync_service.dart';
import 'services/photo_storage_service.dart';
import 'router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  final dbService = DatabaseService();
  await dbService.database; // Ensure database is initialized

  final authService = AuthService();
  await authService.initialize();

  // Initialize background sync
  await BackgroundSyncService.initialize();

  // Prime photo storage so file paths can be resolved synchronously.
  await PhotoStorageService.ensureInitialized();

  runApp(const SitePicturesApp());
}

class SitePicturesApp extends StatelessWidget {
  const SitePicturesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
        ChangeNotifierProxyProvider<AppState, AllPhotosProvider>(
          create: (_) => AllPhotosProvider(),
          update: (_, appState, provider) {
            provider ??= AllPhotosProvider();
            provider.updateAppState(appState);
            return provider;
          },
        ),
        ChangeNotifierProvider(create: (_) => AuthState()..initialize()),
        ChangeNotifierProvider(create: (_) => NavigationState()),
        ChangeNotifierProvider(create: (_) => SyncState()..initialize()),
        ChangeNotifierProvider(create: (_) => FolderProvider()),
        ChangeNotifierProvider(
          create: (_) => NeedsAssignedProvider()..loadGlobalNeedsAssigned(),
        ),
      ],
      child: MaterialApp.router(
        title: 'Ziatech - Site Pictures',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          primaryColor: const Color(0xFF4A90E2),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF4A90E2),
            foregroundColor: Colors.white,
            elevation: 0,
          ),
        ),
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
