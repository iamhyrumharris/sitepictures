import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_state.dart';
import 'providers/auth_state.dart';
import 'providers/navigation_state.dart';
import 'providers/sync_state.dart';
import 'providers/folder_provider.dart';
import 'services/database_service.dart';
import 'services/auth_service.dart';
import 'services/background_sync_service.dart';
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

  runApp(const SitePicturesApp());
}

class SitePicturesApp extends StatelessWidget {
  const SitePicturesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
        ChangeNotifierProvider(create: (_) => AuthState()..initialize()),
        ChangeNotifierProvider(create: (_) => NavigationState()),
        ChangeNotifierProvider(create: (_) => SyncState()..initialize()),
        ChangeNotifierProvider(create: (_) => FolderProvider()),
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
