import 'package:flutter/foundation.dart';
import '../models/recent_location.dart';

class NavigationState extends ChangeNotifier {
  final List<BreadcrumbItem> _breadcrumbs = [];
  final List<RecentLocation> _recentLocations = [];
  int _selectedBottomNavIndex = 0;

  List<BreadcrumbItem> get breadcrumbs => List.unmodifiable(_breadcrumbs);
  List<RecentLocation> get recentLocations =>
      List.unmodifiable(_recentLocations);
  int get selectedBottomNavIndex => _selectedBottomNavIndex;

  void setBottomNavIndex(int index) {
    _selectedBottomNavIndex = index;
    notifyListeners();
  }

  void setBreadcrumbs(List<BreadcrumbItem> items) {
    _breadcrumbs.clear();
    _breadcrumbs.addAll(items);
    notifyListeners();
  }

  void addBreadcrumb(BreadcrumbItem item) {
    _breadcrumbs.add(item);
    notifyListeners();
  }

  void popBreadcrumb() {
    if (_breadcrumbs.isNotEmpty) {
      _breadcrumbs.removeLast();
      notifyListeners();
    }
  }

  void clearBreadcrumbs() {
    _breadcrumbs.clear();
    notifyListeners();
  }

  void navigateToIndex(int index) {
    if (index < _breadcrumbs.length) {
      _breadcrumbs.removeRange(index + 1, _breadcrumbs.length);
      notifyListeners();
    }
  }

  // Recent locations management
  void addRecentLocation(RecentLocation location) {
    // Remove duplicate if exists
    _recentLocations.removeWhere((loc) => loc.id == location.id);

    // Add to beginning
    _recentLocations.insert(0, location);

    // Keep only last 10
    if (_recentLocations.length > 10) {
      _recentLocations.removeRange(10, _recentLocations.length);
    }

    notifyListeners();
  }

  void setRecentLocations(List<RecentLocation> locations) {
    _recentLocations.clear();
    _recentLocations.addAll(locations.take(10));
    notifyListeners();
  }

  // Navigation helper methods
  void navigateToClient(String clientId) {
    // Implementation would use go_router to navigate
    // For now, this is a placeholder
    notifyListeners();
  }

  void navigateToMainSite(String mainSiteId, String clientId) {
    notifyListeners();
  }

  void navigateToSubSite(String subSiteId, String mainSiteId, String clientId) {
    notifyListeners();
  }

  void navigateToEquipment(
    String equipmentId,
    String parentId,
    String clientId,
  ) {
    notifyListeners();
  }
}

class BreadcrumbItem {
  final String id;
  final String title;
  final String route;

  BreadcrumbItem({required this.id, required this.title, required this.route});
}
