import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import '../../models/gps_boundary.dart';
import '../../models/client.dart';
import '../../models/site.dart';
import '../database/database_helper.dart';

class BoundaryDetector {
  static BoundaryDetector? _instance;
  factory BoundaryDetector(DatabaseHelper database) =>
      _instance ??= BoundaryDetector._internal(database);

  final DatabaseHelper _database;
  Map<String, List<GPSBoundary>>? _cachedBoundaries;
  DateTime? _cacheTimestamp;
  static const Duration _cacheDuration = Duration(minutes: 5);

  BoundaryDetector._internal(this._database);

  Future<BoundaryDetectionResult> detectBoundaries({
    required double latitude,
    required double longitude,
    String? companyId,
  }) async {
    try {
      await _refreshCacheIfNeeded(companyId);

      final boundaries = _cachedBoundaries?[companyId ?? 'all'] ?? [];
      final matches = <BoundaryMatch>[];

      for (final boundary in boundaries) {
        final distance = _calculateDistance(
          latitude,
          longitude,
          boundary.centerLatitude,
          boundary.centerLongitude,
        );

        if (distance <= boundary.radiusMeters) {
          final confidence = _calculateConfidence(distance, boundary.radiusMeters);
          matches.add(BoundaryMatch(
            boundary: boundary,
            distance: distance,
            confidence: confidence,
          ));
        }
      }

      matches.sort((a, b) {
        final priorityCompare = b.boundary.priority.compareTo(a.boundary.priority);
        if (priorityCompare != 0) return priorityCompare;
        return a.distance.compareTo(b.distance);
      });

      if (matches.isEmpty) {
        return BoundaryDetectionResult(
          detected: false,
          matches: [],
          primaryMatch: null,
          location: LocationPoint(latitude: latitude, longitude: longitude),
        );
      }

      final primaryMatch = matches.first;
      Client? client;
      Site? site;

      if (primaryMatch.boundary.clientId != null) {
        client = await _database.getClient(primaryMatch.boundary.clientId!);
      }
      if (primaryMatch.boundary.siteId != null) {
        site = await _database.getSite(primaryMatch.boundary.siteId!);
      }

      return BoundaryDetectionResult(
        detected: true,
        matches: matches,
        primaryMatch: primaryMatch,
        location: LocationPoint(latitude: latitude, longitude: longitude),
        client: client,
        site: site,
      );
    } catch (e) {
      debugPrint('Error detecting boundaries: $e');
      return BoundaryDetectionResult(
        detected: false,
        matches: [],
        primaryMatch: null,
        location: LocationPoint(latitude: latitude, longitude: longitude),
        error: e.toString(),
      );
    }
  }

  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371000; // meters
    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);

    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  double _toRadians(double degrees) {
    return degrees * (math.pi / 180);
  }

  double _calculateConfidence(double distance, double radius) {
    if (distance <= radius * 0.5) {
      return 1.0;
    } else if (distance <= radius * 0.75) {
      return 0.9;
    } else if (distance <= radius * 0.9) {
      return 0.75;
    } else if (distance <= radius) {
      return 0.5 + 0.5 * (1 - (distance - radius * 0.9) / (radius * 0.1));
    }
    return 0.0;
  }

  Future<void> _refreshCacheIfNeeded(String? companyId) async {
    final now = DateTime.now();
    final shouldRefresh = _cachedBoundaries == null ||
        _cacheTimestamp == null ||
        now.difference(_cacheTimestamp!) > _cacheDuration;

    if (shouldRefresh) {
      await _loadBoundaries(companyId);
      _cacheTimestamp = now;
    }
  }

  Future<void> _loadBoundaries(String? companyId) async {
    _cachedBoundaries = {};

    final allBoundaries = await _database.getAllBoundaries();
    _cachedBoundaries!['all'] = allBoundaries;

    if (companyId != null) {
      final companyBoundaries = allBoundaries
          .where((b) => b.clientId != null || b.siteId != null)
          .toList();
      _cachedBoundaries![companyId] = companyBoundaries;
    }
  }

  Future<List<LocationPoint>> findNearbyPoints({
    required double latitude,
    required double longitude,
    required double radiusMeters,
    int maxPoints = 100,
  }) async {
    final points = <LocationPoint>[];

    final minLat = latitude - (radiusMeters / 111000);
    final maxLat = latitude + (radiusMeters / 111000);
    final minLon = longitude - (radiusMeters / (111000 * math.cos(_toRadians(latitude))));
    final maxLon = longitude + (radiusMeters / (111000 * math.cos(_toRadians(latitude))));

    final photos = await _database.getPhotosInBoundingBox(
      minLat: minLat,
      maxLat: maxLat,
      minLon: minLon,
      maxLon: maxLon,
    );

    for (final photo in photos) {
      if (photo.latitude != null && photo.longitude != null) {
        final distance = _calculateDistance(
          latitude,
          longitude,
          photo.latitude!,
          photo.longitude!,
        );

        if (distance <= radiusMeters) {
          points.add(LocationPoint(
            latitude: photo.latitude!,
            longitude: photo.longitude!,
            metadata: {'photoId': photo.id, 'distance': distance},
          ));
        }
      }

      if (points.length >= maxPoints) break;
    }

    points.sort((a, b) {
      final distA = a.metadata?['distance'] as double;
      final distB = b.metadata?['distance'] as double;
      return distA.compareTo(distB);
    });

    return points;
  }

  Future<bool> isWithinAnyBoundary({
    required double latitude,
    required double longitude,
    String? companyId,
  }) async {
    final result = await detectBoundaries(
      latitude: latitude,
      longitude: longitude,
      companyId: companyId,
    );
    return result.detected;
  }

  Future<GPSBoundary?> createOptimalBoundary({
    required List<LocationPoint> points,
    required String name,
    String? clientId,
    String? siteId,
    int priority = 1,
  }) async {
    if (points.isEmpty) return null;

    double sumLat = 0;
    double sumLon = 0;
    for (final point in points) {
      sumLat += point.latitude;
      sumLon += point.longitude;
    }

    final centerLat = sumLat / points.length;
    final centerLon = sumLon / points.length;

    double maxDistance = 0;
    for (final point in points) {
      final distance = _calculateDistance(
        centerLat,
        centerLon,
        point.latitude,
        point.longitude,
      );
      if (distance > maxDistance) {
        maxDistance = distance;
      }
    }

    final radiusWithMargin = maxDistance * 1.1;

    final boundary = GPSBoundary(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      centerLatitude: centerLat,
      centerLongitude: centerLon,
      radiusMeters: radiusWithMargin,
      priority: priority,
      clientId: clientId,
      siteId: siteId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isActive: true,
    );

    await _database.insertBoundary(boundary);
    _cachedBoundaries = null;

    return boundary;
  }

  void clearCache() {
    _cachedBoundaries = null;
    _cacheTimestamp = null;
  }

  Future<BoundaryOverlapAnalysis> analyzeOverlaps({
    required GPSBoundary boundary,
    String? companyId,
  }) async {
    await _refreshCacheIfNeeded(companyId);
    final boundaries = _cachedBoundaries?[companyId ?? 'all'] ?? [];
    final overlaps = <BoundaryOverlap>[];

    for (final other in boundaries) {
      if (other.id == boundary.id) continue;

      final distance = _calculateDistance(
        boundary.centerLatitude,
        boundary.centerLongitude,
        other.centerLatitude,
        other.centerLongitude,
      );

      final combinedRadius = boundary.radiusMeters + other.radiusMeters;
      if (distance < combinedRadius) {
        final overlapAmount = combinedRadius - distance;
        final overlapPercentage = overlapAmount / math.min(boundary.radiusMeters, other.radiusMeters);

        overlaps.add(BoundaryOverlap(
          boundary1: boundary,
          boundary2: other,
          distance: distance,
          overlapAmount: overlapAmount,
          overlapPercentage: math.min(overlapPercentage, 1.0),
        ));
      }
    }

    return BoundaryOverlapAnalysis(
      boundary: boundary,
      overlaps: overlaps,
      hasOverlaps: overlaps.isNotEmpty,
      totalOverlaps: overlaps.length,
    );
  }
}

