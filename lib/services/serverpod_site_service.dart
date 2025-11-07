import 'package:sitepictures_server_client/sitepictures_server_client.dart'
    as rpc;

import '../models/site.dart';
import 'serverpod_service.dart';

class ServerpodSiteService {
  ServerpodSiteService._();

  static final ServerpodSiteService instance = ServerpodSiteService._();

  final ServerpodService _serverpodService = ServerpodService.instance;

  Future<MainSite> upsertMainSite(MainSite site) async {
    await _serverpodService.initialize();
    final record = await _serverpodService.client.site.upsertMainSite(
      _toMainSiteRecord(site),
    );
    return _fromMainSiteRecord(record);
  }

  Future<SubSite> upsertSubSite(SubSite site) async {
    await _serverpodService.initialize();
    final record = await _serverpodService.client.site.upsertSubSite(
      _toSubSiteRecord(site),
    );
    return _fromSubSiteRecord(record);
  }

  Future<List<MainSite>> pullMainSites(DateTime? lastSync) async {
    await _serverpodService.initialize();
    final records = await _serverpodService.client.site.pullMainSites(
      lastSync?.toUtc(),
    );
    return records.map(_fromMainSiteRecord).toList();
  }

  Future<List<SubSite>> pullSubSites(DateTime? lastSync) async {
    await _serverpodService.initialize();
    final records = await _serverpodService.client.site.pullSubSites(
      lastSync?.toUtc(),
    );
    return records.map(_fromSubSiteRecord).toList();
  }

  rpc.MainSiteRecord _toMainSiteRecord(MainSite site) {
    return rpc.MainSiteRecord(
      id: null,
      mainSiteId: site.id,
      clientId: site.clientId,
      name: site.name,
      address: site.address,
      latitude: site.latitude,
      longitude: site.longitude,
      createdBy: site.createdBy,
      createdAt: site.createdAt.toUtc(),
      updatedAt: site.updatedAt.toUtc(),
      isActive: site.isActive,
    );
  }

  rpc.SubSiteRecord _toSubSiteRecord(SubSite site) {
    return rpc.SubSiteRecord(
      id: null,
      subSiteId: site.id,
      clientId: site.clientId,
      mainSiteId: site.mainSiteId,
      parentSubSiteId: site.parentSubSiteId,
      name: site.name,
      description: site.description,
      createdBy: site.createdBy,
      createdAt: site.createdAt.toUtc(),
      updatedAt: site.updatedAt.toUtc(),
      isActive: site.isActive,
    );
  }

  MainSite _fromMainSiteRecord(rpc.MainSiteRecord record) {
    return MainSite(
      id: record.mainSiteId,
      clientId: record.clientId,
      name: record.name,
      address: record.address,
      latitude: record.latitude,
      longitude: record.longitude,
      createdBy: record.createdBy,
      createdAt: record.createdAt.toLocal(),
      updatedAt: record.updatedAt.toLocal(),
      isActive: record.isActive,
    );
  }

  SubSite _fromSubSiteRecord(rpc.SubSiteRecord record) {
    return SubSite(
      id: record.subSiteId,
      clientId: record.clientId,
      mainSiteId: record.mainSiteId,
      parentSubSiteId: record.parentSubSiteId,
      name: record.name,
      description: record.description,
      createdBy: record.createdBy,
      createdAt: record.createdAt.toLocal(),
      updatedAt: record.updatedAt.toLocal(),
      isActive: record.isActive,
    );
  }
}
