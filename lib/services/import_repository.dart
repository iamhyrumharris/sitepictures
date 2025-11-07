import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../models/duplicate_registry_entry.dart';
import '../models/folder_photo.dart';
import '../models/import_batch.dart';
import '../models/photo.dart';
import 'database_service.dart';
import 'serverpod_import_service.dart';

class ImportRepository {
  ImportRepository({DatabaseService? databaseService})
    : _databaseService = databaseService ?? DatabaseService();

  final DatabaseService _databaseService;
  final ServerpodImportService _importService =
      ServerpodImportService.instance;
  static const _uuid = Uuid();

  Future<Database> get _db async => _databaseService.database;

  Future<ImportBatch> insertBatch(ImportBatch batch) async {
    final db = await _db;
    await db.insert('import_batches', batch.toMap());
    try {
      await _importService.upsertBatch(batch);
    } catch (_) {
      // Best-effort remote sync.
    }
    return batch;
  }

  Future<void> updateBatch(ImportBatch batch) async {
    final db = await _db;
    await db.update(
      'import_batches',
      {
        'imported_count': batch.importedCount,
        'duplicate_count': batch.duplicateCount,
        'failed_count': batch.failedCount,
        'completed_at': batch.completedAt?.toIso8601String(),
        'updated_at': batch.updatedAt.toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [batch.id],
    );
    try {
      await _importService.upsertBatch(batch);
    } catch (_) {}
  }

  Future<Photo> insertPhoto({
    required Photo photo,
    String? folderId,
    BeforeAfter? beforeAfter,
  }) async {
    final db = await _db;
    await db.transaction((txn) async {
      await txn.insert('photos', photo.toMap());
      if (folderId != null && beforeAfter != null) {
        await txn.insert(
          'folder_photos',
          FolderPhoto(
            folderId: folderId,
            photoId: photo.id,
            beforeAfter: beforeAfter,
          ).toMap(),
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }
    });
    return photo;
  }

  Future<Photo?> findDuplicate({
    required String equipmentId,
    String? folderId,
    String? sourceAssetId,
    String? fingerprintSha1,
  }) async {
    final hasSource = sourceAssetId != null && sourceAssetId.isNotEmpty;
    final hasFingerprint =
        fingerprintSha1 != null && fingerprintSha1.isNotEmpty;
    if (!hasSource && !hasFingerprint) {
      return null;
    }

    final db = await _db;
    final matchClauses = <String>[];
    final matchArgs = <Object?>[];
    if (hasSource) {
      matchClauses.add('p.source_asset_id = ?');
      matchArgs.add(sourceAssetId);
    }
    if (hasFingerprint) {
      matchClauses.add('p.fingerprint_sha1 = ?');
      matchArgs.add(fingerprintSha1);
    }

    final results = await db.rawQuery(
      '''
      SELECT p.*
      FROM photos p
      LEFT JOIN folder_photos fp ON fp.photo_id = p.id
      WHERE p.equipment_id = ?
        AND (
          (? IS NULL AND fp.folder_id IS NULL)
          OR (? IS NOT NULL AND fp.folder_id = ?)
        )
        AND (${matchClauses.join(' OR ')})
      LIMIT 1
      ''',
      [equipmentId, folderId, folderId, folderId, ...matchArgs],
    );
    if (results.isEmpty) {
      return null;
    }
    return Photo.fromMap(results.first);
  }

  Future<void> insertDuplicateEntry({
    required String existingPhotoId,
    String? sourceAssetId,
    String? fingerprintSha1,
  }) async {
    final entry = DuplicateRegistryEntry(
      id: _uuid.v4(),
      photoId: existingPhotoId,
      sourceAssetId: sourceAssetId,
      fingerprintSha1: fingerprintSha1,
    );
    final db = await _db;
    await db.insert(
      'duplicate_registry',
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
    try {
      await _importService.logDuplicate(entry);
    } catch (_) {}
  }
}
