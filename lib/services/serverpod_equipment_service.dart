import 'package:sitepictures_server_client/sitepictures_server_client.dart'
    as rpc;

import '../models/equipment.dart';
import 'serverpod_service.dart';

class ServerpodEquipmentService {
  ServerpodEquipmentService._();

  static final ServerpodEquipmentService instance =
      ServerpodEquipmentService._();

  final ServerpodService _serverpodService = ServerpodService.instance;

  Future<Equipment> upsertEquipment(Equipment equipment) async {
    await _serverpodService.initialize();
    final record = await _serverpodService.client.equipment.upsertEquipment(
      _toRecord(equipment),
    );
    return _fromRecord(record);
  }

  Future<List<Equipment>> pullEquipment(DateTime? lastSync) async {
    await _serverpodService.initialize();
    final records = await _serverpodService.client.equipment.pullEquipment(
      lastSync?.toUtc(),
    );
    return records.map(_fromRecord).toList();
  }

  rpc.EquipmentRecord _toRecord(Equipment equipment) {
    return rpc.EquipmentRecord(
      id: null,
      equipmentId: equipment.id,
      clientId: equipment.clientId,
      mainSiteId: equipment.mainSiteId,
      subSiteId: equipment.subSiteId,
      name: equipment.name,
      serialNumber: equipment.serialNumber,
      manufacturer: equipment.manufacturer,
      model: equipment.model,
      createdBy: equipment.createdBy,
      createdAt: equipment.createdAt.toUtc(),
      updatedAt: equipment.updatedAt.toUtc(),
      isActive: equipment.isActive,
    );
  }

  Equipment _fromRecord(rpc.EquipmentRecord record) {
    return Equipment(
      id: record.equipmentId,
      clientId: record.clientId,
      mainSiteId: record.mainSiteId,
      subSiteId: record.subSiteId,
      name: record.name,
      serialNumber: record.serialNumber,
      manufacturer: record.manufacturer,
      model: record.model,
      createdBy: record.createdBy,
      createdAt: record.createdAt.toLocal(),
      updatedAt: record.updatedAt.toLocal(),
      isActive: record.isActive,
    );
  }
}
