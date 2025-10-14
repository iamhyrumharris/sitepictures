import 'package:flutter/material.dart';
import '../models/fab_menu_item.dart';

/// Reusable expandable FAB with animation support
class ExpandableFAB extends StatefulWidget {
  /// Menu items to display when expanded
  final List<FABMenuItem> menuItems;

  /// Duration for expand/collapse animation
  final Duration animationDuration;

  /// Callback when FAB state changes
  final ValueChanged<bool>? onExpansionChanged;

  /// Hero tag for FAB (must be unique if multiple FABs on screen)
  final String? heroTag;

  /// Initial expansion state (default: false/collapsed)
  final bool initiallyExpanded;

  const ExpandableFAB({
    super.key,
    required this.menuItems,
    this.animationDuration = const Duration(milliseconds: 250),
    this.onExpansionChanged,
    this.heroTag,
    this.initiallyExpanded = false,
  });

  @override
  State<ExpandableFAB> createState() => _ExpandableFABState();
}

class _ExpandableFABState extends State<ExpandableFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    if (_isExpanded) {
      _controller.value = 1.0;
    }

    if (widget.heroTag != null) {
      debugPrint('ExpandableFAB hero tag: ${widget.heroTag}');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _expand() {
    _controller.forward();
    setState(() => _isExpanded = true);
    widget.onExpansionChanged?.call(true);
  }

  void _collapse() {
    _controller.reverse();
    setState(() => _isExpanded = false);
    widget.onExpansionChanged?.call(false);
  }

  void _toggle() {
    if (_isExpanded) {
      _collapse();
    } else {
      _expand();
    }
  }

  void _handleItemTap(FABMenuItem item) {
    try {
      item.onTap();
      _collapse();
    } catch (e) {
      debugPrint('Error in FAB menu item tap: $e');
      _collapse();
    }
  }

  @override
  Widget build(BuildContext context) {
    // If no menu items, render simple FAB (no expansion)
    if (widget.menuItems.isEmpty) {
      return FloatingActionButton(
        heroTag: widget.heroTag,
        onPressed: () {
          debugPrint('Warning: ExpandableFAB has no menu items');
        },
        child: const Icon(Icons.add),
      );
    }

    return Stack(
      children: [
        // Scrim overlay (only visible when expanded)
        if (_isExpanded)
          GestureDetector(
            onTap: _collapse,
            child: Container(
              color: Colors.black.withOpacity(0.3),
            ),
          ),

        // FAB and menu items
        Positioned(
          right: 16,
          bottom: 16,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Menu items (animated)
              ..._buildMenuItems(),

              // Spacing between menu items and main FAB
              if (_isExpanded) const SizedBox(height: 8),

              // Main FAB
              _buildMainFAB(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMainFAB() {
    return Semantics(
      label: _isExpanded ? 'Collapse menu' : 'Expand menu',
      button: true,
      child: FloatingActionButton(
        heroTag: widget.heroTag,
        onPressed: _toggle,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 6.0,
        child: AnimatedRotation(
          turns: _isExpanded ? 0.125 : 0, // 45° rotation when expanded
          duration: widget.animationDuration,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  List<Widget> _buildMenuItems() {
    return widget.menuItems.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;

      return AnimatedBuilder(
        animation: _expandAnimation,
        builder: (context, child) {
          // Stagger animation: each item appears 50ms after the previous
          final progress =
              (_expandAnimation.value * widget.menuItems.length) - index;
          final clampedProgress = progress.clamp(0.0, 1.0);

          return Transform.translate(
            offset: Offset(0, (1 - clampedProgress) * 60),
            child: Opacity(
              opacity: clampedProgress,
              child: _buildMenuItem(item),
            ),
          );
        },
      );
    }).toList().reversed.toList(); // Reverse so top item appears first
  }

  Widget _buildMenuItem(FABMenuItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Label
          Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                item.label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Action button
          FloatingActionButton(
            heroTag: item.heroTag ?? '${widget.heroTag}_${item.label}',
            mini: true,
            onPressed: () => _handleItemTap(item),
            backgroundColor:
                item.backgroundColor ?? Theme.of(context).colorScheme.secondary,
            elevation: 4.0,
            child: Icon(item.icon, size: 20),
          ),
        ],
      ),
    );
  }
}