class BoundaryDetectionResult {
  final bool detected;
  final List<BoundaryMatch> matches;
  final BoundaryMatch? primaryMatch;
  final LocationPoint location;
  final Client? client;
  final Site? site;
  final String? error;

  BoundaryDetectionResult({
    required this.detected,
    required this.matches,
    required this.primaryMatch,
    required this.location,
    this.client,
    this.site,
    this.error,
  });
}

class BoundaryMatch {
  final GPSBoundary boundary;
  final double distance;
  final double confidence;

  BoundaryMatch({
    required this.boundary,
    required this.distance,
    required this.confidence,
  });
}

class LocationPoint {
  final double latitude;
  final double longitude;
  final Map<String, dynamic>? metadata;

  LocationPoint({
    required this.latitude,
    required this.longitude,
    this.metadata,
  });
}

class BoundaryOverlap {
  final GPSBoundary boundary1;
  final GPSBoundary boundary2;
  final double distance;
  final double overlapAmount;
  final double overlapPercentage;

  BoundaryOverlap({
    required this.boundary1,
    required this.boundary2,
    required this.distance,
    required this.overlapAmount,
    required this.overlapPercentage,
  });
}

class BoundaryOverlapAnalysis {
  final GPSBoundary boundary;
  final List<BoundaryOverlap> overlaps;
  final bool hasOverlaps;
  final int totalOverlaps;

  BoundaryOverlapAnalysis({
    required this.boundary,
    required this.overlaps,
    required this.hasOverlaps,
    required this.totalOverlaps,
  });
}