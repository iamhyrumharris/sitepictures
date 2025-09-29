import 'dart:math' as math;
import 'package:json_annotation/json_annotation.dart';

part 'site.g.dart';

@JsonSerializable()
class Site {
  final String id;
  final String clientId;
  final String? parentSiteId;
  final String name;
  final String? address;
  final double? centerLatitude;
  final double? centerLongitude;
  final double? boundaryRadius;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  Site({
    required this.id,
    required this.clientId,
    this.parentSiteId,
    required this.name,
    this.address,
    this.centerLatitude,
    this.centerLongitude,
    this.boundaryRadius,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
  });

  factory Site.fromJson(Map<String, dynamic> json) => _$SiteFromJson(json);
  Map<String, dynamic> toJson() => _$SiteToJson(this);

  Site copyWith({
    String? id,
    String? clientId,
    String? parentSiteId,
    String? name,
    String? address,
    double? centerLatitude,
    double? centerLongitude,
    double? boundaryRadius,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return Site(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      parentSiteId: parentSiteId ?? this.parentSiteId,
      name: name ?? this.name,
      address: address ?? this.address,
      centerLatitude: centerLatitude ?? this.centerLatitude,
      centerLongitude: centerLongitude ?? this.centerLongitude,
      boundaryRadius: boundaryRadius ?? this.boundaryRadius,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  bool get isMainSite => parentSiteId == null;
  bool get isSubSite => parentSiteId != null;

  bool isValidName() {
    return name.isNotEmpty && name.length <= 100;
  }

  bool hasValidCoordinates() {
    if (centerLatitude == null || centerLongitude == null) return true;
    return centerLatitude! >= -90 &&
        centerLatitude! <= 90 &&
        centerLongitude! >= -180 &&
        centerLongitude! <= 180;
  }

  bool containsLocation(double latitude, double longitude) {
    if (centerLatitude == null ||
        centerLongitude == null ||
        boundaryRadius == null) {
      return false;
    }

    final distance = _calculateDistance(
      centerLatitude!,
      centerLongitude!,
      latitude,
      longitude,
    );
    return distance <= boundaryRadius!;
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const earthRadius = 6371000.0;
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.asin(math.sqrt(a));
    return earthRadius * c;
  }

  double _toRadians(double degrees) => degrees * (3.14159265359 / 180.0);

  String getHierarchyPath({Site? parentSite}) {
    if (isMainSite) {
      return name;
    }
    if (parentSite != null) {
      return '${parentSite.name} > $name';
    }
    return name;
  }
}