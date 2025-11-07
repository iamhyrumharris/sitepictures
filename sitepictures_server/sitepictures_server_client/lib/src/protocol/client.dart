/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;
import 'dart:async' as _i2;
import 'package:serverpod_auth_client/serverpod_auth_client.dart' as _i3;
import 'package:sitepictures_server_client/src/protocol/client_record.dart'
    as _i4;
import 'package:sitepictures_server_client/src/protocol/equipment_record.dart'
    as _i5;
import 'package:sitepictures_server_client/src/protocol/photo_folder_record.dart'
    as _i6;
import 'package:sitepictures_server_client/src/protocol/folder_photo_record.dart'
    as _i7;
import 'package:sitepictures_server_client/src/protocol/import_batch_record.dart'
    as _i8;
import 'package:sitepictures_server_client/src/protocol/duplicate_registry_record.dart'
    as _i9;
import 'package:sitepictures_server_client/src/protocol/photo_record.dart'
    as _i10;
import 'package:sitepictures_server_client/src/protocol/photo_payload.dart'
    as _i11;
import 'package:sitepictures_server_client/src/protocol/main_site_record.dart'
    as _i12;
import 'package:sitepictures_server_client/src/protocol/sub_site_record.dart'
    as _i13;
import 'protocol.dart' as _i14;

/// {@category Endpoint}
class EndpointAccount extends _i1.EndpointRef {
  EndpointAccount(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'account';

  _i2.Future<_i3.AuthenticationResponse> registerUser(
    String email,
    String password,
    String fullName,
  ) =>
      caller.callServerEndpoint<_i3.AuthenticationResponse>(
        'account',
        'registerUser',
        {
          'email': email,
          'password': password,
          'fullName': fullName,
        },
      );
}

/// {@category Endpoint}
class EndpointClient extends _i1.EndpointRef {
  EndpointClient(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'client';

  _i2.Future<_i4.ClientRecord> upsertClient(_i4.ClientRecord record) =>
      caller.callServerEndpoint<_i4.ClientRecord>(
        'client',
        'upsertClient',
        {'record': record},
      );

  _i2.Future<List<_i4.ClientRecord>> pullClients(DateTime? lastSync) =>
      caller.callServerEndpoint<List<_i4.ClientRecord>>(
        'client',
        'pullClients',
        {'lastSync': lastSync},
      );
}

/// {@category Endpoint}
class EndpointEquipment extends _i1.EndpointRef {
  EndpointEquipment(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'equipment';

  _i2.Future<_i5.EquipmentRecord> upsertEquipment(_i5.EquipmentRecord record) =>
      caller.callServerEndpoint<_i5.EquipmentRecord>(
        'equipment',
        'upsertEquipment',
        {'record': record},
      );

  _i2.Future<List<_i5.EquipmentRecord>> pullEquipment(DateTime? lastSync) =>
      caller.callServerEndpoint<List<_i5.EquipmentRecord>>(
        'equipment',
        'pullEquipment',
        {'lastSync': lastSync},
      );
}

/// {@category Endpoint}
class EndpointFolder extends _i1.EndpointRef {
  EndpointFolder(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'folder';

  _i2.Future<_i6.PhotoFolderRecord> upsertFolder(
          _i6.PhotoFolderRecord record) =>
      caller.callServerEndpoint<_i6.PhotoFolderRecord>(
        'folder',
        'upsertFolder',
        {'record': record},
      );

  _i2.Future<List<_i6.PhotoFolderRecord>> pullFolders(DateTime? lastSync) =>
      caller.callServerEndpoint<List<_i6.PhotoFolderRecord>>(
        'folder',
        'pullFolders',
        {'lastSync': lastSync},
      );

  _i2.Future<_i7.FolderPhotoRecord> upsertFolderPhoto(
          _i7.FolderPhotoRecord record) =>
      caller.callServerEndpoint<_i7.FolderPhotoRecord>(
        'folder',
        'upsertFolderPhoto',
        {'record': record},
      );

  _i2.Future<List<_i7.FolderPhotoRecord>> pullFolderPhotos(
          DateTime? lastSync) =>
      caller.callServerEndpoint<List<_i7.FolderPhotoRecord>>(
        'folder',
        'pullFolderPhotos',
        {'lastSync': lastSync},
      );
}

/// {@category Endpoint}
class EndpointImport extends _i1.EndpointRef {
  EndpointImport(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'import';

  _i2.Future<_i8.ImportBatchRecord> upsertBatch(_i8.ImportBatchRecord record) =>
      caller.callServerEndpoint<_i8.ImportBatchRecord>(
        'import',
        'upsertBatch',
        {'record': record},
      );

  _i2.Future<List<_i8.ImportBatchRecord>> pullBatches(DateTime? lastSync) =>
      caller.callServerEndpoint<List<_i8.ImportBatchRecord>>(
        'import',
        'pullBatches',
        {'lastSync': lastSync},
      );

  _i2.Future<void> logDuplicate(_i9.DuplicateRegistryRecord record) =>
      caller.callServerEndpoint<void>(
        'import',
        'logDuplicate',
        {'record': record},
      );

  _i2.Future<List<_i9.DuplicateRegistryRecord>> pullDuplicates(
          DateTime? lastSync) =>
      caller.callServerEndpoint<List<_i9.DuplicateRegistryRecord>>(
        'import',
        'pullDuplicates',
        {'lastSync': lastSync},
      );
}

/// Endpoint responsible for synchronizing photo metadata and binaries between
/// the mobile client and the Serverpod backend.
/// {@category Endpoint}
class EndpointPhoto extends _i1.EndpointRef {
  EndpointPhoto(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'photo';

  /// Uploads or updates a photo record, optionally persisting the binary payload.
  _i2.Future<_i10.PhotoRecord> upsertPhoto(_i11.PhotoPayload payload) =>
      caller.callServerEndpoint<_i10.PhotoRecord>(
        'photo',
        'upsertPhoto',
        {'payload': payload},
      );

  /// Returns photo payloads that have changed since [lastSync], including binaries.
  _i2.Future<List<_i11.PhotoPayload>> pullPhotos(DateTime? lastSync) =>
      caller.callServerEndpoint<List<_i11.PhotoPayload>>(
        'photo',
        'pullPhotos',
        {'lastSync': lastSync},
      );

  /// Downloads a single photo payload.
  _i2.Future<_i11.PhotoPayload?> downloadPhoto(String clientId) =>
      caller.callServerEndpoint<_i11.PhotoPayload?>(
        'photo',
        'downloadPhoto',
        {'clientId': clientId},
      );
}

/// {@category Endpoint}
class EndpointSite extends _i1.EndpointRef {
  EndpointSite(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'site';

  _i2.Future<_i12.MainSiteRecord> upsertMainSite(_i12.MainSiteRecord record) =>
      caller.callServerEndpoint<_i12.MainSiteRecord>(
        'site',
        'upsertMainSite',
        {'record': record},
      );

  _i2.Future<_i13.SubSiteRecord> upsertSubSite(_i13.SubSiteRecord record) =>
      caller.callServerEndpoint<_i13.SubSiteRecord>(
        'site',
        'upsertSubSite',
        {'record': record},
      );

  _i2.Future<List<_i12.MainSiteRecord>> pullMainSites(DateTime? lastSync) =>
      caller.callServerEndpoint<List<_i12.MainSiteRecord>>(
        'site',
        'pullMainSites',
        {'lastSync': lastSync},
      );

  _i2.Future<List<_i13.SubSiteRecord>> pullSubSites(DateTime? lastSync) =>
      caller.callServerEndpoint<List<_i13.SubSiteRecord>>(
        'site',
        'pullSubSites',
        {'lastSync': lastSync},
      );
}

class Modules {
  Modules(Client client) {
    auth = _i3.Caller(client);
  }

