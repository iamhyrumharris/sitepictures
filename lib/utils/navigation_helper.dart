import 'package:flutter/material.dart';
import '../routes/app_routes.dart';
import '../models/equipment.dart';
import '../models/photo.dart';

class NavigationHelper {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static BuildContext? get currentContext => navigatorKey.currentContext;

  static void showPhotoCaptureFLow(BuildContext context, {
    Equipment? equipment,
    bool returnToGallery = false,
  }) async {
    final result = await Navigator.pushNamed(
      context,
      AppRoutes.quickCapture,
      arguments: {'equipment': equipment},
    );

    if (result != null && result is Photo && returnToGallery) {
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.gallery,
        arguments: [result],
      );
    }
  }

  static void showEquipmentFlow(BuildContext context) async {
    final result = await Navigator.pushNamed(context, AppRoutes.navigation);

    if (result != null && result is Equipment) {
      Navigator.pushNamed(
        context,
        AppRoutes.equipmentDetail,
        arguments: result,
      );
    }
  }

  static void showNeedsAssignmentFlow(BuildContext context) async {
    final result = await Navigator.pushNamed(context, AppRoutes.needsAssignment);

    if (result != null && result is Map<String, dynamic>) {
      final photo = result['photo'] as Photo?;
      final equipment = result['equipment'] as Equipment?;

      if (photo != null && equipment != null) {
        showSnackBar(
          context,
          'Photo assigned to ${equipment.name}',
          isSuccess: true,
        );
      }
    }
  }

  static void navigateWithSlideTransition(
    BuildContext context,
    Widget page, {
    Duration duration = const Duration(milliseconds: 300),
    bool replace = false,
  }) {
    final route = PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.ease;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: duration,
    );

    if (replace) {
      Navigator.pushReplacement(context, route);
    } else {
      Navigator.push(context, route);
    }
  }

  static void navigateWithFadeTransition(
    BuildContext context,
    Widget page, {
    Duration duration = const Duration(milliseconds: 300),
    bool replace = false,
  }) {
    final route = PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      transitionDuration: duration,
    );

    if (replace) {
      Navigator.pushReplacement(context, route);
    } else {
      Navigator.push(context, route);
    }
  }

  static void showBottomSheet(
    BuildContext context,
    Widget content, {
    bool isDismissible = true,
    bool enableDrag = true,
    Color? backgroundColor,
  }) {
    showModalBottomSheet(
      context: context,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => content,
    );
  }

  static Future<bool?> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: isDestructive
                ? TextButton.styleFrom(foregroundColor: Colors.red)
                : null,
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  static void showSnackBar(
    BuildContext context,
    String message, {
    bool isSuccess = false,
    bool isError = false,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: duration,
      backgroundColor: isSuccess
          ? Colors.green
          : isError
              ? Colors.red
              : null,
      action: action,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static void showLoadingDialog(
    BuildContext context, {
    String message = 'Loading...',
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(message),
          ],
        ),
      ),
    );
  }

  static void hideLoadingDialog(BuildContext context) {
    Navigator.pop(context);
  }

  static bool canPop(BuildContext context) {
    return Navigator.canPop(context);
  }

  static void popUntil(BuildContext context, String routeName) {
    Navigator.popUntil(context, ModalRoute.withName(routeName));
  }

  static void clearStackAndNavigate(BuildContext context, String routeName) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      routeName,
      (route) => false,
    );
  }

  static Future<T?> navigateForResult<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) async {
    return await Navigator.pushNamed<T>(
      context,
      routeName,
      arguments: arguments,
    );
  }
}