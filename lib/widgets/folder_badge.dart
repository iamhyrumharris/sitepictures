import 'package:flutter/material.dart';

class FolderBadge extends StatelessWidget {
  final String folderName;

  const FolderBadge({super.key, required this.folderName});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 4,
      right: 4,
      child: Semantics(
        label: 'In folder: $folderName',
        child: Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Icon(Icons.folder, size: 14, color: Colors.white),
        ),
      ),
    );
  }
}
