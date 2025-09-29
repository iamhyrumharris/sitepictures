import 'dart:async';
import '../models/photo.dart';
import '../models/equipment.dart';
import '../models/site.dart';
import '../models/client.dart';
import 'storage_service.dart';

class SearchService {
  static SearchService? _instance;
  final StorageService _storageService = StorageService.instance;
  List<String> _searchHistory = [];
  Timer? _debounceTimer;

  SearchService._();

  static SearchService get instance {
    _instance ??= SearchService._();
    return _instance!;
  }

  Future<SearchResults> search({
    required String query,
    SearchFilter? filter,
    int limit = 50,
  }) async {
    final stopwatch = Stopwatch()..start();

    try {
      final results = SearchResults();

      if (query.isEmpty && filter == null) {
        return results;
      }

      final db = await _storageService.database;

      if (query.isNotEmpty) {
        final searchResults = await db.rawQuery(
          'SELECT entity_type, entity_id FROM search_index WHERE content MATCH ? LIMIT ?',
          [query, limit],
        );

        for (final result in searchResults) {
          await _loadEntity(result, results);
        }
      }

      if (filter != null) {
        await _applyFilter(filter, results, limit);
      }

      _addToHistory(query);

      results.searchTimeMs = stopwatch.elapsedMilliseconds;

      if (results.searchTimeMs > 1000) {
        print('Warning: Search took ${results.searchTimeMs}ms');
      }

      return results;
    } finally {
      stopwatch.stop();
    }
  }

  Future<void> _loadEntity(Map<String, dynamic> result, SearchResults results) async {
    final entityType = result['entity_type'];
    final entityId = result['entity_id'];

    switch (entityType) {
      case 'Photo':
        final photo = await _storageService.getPhoto(entityId);
        if (photo != null) results.photos.add(photo);
        break;
      case 'Equipment':
        final equipment = await _getEquipment(entityId);
        if (equipment != null) results.equipment.add(equipment);
        break;
      case 'Site':
        final site = await _getSite(entityId);
        if (site != null) results.sites.add(site);
        break;
      case 'Client':
        final client = await _getClient(entityId);
        if (client != null) results.clients.add(client);
        break;
    }
  }

  Future<void> _applyFilter(SearchFilter filter, SearchResults results, int limit) async {
    final db = await _storageService.database;

    if (filter.dateFrom != null || filter.dateTo != null) {
      String whereClause = '';
      List<dynamic> whereArgs = [];

      if (filter.dateFrom != null) {
        whereClause = 'captured_at >= ?';
        whereArgs.add(filter.dateFrom!.toIso8601String());
      }

      if (filter.dateTo != null) {
        if (whereClause.isNotEmpty) whereClause += ' AND ';
        whereClause += 'captured_at <= ?';
        whereArgs.add(filter.dateTo!.toIso8601String());
      }

      final photos = await db.query(
        'photos',
        where: whereClause,
        whereArgs: whereArgs,
        orderBy: 'captured_at DESC',
        limit: limit,
      );

      for (final photoData in photos) {
        results.photos.add(Photo.fromJson(photoData));
      }
    }

    if (filter.equipmentType != null) {
      final equipment = await db.query(
        'equipment',
        where: 'equipment_type = ? AND is_active = ?',
        whereArgs: [filter.equipmentType, 1],
        limit: limit,
      );

      for (final equipmentData in equipment) {
        results.equipment.add(Equipment.fromJson(equipmentData));
      }
    }

    if (filter.clientId != null) {
      final sites = await db.query(
        'sites',
        where: 'client_id = ? AND is_active = ?',
        whereArgs: [filter.clientId, 1],
        limit: limit,
      );

      for (final siteData in sites) {
        results.sites.add(Site.fromJson(siteData));
      }
    }

    if (filter.nearLocation != null) {
      await _searchNearLocation(filter.nearLocation!, filter.radiusMeters ?? 1000, results, limit);
    }
  }

  Future<void> _searchNearLocation(
    LocationPoint location,
    double radiusMeters,
    SearchResults results,
    int limit,
  ) async {
    final db = await _storageService.database;

    final latMin = location.latitude - (radiusMeters / 111000);
    final latMax = location.latitude + (radiusMeters / 111000);
    final lonMin = location.longitude - (radiusMeters / 111000);
    final lonMax = location.longitude + (radiusMeters / 111000);

    final photos = await db.query(
      'photos',
      where: 'latitude BETWEEN ? AND ? AND longitude BETWEEN ? AND ?',
      whereArgs: [latMin, latMax, lonMin, lonMax],
      limit: limit,
    );

    for (final photoData in photos) {
      final photo = Photo.fromJson(photoData);
      final distance = _calculateDistance(
        location.latitude,
        location.longitude,
        photo.latitude ?? 0,
        photo.longitude ?? 0,
      );

      if (distance <= radiusMeters) {
        results.photos.add(photo);
      }
    }
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const earthRadius = 6371000.0;
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    final a = (dLat / 2).sin() * (dLat / 2).sin() +
        _toRadians(lat1).cos() *
            _toRadians(lat2).cos() *
            (dLon / 2).sin() *
            (dLon / 2).sin();
    final c = 2 * a.sqrt().asin();
    return earthRadius * c;
  }