  late final _i3.Caller auth;
}

class Client extends _i1.ServerpodClientShared {
  Client(
    String host, {
    dynamic securityContext,
    _i1.AuthenticationKeyManager? authenticationKeyManager,
    Duration? streamingConnectionTimeout,
    Duration? connectionTimeout,
    Function(
      _i1.MethodCallContext,
      Object,
      StackTrace,
    )? onFailedCall,
    Function(_i1.MethodCallContext)? onSucceededCall,
    bool? disconnectStreamsOnLostInternetConnection,
  }) : super(
          host,
          _i14.Protocol(),
          securityContext: securityContext,
          authenticationKeyManager: authenticationKeyManager,
          streamingConnectionTimeout: streamingConnectionTimeout,
          connectionTimeout: connectionTimeout,
          onFailedCall: onFailedCall,
          onSucceededCall: onSucceededCall,
          disconnectStreamsOnLostInternetConnection:
              disconnectStreamsOnLostInternetConnection,
        ) {
    account = EndpointAccount(this);
    client = EndpointClient(this);
    equipment = EndpointEquipment(this);
    folder = EndpointFolder(this);
    import = EndpointImport(this);
    photo = EndpointPhoto(this);
    site = EndpointSite(this);
    modules = Modules(this);
  }

  late final EndpointAccount account;

  late final EndpointClient client;

  late final EndpointEquipment equipment;

  late final EndpointFolder folder;

  late final EndpointImport import;

  late final EndpointPhoto photo;

  late final EndpointSite site;

  late final Modules modules;

  @override
  Map<String, _i1.EndpointRef> get endpointRefLookup => {
        'account': account,
        'client': client,
        'equipment': equipment,
        'folder': folder,
        'import': import,
        'photo': photo,
        'site': site,
      };

  @override
  Map<String, _i1.ModuleEndpointCaller> get moduleLookup =>
      {'auth': modules.auth};
}
