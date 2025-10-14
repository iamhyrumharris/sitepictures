import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Bottom navigation bar widget
/// Implements FR-011, FR-013
class BottomNav extends StatelessWidget {
  final int currentIndex;

  const BottomNav({Key? key, required this.currentIndex}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Colors.white,
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(context, Icons.home, 'Home', 0),
            _buildNavItem(context, Icons.map, 'Map', 1),
            _buildNavItem(context, Icons.settings, 'Settings', 2),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    IconData icon,
    String label,
    int index,
  ) {
    final isSelected = currentIndex == index;
    final color = isSelected ? const Color(0xFF4A90E2) : Colors.grey;

    return Expanded(
      child: InkWell(
        onTap: () => _onTabTapped(context, index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onTabTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/map');
        break;
      case 2:
        context.go('/settings');
        break;
    }
  }
}
