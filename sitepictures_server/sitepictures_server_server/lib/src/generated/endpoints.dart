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
import '../endpoints/account_endpoint.dart' as _i2;
import '../endpoints/client_endpoint.dart' as _i3;
import '../endpoints/equipment_endpoint.dart' as _i4;
import '../endpoints/folder_endpoint.dart' as _i5;
import '../endpoints/import_endpoint.dart' as _i6;
import '../endpoints/photo_endpoint.dart' as _i7;
import '../endpoints/site_endpoint.dart' as _i8;
import 'package:sitepictures_server_server/src/generated/client_record.dart'
    as _i9;
import 'package:sitepictures_server_server/src/generated/equipment_record.dart'
    as _i10;
import 'package:sitepictures_server_server/src/generated/photo_folder_record.dart'
    as _i11;
import 'package:sitepictures_server_server/src/generated/folder_photo_record.dart'
    as _i12;
import 'package:sitepictures_server_server/src/generated/import_batch_record.dart'
    as _i13;
import 'package:sitepictures_server_server/src/generated/duplicate_registry_record.dart'
    as _i14;
import 'package:sitepictures_server_server/src/generated/photo_payload.dart'
    as _i15;
import 'package:sitepictures_server_server/src/generated/main_site_record.dart'
    as _i16;
import 'package:sitepictures_server_server/src/generated/sub_site_record.dart'
    as _i17;
import 'package:serverpod_auth_server/serverpod_auth_server.dart' as _i18;

