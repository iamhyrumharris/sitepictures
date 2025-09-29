import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../models/equipment.dart';
import '../models/photo.dart';

class AppRoutes {
  static const String home = '/';
  static const String camera = '/camera';
  static const String quickCapture = '/quick-capture';
  static const String navigation = '/navigation';
  static const String equipmentDetail = '/equipment-detail';
  static const String gallery = '/gallery';
  static const String search = '/search';
  static const String settings = '/settings';
  static const String needsAssignment = '/needs-assignment';
  static const String gpsBoundaries = '/gps-boundaries';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      home: (context) => const HomeScreen(),
      camera: (context) => _PlaceholderScreen(title: 'Camera'),
      navigation: (context) => _PlaceholderScreen(title: 'Equipment Navigation'),
      gallery: (context) => _PlaceholderScreen(title: 'Gallery'),
      search: (context) => _PlaceholderScreen(title: 'Search'),
      settings: (context) => _PlaceholderScreen(title: 'Settings'),
      needsAssignment: (context) => _PlaceholderScreen(title: 'Needs Assignment'),
    };
  }

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case equipmentDetail:
        final equipment = settings.arguments as Equipment?;
        return MaterialPageRoute(
          builder: (context) => _PlaceholderScreen(
            title: 'Equipment Detail',
            subtitle: equipment?.name ?? 'No equipment selected',
          ),
        );

      case quickCapture:
        final Map<String, dynamic>? args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (context) => _PlaceholderScreen(
            title: 'Quick Capture',
            subtitle: 'Equipment: ${args?['equipment']?.toString() ?? 'None'}',
          ),
        );

      case gpsBoundaries:
        return MaterialPageRoute(
          builder: (context) => _PlaceholderScreen(title: 'GPS Boundaries'),
        );

      default:
        return MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        );
    }
  }

  static void navigateToCamera(BuildContext context, {Equipment? equipment}) {
    Navigator.pushNamed(
      context,
      quickCapture,
      arguments: {'equipment': equipment},
    );
  }

  static void navigateToEquipmentDetail(BuildContext context, Equipment equipment) {
    Navigator.pushNamed(
      context,
      equipmentDetail,
      arguments: equipment,
    );
  }

  static void navigateToGallery(BuildContext context, {List<Photo>? photos}) {
    Navigator.pushNamed(
      context,
      gallery,
      arguments: photos,
    );
  }

  static Future<bool?> navigateToSettings(BuildContext context) {
    return Navigator.pushNamed<bool>(context, settings);
  }

  static void navigateToSearch(BuildContext context) {
    Navigator.pushNamed(context, search);
  }

  static void navigateToNeedsAssignment(BuildContext context) {
    Navigator.pushNamed(context, needsAssignment);
  }

  static void navigateToNavigation(BuildContext context, {bool showBoundariesOnly = false}) {
    if (showBoundariesOnly) {
      Navigator.pushNamed(context, gpsBoundaries);
    } else {
      Navigator.pushNamed(context, navigation);
    }
  }

  static void popToHome(BuildContext context) {
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  static void replaceCurrent(BuildContext context, String routeName, {Object? arguments}) {
    Navigator.pushReplacementNamed(context, routeName, arguments: arguments);
  }
}

class _PlaceholderScreen extends StatelessWidget {
  final String title;
  final String? subtitle;

  const _PlaceholderScreen({
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 32),
            Text(
              'This screen is under development',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}