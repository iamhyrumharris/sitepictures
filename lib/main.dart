import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_state.dart';
import 'providers/auth_state.dart';
import 'providers/navigation_state.dart';
import 'providers/sync_state.dart';
import 'providers/all_photos_provider.dart';
import 'providers/folder_provider.dart';
import 'providers/needs_assigned_provider.dart';
import 'providers/import_flow_provider.dart';
import 'services/database_service.dart';
import 'services/auth_service.dart';
import 'services/background_sync_service.dart';
import 'services/photo_storage_service.dart';
import 'services/import_repository.dart';
import 'services/import_service.dart';
import 'services/analytics_logger.dart';
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

  final importRepository = ImportRepository(databaseService: dbService);
  final importService = ImportServiceImpl(
    importRepository: importRepository,
    databaseService: dbService,
    navigatorKey: AppRouter.router.routerDelegate.navigatorKey,
  );

  final analyticsLogger = AnalyticsLogger();

  runApp(
    SitePicturesApp(
      importService: importService,
      analyticsLogger: analyticsLogger,
    ),
  );
}

class SitePicturesApp extends StatelessWidget {
  const SitePicturesApp({
    super.key,
    required this.importService,
    required this.analyticsLogger,
  });

  final ImportService importService;
  final AnalyticsLogger analyticsLogger;

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
        Provider<AnalyticsLogger>.value(value: analyticsLogger),
        ChangeNotifierProvider(
          create: (_) => ImportFlowProvider(
            importService: importService,
            analyticsLogger: analyticsLogger,
            navigatorKey: AppRouter.router.routerDelegate.navigatorKey,
          ),
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
