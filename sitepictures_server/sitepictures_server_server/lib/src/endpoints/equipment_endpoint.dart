import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';

/// Equipment CRUD endpoint with flexible hierarchy support
class EquipmentEndpoint extends Endpoint {
  /// Get all equipment for a parent (client, main site, or sub site)
  Future<List<Equipment>> getEquipmentByParent(
    Session session, {
    String? clientId,
    String? mainSiteId,
    String? subSiteId,
  }) async {
    if (clientId != null) {
      return await Equipment.db.find(
        session,
        where: (t) => t.clientId.equals(clientId) & t.isActive.equals(true),
        orderBy: (t) => t.name,
      );
    } else if (mainSiteId != null) {
      return await Equipment.db.find(
        session,
        where: (t) => t.mainSiteId.equals(mainSiteId) & t.isActive.equals(true),
        orderBy: (t) => t.name,
      );
    } else if (subSiteId != null) {
      return await Equipment.db.find(
        session,
        where: (t) => t.subSiteId.equals(subSiteId) & t.isActive.equals(true),
        orderBy: (t) => t.name,
      );
    }
    return [];
  }

  /// Get equipment by UUID
  Future<Equipment?> getEquipmentByUuid(Session session, String uuid) async {
    return await Equipment.db.findFirstRow(
      session,
      where: (t) => t.uuid.equals(uuid),
    );
  }

  /// Create new equipment
  Future<Equipment> createEquipment(
    Session session,
    String name,
    String? serialNumber,
    String? manufacturer,
    String? model,
    String createdBy, {
    String? clientId,
    String? mainSiteId,
    String? subSiteId,
  }) async {
    // Validate that exactly one parent is specified
    final parentCount = [clientId, mainSiteId, subSiteId]
        .where((id) => id != null)
        .length;

    if (parentCount != 1) {
      throw Exception(
        'Equipment must have exactly one parent (client, main site, or sub site)',
      );
    }

    final equipment = Equipment(
      uuid: _generateUuid(),
      clientId: clientId,
      mainSiteId: mainSiteId,
      subSiteId: subSiteId,
      name: name,
      serialNumber: serialNumber,
      manufacturer: manufacturer,
      model: model,
      createdBy: createdBy,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isActive: true,
    );

    await Equipment.db.insertRow(session, equipment);
    return equipment;
  }

  /// Update equipment
  Future<Equipment> updateEquipment(
    Session session,
    String uuid,
    String? name,
    String? serialNumber,
    String? manufacturer,
    String? model,
  ) async {
    final equipment = await getEquipmentByUuid(session, uuid);
    if (equipment == null) {
      throw Exception('Equipment not found');
    }

    if (name != null) equipment.name = name;
    if (serialNumber != null) equipment.serialNumber = serialNumber;
    if (manufacturer != null) equipment.manufacturer = manufacturer;
    if (model != null) equipment.model = model;
    equipment.updatedAt = DateTime.now();

    await Equipment.db.updateRow(session, equipment);
    return equipment;
  }

  /// Soft delete equipment
  Future<void> deleteEquipment(Session session, String uuid) async {
    final equipment = await getEquipmentByUuid(session, uuid);
    if (equipment == null) {
      throw Exception('Equipment not found');
    }

    equipment.isActive = false;
    equipment.updatedAt = DateTime.now();
    await Equipment.db.updateRow(session, equipment);
  }

  String _generateUuid() {
    return '${DateTime.now().millisecondsSinceEpoch}-${DateTime.now().microsecond % 10000}';
  }
}
