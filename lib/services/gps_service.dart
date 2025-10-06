import 'package:geolocator/geolocator.dart';

class GpsService {
  static final GpsService _instance = GpsService._internal();

  Position? _lastKnownPosition;

  factory GpsService() => _instance;

  GpsService._internal();

  Position? get lastKnownPosition => _lastKnownPosition;

  Future<bool> checkPermissions() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  Future<Position?> getCurrentLocation() async {
    try {
      final hasPermission = await checkPermissions();
      if (!hasPermission) {
        return _lastKnownPosition;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _lastKnownPosition = position;
      return position;
    } catch (e) {
      return _lastKnownPosition;
    }
  }

  Future<Position?> getLastKnownLocation() async {
    try {
      final position = await Geolocator.getLastKnownPosition();
      if (position != null) {
        _lastKnownPosition = position;
      }
      return position;
    } catch (e) {
      return null;
    }
  }

  Stream<Position> getPositionStream() {
    return Geolocator.getPositionStream();
  }

  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  Future<LocationPermission> getPermissionStatus() async {
    return await Geolocator.checkPermission();
  }

  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }
}