class Endpoints extends _i1.EndpointDispatch {
  @override
  void initializeEndpoints(_i1.Server server) {
    var endpoints = <String, _i1.Endpoint>{
      'account': _i2.AccountEndpoint()
        ..initialize(
          server,
          'account',
          null,
        ),
      'client': _i3.ClientEndpoint()
        ..initialize(
          server,
          'client',
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
      'import': _i6.ImportEndpoint()
        ..initialize(
          server,
          'import',
          null,
        ),
      'photo': _i7.PhotoEndpoint()
        ..initialize(
          server,
          'photo',
          null,
        ),
      'site': _i8.SiteEndpoint()
        ..initialize(
          server,
          'site',
          null,
        ),
    };
    connectors['account'] = _i1.EndpointConnector(
      name: 'account',
      endpoint: endpoints['account']!,
      methodConnectors: {
        'registerUser': _i1.MethodConnector(
          name: 'registerUser',
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
            'fullName': _i1.ParameterDescription(
              name: 'fullName',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['account'] as _i2.AccountEndpoint).registerUser(
            session,
            params['email'],
            params['password'],
            params['fullName'],
          ),
        )
      },
    );
    connectors['client'] = _i1.EndpointConnector(
      name: 'client',
      endpoint: endpoints['client']!,
      methodConnectors: {
        'upsertClient': _i1.MethodConnector(
          name: 'upsertClient',
          params: {
            'record': _i1.ParameterDescription(
              name: 'record',
              type: _i1.getType<_i9.ClientRecord>(),
              nullable: false,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['client'] as _i3.ClientEndpoint).upsertClient(
            session,
            params['record'],
          ),
        ),
        'pullClients': _i1.MethodConnector(
          name: 'pullClients',
          params: {
            'lastSync': _i1.ParameterDescription(
              name: 'lastSync',
              type: _i1.getType<DateTime?>(),
              nullable: true,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['client'] as _i3.ClientEndpoint).pullClients(
            session,
            params['lastSync'],
          ),
        ),
      },
    );
    connectors['equipment'] = _i1.EndpointConnector(
      name: 'equipment',
      endpoint: endpoints['equipment']!,
      methodConnectors: {
        'upsertEquipment': _i1.MethodConnector(
          name: 'upsertEquipment',
          params: {
            'record': _i1.ParameterDescription(
              name: 'record',
              type: _i1.getType<_i10.EquipmentRecord>(),
              nullable: false,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['equipment'] as _i4.EquipmentEndpoint).upsertEquipment(
            session,
            params['record'],
          ),
        ),
        'pullEquipment': _i1.MethodConnector(
          name: 'pullEquipment',
          params: {
            'lastSync': _i1.ParameterDescription(
              name: 'lastSync',
              type: _i1.getType<DateTime?>(),
              nullable: true,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['equipment'] as _i4.EquipmentEndpoint).pullEquipment(
            session,
            params['lastSync'],
          ),
        ),
      },
    );
    connectors['folder'] = _i1.EndpointConnector(
      name: 'folder',
      endpoint: endpoints['folder']!,
      methodConnectors: {
        'upsertFolder': _i1.MethodConnector(
          name: 'upsertFolder',
          params: {
            'record': _i1.ParameterDescription(
              name: 'record',
              type: _i1.getType<_i11.PhotoFolderRecord>(),
              nullable: false,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['folder'] as _i5.FolderEndpoint).upsertFolder(
            session,
            params['record'],
          ),
        ),
        'pullFolders': _i1.MethodConnector(
          name: 'pullFolders',
          params: {
            'lastSync': _i1.ParameterDescription(
              name: 'lastSync',
              type: _i1.getType<DateTime?>(),
              nullable: true,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['folder'] as _i5.FolderEndpoint).pullFolders(
            session,
            params['lastSync'],
          ),
        ),
        'upsertFolderPhoto': _i1.MethodConnector(
          name: 'upsertFolderPhoto',
          params: {
            'record': _i1.ParameterDescription(
              name: 'record',
              type: _i1.getType<_i12.FolderPhotoRecord>(),
              nullable: false,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['folder'] as _i5.FolderEndpoint).upsertFolderPhoto(
            session,
            params['record'],
          ),
        ),
        'pullFolderPhotos': _i1.MethodConnector(
          name: 'pullFolderPhotos',
          params: {
            'lastSync': _i1.ParameterDescription(
              name: 'lastSync',
              type: _i1.getType<DateTime?>(),
              nullable: true,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['folder'] as _i5.FolderEndpoint).pullFolderPhotos(
            session,
            params['lastSync'],
          ),
        ),
      },
    );
    connectors['import'] = _i1.EndpointConnector(
      name: 'import',
      endpoint: endpoints['import']!,
      methodConnectors: {
        'upsertBatch': _i1.MethodConnector(
          name: 'upsertBatch',
          params: {
            'record': _i1.ParameterDescription(
              name: 'record',
              type: _i1.getType<_i13.ImportBatchRecord>(),
              nullable: false,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['import'] as _i6.ImportEndpoint).upsertBatch(
            session,
            params['record'],
          ),
        ),
        'pullBatches': _i1.MethodConnector(
          name: 'pullBatches',
          params: {
            'lastSync': _i1.ParameterDescription(
              name: 'lastSync',
              type: _i1.getType<DateTime?>(),
              nullable: true,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['import'] as _i6.ImportEndpoint).pullBatches(
            session,
            params['lastSync'],
          ),
        ),
        'logDuplicate': _i1.MethodConnector(
          name: 'logDuplicate',
          params: {
            'record': _i1.ParameterDescription(
              name: 'record',
              type: _i1.getType<_i14.DuplicateRegistryRecord>(),
              nullable: false,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['import'] as _i6.ImportEndpoint).logDuplicate(
            session,
            params['record'],
          ),
        ),
        'pullDuplicates': _i1.MethodConnector(
          name: 'pullDuplicates',
          params: {
            'lastSync': _i1.ParameterDescription(
              name: 'lastSync',
              type: _i1.getType<DateTime?>(),
              nullable: true,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['import'] as _i6.ImportEndpoint).pullDuplicates(
            session,
            params['lastSync'],
          ),
        ),
      },
    );
    connectors['photo'] = _i1.EndpointConnector(
      name: 'photo',
      endpoint: endpoints['photo']!,
      methodConnectors: {
        'upsertPhoto': _i1.MethodConnector(
          name: 'upsertPhoto',
          params: {
            'payload': _i1.ParameterDescription(
              name: 'payload',
              type: _i1.getType<_i15.PhotoPayload>(),
              nullable: false,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['photo'] as _i7.PhotoEndpoint).upsertPhoto(
            session,
            params['payload'],
          ),
        ),
        'pullPhotos': _i1.MethodConnector(
          name: 'pullPhotos',
          params: {
            'lastSync': _i1.ParameterDescription(
              name: 'lastSync',
              type: _i1.getType<DateTime?>(),
              nullable: true,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['photo'] as _i7.PhotoEndpoint).pullPhotos(
            session,
            params['lastSync'],
          ),
        ),
        'downloadPhoto': _i1.MethodConnector(
          name: 'downloadPhoto',
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
              (endpoints['photo'] as _i7.PhotoEndpoint).downloadPhoto(
            session,
            params['clientId'],
          ),
        ),
      },
    );
    connectors['site'] = _i1.EndpointConnector(
      name: 'site',
      endpoint: endpoints['site']!,
      methodConnectors: {
        'upsertMainSite': _i1.MethodConnector(
          name: 'upsertMainSite',
          params: {
            'record': _i1.ParameterDescription(
              name: 'record',
              type: _i1.getType<_i16.MainSiteRecord>(),
              nullable: false,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['site'] as _i8.SiteEndpoint).upsertMainSite(
            session,
            params['record'],
          ),
        ),
        'upsertSubSite': _i1.MethodConnector(
          name: 'upsertSubSite',
          params: {
            'record': _i1.ParameterDescription(
              name: 'record',
              type: _i1.getType<_i17.SubSiteRecord>(),
              nullable: false,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['site'] as _i8.SiteEndpoint).upsertSubSite(
            session,
            params['record'],
          ),
        ),
        'pullMainSites': _i1.MethodConnector(
          name: 'pullMainSites',
          params: {
            'lastSync': _i1.ParameterDescription(
              name: 'lastSync',
              type: _i1.getType<DateTime?>(),
              nullable: true,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['site'] as _i8.SiteEndpoint).pullMainSites(
            session,
            params['lastSync'],
          ),
        ),
        'pullSubSites': _i1.MethodConnector(
          name: 'pullSubSites',
          params: {
            'lastSync': _i1.ParameterDescription(
              name: 'lastSync',
              type: _i1.getType<DateTime?>(),
              nullable: true,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['site'] as _i8.SiteEndpoint).pullSubSites(
            session,
            params['lastSync'],
          ),
        ),
      },
    );
    modules['serverpod_auth'] = _i18.Endpoints()..initializeEndpoints(server);
  }
}
