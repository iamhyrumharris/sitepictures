import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseSchema {
  static const String dbName = 'fieldphoto.db';
  static const int version = 1;

  static Future<Database> initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, dbName);

    return await openDatabase(
      path,
      version: version,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.transaction((txn) async {
      // Company table
      await txn.execute('''
        CREATE TABLE companies (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL UNIQUE,
          settings TEXT DEFAULT '{}',
          created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
          updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
          is_active INTEGER DEFAULT 1
        )
      ''');

      // Client table
      await txn.execute('''
        CREATE TABLE clients (
          id TEXT PRIMARY KEY,
          company_id TEXT NOT NULL,
          name TEXT NOT NULL,
          description TEXT,
          created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
          updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
          is_active INTEGER DEFAULT 1,
          FOREIGN KEY (company_id) REFERENCES companies(id)
        )
      ''');

      // Site table
      await txn.execute('''
        CREATE TABLE sites (
          id TEXT PRIMARY KEY,
          client_id TEXT NOT NULL,
          parent_site_id TEXT,
          name TEXT NOT NULL,
          address TEXT,
          center_latitude REAL,
          center_longitude REAL,
          boundary_radius REAL,
          created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
          updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
          is_active INTEGER DEFAULT 1,
          FOREIGN KEY (client_id) REFERENCES clients(id),
          FOREIGN KEY (parent_site_id) REFERENCES sites(id)
        )
      ''');

      // Equipment table
      await txn.execute('''
        CREATE TABLE equipment (
          id TEXT PRIMARY KEY,
          site_id TEXT NOT NULL,
          name TEXT NOT NULL,
          equipment_type TEXT,
          serial_number TEXT,
          model TEXT,
          manufacturer TEXT,
          tags TEXT DEFAULT '[]',
          created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
          updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
          is_active INTEGER DEFAULT 1,
          FOREIGN KEY (site_id) REFERENCES sites(id)
        )
      ''');

      // Revision table
      await txn.execute('''
        CREATE TABLE revisions (
          id TEXT PRIMARY KEY,
          equipment_id TEXT NOT NULL,
          name TEXT NOT NULL,
          description TEXT,
          created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
          created_by TEXT NOT NULL,
          is_active INTEGER DEFAULT 1,
          FOREIGN KEY (equipment_id) REFERENCES equipment(id)
        )
      ''');

      // Photo table
      await txn.execute('''
        CREATE TABLE photos (
          id TEXT PRIMARY KEY,
          equipment_id TEXT NOT NULL,
          revision_id TEXT,
          file_name TEXT NOT NULL UNIQUE,
          file_hash TEXT NOT NULL,
          latitude REAL,
          longitude REAL,
          captured_at TEXT NOT NULL,
          notes TEXT,
          device_id TEXT NOT NULL,
          created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
          updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
          is_synced INTEGER DEFAULT 0,
          FOREIGN KEY (equipment_id) REFERENCES equipment(id),
          FOREIGN KEY (revision_id) REFERENCES revisions(id)
        )
      ''');

      // User (device) table
      await txn.execute('''
        CREATE TABLE users (
          id TEXT PRIMARY KEY,
          device_name TEXT NOT NULL,
          company_id TEXT,
          preferences TEXT DEFAULT '{}',
          first_seen TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
          last_seen TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
          is_active INTEGER DEFAULT 1,
          FOREIGN KEY (company_id) REFERENCES companies(id)
        )
      ''');

      // GPS Boundary table
      await txn.execute('''
        CREATE TABLE gps_boundaries (
          id TEXT PRIMARY KEY,
          client_id TEXT,
          site_id TEXT,
          name TEXT NOT NULL,
          center_latitude REAL NOT NULL,
          center_longitude REAL NOT NULL,
          radius_meters REAL NOT NULL,
          priority INTEGER NOT NULL DEFAULT 1,
          created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
          updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
          is_active INTEGER DEFAULT 1,
          FOREIGN KEY (client_id) REFERENCES clients(id),
          FOREIGN KEY (site_id) REFERENCES sites(id),
          CHECK (center_latitude >= -90 AND center_latitude <= 90),
          CHECK (center_longitude >= -180 AND center_longitude <= 180),
          CHECK (radius_meters > 0 AND radius_meters <= 10000)
        )
      ''');

      // Sync Package table
      await txn.execute('''
        CREATE TABLE sync_packages (
          id TEXT PRIMARY KEY,
          entity_type TEXT NOT NULL CHECK (entity_type IN ('Photo', 'Client', 'Site', 'Equipment', 'Revision', 'GPSBoundary')),
          entity_id TEXT NOT NULL,
          operation TEXT NOT NULL CHECK (operation IN ('CREATE', 'UPDATE', 'DELETE')),
          data TEXT NOT NULL,
          timestamp TEXT NOT NULL,
          device_id TEXT NOT NULL,
          status TEXT NOT NULL CHECK (status IN ('PENDING', 'SYNCING', 'SYNCED', 'FAILED')) DEFAULT 'PENDING',
          retry_count INTEGER DEFAULT 0 CHECK (retry_count >= 0 AND retry_count <= 10),
          last_attempt TEXT
        )
      ''');

      // Create indexes for performance
      await txn.execute('CREATE INDEX idx_photo_equipment_captured ON photos(equipment_id, captured_at DESC)');
      await txn.execute('CREATE INDEX idx_photo_device_timestamp ON photos(device_id, created_at DESC)');
      await txn.execute('CREATE INDEX idx_photo_gps_location ON photos(latitude, longitude) WHERE latitude IS NOT NULL');
      await txn.execute('CREATE INDEX idx_site_parent ON sites(parent_site_id, name)');
      await txn.execute('CREATE INDEX idx_equipment_site ON equipment(site_id, name)');
      await txn.execute('CREATE INDEX idx_sync_status ON sync_packages(status, timestamp)');
      await txn.execute('CREATE INDEX idx_sync_device ON sync_packages(device_id, status)');

      // Create FTS5 virtual table for search
      await txn.execute('''
        CREATE VIRTUAL TABLE search_index USING fts5(
          entity_type,
          entity_id,
          content,
          tokenize='porter'
        )
      ''');
    });
  }

  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle future database migrations
  }
}