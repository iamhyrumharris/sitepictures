import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

class ImportEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  Future<ImportBatchRecord> upsertBatch(
    Session session,
    ImportBatchRecord record,
  ) async {
    final existing = await ImportBatchRecord.db.findFirstRow(
      session,
      where: (t) => t.batchId.equals(record.batchId),
    );

    final now = DateTime.now().toUtc();
    final createdAt = existing?.startedAt ?? record.startedAt;
    final normalized = record.copyWith(
      id: existing?.id,
      startedAt: createdAt,
      updatedAt: now,
    );

    return existing == null
        ? await ImportBatchRecord.db.insertRow(session, normalized)
        : await ImportBatchRecord.db.updateRow(session, normalized);
  }

  Future<List<ImportBatchRecord>> pullBatches(
    Session session,
    DateTime? lastSync,
  ) async {
    final since = lastSync?.toUtc();
    return await ImportBatchRecord.db.find(
      session,
      where: since != null ? (t) => t.updatedAt > since : null,
      orderBy: (t) => t.updatedAt,
    );
  }

  Future<void> logDuplicate(
    Session session,
    DuplicateRegistryRecord record,
  ) async {
    final normalized = record.copyWith(
      id: null,
      duplicateId: record.duplicateId,
      importedAt: record.importedAt ?? DateTime.now().toUtc(),
    );
    await DuplicateRegistryRecord.db.insertRow(session, normalized);
  }

  Future<List<DuplicateRegistryRecord>> pullDuplicates(
    Session session,
    DateTime? lastSync,
  ) async {
    final since = lastSync?.toUtc();
    return await DuplicateRegistryRecord.db.find(
      session,
      where: since != null ? (t) => t.importedAt > since : null,
      orderBy: (t) => t.importedAt,
    );
  }
}
