import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

class EquipmentEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  Future<EquipmentRecord> upsertEquipment(
    Session session,
    EquipmentRecord record,
  ) async {
    final existing = await EquipmentRecord.db.findFirstRow(
      session,
      where: (t) => t.equipmentId.equals(record.equipmentId),
    );

    final now = DateTime.now().toUtc();
    final createdAt = existing?.createdAt ?? record.createdAt ?? now;
    final normalized = record.copyWith(
      id: existing?.id,
      createdAt: createdAt,
      updatedAt: now,
    );

    return existing == null
        ? await EquipmentRecord.db.insertRow(session, normalized)
        : await EquipmentRecord.db.updateRow(session, normalized);
  }

  Future<List<EquipmentRecord>> pullEquipment(
    Session session,
    DateTime? lastSync,
  ) async {
    final since = lastSync?.toUtc();
    return await EquipmentRecord.db.find(
      session,
      where: since != null ? (t) => t.updatedAt > since : null,
      orderBy: (t) => t.updatedAt,
    );
  }
}
