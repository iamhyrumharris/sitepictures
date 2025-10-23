import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';

import '../widgets/bottom_nav.dart';
import '../widgets/fab_visibility_scope.dart';

/// Shell scaffold with bottom navigation and camera FAB.
class ShellScaffold extends StatefulWidget {
  const ShellScaffold({
    super.key,
    required this.child,
    required this.currentIndex,
    this.showCameraButton = true,
    this.appBar,
    this.floatingActionButton,
  });

  final Widget child;
  final int currentIndex;
  final bool showCameraButton;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;

  @override
  State<ShellScaffold> createState() => _ShellScaffoldState();
}

class _ShellScaffoldState extends State<ShellScaffold> {
  late final FabVisibilityController _fabController;

  @override
  void initState() {
    super.initState();
    _fabController = FabVisibilityController()
      ..addListener(_handleFabVisibilityChanged);
  }

  @override
  void dispose() {
    _fabController
      ..removeListener(_handleFabVisibilityChanged)
      ..dispose();
    super.dispose();
  }

  void _handleFabVisibilityChanged() {
    if (!mounted) return;

    if (SchedulerBinding.instance.schedulerPhase == SchedulerPhase.idle) {
      setState(() {});
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget? fab = widget.floatingActionButton;
    final isVisible = _fabController.isVisible;

    if (!isVisible) {
      fab = null;
    } else if (fab == null && widget.showCameraButton) {
      fab = FloatingActionButton(
        heroTag: 'shell_camera_fab',
        onPressed: () => _showCameraOptions(context),
        backgroundColor: const Color(0xFF4A90E2),
        child: const Icon(Icons.camera_alt),
        tooltip: 'Take Photo',
      );
    }

    return FabVisibilityScope(
      controller: _fabController,
      child: Scaffold(
        appBar: widget.appBar,
        body: widget.child,
        bottomNavigationBar: BottomNav(currentIndex: widget.currentIndex),
        floatingActionButton: fab,
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }

  void _showCameraOptions(BuildContext context) {
    context.push('/camera-capture', extra: {
      'context': 'home',
    });
  }
}
