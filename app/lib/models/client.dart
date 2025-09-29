import 'dart:math' as math;
import 'package:json_annotation/json_annotation.dart';
import 'gps_boundary.dart';

part 'client.g.dart';

@JsonSerializable()
class Client {
  final String id;
  final String companyId;
  final String name;
  final String? description;
  final List<GPSBoundary> boundaries;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  Client({
    required this.id,
    required this.companyId,
    required this.name,
    this.description,
    required this.boundaries,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
  });

  factory Client.fromJson(Map<String, dynamic> json) => _$ClientFromJson(json);
  Map<String, dynamic> toJson() => _$ClientToJson(this);

  Client copyWith({
    String? id,
    String? companyId,
    String? name,
    String? description,
    List<GPSBoundary>? boundaries,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return Client(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      name: name ?? this.name,
      description: description ?? this.description,
      boundaries: boundaries ?? this.boundaries,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  bool isValidName() {
    return name.isNotEmpty && name.length <= 100;
  }

  bool hasOverlappingBoundaries() {
    for (int i = 0; i < boundaries.length; i++) {
      for (int j = i + 1; j < boundaries.length; j++) {
        if (_boundariesOverlap(boundaries[i], boundaries[j])) {
          return true;
        }
      }
    }
    return false;
  }

  bool _boundariesOverlap(GPSBoundary b1, GPSBoundary b2) {
    final distance = _calculateDistance(
      b1.centerLatitude,
      b1.centerLongitude,
      b2.centerLatitude,
      b2.centerLongitude,
    );
    return distance < (b1.radiusMeters + b2.radiusMeters);
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
}