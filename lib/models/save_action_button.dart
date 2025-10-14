import 'package:flutter/material.dart';

/// Configuration for camera save action buttons
class SaveActionButton {
  final String label;
  final VoidCallback onTap;
  final bool enabled;
  final Color? backgroundColor;

  const SaveActionButton({
    required this.label,
    required this.onTap,
    this.enabled = true,
    this.backgroundColor,
  });
}
