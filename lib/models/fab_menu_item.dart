import 'package:flutter/material.dart';

/// Represents a single menu item in expandable FAB
class FABMenuItem {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final String? heroTag; // For unique FAB identification

  const FABMenuItem({
    required this.label,
    required this.icon,
    required this.onTap,
    this.backgroundColor,
    this.heroTag,
  });
}
