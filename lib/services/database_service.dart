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
      version: 1,
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

    // Sub sites table
    await db.execute('''
      CREATE TABLE sub_sites (
        id TEXT PRIMARY KEY,
        main_site_id TEXT NOT NULL,
        name TEXT NOT NULL,
        description TEXT,
        created_by TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1,
        FOREIGN KEY (main_site_id) REFERENCES main_sites (id),
        FOREIGN KEY (created_by) REFERENCES users (id)
      )
    ''');

    // Equipment table
    await db.execute('''
      CREATE TABLE equipment (
        id TEXT PRIMARY KEY,
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
        FOREIGN KEY (main_site_id) REFERENCES main_sites (id),
        FOREIGN KEY (sub_site_id) REFERENCES sub_sites (id),
        FOREIGN KEY (created_by) REFERENCES users (id),
        CHECK ((main_site_id IS NOT NULL AND sub_site_id IS NULL) OR
               (main_site_id IS NULL AND sub_site_id IS NOT NULL))
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

    // Create indexes for performance optimization
    await _createIndexes(db);
  }

  Future<void> _createIndexes(Database db) async {
    // Frequent queries indexes
    await db.execute(
        'CREATE INDEX idx_mainsite_client ON main_sites(client_id, is_active)');
    await db.execute(
        'CREATE INDEX idx_subsite_mainsite ON sub_sites(main_site_id, is_active)');
    await db.execute(
        'CREATE INDEX idx_equipment_mainsite ON equipment(main_site_id, is_active)');
    await db.execute(
        'CREATE INDEX idx_equipment_subsite ON equipment(sub_site_id, is_active)');
    await db.execute(
        'CREATE INDEX idx_photo_equipment ON photos(equipment_id, timestamp DESC)');
    await db.execute(
        'CREATE INDEX idx_photo_sync ON photos(is_synced, created_at)');

    // Recent locations indexes
    await db.execute(
        'CREATE INDEX idx_recent_user ON recent_locations(user_id, accessed_at DESC)');

    // Sync queue indexes
    await db.execute(
        'CREATE INDEX idx_sync_pending ON sync_queue(is_completed, created_at)');
    await db.execute(
        'CREATE INDEX idx_sync_entity ON sync_queue(entity_type, entity_id)');

    // Client name uniqueness
    await db.execute('CREATE UNIQUE INDEX idx_client_name ON clients(name)');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Future migrations will be handled here
    // Example:
    // if (oldVersion < 2) {
    //   await db.execute('ALTER TABLE ...');
    // }
  }

  // Transaction support
  Future<T> transaction<T>(Future<T> Function(Transaction txn) action) async {
    final db = await database;
    return await db.transaction(action);
  }

  // Batch operations support
  Future<List<Object?>> batch(
      Future<void> Function(Batch batch) operations) async {
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
}
