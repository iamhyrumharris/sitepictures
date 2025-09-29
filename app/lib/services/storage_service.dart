import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart';
import '../models/photo.dart';
import '../models/client.dart';
import '../models/site.dart';
import '../models/user.dart';
import '../models/company.dart';

/// Storage service for SQLite operations with offline-first architecture
/// Handles CRUD operations, transactions, full-text search, and migrations
class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  Database? _database;
  static const String _databaseName = 'fieldphoto_pro.db';
  static const int _databaseVersion = 1;

  /// Get database instance, initializing if needed
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize SQLite database with schema and FTS5 indexing
  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final dbPath = path.join(databasePath, _databaseName);

    return await openDatabase(
      dbPath,
      version: _databaseVersion,
      onCreate: _createDatabase,
      onUpgrade: _upgradeDatabase,
      onConfigure: _configureDatabase,
    );
  }

  /// Configure database settings
  Future<void> _configureDatabase(Database db) async {
    // Enable foreign key constraints
    await db.execute('PRAGMA foreign_keys = ON');

    // Optimize for performance
    await db.execute('PRAGMA journal_mode = WAL');
    await db.execute('PRAGMA synchronous = NORMAL');
    await db.execute('PRAGMA cache_size = 10000');
    await db.execute('PRAGMA temp_store = MEMORY');
  }

  /// Create database schema
  Future<void> _createDatabase(Database db, int version) async {
    // Companies table
    await db.execute('''
      CREATE TABLE companies (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        settings TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1
      )
    ''');

    // Users table
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        device_name TEXT NOT NULL,
        company_id TEXT,
        preferences TEXT,
        first_seen TEXT NOT NULL,
        last_seen TEXT NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1,
        FOREIGN KEY (company_id) REFERENCES companies (id)
      )
    ''');

    // Clients table
    await db.execute('''
      CREATE TABLE clients (
        id TEXT PRIMARY KEY,
        company_id TEXT NOT NULL,
        name TEXT NOT NULL,
        description TEXT,
        boundaries TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1,
        FOREIGN KEY (company_id) REFERENCES companies (id)
      )
    ''');

    // Sites table
    await db.execute('''
      CREATE TABLE sites (
        id TEXT PRIMARY KEY,
        client_id TEXT NOT NULL,
        parent_site_id TEXT,
        name TEXT NOT NULL,
        address TEXT,
        center_latitude REAL,
        center_longitude REAL,
        boundary_radius REAL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1,
        FOREIGN KEY (client_id) REFERENCES clients (id),
        FOREIGN KEY (parent_site_id) REFERENCES sites (id)
      )
    ''');

    // Equipment table
    await db.execute('''
      CREATE TABLE equipment (
        id TEXT PRIMARY KEY,
        site_id TEXT NOT NULL,
        name TEXT NOT NULL,
        equipment_type TEXT,
        serial_number TEXT,
        model TEXT,
        manufacturer TEXT,
        tags TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1,
        FOREIGN KEY (site_id) REFERENCES sites (id)
      )
    ''');

    // Photos table
    await db.execute('''
      CREATE TABLE photos (
        id TEXT PRIMARY KEY,
        equipment_id TEXT NOT NULL,
        revision_id TEXT,
        file_name TEXT NOT NULL,
        file_hash TEXT NOT NULL UNIQUE,
        latitude REAL,
        longitude REAL,
        captured_at TEXT NOT NULL,
        notes TEXT,
        device_id TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        is_synced INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (equipment_id) REFERENCES equipment (id)
      )
    ''');

    // Sync packages table
    await db.execute('''
      CREATE TABLE sync_packages (
        id TEXT PRIMARY KEY,
        entity_type TEXT NOT NULL,
        entity_id TEXT NOT NULL,
        operation TEXT NOT NULL,
        data TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        device_id TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'PENDING',
        retry_count INTEGER NOT NULL DEFAULT 0,
        last_attempt TEXT,
        error_message TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    // Full-text search index using FTS5
    await db.execute('''
      CREATE VIRTUAL TABLE search_index USING fts5(
        entity_type,
        entity_id,
        content,
        tokenize = 'porter'
      )
    ''');

    // Create indexes for performance
    await _createIndexes(db);

    debugPrint('Database schema created successfully');
  }

  /// Create performance indexes
  Future<void> _createIndexes(Database db) async {
    // Photo indexes
    await db.execute('CREATE INDEX idx_photos_equipment_id ON photos (equipment_id)');
    await db.execute('CREATE INDEX idx_photos_captured_at ON photos (captured_at DESC)');
    await db.execute('CREATE INDEX idx_photos_location ON photos (latitude, longitude)');
    await db.execute('CREATE INDEX idx_photos_sync_status ON photos (is_synced)');

    // Equipment indexes
    await db.execute('CREATE INDEX idx_equipment_site_id ON equipment (site_id)');
    await db.execute('CREATE INDEX idx_equipment_name ON equipment (name)');
    await db.execute('CREATE INDEX idx_equipment_type ON equipment (equipment_type)');

    // Site indexes
    await db.execute('CREATE INDEX idx_sites_client_id ON sites (client_id)');
    await db.execute('CREATE INDEX idx_sites_parent ON sites (parent_site_id)');
    await db.execute('CREATE INDEX idx_sites_location ON sites (center_latitude, center_longitude)');

    // Sync package indexes
    await db.execute('CREATE INDEX idx_sync_packages_status ON sync_packages (status)');
    await db.execute('CREATE INDEX idx_sync_packages_timestamp ON sync_packages (timestamp)');
    await db.execute('CREATE INDEX idx_sync_packages_entity ON sync_packages (entity_type, entity_id)');
  }

  /// Handle database upgrades
  Future<void> _upgradeDatabase(Database db, int oldVersion, int newVersion) async {
    // Future migrations will be handled here
    debugPrint('Database upgraded from version $oldVersion to $newVersion');
  }

  // CRUD Operations for Photos
  Future<void> insertPhoto(Photo photo) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.insert('photos', photo.toMap());

      // Add to search index if notes exist
      if (photo.notes != null && photo.notes!.isNotEmpty) {
        await txn.insert('search_index', {
          'entity_type': 'Photo',
          'entity_id': photo.id,
          'content': photo.notes!,
        });
      }
    });
  }

  Future<List<Photo>> getPhotos({
    String? equipmentId,
    String? siteId,
    DateTime? startDate,
    DateTime? endDate,
    bool? synced,
    int? limit,
    int? offset,
  }) async {
    final db = await database;

    final whereConditions = <String>[];
    final whereArgs = <dynamic>[];

    if (equipmentId != null) {
      whereConditions.add('equipment_id = ?');
      whereArgs.add(equipmentId);
    }

    if (siteId != null) {
      whereConditions.add('equipment_id IN (SELECT id FROM equipment WHERE site_id = ?)');
      whereArgs.add(siteId);
    }

    if (startDate != null) {
      whereConditions.add('captured_at >= ?');
      whereArgs.add(startDate.toIso8601String());
    }

    if (endDate != null) {
      whereConditions.add('captured_at <= ?');
      whereArgs.add(endDate.toIso8601String());
    }

    if (synced != null) {
      whereConditions.add('is_synced = ?');
      whereArgs.add(synced ? 1 : 0);
    }

    final whereClause = whereConditions.isNotEmpty
        ? whereConditions.join(' AND ')
        : null;

    final results = await db.query(
      'photos',
      where: whereClause,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'captured_at DESC',
      limit: limit,
      offset: offset,
    );

    return results.map((map) => Photo.fromMap(map)).toList();
  }

  Future<Photo?> getPhotoById(String id) async {
    final db = await database;
    final results = await db.query(
      'photos',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (results.isNotEmpty) {
      return Photo.fromMap(results.first);
    }
    return null;
  }

  Future<void> updatePhoto(Photo photo) async {
    final db = await database;
    await db.update(
      'photos',
      photo.toMap(),
      where: 'id = ?',
      whereArgs: [photo.id],
    );
  }

  Future<void> deletePhoto(String id) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('photos', where: 'id = ?', whereArgs: [id]);
      await txn.delete('search_index', where: 'entity_id = ?', whereArgs: [id]);
    });
  }

  // CRUD Operations for Equipment
  Future<void> insertEquipment(Map<String, dynamic> equipment) async {
    final db = await database;
    await db.insert('equipment', equipment);
  }

  Future<List<Map<String, dynamic>>> getEquipment({
    String? siteId,
    String? equipmentType,
    bool? isActive,
  }) async {
    final db = await database;

    final whereConditions = <String>[];
    final whereArgs = <dynamic>[];

    if (siteId != null) {
      whereConditions.add('site_id = ?');
      whereArgs.add(siteId);
    }

    if (equipmentType != null) {
      whereConditions.add('equipment_type = ?');
      whereArgs.add(equipmentType);
    }

    if (isActive != null) {
      whereConditions.add('is_active = ?');
      whereArgs.add(isActive ? 1 : 0);
    }

    final whereClause = whereConditions.isNotEmpty
        ? whereConditions.join(' AND ')
        : null;

    return await db.query(
      'equipment',
      where: whereClause,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'name',
    );
  }

  // Full-text search with FTS5
  Future<List<Map<String, dynamic>>> searchContent(
    String query, {
    List<String>? entityTypes,
    int? limit,
  }) async {
    final db = await database;

    String searchQuery = query;
    final whereConditions = <String>[];
    final whereArgs = <dynamic>[];

    // Build search query
    whereConditions.add('search_index MATCH ?');
    whereArgs.add(searchQuery);

    if (entityTypes != null && entityTypes.isNotEmpty) {
      final typeConditions = entityTypes.map((_) => 'entity_type = ?').join(' OR ');
      whereConditions.add('($typeConditions)');
      whereArgs.addAll(entityTypes);
    }

    final results = await db.query(
      'search_index',
      where: whereConditions.join(' AND '),
      whereArgs: whereArgs,
      orderBy: 'rank',
      limit: limit,
    );

    return results;
  }

  // Add content to search index
  Future<void> addToSearchIndex(
    String entityType,
    String entityId,
    String content,
  ) async {
    final db = await database;
    await db.insert(
      'search_index',
      {
        'entity_type': entityType,
        'entity_id': entityId,
        'content': content,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Transaction support
  Future<T> transaction<T>(Future<T> Function(Transaction txn) action) async {
    final db = await database;
    return await db.transaction(action);
  }

  // Sync package operations
  Future<void> insertSyncPackage(Map<String, dynamic> package) async {
    final db = await database;
    await db.insert('sync_packages', package);
  }

  Future<List<Map<String, dynamic>>> getPendingSyncPackages() async {
    final db = await database;
    return await db.query(
      'sync_packages',
      where: 'status = ?',
      whereArgs: ['PENDING'],
      orderBy: 'timestamp ASC',
    );
  }

  Future<void> updateSyncPackageStatus(
    String id,
    String status, {
    DateTime? lastAttempt,
    int? retryCount,
    String? errorMessage,
  }) async {
    final db = await database;
    final updates = <String, dynamic>{'status': status};

    if (lastAttempt != null) {
      updates['last_attempt'] = lastAttempt.toIso8601String();
    }
    if (retryCount != null) {
      updates['retry_count'] = retryCount;
    }
    if (errorMessage != null) {
      updates['error_message'] = errorMessage;
    }

    await db.update(
      'sync_packages',
      updates,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Database maintenance
  Future<void> vacuum() async {
    final db = await database;
    await db.execute('VACUUM');
    debugPrint('Database vacuumed');
  }

  Future<void> analyze() async {
    final db = await database;
    await db.execute('ANALYZE');
    debugPrint('Database analyzed');
  }

  // Get database statistics
  Future<Map<String, int>> getDatabaseStats() async {
    final db = await database;

    final stats = <String, int>{};

    final tables = ['photos', 'equipment', 'sites', 'clients', 'companies', 'users', 'sync_packages'];

    for (final table in tables) {
      final result = await db.rawQuery('SELECT COUNT(*) as count FROM $table');
      stats[table] = Sqflite.firstIntValue(result) ?? 0;
    }

    return stats;
  }

  // Close database connection
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
      debugPrint('Database connection closed');
    }
  }

  // Backup and restore
  Future<String> getBackupPath() async {
    final db = await database;
    return db.path;
  }

  // Clear all data (for testing/reset)
  Future<void> clearAllData() async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('search_index');
      await txn.delete('sync_packages');
      await txn.delete('photos');
      await txn.delete('equipment');
      await txn.delete('sites');
      await txn.delete('clients');
      await txn.delete('users');
      await txn.delete('companies');
    });
    debugPrint('All data cleared from database');
  }

  // Check database integrity
  Future<bool> checkIntegrity() async {
    final db = await database;
    try {
      final result = await db.rawQuery('PRAGMA integrity_check');
      return result.isNotEmpty && result.first['integrity_check'] == 'ok';
    } catch (e) {
      debugPrint('Database integrity check failed: $e');
      return false;
    }
  }
}