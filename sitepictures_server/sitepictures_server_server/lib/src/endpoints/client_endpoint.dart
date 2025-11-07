import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

class ClientEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  Future<ClientRecord> upsertClient(Session session, ClientRecord record) async {
    final existing = await ClientRecord.db.findFirstRow(
      session,
      where: (t) => t.clientId.equals(record.clientId),
    );

    final now = DateTime.now().toUtc();
    final createdAt = existing?.createdAt ?? record.createdAt ?? now;

    final normalized = record.copyWith(
      id: existing?.id,
      createdAt: createdAt,
      updatedAt: now,
    );

    return existing == null
        ? await ClientRecord.db.insertRow(session, normalized)
        : await ClientRecord.db.updateRow(session, normalized);
  }

  Future<List<ClientRecord>> pullClients(
    Session session,
    DateTime? lastSync,
  ) async {
    final since = lastSync?.toUtc();
    return await ClientRecord.db.find(
      session,
      where: since != null ? (t) => t.updatedAt > since : null,
      orderBy: (t) => t.updatedAt,
    );
  }
}
