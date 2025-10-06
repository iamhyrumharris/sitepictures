import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/bottom_nav.dart';

/// Shell scaffold with bottom navigation and camera FAB
/// Implements FR-007, FR-013
class ShellScaffold extends StatelessWidget {
  final Widget child;
  final int currentIndex;
  final bool showCameraButton;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;

  const ShellScaffold({
    Key? key,
    required this.child,
    required this.currentIndex,
    this.showCameraButton = true,
    this.appBar,
    this.floatingActionButton,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine which FAB to show: custom one from child screen, or default camera button
    Widget? fab = floatingActionButton;
    if (fab == null && showCameraButton) {
      fab = FloatingActionButton(
        heroTag: 'shell_camera_fab',
        onPressed: () => _showCameraOptions(context),
        backgroundColor: const Color(0xFF4A90E2),
        child: const Icon(Icons.camera_alt),
        tooltip: 'Take Photo',
      );
    }

    return Scaffold(
      appBar: appBar,
      body: child,
      bottomNavigationBar: BottomNav(currentIndex: currentIndex),
      floatingActionButton: fab,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  void _showCameraOptions(BuildContext context) {
    // For now, show a message that user needs to navigate to equipment first
    // In a real app, this could show recent equipment or allow quick selection
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Take a Photo',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Navigate to an equipment item to capture photos',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      ),
    );
  }
}
