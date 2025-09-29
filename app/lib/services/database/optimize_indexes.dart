import 'package:sqflite/sqflite.dart';

/// Database index optimization for performance requirements
class DatabaseIndexOptimizer {
  static Future<void> optimizeIndexes(Database db) async {
    await db.transaction((txn) async {
      // Photo search performance indexes (<1s requirement)
      await txn.execute('''
        CREATE INDEX IF NOT EXISTS idx_photo_equipment_captured
        ON photos(equipment_id, captured_at DESC)
      ''');

      await txn.execute('''
        CREATE INDEX IF NOT EXISTS idx_photo_device_timestamp
        ON photos(device_id, created_at DESC)
      ''');

      await txn.execute('''
        CREATE INDEX IF NOT EXISTS idx_photo_gps_location
        ON photos(latitude, longitude)
        WHERE latitude IS NOT NULL AND longitude IS NOT NULL
      ''');

      await txn.execute('''
        CREATE INDEX IF NOT EXISTS idx_photo_sync_status
        ON photos(is_synced, updated_at DESC)
      ''');

      await txn.execute('''
        CREATE INDEX IF NOT EXISTS idx_photo_revision
        ON photos(revision_id, captured_at DESC)
        WHERE revision_id IS NOT NULL
      ''');

      // Hierarchy navigation indexes (<500ms requirement)
      await txn.execute('''
        CREATE INDEX IF NOT EXISTS idx_site_parent
        ON sites(parent_site_id, name)
      ''');

      await txn.execute('''
        CREATE INDEX IF NOT EXISTS idx_site_client
        ON sites(client_id, is_active, name)
      ''');

      await txn.execute('''
        CREATE INDEX IF NOT EXISTS idx_equipment_site
        ON equipment(site_id, is_active, name)
      ''');

      await txn.execute('''
        CREATE INDEX IF NOT EXISTS idx_equipment_type
        ON equipment(equipment_type, name)
        WHERE equipment_type IS NOT NULL
      ''');

      // Sync operations indexes (>99.5% success requirement)
      await txn.execute('''
        CREATE INDEX IF NOT EXISTS idx_sync_status
        ON sync_packages(status, timestamp)
      ''');

      await txn.execute('''
        CREATE INDEX IF NOT EXISTS idx_sync_device
        ON sync_packages(device_id, status, retry_count)
      ''');

      await txn.execute('''
        CREATE INDEX IF NOT EXISTS idx_sync_entity
        ON sync_packages(entity_type, entity_id, operation)
      ''');

      await txn.execute('''
        CREATE INDEX IF NOT EXISTS idx_sync_pending
        ON sync_packages(status, retry_count, last_attempt)
        WHERE status = 'PENDING' OR status = 'FAILED'
      ''');

      // GPS boundary detection indexes
      await txn.execute('''
        CREATE INDEX IF NOT EXISTS idx_boundary_active
        ON gps_boundaries(is_active, priority DESC)
        WHERE is_active = 1
      ''');

      await txn.execute('''
        CREATE INDEX IF NOT EXISTS idx_boundary_client
        ON gps_boundaries(client_id, is_active)
        WHERE client_id IS NOT NULL
      ''');

      await txn.execute('''
        CREATE INDEX IF NOT EXISTS idx_boundary_site
        ON gps_boundaries(site_id, is_active)
        WHERE site_id IS NOT NULL
      ''');

      // Full-text search index for global search
      await txn.execute('''
        CREATE VIRTUAL TABLE IF NOT EXISTS search_index USING fts5(
          entity_type,
          entity_id,
          content,
          tokenize='porter'
        )
      ''');

      // Create triggers to maintain search index
      await txn.execute('''
        CREATE TRIGGER IF NOT EXISTS photo_search_insert
        AFTER INSERT ON photos
        BEGIN
          INSERT INTO search_index(entity_type, entity_id, content)
          VALUES ('Photo', NEW.id,
            COALESCE(NEW.notes, '') || ' ' || NEW.file_name);
        END
      ''');

      await txn.execute('''
        CREATE TRIGGER IF NOT EXISTS photo_search_update
        AFTER UPDATE ON photos
        BEGIN
          UPDATE search_index
          SET content = COALESCE(NEW.notes, '') || ' ' || NEW.file_name
          WHERE entity_type = 'Photo' AND entity_id = NEW.id;
        END
      ''');

      await txn.execute('''
        CREATE TRIGGER IF NOT EXISTS equipment_search_insert
        AFTER INSERT ON equipment
        BEGIN
          INSERT INTO search_index(entity_type, entity_id, content)
          VALUES ('Equipment', NEW.id,
            NEW.name || ' ' || COALESCE(NEW.equipment_type, '') || ' ' ||
            COALESCE(NEW.serial_number, '') || ' ' || COALESCE(NEW.model, ''));
        END
      ''');

      await txn.execute('''
        CREATE TRIGGER IF NOT EXISTS equipment_search_update
        AFTER UPDATE ON equipment
        BEGIN
          UPDATE search_index
          SET content = NEW.name || ' ' || COALESCE(NEW.equipment_type, '') || ' ' ||
            COALESCE(NEW.serial_number, '') || ' ' || COALESCE(NEW.model, '')
          WHERE entity_type = 'Equipment' AND entity_id = NEW.id;
        END
      ''');

      // Composite indexes for complex queries
      await txn.execute('''
        CREATE INDEX IF NOT EXISTS idx_photo_composite_search
        ON photos(equipment_id, captured_at DESC, is_synced)
      ''');

      await txn.execute('''
        CREATE INDEX IF NOT EXISTS idx_equipment_composite_nav
        ON equipment(site_id, equipment_type, name, is_active)
      ''');

      // Covering indexes for common queries to avoid table lookups
      await txn.execute('''
        CREATE INDEX IF NOT EXISTS idx_photo_covering_list
        ON photos(equipment_id, captured_at DESC, id, file_name, file_hash)
      ''');

      // Optimize existing indexes
      await txn.execute('ANALYZE');
      await txn.execute('VACUUM');
    });
  }

