import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

class SiteEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  Future<MainSiteRecord> upsertMainSite(
    Session session,
    MainSiteRecord record,
  ) async {
    final existing = await MainSiteRecord.db.findFirstRow(
      session,
      where: (t) => t.mainSiteId.equals(record.mainSiteId),
    );

    final now = DateTime.now().toUtc();
    final createdAt = existing?.createdAt ?? record.createdAt ?? now;
    final normalized = record.copyWith(
      id: existing?.id,
      createdAt: createdAt,
      updatedAt: now,
    );

    return existing == null
        ? await MainSiteRecord.db.insertRow(session, normalized)
        : await MainSiteRecord.db.updateRow(session, normalized);
  }

  Future<SubSiteRecord> upsertSubSite(
    Session session,
    SubSiteRecord record,
  ) async {
    final existing = await SubSiteRecord.db.findFirstRow(
      session,
      where: (t) => t.subSiteId.equals(record.subSiteId),
    );

    final now = DateTime.now().toUtc();
    final createdAt = existing?.createdAt ?? record.createdAt ?? now;
    final normalized = record.copyWith(
      id: existing?.id,
      createdAt: createdAt,
      updatedAt: now,
    );

    return existing == null
        ? await SubSiteRecord.db.insertRow(session, normalized)
        : await SubSiteRecord.db.updateRow(session, normalized);
  }

  Future<List<MainSiteRecord>> pullMainSites(
    Session session,
    DateTime? lastSync,
  ) async {
    final since = lastSync?.toUtc();
    return await MainSiteRecord.db.find(
      session,
      where: since != null ? (t) => t.updatedAt > since : null,
      orderBy: (t) => t.updatedAt,
    );
  }

  Future<List<SubSiteRecord>> pullSubSites(
    Session session,
    DateTime? lastSync,
  ) async {
    final since = lastSync?.toUtc();
    return await SubSiteRecord.db.find(
      session,
      where: since != null ? (t) => t.updatedAt > since : null,
      orderBy: (t) => t.updatedAt,
    );
  }
}
