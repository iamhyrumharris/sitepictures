/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/serverpod.dart' as _i1;
import '../endpoints/auth_endpoint.dart' as _i2;
import '../endpoints/company_endpoint.dart' as _i3;
import '../endpoints/equipment_endpoint.dart' as _i4;
import '../endpoints/folder_endpoint.dart' as _i5;
import '../endpoints/photo_endpoint.dart' as _i6;
import '../endpoints/site_endpoint.dart' as _i7;
import '../endpoints/sync_endpoint.dart' as _i8;
import 'dart:typed_data' as _i9;

class Endpoints extends _i1.EndpointDispatch {
  @override
  void initializeEndpoints(_i1.Server server) {
    var endpoints = <String, _i1.Endpoint>{
      'auth': _i2.AuthEndpoint()
        ..initialize(
          server,
          'auth',
          null,
        ),
      'company': _i3.CompanyEndpoint()
        ..initialize(
          server,
          'company',
          null,
        ),
      'equipment': _i4.EquipmentEndpoint()
        ..initialize(
          server,
          'equipment',
          null,
        ),
      'folder': _i5.FolderEndpoint()
        ..initialize(
          server,
          'folder',
          null,
        ),
      'photo': _i6.PhotoEndpoint()
        ..initialize(
          server,
          'photo',
          null,
        ),
      'site': _i7.SiteEndpoint()
        ..initialize(
          server,
          'site',
          null,
        ),
      'sync': _i8.SyncEndpoint()
        ..initialize(
          server,
          'sync',
          null,
        ),
    };
    connectors['auth'] = _i1.EndpointConnector(
      name: 'auth',
      endpoint: endpoints['auth']!,
      methodConnectors: {
        'login': _i1.MethodConnector(
          name: 'login',
          params: {
            'email': _i1.ParameterDescription(
              name: 'email',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'password': _i1.ParameterDescription(
              name: 'password',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['auth'] as _i2.AuthEndpoint).login(
            session,
            params['email'],
            params['password'],
          ),
        ),
        'register': _i1.MethodConnector(
          name: 'register',
          params: {
            'email': _i1.ParameterDescription(
              name: 'email',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'name': _i1.ParameterDescription(
              name: 'name',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'password': _i1.ParameterDescription(
              name: 'password',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'role': _i1.ParameterDescription(
              name: 'role',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['auth'] as _i2.AuthEndpoint).register(
            session,
            params['email'],
            params['name'],
            params['password'],
            params['role'],
          ),
        ),
        'getCurrentUser': _i1.MethodConnector(
          name: 'getCurrentUser',
          params: {
            'uuid': _i1.ParameterDescription(
              name: 'uuid',
              type: _i1.getType<String>(),
              nullable: false,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['auth'] as _i2.AuthEndpoint).getCurrentUser(
            session,
            params['uuid'],
          ),
        ),
        'logout': _i1.MethodConnector(
          name: 'logout',
          params: {},
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['auth'] as _i2.AuthEndpoint).logout(session),
        ),
      },
    );
    connectors['company'] = _i1.EndpointConnector(
      name: 'company',
      endpoint: endpoints['company']!,
      methodConnectors: {
        'getAllCompanies': _i1.MethodConnector(
          name: 'getAllCompanies',
          params: {
            'includeSystem': _i1.ParameterDescription(
              name: 'includeSystem',
              type: _i1.getType<bool>(),
              nullable: false,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['company'] as _i3.CompanyEndpoint).getAllCompanies(
            session,
            includeSystem: params['includeSystem'],
          ),
        ),
        'getCompanyByUuid': _i1.MethodConnector(
          name: 'getCompanyByUuid',
          params: {
            'uuid': _i1.ParameterDescription(
              name: 'uuid',
              type: _i1.getType<String>(),
              nullable: false,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['company'] as _i3.CompanyEndpoint).getCompanyByUuid(
            session,
            params['uuid'],
          ),
        ),
        'createCompany': _i1.MethodConnector(
          name: 'createCompany',
          params: {
            'name': _i1.ParameterDescription(
              name: 'name',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'description': _i1.ParameterDescription(
              name: 'description',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'createdBy': _i1.ParameterDescription(
              name: 'createdBy',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['company'] as _i3.CompanyEndpoint).createCompany(
            session,
            params['name'],
            params['description'],
            params['createdBy'],
          ),
        ),
        'updateCompany': _i1.MethodConnector(
          name: 'updateCompany',
          params: {
            'uuid': _i1.ParameterDescription(
              name: 'uuid',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'name': _i1.ParameterDescription(
              name: 'name',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'description': _i1.ParameterDescription(
              name: 'description',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['company'] as _i3.CompanyEndpoint).updateCompany(
            session,
            params['uuid'],
            params['name'],
            params['description'],
          ),
        ),
        'deleteCompany': _i1.MethodConnector(
          name: 'deleteCompany',
          params: {
            'uuid': _i1.ParameterDescription(
              name: 'uuid',
              type: _i1.getType<String>(),
              nullable: false,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['company'] as _i3.CompanyEndpoint).deleteCompany(
            session,
            params['uuid'],
          ),
        ),
      },
    );
    connectors['equipment'] = _i1.EndpointConnector(
      name: 'equipment',
      endpoint: endpoints['equipment']!,
      methodConnectors: {
        'getEquipmentByParent': _i1.MethodConnector(
          name: 'getEquipmentByParent',
          params: {
            'clientId': _i1.ParameterDescription(
              name: 'clientId',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'mainSiteId': _i1.ParameterDescription(
              name: 'mainSiteId',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'subSiteId': _i1.ParameterDescription(
              name: 'subSiteId',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['equipment'] as _i4.EquipmentEndpoint)
                  .getEquipmentByParent(
            session,
            clientId: params['clientId'],
            mainSiteId: params['mainSiteId'],
            subSiteId: params['subSiteId'],
          ),
        ),
        'getEquipmentByUuid': _i1.MethodConnector(
          name: 'getEquipmentByUuid',
          params: {
            'uuid': _i1.ParameterDescription(
              name: 'uuid',
              type: _i1.getType<String>(),
              nullable: false,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['equipment'] as _i4.EquipmentEndpoint)
                  .getEquipmentByUuid(
            session,
            params['uuid'],
          ),
        ),
        'createEquipment': _i1.MethodConnector(
          name: 'createEquipment',
          params: {
            'name': _i1.ParameterDescription(
              name: 'name',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'serialNumber': _i1.ParameterDescription(
              name: 'serialNumber',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'manufacturer': _i1.ParameterDescription(
              name: 'manufacturer',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'model': _i1.ParameterDescription(
              name: 'model',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'createdBy': _i1.ParameterDescription(
              name: 'createdBy',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'clientId': _i1.ParameterDescription(
              name: 'clientId',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'mainSiteId': _i1.ParameterDescription(
              name: 'mainSiteId',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'subSiteId': _i1.ParameterDescription(
              name: 'subSiteId',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['equipment'] as _i4.EquipmentEndpoint).createEquipment(
            session,
            params['name'],
            params['serialNumber'],
            params['manufacturer'],
            params['model'],
            params['createdBy'],
            clientId: params['clientId'],
            mainSiteId: params['mainSiteId'],
            subSiteId: params['subSiteId'],
          ),
        ),
        'updateEquipment': _i1.MethodConnector(
          name: 'updateEquipment',
          params: {
            'uuid': _i1.ParameterDescription(
              name: 'uuid',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'name': _i1.ParameterDescription(
              name: 'name',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'serialNumber': _i1.ParameterDescription(
              name: 'serialNumber',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'manufacturer': _i1.ParameterDescription(
              name: 'manufacturer',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'model': _i1.ParameterDescription(
              name: 'model',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['equipment'] as _i4.EquipmentEndpoint).updateEquipment(
            session,
            params['uuid'],
            params['name'],
            params['serialNumber'],
            params['manufacturer'],
            params['model'],
          ),
        ),
        'deleteEquipment': _i1.MethodConnector(
          name: 'deleteEquipment',
          params: {
            'uuid': _i1.ParameterDescription(
              name: 'uuid',
              type: _i1.getType<String>(),
              nullable: false,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['equipment'] as _i4.EquipmentEndpoint).deleteEquipment(
            session,
            params['uuid'],
          ),
        ),
      },
    );
    connectors['folder'] = _i1.EndpointConnector(
      name: 'folder',
      endpoint: endpoints['folder']!,
      methodConnectors: {
        'getFoldersByEquipment': _i1.MethodConnector(
          name: 'getFoldersByEquipment',
          params: {
            'equipmentId': _i1.ParameterDescription(
              name: 'equipmentId',
              type: _i1.getType<String>(),
              nullable: false,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['folder'] as _i5.FolderEndpoint).getFoldersByEquipment(
            session,
            params['equipmentId'],
          ),
        ),
        'getFolderByUuid': _i1.MethodConnector(
          name: 'getFolderByUuid',
          params: {
            'uuid': _i1.ParameterDescription(
              name: 'uuid',
              type: _i1.getType<String>(),
              nullable: false,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['folder'] as _i5.FolderEndpoint).getFolderByUuid(
            session,
            params['uuid'],
          ),
        ),
        'createFolder': _i1.MethodConnector(
          name: 'createFolder',
          params: {
            'equipmentId': _i1.ParameterDescription(
              name: 'equipmentId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'name': _i1.ParameterDescription(
              name: 'name',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'workOrder': _i1.ParameterDescription(
              name: 'workOrder',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'createdBy': _i1.ParameterDescription(
              name: 'createdBy',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['folder'] as _i5.FolderEndpoint).createFolder(
            session,
            params['equipmentId'],
            params['name'],
            params['workOrder'],
            params['createdBy'],
          ),
        ),
        'addPhotoToFolder': _i1.MethodConnector(
          name: 'addPhotoToFolder',
          params: {
            'folderId': _i1.ParameterDescription(
              name: 'folderId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'photoId': _i1.ParameterDescription(
              name: 'photoId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'beforeAfter': _i1.ParameterDescription(
              name: 'beforeAfter',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['folder'] as _i5.FolderEndpoint).addPhotoToFolder(
            session,
            params['folderId'],
            params['photoId'],
            params['beforeAfter'],
          ),
        ),
        'getPhotosInFolder': _i1.MethodConnector(
          name: 'getPhotosInFolder',
          params: {
            'folderId': _i1.ParameterDescription(
              name: 'folderId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'beforeAfterFilter': _i1.ParameterDescription(
              name: 'beforeAfterFilter',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['folder'] as _i5.FolderEndpoint).getPhotosInFolder(
            session,
            params['folderId'],
            beforeAfterFilter: params['beforeAfterFilter'],
          ),
        ),
        'removePhotoFromFolder': _i1.MethodConnector(
          name: 'removePhotoFromFolder',
          params: {
            'folderId': _i1.ParameterDescription(
              name: 'folderId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'photoId': _i1.ParameterDescription(
              name: 'photoId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['folder'] as _i5.FolderEndpoint).removePhotoFromFolder(
            session,
            params['folderId'],
            params['photoId'],
          ),
        ),
        'deleteFolder': _i1.MethodConnector(
          name: 'deleteFolder',
          params: {
            'uuid': _i1.ParameterDescription(
              name: 'uuid',
              type: _i1.getType<String>(),
              nullable: false,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['folder'] as _i5.FolderEndpoint).deleteFolder(
            session,
            params['uuid'],
          ),
        ),
      },
    );
    connectors['photo'] = _i1.EndpointConnector(
      name: 'photo',
      endpoint: endpoints['photo']!,
      methodConnectors: {
        'getPhotosByEquipment': _i1.MethodConnector(
          name: 'getPhotosByEquipment',
          params: {
            'equipmentId': _i1.ParameterDescription(
              name: 'equipmentId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'limit': _i1.ParameterDescription(
              name: 'limit',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'offset': _i1.ParameterDescription(
              name: 'offset',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['photo'] as _i6.PhotoEndpoint).getPhotosByEquipment(
            session,
            params['equipmentId'],
            limit: params['limit'],
            offset: params['offset'],
          ),
        ),
        'getPhotoByUuid': _i1.MethodConnector(
          name: 'getPhotoByUuid',
          params: {
            'uuid': _i1.ParameterDescription(
              name: 'uuid',
              type: _i1.getType<String>(),
              nullable: false,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['photo'] as _i6.PhotoEndpoint).getPhotoByUuid(
            session,
            params['uuid'],
          ),
        ),
        'createPhoto': _i1.MethodConnector(
          name: 'createPhoto',
          params: {
            'equipmentId': _i1.ParameterDescription(
              name: 'equipmentId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'filePath': _i1.ParameterDescription(
              name: 'filePath',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'latitude': _i1.ParameterDescription(
              name: 'latitude',
              type: _i1.getType<double>(),
              nullable: false,
            ),
            'longitude': _i1.ParameterDescription(
              name: 'longitude',
              type: _i1.getType<double>(),
              nullable: false,
            ),
            'timestamp': _i1.ParameterDescription(
              name: 'timestamp',
              type: _i1.getType<DateTime>(),
              nullable: false,
            ),
            'capturedBy': _i1.ParameterDescription(
              name: 'capturedBy',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'fileSize': _i1.ParameterDescription(
              name: 'fileSize',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'thumbnailPath': _i1.ParameterDescription(
              name: 'thumbnailPath',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'sourceAssetId': _i1.ParameterDescription(
              name: 'sourceAssetId',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'fingerprintSha1': _i1.ParameterDescription(
              name: 'fingerprintSha1',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'importBatchId': _i1.ParameterDescription(
              name: 'importBatchId',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'importSource': _i1.ParameterDescription(
              name: 'importSource',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['photo'] as _i6.PhotoEndpoint).createPhoto(
            session,
            params['equipmentId'],
            params['filePath'],
            params['latitude'],
            params['longitude'],
            params['timestamp'],
            params['capturedBy'],
            params['fileSize'],
            thumbnailPath: params['thumbnailPath'],
            sourceAssetId: params['sourceAssetId'],
            fingerprintSha1: params['fingerprintSha1'],
            importBatchId: params['importBatchId'],
            importSource: params['importSource'],
          ),
        ),
        'uploadPhoto': _i1.MethodConnector(
          name: 'uploadPhoto',
          params: {
            'equipmentId': _i1.ParameterDescription(
              name: 'equipmentId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'fileData': _i1.ParameterDescription(
              name: 'fileData',
              type: _i1.getType<_i9.ByteData>(),
              nullable: false,
            ),
            'fileName': _i1.ParameterDescription(
              name: 'fileName',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'latitude': _i1.ParameterDescription(
              name: 'latitude',
              type: _i1.getType<double>(),
              nullable: false,
            ),
            'longitude': _i1.ParameterDescription(
              name: 'longitude',
              type: _i1.getType<double>(),
              nullable: false,
            ),
            'timestamp': _i1.ParameterDescription(
              name: 'timestamp',
              type: _i1.getType<DateTime>(),
              nullable: false,
            ),
            'capturedBy': _i1.ParameterDescription(
              name: 'capturedBy',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'importSource': _i1.ParameterDescription(
              name: 'importSource',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['photo'] as _i6.PhotoEndpoint).uploadPhoto(
            session,
            params['equipmentId'],
            params['fileData'],
            params['fileName'],
            params['latitude'],
            params['longitude'],
            params['timestamp'],
            params['capturedBy'],
            params['importSource'],
          ),
        ),
        'getUnsyncedPhotos': _i1.MethodConnector(
          name: 'getUnsyncedPhotos',
          params: {},
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['photo'] as _i6.PhotoEndpoint)
                  .getUnsyncedPhotos(session),
        ),
        'markPhotoAsSynced': _i1.MethodConnector(
          name: 'markPhotoAsSynced',
          params: {
            'uuid': _i1.ParameterDescription(
              name: 'uuid',
              type: _i1.getType<String>(),
              nullable: false,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['photo'] as _i6.PhotoEndpoint).markPhotoAsSynced(
            session,
            params['uuid'],
          ),
        ),
        'deletePhoto': _i1.MethodConnector(
          name: 'deletePhoto',
          params: {
            'uuid': _i1.ParameterDescription(
              name: 'uuid',
              type: _i1.getType<String>(),
              nullable: false,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['photo'] as _i6.PhotoEndpoint).deletePhoto(
            session,
            params['uuid'],
          ),
        ),
        'getPhotoUrl': _i1.MethodConnector(
          name: 'getPhotoUrl',
          params: {
            'uuid': _i1.ParameterDescription(
              name: 'uuid',
              type: _i1.getType<String>(),
              nullable: false,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['photo'] as _i6.PhotoEndpoint).getPhotoUrl(
            session,
            params['uuid'],
          ),
        ),
      },
    );
    connectors['site'] = _i1.EndpointConnector(
      name: 'site',
      endpoint: endpoints['site']!,
      methodConnectors: {
        'getMainSitesByCompany': _i1.MethodConnector(
          name: 'getMainSitesByCompany',
          params: {
            'clientId': _i1.ParameterDescription(
              name: 'clientId',
              type: _i1.getType<String>(),
              nullable: false,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['site'] as _i7.SiteEndpoint).getMainSitesByCompany(
            session,
            params['clientId'],
          ),
        ),
        'getMainSiteByUuid': _i1.MethodConnector(
          name: 'getMainSiteByUuid',
          params: {
            'uuid': _i1.ParameterDescription(
              name: 'uuid',
              type: _i1.getType<String>(),
              nullable: false,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['site'] as _i7.SiteEndpoint).getMainSiteByUuid(
            session,
            params['uuid'],
          ),
        ),
        'createMainSite': _i1.MethodConnector(
          name: 'createMainSite',
          params: {
            'clientId': _i1.ParameterDescription(
              name: 'clientId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'name': _i1.ParameterDescription(
              name: 'name',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'address': _i1.ParameterDescription(
              name: 'address',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'latitude': _i1.ParameterDescription(
              name: 'latitude',
              type: _i1.getType<double?>(),
              nullable: true,
            ),
            'longitude': _i1.ParameterDescription(
              name: 'longitude',
              type: _i1.getType<double?>(),
              nullable: true,
            ),
            'createdBy': _i1.ParameterDescription(
              name: 'createdBy',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['site'] as _i7.SiteEndpoint).createMainSite(
            session,
            params['clientId'],
            params['name'],
            params['address'],
            params['latitude'],
            params['longitude'],
            params['createdBy'],
          ),
        ),
        'updateMainSite': _i1.MethodConnector(
          name: 'updateMainSite',
          params: {
            'uuid': _i1.ParameterDescription(
              name: 'uuid',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'name': _i1.ParameterDescription(
              name: 'name',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'address': _i1.ParameterDescription(
              name: 'address',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'latitude': _i1.ParameterDescription(
              name: 'latitude',
              type: _i1.getType<double?>(),
              nullable: true,
            ),
            'longitude': _i1.ParameterDescription(
              name: 'longitude',
              type: _i1.getType<double?>(),
              nullable: true,
            ),
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['site'] as _i7.SiteEndpoint).updateMainSite(
            session,
            params['uuid'],
            params['name'],
            params['address'],
            params['latitude'],
            params['longitude'],
          ),
        ),
        'deleteMainSite': _i1.MethodConnector(
          name: 'deleteMainSite',
          params: {
            'uuid': _i1.ParameterDescription(
              name: 'uuid',
              type: _i1.getType<String>(),
              nullable: false,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['site'] as _i7.SiteEndpoint).deleteMainSite(
            session,
            params['uuid'],
          ),
        ),
        'getSubSitesByParent': _i1.MethodConnector(
          name: 'getSubSitesByParent',
          params: {
            'clientId': _i1.ParameterDescription(
              name: 'clientId',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'mainSiteId': _i1.ParameterDescription(
              name: 'mainSiteId',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'parentSubSiteId': _i1.ParameterDescription(
              name: 'parentSubSiteId',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['site'] as _i7.SiteEndpoint).getSubSitesByParent(
            session,
            clientId: params['clientId'],
            mainSiteId: params['mainSiteId'],
            parentSubSiteId: params['parentSubSiteId'],
          ),
        ),
        'getSubSiteByUuid': _i1.MethodConnector(
          name: 'getSubSiteByUuid',
          params: {
            'uuid': _i1.ParameterDescription(
              name: 'uuid',
              type: _i1.getType<String>(),
              nullable: false,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['site'] as _i7.SiteEndpoint).getSubSiteByUuid(
            session,
            params['uuid'],
          ),
        ),
        'createSubSite': _i1.MethodConnector(
          name: 'createSubSite',
          params: {
            'name': _i1.ParameterDescription(
              name: 'name',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'description': _i1.ParameterDescription(
              name: 'description',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'createdBy': _i1.ParameterDescription(
              name: 'createdBy',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'clientId': _i1.ParameterDescription(
              name: 'clientId',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'mainSiteId': _i1.ParameterDescription(
              name: 'mainSiteId',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'parentSubSiteId': _i1.ParameterDescription(
              name: 'parentSubSiteId',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['site'] as _i7.SiteEndpoint).createSubSite(
            session,
            params['name'],
            params['description'],
            params['createdBy'],
            clientId: params['clientId'],
            mainSiteId: params['mainSiteId'],
            parentSubSiteId: params['parentSubSiteId'],
          ),
        ),
        'updateSubSite': _i1.MethodConnector(
          name: 'updateSubSite',
          params: {
            'uuid': _i1.ParameterDescription(
              name: 'uuid',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'name': _i1.ParameterDescription(
              name: 'name',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'description': _i1.ParameterDescription(
              name: 'description',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['site'] as _i7.SiteEndpoint).updateSubSite(
            session,
            params['uuid'],
            params['name'],
            params['description'],
          ),
        ),
        'deleteSubSite': _i1.MethodConnector(
          name: 'deleteSubSite',
          params: {
            'uuid': _i1.ParameterDescription(
              name: 'uuid',
              type: _i1.getType<String>(),
              nullable: false,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['site'] as _i7.SiteEndpoint).deleteSubSite(
            session,
            params['uuid'],
          ),
        ),
      },
    );
    connectors['sync'] = _i1.EndpointConnector(
      name: 'sync',
      endpoint: endpoints['sync']!,
      methodConnectors: {
        'getChangesSince': _i1.MethodConnector(
          name: 'getChangesSince',
          params: {
            'since': _i1.ParameterDescription(
              name: 'since',
              type: _i1.getType<DateTime>(),
              nullable: false,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['sync'] as _i8.SyncEndpoint).getChangesSince(
            session,
            params['since'],
          ),
        ),
        'pushChanges': _i1.MethodConnector(
          name: 'pushChanges',
          params: {
            'changes': _i1.ParameterDescription(
              name: 'changes',
              type: _i1.getType<List<Map<String, dynamic>>>(),
              nullable: false,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['sync'] as _i8.SyncEndpoint).pushChanges(
            session,
            params['changes'],
          ),
        ),
      },
    );
  }
}
