import 'package:flutter/material.dart';

/// Dialog for confirming photo deletion
/// Implements FR-021b, FR-021c (confirmation before deletion)
class PhotoDeleteDialog extends StatelessWidget {
  final String photoId;
  final VoidCallback onConfirm;

  const PhotoDeleteDialog({
    Key? key,
    required this.photoId,
    required this.onConfirm,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Delete Photo?'),
      content: const Text('This photo will be permanently deleted.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm();
          },
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Delete'),
        ),
      ],
    );
  }
}
