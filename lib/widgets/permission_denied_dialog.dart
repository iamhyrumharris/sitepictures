import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

Future<bool?> showPermissionDeniedDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        semanticLabel: 'Photo permission required',
        title: const Text('Allow photo access to continue'),
        content: const Text(
          'FieldPhoto Pro needs access to your photo library to import before/after images. '
          'You can enable access in Settings and return here to try again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              await PhotoManager.openSetting();
              // Dismiss dialog after opening settings so the flow can resume when returning.
              if (dialogContext.mounted) {
                Navigator.of(dialogContext).pop(true);
              }
            },
            child: const Text('Open Settings'),
          ),
        ],
      );
    },
  );
}
