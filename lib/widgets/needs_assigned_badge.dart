import 'package:flutter/material.dart';

/// Visual indicator for "Needs Assigned" folders (global and per-client)
/// Displays inbox icon + "Needs Assigned" label with distinctive styling
class NeedsAssignedBadge extends StatelessWidget {
  final bool isGlobal;
  final VoidCallback? onTap;

  const NeedsAssignedBadge({
    Key? key,
    this.isGlobal = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.secondary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inbox,
              color: color,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              'Needs Assigned',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 16,
              ),
            ),
            if (isGlobal) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.language,
                color: color.withOpacity(0.7),
                size: 16,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Compact version for list tiles
class NeedsAssignedBadgeCompact extends StatelessWidget {
  final bool isGlobal;

  const NeedsAssignedBadgeCompact({
    Key? key,
    this.isGlobal = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.secondary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.inbox,
          color: color,
          size: 20,
        ),
        const SizedBox(width: 6),
        Text(
          'Needs Assigned',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: color,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
