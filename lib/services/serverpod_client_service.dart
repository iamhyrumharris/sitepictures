import 'package:sitepictures_server_client/sitepictures_server_client.dart'
    as rpc;

import '../models/client.dart';
import 'serverpod_service.dart';

class ServerpodClientService {
  ServerpodClientService._();

  static final ServerpodClientService instance = ServerpodClientService._();

  final ServerpodService _serverpodService = ServerpodService.instance;

  Future<Client?> upsertClient(Client client) async {
    await _serverpodService.initialize();
    final record = await _serverpodService.client.client.upsertClient(
      _toRecord(client),
    );
    return _fromRecord(record);
  }

  Future<List<Client>> pullClients(DateTime? lastSync) async {
    await _serverpodService.initialize();
    final records = await _serverpodService.client.client.pullClients(
      lastSync?.toUtc(),
    );
    return records.map(_fromRecord).toList();
  }

  rpc.ClientRecord _toRecord(Client client) {
    return rpc.ClientRecord(
      id: null,
      clientId: client.id,
      name: client.name,
      description: client.description,
      isSystem: client.isSystem,
      createdBy: client.createdBy,
      createdAt: client.createdAt.toUtc(),
      updatedAt: client.updatedAt.toUtc(),
      isActive: client.isActive,
    );
  }

  Client _fromRecord(rpc.ClientRecord record) {
    return Client(
      id: record.clientId,
      name: record.name,
      description: record.description,
      isSystem: record.isSystem,
      createdBy: record.createdBy,
      createdAt: record.createdAt.toLocal(),
      updatedAt: record.updatedAt.toLocal(),
      isActive: record.isActive,
    );
  }
}
