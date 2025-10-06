import '../models/recent_location.dart';
import 'database_service.dart';

/// Service for tracking and managing recent user locations
/// Implements FR-001 recent locations feature
class RecentLocationsService {
  static final RecentLocationsService _instance =
      RecentLocationsService._internal();
  final DatabaseService _dbService = DatabaseService();

  factory RecentLocationsService() => _instance;

  RecentLocationsService._internal();

  /// Track a location visit
  /// Automatically limits to 10 most recent locations per user
  Future<void> trackLocation({
    required String userId,
    required String displayName,
    required String navigationPath,
    String? clientId,
    String? mainSiteId,
    String? subSiteId,
    String? equipmentId,
  }) async {
    final db = await _dbService.database;

    // Check if this location already exists
    final existing = await db.query(
      'recent_locations',
      where: '''
        user_id = ? AND
        (client_id = ? OR (client_id IS NULL AND ? IS NULL)) AND
        (main_site_id = ? OR (main_site_id IS NULL AND ? IS NULL)) AND
        (sub_site_id = ? OR (sub_site_id IS NULL AND ? IS NULL)) AND
        (equipment_id = ? OR (equipment_id IS NULL AND ? IS NULL))
      ''',
      whereArgs: [
        userId,
        clientId,
        clientId,
        mainSiteId,
        mainSiteId,
        subSiteId,
        subSiteId,
        equipmentId,
        equipmentId,
      ],
    );

    if (existing.isNotEmpty) {
      // Update the accessed_at timestamp for existing location
      await db.update(
        'recent_locations',
        {'accessed_at': DateTime.now().toIso8601String()},
        where: 'id = ?',
        whereArgs: [existing.first['id']],
      );
    } else {
      // Create new recent location entry
      final recentLocation = RecentLocation(
        id: '${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        clientId: clientId,
        mainSiteId: mainSiteId,
        subSiteId: subSiteId,
        equipmentId: equipmentId,
        accessedAt: DateTime.now(),
        displayName: displayName,
        navigationPath: navigationPath,
      );

      await db.insert('recent_locations', recentLocation.toMap());
    }

    // Maintain max 10 recent locations per user
    await _cleanupOldLocations(userId);
  }

  /// Get recent locations for a user
  Future<List<RecentLocation>> getRecentLocations(String userId) async {
    final db = await _dbService.database;
    final results = await db.query(
      'recent_locations',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'accessed_at DESC',
      limit: 10,
    );

    return results.map((map) => RecentLocation.fromMap(map)).toList();
  }

  /// Remove old locations beyond the 10 most recent
  Future<void> _cleanupOldLocations(String userId) async {
    final db = await _dbService.database;

    // Get all locations for user, ordered by most recent
    final allLocations = await db.query(
      'recent_locations',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'accessed_at DESC',
    );

    // If more than 10, delete the oldest ones
    if (allLocations.length > 10) {
      final locationsToDelete = allLocations.skip(10);
      for (final location in locationsToDelete) {
        await db.delete(
          'recent_locations',
          where: 'id = ?',
          whereArgs: [location['id']],
        );
      }
    }
  }

  /// Clear all recent locations for a user
  Future<void> clearRecentLocations(String userId) async {
    final db = await _dbService.database;
    await db.delete(
      'recent_locations',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  /// Build navigation path string for breadcrumb
  String buildNavigationPath({
    String? clientName,
    String? mainSiteName,
    String? subSiteName,
    String? equipmentName,
  }) {
    final parts = <String>[];
    if (clientName != null) parts.add(clientName);
    if (mainSiteName != null) parts.add(mainSiteName);
    if (subSiteName != null) parts.add(subSiteName);
    if (equipmentName != null) parts.add(equipmentName);
    return parts.join(' > ');
  }
}
