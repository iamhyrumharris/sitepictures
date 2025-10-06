import 'package:uuid/uuid.dart';

class RecentLocation {
  final String id;
  final String userId;
  final String? clientId;
  final String? mainSiteId;
  final String? subSiteId;
  final String? equipmentId;
  final DateTime accessedAt;
  final String displayName;
  final String navigationPath;

  RecentLocation({
    String? id,
    required this.userId,
    this.clientId,
    this.mainSiteId,
    this.subSiteId,
    this.equipmentId,
    required this.accessedAt,
    required this.displayName,
    required this.navigationPath,
  }) : id = id ?? const Uuid().v4();

  // Validation
  bool isValid() {
    if (userId.isEmpty) return false;
    if (displayName.isEmpty) return false;
    if (navigationPath.isEmpty) return false;
    // At least one location ID must be non-null
    if (clientId == null && mainSiteId == null &&
        subSiteId == null && equipmentId == null) {
      return false;
    }
    return true;
  }

  // Get the deepest level location type
  String get locationType {
    if (equipmentId != null) return 'equipment';
    if (subSiteId != null) return 'subsite';
    if (mainSiteId != null) return 'mainsite';
    if (clientId != null) return 'client';
    return 'unknown';
  }

  // Convert to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'client_id': clientId,
      'main_site_id': mainSiteId,
      'sub_site_id': subSiteId,
      'equipment_id': equipmentId,
      'accessed_at': accessedAt.toIso8601String(),
      'display_name': displayName,
      'navigation_path': navigationPath,
    };
  }

  // Create from database map
  factory RecentLocation.fromMap(Map<String, dynamic> map) {
    return RecentLocation(
      id: map['id'],
      userId: map['user_id'],
      clientId: map['client_id'],
      mainSiteId: map['main_site_id'],
      subSiteId: map['sub_site_id'],
      equipmentId: map['equipment_id'],
      accessedAt: DateTime.parse(map['accessed_at']),
      displayName: map['display_name'],
      navigationPath: map['navigation_path'],
    );
  }

  // Create from API JSON
  factory RecentLocation.fromJson(Map<String, dynamic> json) {
    return RecentLocation(
      id: json['id'],
      userId: json['userId'],
      clientId: json['clientId'],
      mainSiteId: json['mainSiteId'],
      subSiteId: json['subSiteId'],
      equipmentId: json['equipmentId'],
      accessedAt: DateTime.parse(json['accessedAt']),
      displayName: json['displayName'],
      navigationPath: json['navigationPath'],
    );
  }

  // Convert to JSON for API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'clientId': clientId,
      'mainSiteId': mainSiteId,
      'subSiteId': subSiteId,
      'equipmentId': equipmentId,
      'accessedAt': accessedAt.toIso8601String(),
      'displayName': displayName,
      'navigationPath': navigationPath,
    };
  }

  @override
  String toString() {
    return 'RecentLocation{id: $id, displayName: $displayName, type: $locationType}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RecentLocation && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}