import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// Controller that manages visibility for floating action buttons shared across
/// shell and detail scaffolds.
class FabVisibilityController extends ChangeNotifier {
  bool _isVisible = true;
  bool _notificationScheduled = false;

  bool get isVisible => _isVisible;

  void show() => setVisible(true);
  void hide() => setVisible(false);

  void setVisible(bool value) {
    if (_isVisible == value) {
      return;
    }
    _isVisible = value;
    if (SchedulerBinding.instance.schedulerPhase == SchedulerPhase.idle) {
      notifyListeners();
      return;
    }

    if (_notificationScheduled) {
      return;
    }

    _notificationScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!hasListeners) {
        _notificationScheduled = false;
        return;
      }
      _notificationScheduled = false;
      notifyListeners();
    });
  }
}

/// Inherited scope that exposes a [FabVisibilityController] so child widgets
/// can hide or show the surrounding FAB without tight coupling.
class FabVisibilityScope extends InheritedNotifier<FabVisibilityController> {
  const FabVisibilityScope({
    super.key,
    required FabVisibilityController controller,
    required Widget child,
  })  : _controller = controller,
        super(notifier: controller, child: child);

  final FabVisibilityController _controller;

  static FabVisibilityController? maybeOf(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<FabVisibilityScope>();
    return scope?._controller;
  }

  static FabVisibilityController of(BuildContext context) {
    final controller = maybeOf(context);
    if (controller == null) {
      throw FlutterError(
        'FabVisibilityScope.of() called with no FabVisibilityScope in context.',
      );
    }
    return controller;
  }
}