  static Future<void> updateStatistics(Database db) async {
    // Update query planner statistics for better performance
    await db.execute('ANALYZE');
  }

  static Future<Map<String, dynamic>> getIndexStats(Database db) async {
    final indexes = await db.rawQuery('''
      SELECT name, tbl_name as table_name
      FROM sqlite_master
      WHERE type = 'index' AND name NOT LIKE 'sqlite_%'
      ORDER BY tbl_name, name
    ''');

    final stats = <String, dynamic>{
      'totalIndexes': indexes.length,
      'byTable': <String, int>{},
    };

    for (final index in indexes) {
      final tableName = index['table_name'] as String;
      stats['byTable'][tableName] = (stats['byTable'][tableName] ?? 0) + 1;
    }

    return stats;
  }

  static Future<void> dropUnusedIndexes(Database db) async {
    // Identify and drop indexes that are not being used
    // This requires monitoring query patterns over time

    // For now, we'll keep all indexes as they're optimized for our use cases
    // In production, implement query logging to identify unused indexes
  }

  static Future<void> rebuildFragmentedIndexes(Database db) async {
    final tables = ['photos', 'equipment', 'sites', 'sync_packages'];

    for (final table in tables) {
      await db.execute('REINDEX $table');
    }
  }

  static Future<Map<String, dynamic>> estimateQueryPerformance(
    Database db,
    String query,
  ) async {
    final plan = await db.rawQuery('EXPLAIN QUERY PLAN $query');

    return {
      'queryPlan': plan,
      'estimatedCost': _calculateEstimatedCost(plan),
      'usesIndex': _checkIndexUsage(plan),
    };
  }

  static int _calculateEstimatedCost(List<Map<String, Object?>> plan) {
    // Simple cost estimation based on query plan
    int cost = 0;

    for (final step in plan) {
      final detail = step['detail'] as String?;
      if (detail != null) {
        if (detail.contains('SCAN')) {
          cost += 1000; // Table scan is expensive
        } else if (detail.contains('SEARCH')) {
          cost += 10; // Index search is cheap
        }
        if (detail.contains('TEMP B-TREE')) {
          cost += 100; // Temporary sorting
        }
      }
    }

    return cost;
  }

  static bool _checkIndexUsage(List<Map<String, Object?>> plan) {
    for (final step in plan) {
      final detail = step['detail'] as String?;
      if (detail != null && detail.contains('USING INDEX')) {
        return true;
      }
    }
    return false;
  }
}

/// Index maintenance scheduler
class IndexMaintenanceScheduler {
  static Duration maintenanceInterval = const Duration(days: 7);
  static DateTime? lastMaintenance;

  static Future<void> scheduleMaintenance(Database db) async {
    if (shouldRunMaintenance()) {
      await runMaintenance(db);
    }
  }

  static bool shouldRunMaintenance() {
    if (lastMaintenance == null) return true;

    final now = DateTime.now();
    return now.difference(lastMaintenance!) > maintenanceInterval;
  }

  static Future<void> runMaintenance(Database db) async {
    await DatabaseIndexOptimizer.updateStatistics(db);
    await DatabaseIndexOptimizer.rebuildFragmentedIndexes(db);
    lastMaintenance = DateTime.now();
  }
}