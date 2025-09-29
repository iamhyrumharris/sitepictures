import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';
import 'schema.dart';

// T057: SQLite database initialization and migrations
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('fieldphoto.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
      onConfigure: _onConfigure,
    );
  }

  Future<void> _onConfigure(Database db) async {
    // Enable foreign keys
    await db.execute('PRAGMA foreign_keys = ON');

    // Optimize for performance
    await db.execute('PRAGMA journal_mode = WAL');
    await db.execute('PRAGMA synchronous = NORMAL');
    await db.execute('PRAGMA temp_store = MEMORY');
    await db.execute('PRAGMA mmap_size = 30000000000');
  }

  Future<void> _createDB(Database db, int version) async {
    // Create all tables
    await _createCompanyTable(db);
    await _createUserTable(db);
    await _createClientTable(db);
    await _createSiteTable(db);
    await _createEquipmentTable(db);
    await _createRevisionTable(db);
    await _createPhotoTable(db);
    await _createGPSBoundaryTable(db);
    await _createSyncPackageTable(db);

    // Create indexes for performance
    await _createIndexes(db);

    // Create FTS5 search table
    await _createSearchIndex(db);
  }

  Future<void> _createCompanyTable(Database db) async {
    await db.execute('''
      CREATE TABLE companies (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL UNIQUE,
        settings TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1
      )
    ''');
  }

  Future<void> _createUserTable(Database db) async {
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
  }

  Future<void> _createClientTable(Database db) async {
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
  }

  Future<void> _createSiteTable(Database db) async {
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
  }

  Future<void> _createEquipmentTable(Database db) async {
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
  }

  Future<void> _createRevisionTable(Database db) async {
    await db.execute('''
      CREATE TABLE revisions (
        id TEXT PRIMARY KEY,
        equipment_id TEXT NOT NULL,
        name TEXT NOT NULL,
        description TEXT,
        created_at TEXT NOT NULL,
        created_by TEXT NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1,
        FOREIGN KEY (equipment_id) REFERENCES equipment (id),
        FOREIGN KEY (created_by) REFERENCES users (id)
      )
    ''');
  }

  Future<void> _createPhotoTable(Database db) async {
    await db.execute('''
      CREATE TABLE photos (
        id TEXT PRIMARY KEY,
        equipment_id TEXT,
        revision_id TEXT,
        file_name TEXT NOT NULL UNIQUE,
        file_hash TEXT NOT NULL,
        latitude REAL,
        longitude REAL,
        captured_at TEXT NOT NULL,
        notes TEXT,
        device_id TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        is_synced INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (equipment_id) REFERENCES equipment (id),
        FOREIGN KEY (revision_id) REFERENCES revisions (id)
      )
    ''');
  }

  Future<void> _createGPSBoundaryTable(Database db) async {
    await db.execute('''
      CREATE TABLE gps_boundaries (
        id TEXT PRIMARY KEY,
        client_id TEXT,
        site_id TEXT,
        name TEXT NOT NULL,
        center_latitude REAL NOT NULL,
        center_longitude REAL NOT NULL,
        radius_meters REAL NOT NULL,
        priority INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1,
        FOREIGN KEY (client_id) REFERENCES clients (id),
        FOREIGN KEY (site_id) REFERENCES sites (id),
        CHECK (center_latitude >= -90 AND center_latitude <= 90),
        CHECK (center_longitude >= -180 AND center_longitude <= 180),
        CHECK (radius_meters > 0 AND radius_meters <= 10000)
      )
    ''');
  }

  Future<void> _createSyncPackageTable(Database db) async {
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
        CHECK (operation IN ('CREATE', 'UPDATE', 'DELETE')),
        CHECK (status IN ('PENDING', 'SYNCING', 'SYNCED', 'FAILED')),
        CHECK (retry_count >= 0 AND retry_count <= 10)
      )
    ''');
  }

  Future<void> _createIndexes(Database db) async {
    // Photo search performance
    await db.execute('''
      CREATE INDEX idx_photo_equipment_captured
      ON photos(equipment_id, captured_at DESC)
    ''');

    await db.execute('''
      CREATE INDEX idx_photo_device_timestamp
      ON photos(device_id, created_at DESC)
    ''');

    await db.execute('''
      CREATE INDEX idx_photo_gps_location
      ON photos(latitude, longitude)
      WHERE latitude IS NOT NULL
    ''');

    await db.execute('''
      CREATE INDEX idx_photo_unassigned
      ON photos(equipment_id)
      WHERE equipment_id IS NULL
    ''');

    // Hierarchy navigation
    await db.execute('''
      CREATE INDEX idx_site_parent
      ON sites(parent_site_id, name)
    ''');

    await db.execute('''
      CREATE INDEX idx_equipment_site
      ON equipment(site_id, name)
    ''');

    // Sync operations
    await db.execute('''
      CREATE INDEX idx_sync_status
      ON sync_packages(status, timestamp)
    ''');

    await db.execute('''
      CREATE INDEX idx_sync_device
      ON sync_packages(device_id, status)
    ''');

    // GPS boundaries
    await db.execute('''
      CREATE INDEX idx_boundary_location
      ON gps_boundaries(center_latitude, center_longitude, radius_meters)
      WHERE is_active = 1
    ''');
  }

  Future<void> _createSearchIndex(Database db) async {
    // Create FTS5 virtual table for global search
    await db.execute('''
      CREATE VIRTUAL TABLE search_index USING fts5(
        entity_type,
        entity_id,
        content,
        tokenize='porter'
      )
    ''');
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    // Handle migrations for future versions
    for (int version = oldVersion + 1; version <= newVersion; version++) {
      switch (version) {
        case 2:
          // Future migration example
          // await _migrateToV2(db);
          break;
        default:
          break;
      }
    }
  }

  // Transaction support
  Future<T> transaction<T>(Future<T> Function(Transaction txn) action) async {
    final db = await database;
    return await db.transaction(action);
  }

  // Batch operations
  Future<void> batchInsert(String table, List<Map<String, dynamic>> rows) async {
    final db = await database;
    final batch = db.batch();

    for (final row in rows) {
      batch.insert(table, row, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    await batch.commit(noResult: true);
  }

  // Search index management
  Future<void> updateSearchIndex(
    String entityType,
    String entityId,
    String content,
  ) async {
    final db = await database;

    // Delete old entry if exists
    await db.delete(
      'search_index',
      where: 'entity_type = ? AND entity_id = ?',
      whereArgs: [entityType, entityId],
    );

    // Insert new entry
    await db.insert('search_index', {
      'entity_type': entityType,
      'entity_id': entityId,
      'content': content,
    });
  }

  Future<List<Map<String, dynamic>>> search(String query) async {
    final db = await database;

    return await db.rawQuery('''
      SELECT entity_type, entity_id, snippet(search_index, 2, '<b>', '</b>', '...', 30) as snippet
      FROM search_index
      WHERE search_index MATCH ?
      ORDER BY rank
      LIMIT 100
    ''', [query]);
  }

  // Database maintenance
  Future<void> vacuum() async {
    final db = await database;
    await db.execute('VACUUM');
  }

  Future<void> analyze() async {
    final db = await database;
    await db.execute('ANALYZE');
  }

  Future<Map<String, dynamic>> getDatabaseStats() async {
    final db = await database;

    final photoCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM photos')
    ) ?? 0;

    final equipmentCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM equipment')
    ) ?? 0;

    final syncPendingCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM sync_packages WHERE status = ?', ['PENDING'])
    ) ?? 0;

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'fieldphoto.db');
    final file = File(path);
    final sizeBytes = await file.length();

    return {
      'photoCount': photoCount,
      'equipmentCount': equipmentCount,
      'syncPendingCount': syncPendingCount,
      'databaseSizeMB': (sizeBytes / 1024 / 1024).toStringAsFixed(2),
    };
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}