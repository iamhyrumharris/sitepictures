import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';

/// Site endpoint for MainSite and SubSite management
class SiteEndpoint extends Endpoint {
  // ========== MainSite Operations ==========

  /// Get all main sites for a company
  Future<List<MainSite>> getMainSitesByCompany(
    Session session,
    String clientId,
  ) async {
    return await MainSite.db.find(
      session,
      where: (t) => t.clientId.equals(clientId) & t.isActive.equals(true),
      orderBy: (t) => t.name,
    );
  }

  /// Get main site by UUID
  Future<MainSite?> getMainSiteByUuid(Session session, String uuid) async {
    return await MainSite.db.findFirstRow(
      session,
      where: (t) => t.uuid.equals(uuid),
    );
  }

  /// Create new main site
  Future<MainSite> createMainSite(
    Session session,
    String clientId,
    String name,
    String? address,
    double? latitude,
    double? longitude,
    String createdBy,
  ) async {
    final mainSite = MainSite(
      uuid: _generateUuid(),
      clientId: clientId,
      name: name,
      address: address,
      latitude: latitude,
      longitude: longitude,
      createdBy: createdBy,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isActive: true,
    );

    await MainSite.db.insertRow(session, mainSite);
    return mainSite;
  }

  /// Update main site
  Future<MainSite> updateMainSite(
    Session session,
    String uuid,
    String? name,
    String? address,
    double? latitude,
    double? longitude,
  ) async {
    final mainSite = await getMainSiteByUuid(session, uuid);
    if (mainSite == null) {
      throw Exception('Main site not found');
    }

    if (name != null) mainSite.name = name;
    if (address != null) mainSite.address = address;
    if (latitude != null) mainSite.latitude = latitude;
    if (longitude != null) mainSite.longitude = longitude;
    mainSite.updatedAt = DateTime.now();

    await MainSite.db.updateRow(session, mainSite);
    return mainSite;
  }

  /// Soft delete main site
  Future<void> deleteMainSite(Session session, String uuid) async {
    final mainSite = await getMainSiteByUuid(session, uuid);
    if (mainSite == null) {
      throw Exception('Main site not found');
    }

    mainSite.isActive = false;
    mainSite.updatedAt = DateTime.now();
    await MainSite.db.updateRow(session, mainSite);
  }

  // ========== SubSite Operations ==========

  /// Get all sub sites for a parent (client, main site, or parent subsite)
  Future<List<SubSite>> getSubSitesByParent(
    Session session, {
    String? clientId,
    String? mainSiteId,
    String? parentSubSiteId,
  }) async {
    if (clientId != null) {
      return await SubSite.db.find(
        session,
        where: (t) => t.clientId.equals(clientId) & t.isActive.equals(true),
        orderBy: (t) => t.name,
      );
    } else if (mainSiteId != null) {
      return await SubSite.db.find(
        session,
        where: (t) => t.mainSiteId.equals(mainSiteId) & t.isActive.equals(true),
        orderBy: (t) => t.name,
      );
    } else if (parentSubSiteId != null) {
      return await SubSite.db.find(
        session,
        where: (t) =>
            t.parentSubSiteId.equals(parentSubSiteId) & t.isActive.equals(true),
        orderBy: (t) => t.name,
      );
    }
    return [];
  }

  /// Get sub site by UUID
  Future<SubSite?> getSubSiteByUuid(Session session, String uuid) async {
    return await SubSite.db.findFirstRow(
      session,
      where: (t) => t.uuid.equals(uuid),
    );
  }

  /// Create new sub site
  Future<SubSite> createSubSite(
    Session session,
    String name,
    String? description,
    String createdBy, {
    String? clientId,
    String? mainSiteId,
    String? parentSubSiteId,
  }) async {
    // Validate that exactly one parent is specified
    final parentCount = [clientId, mainSiteId, parentSubSiteId]
        .where((id) => id != null)
        .length;

    if (parentCount != 1) {
      throw Exception(
        'SubSite must have exactly one parent (client, main site, or parent subsite)',
      );
    }

    final subSite = SubSite(
      uuid: _generateUuid(),
      clientId: clientId,
      mainSiteId: mainSiteId,
      parentSubSiteId: parentSubSiteId,
      name: name,
      description: description,
      createdBy: createdBy,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isActive: true,
    );

    await SubSite.db.insertRow(session, subSite);
    return subSite;
  }

  /// Update sub site
  Future<SubSite> updateSubSite(
    Session session,
    String uuid,
    String? name,
    String? description,
  ) async {
    final subSite = await getSubSiteByUuid(session, uuid);
    if (subSite == null) {
      throw Exception('Sub site not found');
    }

    if (name != null) subSite.name = name;
    if (description != null) subSite.description = description;
    subSite.updatedAt = DateTime.now();

    await SubSite.db.updateRow(session, subSite);
    return subSite;
  }

  /// Soft delete sub site
  Future<void> deleteSubSite(Session session, String uuid) async {
    final subSite = await getSubSiteByUuid(session, uuid);
    if (subSite == null) {
      throw Exception('Sub site not found');
    }

    subSite.isActive = false;
    subSite.updatedAt = DateTime.now();
    await SubSite.db.updateRow(session, subSite);
  }

  String _generateUuid() {
    return '${DateTime.now().millisecondsSinceEpoch}-${DateTime.now().microsecond % 10000}';
  }
}
