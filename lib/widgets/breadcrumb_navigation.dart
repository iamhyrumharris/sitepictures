import 'package:flutter/material.dart';
import '../providers/navigation_state.dart';

class BreadcrumbNavigation extends StatelessWidget {
  final List<BreadcrumbItem> breadcrumbs;
  final Function(int) onTap;

  const BreadcrumbNavigation({
    super.key,
    required this.breadcrumbs,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (breadcrumbs.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 40,
      color: Colors.grey[100],
      child: ListView.builder(
        key: const Key('breadcrumb-scroll'),
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: breadcrumbs.length,
        itemBuilder: (context, index) {
          final item = breadcrumbs[index];
          final isLast = index == breadcrumbs.length - 1;

          return Row(
            children: [
              InkWell(
                onTap: () => onTap(index),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 10,
                  ),
                  child: Text(
                    item.title,
                    style: TextStyle(
                      color: isLast ? Colors.black : Colors.blue[700],
                      fontWeight: isLast ? FontWeight.bold : FontWeight.normal,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              if (!isLast)
                Icon(Icons.chevron_right, color: Colors.grey[600], size: 20),
            ],
          );
        },
      ),
    );
  }
}