  double _toRadians(double degrees) => degrees * (3.14159265359 / 180.0);

  Future<List<String>> getSuggestions(String query) async {
    if (query.isEmpty) {
      return _searchHistory.take(5).toList();
    }

    final suggestions = <String>[];

    suggestions.addAll(_searchHistory
        .where((h) => h.toLowerCase().contains(query.toLowerCase()))
        .take(3));

    final db = await _storageService.database;
    final results = await db.rawQuery(
      'SELECT DISTINCT content FROM search_index WHERE content MATCH ? LIMIT 5',
      ['$query*'],
    );

    for (final result in results) {
      final content = result['content'] as String;
      if (!suggestions.contains(content)) {
        suggestions.add(content);
      }
    }

    return suggestions.take(10).toList();
  }

  Future<SearchResults> searchWithDebounce({
    required String query,
    SearchFilter? filter,
    Duration delay = const Duration(milliseconds: 300),
  }) async {
    _debounceTimer?.cancel();

    final completer = Completer<SearchResults>();

    _debounceTimer = Timer(delay, () async {
      final results = await search(query: query, filter: filter);
      completer.complete(results);
    });

    return completer.future;
  }

  Future<List<Photo>> searchPhotosByEquipment(String equipmentId) async {
    return await _storageService.getPhotosByEquipment(equipmentId);
  }

  Future<List<Equipment>> searchEquipmentBySite(String siteId) async {
    return await _storageService.getEquipmentBySite(siteId);
  }

  Future<List<Site>> searchSitesByClient(String clientId) async {
    return await _storageService.getSitesByClient(clientId);
  }

  Future<SearchHierarchy> getHierarchy(String entityType, String entityId) async {
    final hierarchy = SearchHierarchy();

    switch (entityType) {
      case 'Photo':
        final photo = await _storageService.getPhoto(entityId);
        if (photo != null) {
          hierarchy.photo = photo;
          final equipment = await _getEquipment(photo.equipmentId);
          if (equipment != null) {
            hierarchy.equipment = equipment;
            final site = await _getSite(equipment.siteId);
            if (site != null) {
              hierarchy.site = site;
              final client = await _getClient(site.clientId);
              hierarchy.client = client;
            }
          }
        }
        break;
      case 'Equipment':
        final equipment = await _getEquipment(entityId);
        if (equipment != null) {
          hierarchy.equipment = equipment;
          final site = await _getSite(equipment.siteId);
          if (site != null) {
            hierarchy.site = site;
            final client = await _getClient(site.clientId);
            hierarchy.client = client;
          }
        }
        break;
      case 'Site':
        final site = await _getSite(entityId);
        if (site != null) {
          hierarchy.site = site;
          final client = await _getClient(site.clientId);
          hierarchy.client = client;
        }
        break;
      case 'Client':
        final client = await _getClient(entityId);
        hierarchy.client = client;
        break;
    }

    return hierarchy;
  }

  void _addToHistory(String query) {
    if (query.isNotEmpty && !_searchHistory.contains(query)) {
      _searchHistory.insert(0, query);
      if (_searchHistory.length > 20) {
        _searchHistory = _searchHistory.take(20).toList();
      }
    }
  }

  void clearHistory() {
    _searchHistory.clear();
  }

  Future<Equipment?> _getEquipment(String id) async {
    final db = await _storageService.database;
    final results = await db.query(
      'equipment',
      where: 'id = ?',
      whereArgs: [id],
    );
    return results.isNotEmpty ? Equipment.fromJson(results.first) : null;
  }

  Future<Site?> _getSite(String id) async {
    final db = await _storageService.database;
    final results = await db.query(
      'sites',
      where: 'id = ?',
      whereArgs: [id],
    );
    return results.isNotEmpty ? Site.fromJson(results.first) : null;
  }

  Future<Client?> _getClient(String id) async {
    final db = await _storageService.database;
    final results = await db.query(
      'clients',
      where: 'id = ?',
      whereArgs: [id],
    );
    return results.isNotEmpty ? Client.fromJson(results.first) : null;
  }
}

class SearchResults {
  final List<Photo> photos = [];
  final List<Equipment> equipment = [];
  final List<Site> sites = [];
  final List<Client> clients = [];
  int searchTimeMs = 0;

  int get totalResults => photos.length + equipment.length + sites.length + clients.length;
  bool get isEmpty => totalResults == 0;
}

class SearchFilter {
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final String? equipmentType;
  final String? clientId;
  final String? siteId;
  final LocationPoint? nearLocation;
  final double? radiusMeters;
  final List<String>? tags;

  SearchFilter({
    this.dateFrom,
    this.dateTo,
    this.equipmentType,
    this.clientId,
    this.siteId,
    this.nearLocation,
    this.radiusMeters,
    this.tags,
  });
}

class LocationPoint {
  final double latitude;
  final double longitude;

  LocationPoint(this.latitude, this.longitude);
}

class SearchHierarchy {
  Client? client;
  Site? site;
  Equipment? equipment;
  Photo? photo;

  String get breadcrumb {
    final parts = <String>[];
    if (client != null) parts.add(client!.name);
    if (site != null) parts.add(site!.name);
    if (equipment != null) parts.add(equipment!.name);
    return parts.join(' > ');
  }
}