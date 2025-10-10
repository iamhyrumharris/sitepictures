import 'package:flutter/material.dart';

class DeleteFolderDialog extends StatelessWidget {
  final String folderName;
  final int photoCount;
  final void Function(bool deletePhotos) onConfirm;

  const DeleteFolderDialog({
    super.key,
    required this.folderName,
    required this.photoCount,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Delete Folder?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Folder: $folderName'),
          const SizedBox(height: 8),
          Text(
            'Choose what happens to the $photoCount ${photoCount == 1 ? 'photo' : 'photos'} in this folder:',
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm(false); // Keep photos as standalone
          },
          child: const Text('Keep photos as standalone'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm(true); // Delete all photos
          },
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Delete all photos in folder'),
        ),
      ],
    );
  }
}
