import 'package:flutter/material.dart';

import '../services/import_service.dart';

Future<BeforeAfterChoice?> showBeforeAfterChoiceSheet(
  BuildContext context, {
  required BeforeAfterChoice initialChoice,
}) {
  return showModalBottomSheet<BeforeAfterChoice>(
    context: context,
    useRootNavigator: true,
    builder: (sheetContext) {
      var selection = initialChoice;
      return StatefulBuilder(
        builder: (context, setState) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Import photos to…',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  RadioListTile<BeforeAfterChoice>(
                    value: BeforeAfterChoice.before,
                    groupValue: selection,
                    title: const Text('Before'),
                    onChanged: (choice) {
                      if (choice == null) return;
                      setState(() => selection = choice);
                    },
                  ),
                  RadioListTile<BeforeAfterChoice>(
                    value: BeforeAfterChoice.after,
                    groupValue: selection,
                    title: const Text('After'),
                    onChanged: (choice) {
                      if (choice == null) return;
                      setState(() => selection = choice);
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(sheetContext).pop(),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: () =>
                            Navigator.of(sheetContext).pop(selection),
                        child: const Text('Continue'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
