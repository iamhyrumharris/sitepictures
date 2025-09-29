import 'package:sqflite/sqflite.dart';
import 'schema.dart';

class DatabaseHelper {
  static Database? _database;
  static final DatabaseHelper instance = DatabaseHelper._();

  DatabaseHelper._();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await DatabaseSchema.initDatabase();
    return _database!;
  }

  // Photo operations
  Future<int> insertPhoto(Map<String, dynamic> photo) async {
    final db = await database;
    return await db.insert('photos', photo);
  }

  Future<List<Map<String, dynamic>>> getPhotos({
    String? equipmentId,
    int? limit,
    int? offset,
  }) async {
    final db = await database;
    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (equipmentId != null) {
      whereClause = 'equipment_id = ?';
      whereArgs.add(equipmentId);
    }

    return await db.query(
      'photos',
      where: whereClause.isNotEmpty ? whereClause : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'captured_at DESC',
      limit: limit,
      offset: offset,
    );
  }

  // Equipment operations
  Future<int> insertEquipment(Map<String, dynamic> equipment) async {
    final db = await database;
    return await db.insert('equipment', equipment);
  }

  Future<List<Map<String, dynamic>>> getEquipment({String? siteId}) async {
    final db = await database;
    if (siteId != null) {
      return await db.query(
        'equipment',
        where: 'site_id = ? AND is_active = 1',
        whereArgs: [siteId],
        orderBy: 'name',
      );
    }
    return await db.query(
      'equipment',
      where: 'is_active = 1',
      orderBy: 'name',
    );
  }

  // Sync package operations
  Future<int> insertSyncPackage(Map<String, dynamic> package) async {
    final db = await database;
    return await db.insert('sync_packages', package);
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

  Future<int> updateSyncPackageStatus(
    String id,
    String status, {
    DateTime? lastAttempt,
    int? retryCount,
  }) async {
    final db = await database;
    final updates = <String, dynamic>{
      'status': status,
    };

    if (lastAttempt != null) {
      updates['last_attempt'] = lastAttempt.toIso8601String();
    }
    if (retryCount != null) {
      updates['retry_count'] = retryCount;
    }

    return await db.update(
      'sync_packages',
      updates,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Transaction support
  Future<T> transaction<T>(Future<T> Function(Transaction txn) action) async {
    final db = await database;
    return await db.transaction(action);
  }

  // Search operations using FTS5
  Future<List<Map<String, dynamic>>> search(String query) async {
    final db = await database;
    return await db.rawQuery(
      'SELECT entity_type, entity_id FROM search_index WHERE search_index MATCH ?',
      [query],
    );
  }

  Future<void> addToSearchIndex(
    String entityType,
    String entityId,
    String content,
  ) async {
    final db = await database;
    await db.insert('search_index', {
      'entity_type': entityType,
      'entity_id': entityId,
      'content': content,
    });
  }

  // Cleanup
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}