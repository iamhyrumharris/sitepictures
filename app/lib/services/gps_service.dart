import 'dart:async';
import 'dart:math' as math;
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import '../models/site.dart';
import '../models/gps_boundary.dart';
import 'storage_service.dart';

/// GPS service with location tracking and boundary detection
/// Handles battery-optimized location tracking and Haversine distance calculations
class GPSService {
  static final GPSService _instance = GPSService._internal();
  factory GPSService() => _instance;
  GPSService._internal();

  final _storageService = StorageService();

  // Location tracking state
  StreamSubscription<Position>? _locationSubscription;
  Position? _lastKnownPosition;
  DateTime? _lastLocationUpdate;

  // Background location settings
  final LocationSettings _backgroundSettings = const LocationSettings(
    accuracy: LocationAccuracy.balanced,
    distanceFilter: 10, // Only update if moved 10 meters
  );

  final LocationSettings _highAccuracySettings = const LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 1,
  );

  final LocationSettings _quickSettings = const LocationSettings(
    accuracy: LocationAccuracy.medium,
    distanceFilter: 5,
    timeLimit: Duration(seconds: 3),
  );

  // Cached boundaries for performance
  List<GPSBoundary>? _cachedBoundaries;
  DateTime? _boundariesCacheTime;
  static const Duration _cacheValidDuration = Duration(minutes: 10);

  /// Initialize GPS service and request permissions
  Future<bool> initialize() async {
    try {
      // Check location service availability
      if (!await Geolocator.isLocationServiceEnabled()) {
        debugPrint('Location services are disabled');
        return false;
      }

      // Request location permissions
      final permission = await _requestLocationPermission();
      if (!permission) {
        debugPrint('Location permission denied');
        return false;
      }

      // Get initial position
      await _updateCurrentLocation();

      debugPrint('GPSService initialized successfully');
      return true;

    } catch (e) {
      debugPrint('GPSService initialization failed: $e');
      return false;
    }
  }

  /// Request location permissions with proper handling
  Future<bool> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Open app settings for user to enable manually
      await openAppSettings();
      return false;
    }

    return true;
  }

  /// Get current location with high accuracy
  Future<Position?> getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: _highAccuracySettings,
      );

      _lastKnownPosition = position;
      _lastLocationUpdate = DateTime.now();

      debugPrint('Current location: ${position.latitude}, ${position.longitude}');
      return position;

    } catch (e) {
      debugPrint('Failed to get current location: $e');
      return _lastKnownPosition;
    }
  }

  /// Get current location quickly for time-sensitive operations
  Future<Position?> getCurrentLocationQuick() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: _quickSettings,
      );

      _lastKnownPosition = position;
      return position;

    } catch (e) {
      debugPrint('Quick location failed: $e');
      return _lastKnownPosition;
    }
  }

  /// Get last known position without GPS query
  Position? getLastKnownPosition() {
    return _lastKnownPosition;
  }

  /// Start background location tracking
  Future<void> startLocationTracking() async {
    if (_locationSubscription != null) {
      await stopLocationTracking();
    }

    try {
      _locationSubscription = Geolocator.getPositionStream(
        locationSettings: _backgroundSettings,
      ).listen(
        (Position position) {
          _lastKnownPosition = position;
          _lastLocationUpdate = DateTime.now();

          // Check for automatic assignment opportunities
          _checkAutoAssignment(position);
        },
        onError: (e) {
          debugPrint('Location tracking error: $e');
        },
      );

      debugPrint('Background location tracking started');

    } catch (e) {
      debugPrint('Failed to start location tracking: $e');
    }
  }

  /// Stop background location tracking
  Future<void> stopLocationTracking() async {
    await _locationSubscription?.cancel();
    _locationSubscription = null;
    debugPrint('Background location tracking stopped');
  }

  /// Check if location is within any GPS boundaries
  Future<List<Site>> findSitesInBoundary(double latitude, double longitude) async {
    try {
      final boundaries = await _getCachedBoundaries();
      final matchingSites = <Site>[];

      for (final boundary in boundaries) {
        if (_isLocationInBoundary(latitude, longitude, boundary)) {
          // Get site details
          final siteData = await _storageService.database.then((db) =>
              db.query('sites', where: 'id = ?', whereArgs: [boundary.id]));

          if (siteData.isNotEmpty) {
            matchingSites.add(Site.fromJson(siteData.first));
          }
        }
      }

      return matchingSites;

    } catch (e) {
      debugPrint('Failed to find sites in boundary: $e');
      return [];
    }
  }

  /// Find equipment within GPS boundaries
  Future<List<Map<String, dynamic>>> findEquipmentInBoundary(
    double latitude,
    double longitude,
  ) async {
    try {
      final sitesInBoundary = await findSitesInBoundary(latitude, longitude);
      final equipment = <Map<String, dynamic>>[];

      for (final site in sitesInBoundary) {
        final siteEquipment = await _storageService.getEquipment(siteId: site.id);
        equipment.addAll(siteEquipment);
      }

      // Sort by distance from current location
      equipment.sort((a, b) {
        final distanceA = _calculateSiteDistance(latitude, longitude, a['site_id']);
        final distanceB = _calculateSiteDistance(latitude, longitude, b['site_id']);
        return distanceA.compareTo(distanceB);
      });

      return equipment;

    } catch (e) {
      debugPrint('Failed to find equipment in boundary: $e');
      return [];
    }
  }

  /// Calculate distance between two coordinates using Haversine formula
  double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371000.0; // Earth radius in meters

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

  /// Check if location is within a specific boundary
  bool _isLocationInBoundary(
    double latitude,
    double longitude,
    GPSBoundary boundary,
  ) {
    final distance = calculateDistance(
      latitude,
      longitude,
      boundary.centerLatitude,
      boundary.centerLongitude,
    );

    return distance <= boundary.radiusMeters;
  }

  /// Get bearing between two coordinates
  double calculateBearing(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    final double dLon = _toRadians(lon2 - lon1);
    final double lat1Rad = _toRadians(lat1);
    final double lat2Rad = _toRadians(lat2);

    final double y = math.sin(dLon) * math.cos(lat2Rad);
    final double x = math.cos(lat1Rad) * math.sin(lat2Rad) -
        math.sin(lat1Rad) * math.cos(lat2Rad) * math.cos(dLon);

    double bearing = math.atan2(y, x);
    bearing = _toDegrees(bearing);
    bearing = (bearing + 360) % 360; // Normalize to 0-360

    return bearing;
  }

  /// Get GPS accuracy status
  LocationAccuracy getLocationAccuracy() {
    if (_lastKnownPosition == null) {
      return LocationAccuracy.none;
    }

    final accuracy = _lastKnownPosition!.accuracy;

    if (accuracy <= 3) return LocationAccuracy.best;
    if (accuracy <= 5) return LocationAccuracy.high;
    if (accuracy <= 10) return LocationAccuracy.medium;
    if (accuracy <= 100) return LocationAccuracy.low;
    return LocationAccuracy.lowest;
  }

  /// Get location age in seconds
  int? getLocationAge() {
    if (_lastLocationUpdate == null) return null;
    return DateTime.now().difference(_lastLocationUpdate!).inSeconds;
  }

  /// Check if GPS is currently active
  bool get isLocationTrackingActive => _locationSubscription != null;

  /// Get location tracking statistics
  Map<String, dynamic> getLocationStats() {
    return {
      'isTracking': isLocationTrackingActive,
      'lastPosition': _lastKnownPosition != null
          ? {
              'latitude': _lastKnownPosition!.latitude,
              'longitude': _lastKnownPosition!.longitude,
              'accuracy': _lastKnownPosition!.accuracy,
              'altitude': _lastKnownPosition!.altitude,
              'speed': _lastKnownPosition!.speed,
              'heading': _lastKnownPosition!.heading,
              'timestamp': _lastKnownPosition!.timestamp.toIso8601String(),
            }
          : null,
      'locationAge': getLocationAge(),
      'accuracyLevel': getLocationAccuracy().toString(),
    };
  }

  /// Get cached GPS boundaries for performance
  Future<List<GPSBoundary>> _getCachedBoundaries() async {
    final now = DateTime.now();

    // Return cached data if still valid
    if (_cachedBoundaries != null &&
        _boundariesCacheTime != null &&
        now.difference(_boundariesCacheTime!).inSeconds < _cacheValidDuration.inSeconds) {
      return _cachedBoundaries!;
    }

    // Refresh boundaries from database
    try {
      final db = await _storageService.database;
      final results = await db.rawQuery('''
        SELECT c.boundaries
        FROM clients c
        WHERE c.is_active = 1
      ''');

      final boundaries = <GPSBoundary>[];
      for (final row in results) {
        if (row['boundaries'] != null) {
          // Parse JSON boundaries (implementation depends on storage format)
          // This is a simplified example
          boundaries.addAll(_parseBoundariesFromJson(row['boundaries'] as String));
        }
      }

      _cachedBoundaries = boundaries;
      _boundariesCacheTime = now;

      return boundaries;

    } catch (e) {
      debugPrint('Failed to load GPS boundaries: $e');
      return _cachedBoundaries ?? [];
    }
  }

  /// Parse boundaries from JSON storage format
  List<GPSBoundary> _parseBoundariesFromJson(String json) {
    // Implementation would parse the actual JSON format used in storage
    // This is a placeholder
    return [];
  }

  /// Check for automatic assignment opportunities
  Future<void> _checkAutoAssignment(Position position) async {
    try {
      final sitesInRange = await findSitesInBoundary(
        position.latitude,
        position.longitude,
      );

      if (sitesInRange.isNotEmpty) {
        debugPrint('Automatic assignment opportunity detected at ${sitesInRange.length} sites');
        // Trigger automatic assignment logic
        // This would typically emit an event or call a callback
      }

    } catch (e) {
      debugPrint('Auto-assignment check failed: $e');
    }
  }

  /// Calculate distance to a site by site ID
  double _calculateSiteDistance(double currentLat, double currentLon, String siteId) {
    // This would look up site coordinates and calculate distance
    // Simplified implementation
    return 0.0;
  }

  /// Update current location without external call
  Future<void> _updateCurrentLocation() async {
    try {
      final position = await Geolocator.getLastKnownPosition();
      if (position != null) {
        _lastKnownPosition = position;
        _lastLocationUpdate = DateTime.now();
      }
    } catch (e) {
      debugPrint('Failed to get last known position: $e');
    }
  }

  /// Convert degrees to radians
  double _toRadians(double degrees) => degrees * (math.pi / 180.0);

  /// Convert radians to degrees
  double _toDegrees(double radians) => radians * (180.0 / math.pi);

  /// Check location permissions status
  Future<bool> hasLocationPermission() async {
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always ||
           permission == LocationPermission.whileInUse;
  }

  /// Open location settings
  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  /// Dispose GPS service resources
  Future<void> dispose() async {
    await stopLocationTracking();
    _cachedBoundaries = null;
    _boundariesCacheTime = null;
    debugPrint('GPSService disposed');
  }

  /// Mock location for testing (debug only)
  void setMockLocation(double latitude, double longitude) {
    if (kDebugMode) {
      _lastKnownPosition = Position(
        latitude: latitude,
        longitude: longitude,
        timestamp: DateTime.now(),
        accuracy: 1.0,
        altitude: 0.0,
        altitudeAccuracy: 1.0,
        heading: 0.0,
        headingAccuracy: 1.0,
        speed: 0.0,
        speedAccuracy: 1.0,
      );
      _lastLocationUpdate = DateTime.now();
      debugPrint('Mock location set: $latitude, $longitude');
    }
  }

  /// Get estimated time to GPS fix
  Duration? getEstimatedTimeToFix() {
    final accuracy = getLocationAccuracy();
    switch (accuracy) {
      case LocationAccuracy.best:
      case LocationAccuracy.high:
        return const Duration(seconds: 2);
      case LocationAccuracy.medium:
        return const Duration(seconds: 5);
      case LocationAccuracy.low:
        return const Duration(seconds: 10);
      case LocationAccuracy.lowest:
        return const Duration(seconds: 30);
      default:
        return null;
    }
  }
}