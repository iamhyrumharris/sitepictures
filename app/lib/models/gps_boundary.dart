import 'dart:math' as math;
import 'package:json_annotation/json_annotation.dart';

part 'gps_boundary.g.dart';

@JsonSerializable()
class GPSBoundary {
  final String id;
  final String? clientId;
  final String? siteId;
  final String name;
  final double centerLatitude;
  final double centerLongitude;
  final double radiusMeters;
  final int priority;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  GPSBoundary({
    required this.id,
    this.clientId,
    this.siteId,
    required this.name,
    required this.centerLatitude,
    required this.centerLongitude,
    required this.radiusMeters,
    required this.priority,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
  });

  factory GPSBoundary.fromJson(Map<String, dynamic> json) => _$GPSBoundaryFromJson(json);
  Map<String, dynamic> toJson() => _$GPSBoundaryToJson(this);

  GPSBoundary copyWith({
    String? id,
    String? clientId,
    String? siteId,
    String? name,
    double? centerLatitude,
    double? centerLongitude,
    double? radiusMeters,
    int? priority,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return GPSBoundary(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      siteId: siteId ?? this.siteId,
      name: name ?? this.name,
      centerLatitude: centerLatitude ?? this.centerLatitude,
      centerLongitude: centerLongitude ?? this.centerLongitude,
      radiusMeters: radiusMeters ?? this.radiusMeters,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  bool isValidCoordinates() {
    return centerLatitude >= -90 &&
        centerLatitude <= 90 &&
        centerLongitude >= -180 &&
        centerLongitude <= 180;
  }

  bool isValidRadius() {
    return radiusMeters > 0 && radiusMeters <= 10000;
  }

  bool containsLocation(double latitude, double longitude) {
    final distance = _calculateDistance(
      centerLatitude,
      centerLongitude,
      latitude,
      longitude,
    );
    return distance <= radiusMeters;
  }

  double distanceToLocation(double latitude, double longitude) {
    return _calculateDistance(
      centerLatitude,
      centerLongitude,
      latitude,
      longitude,
    );
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

  double get confidence {
    if (radiusMeters <= 100) return 1.0;
    if (radiusMeters <= 500) return 0.9;
    if (radiusMeters <= 1000) return 0.8;
    if (radiusMeters <= 5000) return 0.6;
    return 0.4;
  }

  bool overlapsWith(GPSBoundary other) {
    final distance = _calculateDistance(
      centerLatitude,
      centerLongitude,
      other.centerLatitude,
      other.centerLongitude,
    );
    return distance < (radiusMeters + other.radiusMeters);
  }

  int compareTo(GPSBoundary other) {
    if (priority != other.priority) {
      return other.priority.compareTo(priority);
    }
    return radiusMeters.compareTo(other.radiusMeters);
  }
}