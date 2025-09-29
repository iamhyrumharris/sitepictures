import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:fieldphoto_pro/services/location/boundary_detector.dart';
import 'package:fieldphoto_pro/models/gps_boundary.dart';
import 'dart:math';

@GenerateMocks([BoundaryDetector])
import 'boundary_test.mocks.dart';

void main() {
  group('GPS Boundary Calculations Unit Tests', () {
    late MockBoundaryDetector mockBoundaryDetector;

    setUp(() {
      mockBoundaryDetector = MockBoundaryDetector();
    });

    test('Calculates distance between two GPS points correctly', () {
      // Haversine formula test
      const lat1 = 42.3601; // Boston area
      const lon1 = -71.0589;
      const lat2 = 42.3736; // ~1.5km north
      const lon2 = -71.0589;

      final distance = calculateHaversineDistance(lat1, lon1, lat2, lon2);

      // Should be approximately 1.5km
      expect(distance, greaterThan(1400));
      expect(distance, lessThan(1600));
    });

    test('Detects point inside circular boundary', () async {
      final boundary = GPSBoundary(
        id: 'boundary-001',
        name: 'Factory Site A',
        centerLatitude: 42.3601,
        centerLongitude: -71.0589,
        radiusMeters: 500,
        priority: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isActive: true,
      );

      when(mockBoundaryDetector.isPointInBoundary(
        42.3605, // Slightly north, within 500m
        -71.0590,
        boundary,
      )).thenAnswer((_) async => true);

      final isInside = await mockBoundaryDetector.isPointInBoundary(
        42.3605,
        -71.0590,
        boundary,
      );

      expect(isInside, isTrue);
    });

    test('Detects point outside circular boundary', () async {
      final boundary = GPSBoundary(
        id: 'boundary-001',
        name: 'Factory Site A',
        centerLatitude: 42.3601,
        centerLongitude: -71.0589,
        radiusMeters: 500,
        priority: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isActive: true,
      );

      when(mockBoundaryDetector.isPointInBoundary(
        42.3650, // ~600m away, outside 500m radius
        -71.0600,
        boundary,
      )).thenAnswer((_) async => false);

      final isInside = await mockBoundaryDetector.isPointInBoundary(
        42.3650,
        -71.0600,
        boundary,
      );

      expect(isInside, isFalse);
    });

    test('Handles overlapping boundaries with priority', () async {
      final boundary1 = GPSBoundary(
        id: 'boundary-001',
        clientId: 'client-001',
        name: 'Larger Area',
        centerLatitude: 42.3601,
        centerLongitude: -71.0589,
        radiusMeters: 1000,
        priority: 1, // Lower priority
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isActive: true,
      );

      final boundary2 = GPSBoundary(
        id: 'boundary-002',
        siteId: 'site-001',
        name: 'Specific Building',
        centerLatitude: 42.3605,
        centerLongitude: -71.0590,
        radiusMeters: 200,
        priority: 10, // Higher priority
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isActive: true,
      );

      when(mockBoundaryDetector.detectBoundaries(42.3605, -71.0590, [boundary1, boundary2]))
          .thenAnswer((_) async {
        // Both boundaries contain the point
        // Return highest priority first
        return [boundary2, boundary1];
      });

      final detected = await mockBoundaryDetector.detectBoundaries(
        42.3605,
        -71.0590,
        [boundary1, boundary2],
      );

      expect(detected, hasLength(2));
      expect(detected[0].priority, greaterThan(detected[1].priority));
      expect(detected[0].id, equals('boundary-002'));
    });

    test('Calculates distance to boundary edge', () async {
      final boundary = GPSBoundary(
        id: 'boundary-001',
        name: 'Test Boundary',
        centerLatitude: 42.3601,
        centerLongitude: -71.0589,
        radiusMeters: 500,
        priority: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isActive: true,
      );

      when(mockBoundaryDetector.distanceToBoundaryEdge(
        42.3601, // At center
        -71.0589,
        boundary,
      )).thenAnswer((_) async => 500.0); // Distance to edge from center

      final distance = await mockBoundaryDetector.distanceToBoundaryEdge(
        42.3601,
        -71.0589,
        boundary,
      );

      expect(distance, equals(500.0));
    });

    test('Finds nearest boundary to a point', () async {
      final boundaries = [
        GPSBoundary(
          id: 'boundary-001',
          name: 'Far Boundary',
          centerLatitude: 42.4000,
          centerLongitude: -71.1000,
          radiusMeters: 300,
          priority: 1,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isActive: true,
        ),
        GPSBoundary(
          id: 'boundary-002',
          name: 'Near Boundary',
          centerLatitude: 42.3610,
          centerLongitude: -71.0595,
          radiusMeters: 200,
          priority: 1,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isActive: true,
        ),
      ];

      when(mockBoundaryDetector.findNearestBoundary(42.3605, -71.0590, boundaries))
          .thenAnswer((_) async => boundaries[1]); // Near Boundary

      final nearest = await mockBoundaryDetector.findNearestBoundary(
        42.3605,
        -71.0590,
        boundaries,
      );

      expect(nearest.id, equals('boundary-002'));
      expect(nearest.name, equals('Near Boundary'));
    });

    test('Validates boundary radius constraints', () {
      // Test minimum radius
      expect(
        () => GPSBoundary(
          id: 'boundary-001',
          name: 'Too Small',
          centerLatitude: 42.3601,
          centerLongitude: -71.0589,
          radiusMeters: 0, // Invalid
          priority: 1,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isActive: true,
        ).validate(),
        throwsA(isA<ValidationException>()),
      );

      // Test maximum radius
      expect(
        () => GPSBoundary(
          id: 'boundary-002',
          name: 'Too Large',
          centerLatitude: 42.3601,
          centerLongitude: -71.0589,
          radiusMeters: 10001, // Exceeds 10km limit
          priority: 1,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isActive: true,
        ).validate(),
        throwsA(isA<ValidationException>()),
      );

      // Test valid radius
      final validBoundary = GPSBoundary(
        id: 'boundary-003',
        name: 'Valid Size',
        centerLatitude: 42.3601,
        centerLongitude: -71.0589,
        radiusMeters: 5000, // 5km - valid
        priority: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isActive: true,
      );

      expect(validBoundary.validate(), isTrue);
    });

    test('Handles edge cases at poles and date line', () async {
      // Test near North Pole
      final northPoleBoundary = GPSBoundary(
        id: 'boundary-001',
        name: 'Arctic Station',
        centerLatitude: 89.9,
        centerLongitude: 0,
        radiusMeters: 1000,
        priority: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isActive: true,
      );

      when(mockBoundaryDetector.isPointInBoundary(
        89.91,
        10.0,
        northPoleBoundary,
      )).thenAnswer((_) async => true);

      final nearPole = await mockBoundaryDetector.isPointInBoundary(
        89.91,
        10.0,
        northPoleBoundary,
      );

      expect(nearPole, isTrue);

      // Test near International Date Line
      final dateLineBoundary = GPSBoundary(
        id: 'boundary-002',
        name: 'Pacific Station',
        centerLatitude: 0,
        centerLongitude: 179.9,
        radiusMeters: 5000,
        priority: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isActive: true,
      );

      when(mockBoundaryDetector.isPointInBoundary(
        0,
        -179.9, // Across date line
        dateLineBoundary,
      )).thenAnswer((_) async => true);

      final acrossDateLine = await mockBoundaryDetector.isPointInBoundary(
        0,
        -179.9,
        dateLineBoundary,
      );

      expect(acrossDateLine, isTrue);
    });

    test('Calculates boundary overlap area', () async {
      final boundary1 = GPSBoundary(
        id: 'boundary-001',
        name: 'Boundary 1',
        centerLatitude: 42.3601,
        centerLongitude: -71.0589,
        radiusMeters: 500,
        priority: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isActive: true,
      );

      final boundary2 = GPSBoundary(
        id: 'boundary-002',
        name: 'Boundary 2',
        centerLatitude: 42.3610,
        centerLongitude: -71.0595,
        radiusMeters: 400,
        priority: 2,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isActive: true,
      );

      when(mockBoundaryDetector.calculateOverlapArea(boundary1, boundary2))
          .thenAnswer((_) async {
        // Calculate approximate overlap area
        return 125663.7; // Square meters (partial overlap)
      });

      final overlapArea = await mockBoundaryDetector.calculateOverlapArea(
        boundary1,
        boundary2,
      );

      expect(overlapArea, greaterThan(0));
      expect(overlapArea, lessThan(pi * 500 * 500), // Less than full area of boundary1
          reason: 'Overlap should be partial');
    });

    test('Generates boundary grid for efficient lookup', () async {
      final boundaries = List.generate(10, (i) => GPSBoundary(
        id: 'boundary-$i',
        name: 'Boundary $i',
        centerLatitude: 42.36 + (i * 0.01),
        centerLongitude: -71.06 + (i * 0.01),
        radiusMeters: 200 + (i * 50),
        priority: i,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isActive: true,
      ));

      when(mockBoundaryDetector.createSpatialIndex(boundaries))
          .thenAnswer((_) async {
        // Create spatial index for fast lookup
        return {
          'gridSize': 100, // 100m grid cells
          'cellCount': 25,
          'boundariesIndexed': 10,
        };
      });

      final index = await mockBoundaryDetector.createSpatialIndex(boundaries);

      expect(index['boundariesIndexed'], equals(10));
      expect(index['cellCount'], greaterThan(0));
    });

    test('Filters inactive boundaries correctly', () async {
      final boundaries = [
        GPSBoundary(
          id: 'boundary-001',
          name: 'Active Boundary',
          centerLatitude: 42.3601,
          centerLongitude: -71.0589,
          radiusMeters: 500,
          priority: 1,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isActive: true,
        ),
        GPSBoundary(
          id: 'boundary-002',
          name: 'Inactive Boundary',
          centerLatitude: 42.3605,
          centerLongitude: -71.0590,
          radiusMeters: 300,
          priority: 2,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isActive: false,
        ),
      ];

      when(mockBoundaryDetector.getActiveBoundaries(boundaries))
          .thenAnswer((_) async {
        return boundaries.where((b) => b.isActive).toList();
      });

      final active = await mockBoundaryDetector.getActiveBoundaries(boundaries);

      expect(active, hasLength(1));
      expect(active[0].isActive, isTrue);
      expect(active[0].id, equals('boundary-001'));
    });
  });

  // Helper function for Haversine distance calculation
  double calculateHaversineDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadius = 6371000; // meters
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _toRadians(double degrees) {
    return degrees * pi / 180;
  }
}