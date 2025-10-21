import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'sitepictures.db');

    return await openDatabase(
      path,
      version: 6,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        email TEXT UNIQUE NOT NULL,
        name TEXT NOT NULL,
        role TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        last_sync_at TEXT
      )
    ''');

    // Clients table
    await db.execute('''
      CREATE TABLE clients (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        is_system INTEGER DEFAULT 0,
        created_by TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1,
        FOREIGN KEY (created_by) REFERENCES users (id)
      )
    ''');

    // Main sites table
    await db.execute('''
      CREATE TABLE main_sites (
        id TEXT PRIMARY KEY,
        client_id TEXT NOT NULL,
        name TEXT NOT NULL,
        address TEXT,
        latitude REAL,
        longitude REAL,
        created_by TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1,
        FOREIGN KEY (client_id) REFERENCES clients (id),
        FOREIGN KEY (created_by) REFERENCES users (id)
      )
    ''');

    // Sub sites table - supports flexible hierarchy (client, main_site, or parent_subsite)
    await db.execute('''
      CREATE TABLE sub_sites (
        id TEXT PRIMARY KEY,
        client_id TEXT,
        main_site_id TEXT,
        parent_subsite_id TEXT,
        name TEXT NOT NULL,
        description TEXT,
        created_by TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1,
        FOREIGN KEY (client_id) REFERENCES clients (id),
        FOREIGN KEY (main_site_id) REFERENCES main_sites (id),
        FOREIGN KEY (parent_subsite_id) REFERENCES sub_sites (id),
        FOREIGN KEY (created_by) REFERENCES users (id),
        CHECK (
          (client_id IS NOT NULL AND main_site_id IS NULL AND parent_subsite_id IS NULL) OR
          (client_id IS NULL AND main_site_id IS NOT NULL AND parent_subsite_id IS NULL) OR
          (client_id IS NULL AND main_site_id IS NULL AND parent_subsite_id IS NOT NULL)
        )
      )
    ''');

    // Equipment table - supports flexible hierarchy (client, main_site, or sub_site)
    await db.execute('''
      CREATE TABLE equipment (
        id TEXT PRIMARY KEY,
        client_id TEXT,
        main_site_id TEXT,
        sub_site_id TEXT,
        name TEXT NOT NULL,
        serial_number TEXT,
        manufacturer TEXT,
        model TEXT,
        created_by TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1,
        FOREIGN KEY (client_id) REFERENCES clients (id),
        FOREIGN KEY (main_site_id) REFERENCES main_sites (id),
        FOREIGN KEY (sub_site_id) REFERENCES sub_sites (id),
        FOREIGN KEY (created_by) REFERENCES users (id),
        CHECK (
          (client_id IS NOT NULL AND main_site_id IS NULL AND sub_site_id IS NULL) OR
          (client_id IS NULL AND main_site_id IS NOT NULL AND sub_site_id IS NULL) OR
          (client_id IS NULL AND main_site_id IS NULL AND sub_site_id IS NOT NULL)
        )
      )
    ''');

    // Photos table
    await db.execute('''
      CREATE TABLE photos (
        id TEXT PRIMARY KEY,
        equipment_id TEXT NOT NULL,
        file_path TEXT NOT NULL,
        thumbnail_path TEXT,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        timestamp TEXT NOT NULL,
        captured_by TEXT NOT NULL,
        file_size INTEGER NOT NULL,
        is_synced INTEGER NOT NULL DEFAULT 0,
        synced_at TEXT,
        remote_url TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (equipment_id) REFERENCES equipment (id),
        FOREIGN KEY (captured_by) REFERENCES users (id)
      )
    ''');

    // Recent locations table
    await db.execute('''
      CREATE TABLE recent_locations (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        client_id TEXT,
        main_site_id TEXT,
        sub_site_id TEXT,
        equipment_id TEXT,
        accessed_at TEXT NOT NULL,
        display_name TEXT NOT NULL,
        navigation_path TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id),
        FOREIGN KEY (client_id) REFERENCES clients (id),
        FOREIGN KEY (main_site_id) REFERENCES main_sites (id),
        FOREIGN KEY (sub_site_id) REFERENCES sub_sites (id),
        FOREIGN KEY (equipment_id) REFERENCES equipment (id)
      )
    ''');

    // Sync queue table
    await db.execute('''
      CREATE TABLE sync_queue (
        id TEXT PRIMARY KEY,
        entity_type TEXT NOT NULL,
        entity_id TEXT NOT NULL,
        operation TEXT NOT NULL,
        payload TEXT NOT NULL,
        retry_count INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        last_attempt TEXT,
        error TEXT,
        is_completed INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Photo folders table
    await db.execute('''
      CREATE TABLE photo_folders (
        id TEXT PRIMARY KEY,
        equipment_id TEXT NOT NULL,
        name TEXT NOT NULL,
        work_order TEXT NOT NULL,
        created_at TEXT NOT NULL,
        created_by TEXT NOT NULL,
        is_deleted INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (equipment_id) REFERENCES equipment(id) ON DELETE CASCADE,
        FOREIGN KEY (created_by) REFERENCES users(id)
      )
    ''');

    // Folder photos junction table
    await db.execute('''
      CREATE TABLE folder_photos (
        folder_id TEXT NOT NULL,
        photo_id TEXT NOT NULL,
        before_after TEXT NOT NULL CHECK(before_after IN ('before', 'after')),
        added_at TEXT NOT NULL,
        PRIMARY KEY (folder_id, photo_id),
        FOREIGN KEY (folder_id) REFERENCES photo_folders(id) ON DELETE CASCADE,
        FOREIGN KEY (photo_id) REFERENCES photos(id) ON DELETE CASCADE
      )
    ''');

    // Create indexes for performance optimization
    await _createIndexes(db);
  }

  Future<void> _createIndexes(Database db) async {
    // Frequent queries indexes
    await db.execute(
      'CREATE INDEX idx_mainsite_client ON main_sites(client_id, is_active)',
    );
    await db.execute(
      'CREATE INDEX idx_subsite_client ON sub_sites(client_id, is_active)',
    );
    await db.execute(
      'CREATE INDEX idx_subsite_mainsite ON sub_sites(main_site_id, is_active)',
    );
    await db.execute(
      'CREATE INDEX idx_subsite_parent ON sub_sites(parent_subsite_id, is_active)',
    );
    await db.execute(
      'CREATE INDEX idx_equipment_client ON equipment(client_id, is_active)',
    );
    await db.execute(
      'CREATE INDEX idx_equipment_mainsite ON equipment(main_site_id, is_active)',
    );
    await db.execute(
      'CREATE INDEX idx_equipment_subsite ON equipment(sub_site_id, is_active)',
    );
    await db.execute(
      'CREATE INDEX idx_photo_equipment ON photos(equipment_id, timestamp DESC)',
    );
    await db.execute(
      'CREATE INDEX idx_photo_sync ON photos(is_synced, created_at)',
    );
    await db.execute(
      'CREATE INDEX idx_photo_folders_equipment ON photo_folders(equipment_id)',
    );
    await db.execute(
      'CREATE INDEX idx_photo_folders_created_at ON photo_folders(created_at DESC)',
    );
    await db.execute(
      'CREATE INDEX idx_photo_folders_equipment_created ON photo_folders(equipment_id, created_at DESC)',
    );
    await db.execute(
      'CREATE INDEX idx_folder_photos_folder ON folder_photos(folder_id)',
    );
    await db.execute(
      'CREATE INDEX idx_folder_photos_photo ON folder_photos(photo_id)',
    );

    // Recent locations indexes
    await db.execute(
      'CREATE INDEX idx_recent_user ON recent_locations(user_id, accessed_at DESC)',
    );

    // Sync queue indexes
    await db.execute(
      'CREATE INDEX idx_sync_pending ON sync_queue(is_completed, created_at)',
    );
    await db.execute(
      'CREATE INDEX idx_sync_entity ON sync_queue(entity_type, entity_id)',
    );

    // Client name uniqueness
    await db.execute('CREATE UNIQUE INDEX idx_client_name ON clients(name)');

    // System clients filtering
    await db.execute(
      'CREATE INDEX idx_clients_system ON clients(is_system, is_active)',
    );

    // All Photos gallery index
    await _migration006(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Migration 002: Add photo folders feature
    if (oldVersion < 2) {
      await _migration002(db);
    }
    // Migration 003: Flexible hierarchy for subsites and equipment
    if (oldVersion < 3) {
      await _migration003(db);
    }
    // Migration 004: Global "Needs Assigned" support
    if (oldVersion < 4) {
      await _migration004(db);
    }
    // Migration 005: Ensure photo folders tables exist for installations created before migration 002
    if (oldVersion < 5) {
      await _migration005(db);
    }
    // Migration 006: Descending timestamp index for global gallery
    if (oldVersion < 6) {
      await _migration006(db);
    }
  }

  Future<void> _migration002(Database db) async {
    // Migration 002: Photo Folders
    // Feature: 004-i-want-to
    // Date: 2025-10-09

    // Create photo_folders table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS photo_folders (
        id TEXT PRIMARY KEY,
        equipment_id TEXT NOT NULL,
        name TEXT NOT NULL,
        work_order TEXT NOT NULL,
        created_at TEXT NOT NULL,
        created_by TEXT NOT NULL,
        is_deleted INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (equipment_id) REFERENCES equipment(id) ON DELETE CASCADE,
        FOREIGN KEY (created_by) REFERENCES users(id)
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_photo_folders_equipment ON photo_folders(equipment_id)',
    );
    await db.execute(
      'CREATE INDEX idx_photo_folders_created_at ON photo_folders(created_at DESC)',
    );
    await db.execute(
      'CREATE INDEX idx_photo_folders_equipment_created ON photo_folders(equipment_id, created_at DESC)',
    );

    // Create folder_photos junction table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS folder_photos (
        folder_id TEXT NOT NULL,
        photo_id TEXT NOT NULL,
        before_after TEXT NOT NULL CHECK(before_after IN ('before', 'after')),
        added_at TEXT NOT NULL,
        PRIMARY KEY (folder_id, photo_id),
        FOREIGN KEY (folder_id) REFERENCES photo_folders(id) ON DELETE CASCADE,
        FOREIGN KEY (photo_id) REFERENCES photos(id) ON DELETE CASCADE
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_folder_photos_folder ON folder_photos(folder_id)',
    );
    await db.execute(
      'CREATE INDEX idx_folder_photos_photo ON folder_photos(photo_id)',
    );
  }

  Future<void> _migration003(Database db) async {
    // Migration 003: Flexible Hierarchy
    // Feature: 005-i-want-to
    // Date: 2025-10-13
    // Changes: Add support for subsites and equipment at client level, and nested subsites

    // === STEP 1: Migrate sub_sites table ===

    // Create new sub_sites table with updated schema
    await db.execute('''
      CREATE TABLE sub_sites_new (
        id TEXT PRIMARY KEY,
        client_id TEXT,
        main_site_id TEXT,
        parent_subsite_id TEXT,
        name TEXT NOT NULL,
        description TEXT,
        created_by TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1,
        FOREIGN KEY (client_id) REFERENCES clients (id),
        FOREIGN KEY (main_site_id) REFERENCES main_sites (id),
        FOREIGN KEY (parent_subsite_id) REFERENCES sub_sites_new (id),
        FOREIGN KEY (created_by) REFERENCES users (id),
        CHECK (
          (client_id IS NOT NULL AND main_site_id IS NULL AND parent_subsite_id IS NULL) OR
          (client_id IS NULL AND main_site_id IS NOT NULL AND parent_subsite_id IS NULL) OR
          (client_id IS NULL AND main_site_id IS NULL AND parent_subsite_id IS NOT NULL)
        )
      )
    ''');

    // Copy existing data from old sub_sites table (all existing subsites belong to main_sites)
    await db.execute('''
      INSERT INTO sub_sites_new
        (id, main_site_id, name, description, created_by, created_at, updated_at, is_active)
      SELECT
        id, main_site_id, name, description, created_by, created_at, updated_at, is_active
      FROM sub_sites
    ''');

    // Drop old table and rename new table
    await db.execute('DROP TABLE sub_sites');
    await db.execute('ALTER TABLE sub_sites_new RENAME TO sub_sites');

    // Recreate indexes for sub_sites
    await db.execute(
      'CREATE INDEX idx_subsite_client ON sub_sites(client_id, is_active)',
    );
    await db.execute(
      'CREATE INDEX idx_subsite_mainsite ON sub_sites(main_site_id, is_active)',
    );
    await db.execute(
      'CREATE INDEX idx_subsite_parent ON sub_sites(parent_subsite_id, is_active)',
    );

    // === STEP 2: Migrate equipment table ===

    // Create new equipment table with updated schema
    await db.execute('''
      CREATE TABLE equipment_new (
        id TEXT PRIMARY KEY,
        client_id TEXT,
        main_site_id TEXT,
        sub_site_id TEXT,
        name TEXT NOT NULL,
        serial_number TEXT,
        manufacturer TEXT,
        model TEXT,
        created_by TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1,
        FOREIGN KEY (client_id) REFERENCES clients (id),
        FOREIGN KEY (main_site_id) REFERENCES main_sites (id),
        FOREIGN KEY (sub_site_id) REFERENCES sub_sites (id),
        FOREIGN KEY (created_by) REFERENCES users (id),
        CHECK (
          (client_id IS NOT NULL AND main_site_id IS NULL AND sub_site_id IS NULL) OR
          (client_id IS NULL AND main_site_id IS NOT NULL AND sub_site_id IS NULL) OR
          (client_id IS NULL AND main_site_id IS NULL AND sub_site_id IS NOT NULL)
        )
      )
    ''');

    // Copy existing data from old equipment table
    await db.execute('''
      INSERT INTO equipment_new
        (id, main_site_id, sub_site_id, name, serial_number, manufacturer, model,
         created_by, created_at, updated_at, is_active)
      SELECT
        id, main_site_id, sub_site_id, name, serial_number, manufacturer, model,
        created_by, created_at, updated_at, is_active
      FROM equipment
    ''');

    // Drop old table and rename new table
    await db.execute('DROP TABLE equipment');
    await db.execute('ALTER TABLE equipment_new RENAME TO equipment');

    // Recreate indexes for equipment
    await db.execute(
      'CREATE INDEX idx_equipment_client ON equipment(client_id, is_active)',
    );
    await db.execute(
      'CREATE INDEX idx_equipment_mainsite ON equipment(main_site_id, is_active)',
    );
    await db.execute(
      'CREATE INDEX idx_equipment_subsite ON equipment(sub_site_id, is_active)',
    );
  }

  Future<void> _migration004(Database db) async {
    // Migration 004: Global "Needs Assigned" Support
    // Feature: 006-i-want-to
    // Date: 2025-10-14
    // Changes: Add is_system column to clients table for special system clients

    // Add system flag to clients table
    await db.execute(
      'ALTER TABLE clients ADD COLUMN is_system INTEGER DEFAULT 0',
    );

    // Create global "Needs Assigned" client
    await db.insert('clients', {
      'id': 'GLOBAL_NEEDS_ASSIGNED',
      'name': 'Needs Assigned',
      'description': 'Global holding area for unorganized photos',
      'is_system': 1,
      'created_by': 'SYSTEM',
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
      'is_active': 1,
    });

    // Create index for filtering out system clients from user lists
    await db.execute(
      'CREATE INDEX idx_clients_system ON clients(is_system, is_active)',
    );
  }

  Future<void> _migration005(Database db) async {
    // Migration 005: Backfill photo folders tables for older installations
    await db.execute('''
      CREATE TABLE IF NOT EXISTS photo_folders (
        id TEXT PRIMARY KEY,
        equipment_id TEXT NOT NULL,
        name TEXT NOT NULL,
        work_order TEXT NOT NULL,
        created_at TEXT NOT NULL,
        created_by TEXT NOT NULL,
        is_deleted INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (equipment_id) REFERENCES equipment(id) ON DELETE CASCADE,
        FOREIGN KEY (created_by) REFERENCES users(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS folder_photos (
        folder_id TEXT NOT NULL,
        photo_id TEXT NOT NULL,
        before_after TEXT NOT NULL CHECK(before_after IN ('before', 'after')),
        added_at TEXT NOT NULL,
        PRIMARY KEY (folder_id, photo_id),
        FOREIGN KEY (folder_id) REFERENCES photo_folders(id) ON DELETE CASCADE,
        FOREIGN KEY (photo_id) REFERENCES photos(id) ON DELETE CASCADE
      )
    ''');

    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_photo_folders_equipment ON photo_folders(equipment_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_photo_folders_created_at ON photo_folders(created_at DESC)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_photo_folders_equipment_created ON photo_folders(equipment_id, created_at DESC)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_folder_photos_folder ON folder_photos(folder_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_folder_photos_photo ON folder_photos(photo_id)',
    );
  }

  Future<void> _migration006(Database db) async {
    // Migration 006: Timestamp index for global All Photos gallery
    // Feature: 007-i-want-to
    // Date: 2025-10-19
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_photos_timestamp ON photos(timestamp DESC)',
    );
  }

  // Transaction support
  Future<T> transaction<T>(Future<T> Function(Transaction txn) action) async {
    final db = await database;
    return await db.transaction(action);
  }

  // Batch operations support
  Future<List<Object?>> batch(
    Future<void> Function(Batch batch) operations,
  ) async {
    final db = await database;
    final batch = db.batch();
    await operations(batch);
    return await batch.commit();
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  // Clear all data (for testing/logout)
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('sync_queue');
    await db.delete('recent_locations');
    await db.delete('photos');
    await db.delete('equipment');
    await db.delete('sub_sites');
    await db.delete('main_sites');
    await db.delete('clients');
    await db.delete('users');
  }

  // Get database path (useful for debugging)
  Future<String> getDatabasePath() async {
    final databasePath = await getDatabasesPath();
    return join(databasePath, 'sitepictures.db');
  }

  // ===== Folder Query Methods (T003) =====

  /// Get all folders for an equipment item
  Future<List<Map<String, dynamic>>> getFoldersForEquipment(
    String equipmentId,
  ) async {
    final db = await database;
    return await db.query(
      'photo_folders',
      where: 'equipment_id = ? AND is_deleted = 0',
      whereArgs: [equipmentId],
      orderBy: 'created_at DESC',
    );
  }

  /// Get a single folder by ID
  Future<Map<String, dynamic>?> getFolderById(String folderId) async {
    final db = await database;
    final results = await db.query(
      'photo_folders',
      where: 'id = ? AND is_deleted = 0',
      whereArgs: [folderId],
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  /// Get before photos for a folder
  Future<List<Map<String, dynamic>>> getBeforePhotos(String folderId) async {
    final db = await database;
    return await db.rawQuery(
      '''
      SELECT p.*
      FROM photos p
      JOIN folder_photos fp ON p.id = fp.photo_id
      WHERE fp.folder_id = ? AND fp.before_after = 'before'
      ORDER BY p.timestamp DESC
    ''',
      [folderId],
    );
  }

  /// Get after photos for a folder
  Future<List<Map<String, dynamic>>> getAfterPhotos(String folderId) async {
    final db = await database;
    return await db.rawQuery(
      '''
      SELECT p.*
      FROM photos p
      JOIN folder_photos fp ON p.id = fp.photo_id
      WHERE fp.folder_id = ? AND fp.before_after = 'after'
      ORDER BY p.timestamp DESC
    ''',
      [folderId],
    );
  }

  /// Get all photos with folder information for an equipment item
  Future<List<Map<String, dynamic>>> getAllPhotosWithFolderInfo(
    String equipmentId,
  ) async {
    final db = await database;
    return await db.rawQuery(
      '''
      SELECT
        p.*,
        fp.folder_id AS folder_id,
        pf.name AS folder_name,
        fp.before_after AS before_after
      FROM photos p
      LEFT JOIN folder_photos fp ON p.id = fp.photo_id
      LEFT JOIN photo_folders pf ON fp.folder_id = pf.id
      WHERE p.equipment_id = ?
        AND (pf.is_deleted IS NULL OR pf.is_deleted = 0)
      ORDER BY p.timestamp DESC
    ''',
      [equipmentId],
    );
  }

  /// Get all photos across equipment with metadata for All Photos gallery
  Future<List<Map<String, dynamic>>> getAllPhotos({
    int limit = 50,
    int offset = 0,
    DateTime? before,
  }) async {
    final db = await database;
    final beforeClause = before != null
        ? 'AND datetime(p.timestamp) < datetime(?)'
        : '';
    final args = <Object?>[];
    if (before != null) {
      args.add(before.toIso8601String());
    }
    args
      ..add(limit)
      ..add(offset);

    final query =
        '''
      SELECT
        p.*,
        e.name AS equipment_name,
        c.name AS client_name,
        ms.name AS main_site_name,
        ss.name AS sub_site_name,
        COALESCE(
          NULLIF(TRIM(
            COALESCE(ss.name || ' • ', '') ||
            COALESCE(ms.name || ' • ', '') ||
            COALESCE(c.name, '')
          ), ''),
          e.name
        ) AS location_summary
      FROM photos p
      JOIN equipment e ON e.id = p.equipment_id
      LEFT JOIN main_sites ms ON ms.id = e.main_site_id
      LEFT JOIN sub_sites ss ON ss.id = e.sub_site_id
      LEFT JOIN clients c ON c.id = COALESCE(
        ss.client_id,
        ms.client_id,
        e.client_id
      )
      WHERE e.is_active = 1
        AND (ms.id IS NULL OR ms.is_active = 1)
        AND (ss.id IS NULL OR ss.is_active = 1)
        AND (c.id IS NULL OR c.is_active = 1)
        $beforeClause
      ORDER BY datetime(p.timestamp) DESC, datetime(p.created_at) DESC
      LIMIT ? OFFSET ?
    ''';

    return await db.rawQuery(query, args);
  }
}
