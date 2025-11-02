import 'package:flutter/material.dart';

Future<bool?> showPermissionEducationSheet(BuildContext context) {
  return showModalBottomSheet<bool>(
    context: context,
    useRootNavigator: true,
    builder: (sheetContext) {
      return SafeArea(
        child: Semantics(
          label: 'Photo permission education',
          container: true,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Access your photo library',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                const Text(
                  'We use your gallery to import before/after documentation, '
                  'keep audit trails complete, and respect limited access selections.',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(sheetContext).pop(false),
                      child: const Text('Not now'),
                    ),
                    const SizedBox(width: 12),
                    FilledButton(
                      onPressed: () => Navigator.of(sheetContext).pop(true),
                      child: const Text('Continue'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
