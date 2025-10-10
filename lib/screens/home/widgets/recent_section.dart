import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/recent_location.dart';
import '../../../providers/navigation_state.dart';
import '../../../widgets/recent_location_card.dart';

/// Recent locations section widget for home screen
/// Displays the last 10 accessed locations
class RecentSection extends StatelessWidget {
  const RecentSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationState>(
      builder: (context, navState, child) {
        final recentLocations = navState.recentLocations;

        if (recentLocations.isEmpty) {
          return _buildEmptyState(context);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Recent',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                itemCount: recentLocations.length,
                itemBuilder: (context, index) {
                  final location = recentLocations[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: RecentLocationCard(
                      location: location,
                      onTap: () => _navigateToLocation(context, location),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Icon(Icons.history, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No Recent Locations',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Your recently visited locations will appear here',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _navigateToLocation(BuildContext context, RecentLocation location) {
    final navState = context.read<NavigationState>();

    // Navigate to the deepest level available in the location
    if (location.equipmentId != null) {
      navState.navigateToEquipment(
        location.equipmentId!,
        location.subSiteId ?? location.mainSiteId!,
        location.clientId!,
      );
    } else if (location.subSiteId != null) {
      navState.navigateToSubSite(
        location.subSiteId!,
        location.mainSiteId!,
        location.clientId!,
      );
    } else if (location.mainSiteId != null) {
      navState.navigateToMainSite(location.mainSiteId!, location.clientId!);
    } else if (location.clientId != null) {
      navState.navigateToClient(location.clientId!);
    }
  }
}
