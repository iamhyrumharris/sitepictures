import 'package:sitepictures_server_client/sitepictures_server_client.dart'
    as rpc;

import '../models/import_batch.dart';
import '../models/duplicate_registry_entry.dart';
import 'serverpod_service.dart';

class ServerpodImportService {
  ServerpodImportService._();

  static final ServerpodImportService instance = ServerpodImportService._();

  final ServerpodService _serverpodService = ServerpodService.instance;

  Future<void> upsertBatch(ImportBatch batch) async {
    await _serverpodService.initialize();
    await _serverpodService.client.import.upsertBatch(
      _toRecord(batch),
    );
  }

  Future<List<ImportBatch>> pullBatches(DateTime? lastSync) async {
    await _serverpodService.initialize();
    final records = await _serverpodService.client.import.pullBatches(
      lastSync?.toUtc(),
    );
    return records.map(_fromRecord).toList();
  }

  Future<void> logDuplicate(DuplicateRegistryEntry entry) async {
    await _serverpodService.initialize();
    await _serverpodService.client.import.logDuplicate(
      _toDuplicateRecord(entry),
    );
  }

  Future<List<DuplicateRegistryEntry>> pullDuplicates(
    DateTime? lastSync,
  ) async {
    await _serverpodService.initialize();
    final records = await _serverpodService.client.import.pullDuplicates(
      lastSync?.toUtc(),
    );
    return records.map(_fromDuplicateRecord).toList();
  }

  rpc.ImportBatchRecord _toRecord(ImportBatch batch) {
    return rpc.ImportBatchRecord(
      id: null,
      batchId: batch.id,
      entryPoint: batch.entryPoint.dbValue,
      equipmentId: batch.equipmentId,
      folderId: batch.folderId,
      destinationCategory: batch.destinationCategory.dbValue,
      selectedCount: batch.selectedCount,
      importedCount: batch.importedCount,
      duplicateCount: batch.duplicateCount,
      failedCount: batch.failedCount,
      startedAt: batch.startedAt.toUtc(),
      completedAt: batch.completedAt?.toUtc(),
      permissionState: batch.permissionState.dbValue,
      deviceFreeSpaceBytes: batch.deviceFreeSpaceBytes,
      updatedAt: batch.updatedAt.toUtc(),
    );
  }

  ImportBatch _fromRecord(rpc.ImportBatchRecord record) {
    return ImportBatch(
      id: record.batchId,
      entryPoint: ImportEntryPoint.fromDb(record.entryPoint),
      equipmentId: record.equipmentId,
      folderId: record.folderId,
      destinationCategory:
          ImportDestinationCategory.fromDb(record.destinationCategory),
      selectedCount: record.selectedCount,
      importedCount: record.importedCount,
      duplicateCount: record.duplicateCount,
      failedCount: record.failedCount,
      startedAt: record.startedAt.toLocal(),
      completedAt: record.completedAt?.toLocal(),
      permissionState: ImportPermissionState.fromDb(record.permissionState),
      deviceFreeSpaceBytes: record.deviceFreeSpaceBytes,
      updatedAt: record.updatedAt.toLocal(),
    );
  }

  rpc.DuplicateRegistryRecord _toDuplicateRecord(
    DuplicateRegistryEntry entry,
  ) {
    return rpc.DuplicateRegistryRecord(
      id: null,
      duplicateId: entry.id,
      photoId: entry.photoId,
      sourceAssetId: entry.sourceAssetId,
      fingerprintSha1: entry.fingerprintSha1,
      importedAt: entry.importedAt.toUtc(),
    );
  }

  DuplicateRegistryEntry _fromDuplicateRecord(
    rpc.DuplicateRegistryRecord record,
  ) {
    return DuplicateRegistryEntry(
      id: record.duplicateId,
      photoId: record.photoId,
      sourceAssetId: record.sourceAssetId,
      fingerprintSha1: record.fingerprintSha1,
      importedAt: record.importedAt.toLocal(),
    );
  }
}
