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
import 'package:sitepictures_server_client/src/protocol/user.dart' as _i3;
import 'package:sitepictures_server_client/src/protocol/company.dart' as _i4;
import 'package:sitepictures_server_client/src/protocol/equipment.dart' as _i5;
import 'package:sitepictures_server_client/src/protocol/photo_folder.dart'
    as _i6;
import 'package:sitepictures_server_client/src/protocol/folder_photo.dart'
    as _i7;
import 'package:sitepictures_server_client/src/protocol/photo.dart' as _i8;
import 'dart:typed_data' as _i9;
import 'package:sitepictures_server_client/src/protocol/main_site.dart' as _i10;
import 'package:sitepictures_server_client/src/protocol/sub_site.dart' as _i11;
import 'protocol.dart' as _i12;

/// Authentication endpoint for user login and token management
/// {@category Endpoint}
class EndpointAuth extends _i1.EndpointRef {
  EndpointAuth(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'auth';

  /// Login with email and basic auth
  /// Returns user object if successful
  _i2.Future<_i3.User?> login(
    String email,
    String password,
  ) =>
      caller.callServerEndpoint<_i3.User?>(
        'auth',
        'login',
        {
          'email': email,
          'password': password,
        },
      );

  /// Register a new user
  _i2.Future<_i3.User> register(
    String email,
    String name,
    String password,
    String role,
  ) =>
      caller.callServerEndpoint<_i3.User>(
        'auth',
        'register',
        {
          'email': email,
          'name': name,
          'password': password,
          'role': role,
        },
      );

  /// Get current user by UUID
  _i2.Future<_i3.User?> getCurrentUser(String uuid) =>
      caller.callServerEndpoint<_i3.User?>(
        'auth',
        'getCurrentUser',
        {'uuid': uuid},
      );

  /// Logout (client-side token removal)
  _i2.Future<void> logout() => caller.callServerEndpoint<void>(
        'auth',
        'logout',
        {},
      );
}

/// Company (Client) CRUD endpoint
/// {@category Endpoint}
class EndpointCompany extends _i1.EndpointRef {
  EndpointCompany(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'company';

  /// Get all active companies (excluding system companies by default)
  _i2.Future<List<_i4.Company>> getAllCompanies(
          {required bool includeSystem}) =>
      caller.callServerEndpoint<List<_i4.Company>>(
        'company',
        'getAllCompanies',
        {'includeSystem': includeSystem},
      );

  /// Get company by UUID
  _i2.Future<_i4.Company?> getCompanyByUuid(String uuid) =>
      caller.callServerEndpoint<_i4.Company?>(
        'company',
        'getCompanyByUuid',
        {'uuid': uuid},
      );

  /// Create new company
  _i2.Future<_i4.Company> createCompany(
    String name,
    String? description,
    String createdBy,
  ) =>
      caller.callServerEndpoint<_i4.Company>(
        'company',
        'createCompany',
        {
          'name': name,
          'description': description,
          'createdBy': createdBy,
        },
      );

  /// Update company
  _i2.Future<_i4.Company> updateCompany(
    String uuid,
    String? name,
    String? description,
  ) =>
      caller.callServerEndpoint<_i4.Company>(
        'company',
        'updateCompany',
        {
          'uuid': uuid,
          'name': name,
          'description': description,
        },
      );

  /// Soft delete company
  _i2.Future<void> deleteCompany(String uuid) =>
      caller.callServerEndpoint<void>(
        'company',
        'deleteCompany',
        {'uuid': uuid},
      );
}

/// Equipment CRUD endpoint with flexible hierarchy support
/// {@category Endpoint}
class EndpointEquipment extends _i1.EndpointRef {
  EndpointEquipment(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'equipment';

  /// Get all equipment for a parent (client, main site, or sub site)
  _i2.Future<List<_i5.Equipment>> getEquipmentByParent({
    String? clientId,
    String? mainSiteId,
    String? subSiteId,
  }) =>
      caller.callServerEndpoint<List<_i5.Equipment>>(
        'equipment',
        'getEquipmentByParent',
        {
          'clientId': clientId,
          'mainSiteId': mainSiteId,
          'subSiteId': subSiteId,
        },
      );

  /// Get equipment by UUID
  _i2.Future<_i5.Equipment?> getEquipmentByUuid(String uuid) =>
      caller.callServerEndpoint<_i5.Equipment?>(
        'equipment',
        'getEquipmentByUuid',
        {'uuid': uuid},
      );

  /// Create new equipment
  _i2.Future<_i5.Equipment> createEquipment(
    String name,
    String? serialNumber,
    String? manufacturer,
    String? model,
    String createdBy, {
    String? clientId,
    String? mainSiteId,
    String? subSiteId,
  }) =>
      caller.callServerEndpoint<_i5.Equipment>(
        'equipment',
        'createEquipment',
        {
          'name': name,
          'serialNumber': serialNumber,
          'manufacturer': manufacturer,
          'model': model,
          'createdBy': createdBy,
          'clientId': clientId,
          'mainSiteId': mainSiteId,
          'subSiteId': subSiteId,
        },
      );

  /// Update equipment
  _i2.Future<_i5.Equipment> updateEquipment(
    String uuid,
    String? name,
    String? serialNumber,
    String? manufacturer,
    String? model,
  ) =>
      caller.callServerEndpoint<_i5.Equipment>(
        'equipment',
        'updateEquipment',
        {
          'uuid': uuid,
          'name': name,
          'serialNumber': serialNumber,
          'manufacturer': manufacturer,
          'model': model,
        },
      );

  /// Soft delete equipment
  _i2.Future<void> deleteEquipment(String uuid) =>
      caller.callServerEndpoint<void>(
        'equipment',
        'deleteEquipment',
        {'uuid': uuid},
      );
}

/// Photo Folder management endpoint
/// {@category Endpoint}
class EndpointFolder extends _i1.EndpointRef {
  EndpointFolder(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'folder';

  /// Get all folders for equipment
  _i2.Future<List<_i6.PhotoFolder>> getFoldersByEquipment(String equipmentId) =>
      caller.callServerEndpoint<List<_i6.PhotoFolder>>(
        'folder',
        'getFoldersByEquipment',
        {'equipmentId': equipmentId},
      );

  /// Get folder by UUID
  _i2.Future<_i6.PhotoFolder?> getFolderByUuid(String uuid) =>
      caller.callServerEndpoint<_i6.PhotoFolder?>(
        'folder',
        'getFolderByUuid',
        {'uuid': uuid},
      );

  /// Create new folder
  _i2.Future<_i6.PhotoFolder> createFolder(
    String equipmentId,
    String name,
    String workOrder,
    String createdBy,
  ) =>
      caller.callServerEndpoint<_i6.PhotoFolder>(
        'folder',
        'createFolder',
        {
          'equipmentId': equipmentId,
          'name': name,
          'workOrder': workOrder,
          'createdBy': createdBy,
        },
      );

  /// Add photo to folder
  _i2.Future<_i7.FolderPhoto> addPhotoToFolder(
    String folderId,
    String photoId,
    String beforeAfter,
  ) =>
      caller.callServerEndpoint<_i7.FolderPhoto>(
        'folder',
        'addPhotoToFolder',
        {
          'folderId': folderId,
          'photoId': photoId,
          'beforeAfter': beforeAfter,
        },
      );

  /// Get photos in folder
  _i2.Future<List<_i7.FolderPhoto>> getPhotosInFolder(
    String folderId, {
    String? beforeAfterFilter,
  }) =>
      caller.callServerEndpoint<List<_i7.FolderPhoto>>(
        'folder',
        'getPhotosInFolder',
        {
          'folderId': folderId,
          'beforeAfterFilter': beforeAfterFilter,
        },
      );

  /// Remove photo from folder
  _i2.Future<void> removePhotoFromFolder(
    String folderId,
    String photoId,
  ) =>
      caller.callServerEndpoint<void>(
        'folder',
        'removePhotoFromFolder',
        {
          'folderId': folderId,
          'photoId': photoId,
        },
      );

  /// Soft delete folder
  _i2.Future<void> deleteFolder(String uuid) => caller.callServerEndpoint<void>(
        'folder',
        'deleteFolder',
        {'uuid': uuid},
      );
}

/// Photo endpoint with file upload support using Serverpod storage
/// {@category Endpoint}
class EndpointPhoto extends _i1.EndpointRef {
  EndpointPhoto(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'photo';

  /// Get all photos for equipment
  _i2.Future<List<_i8.Photo>> getPhotosByEquipment(
    String equipmentId, {
    required int limit,
    required int offset,
  }) =>
      caller.callServerEndpoint<List<_i8.Photo>>(
        'photo',
        'getPhotosByEquipment',
        {
          'equipmentId': equipmentId,
          'limit': limit,
          'offset': offset,
        },
      );

  /// Get photo by UUID
  _i2.Future<_i8.Photo?> getPhotoByUuid(String uuid) =>
      caller.callServerEndpoint<_i8.Photo?>(
        'photo',
        'getPhotoByUuid',
        {'uuid': uuid},
      );

  /// Create photo metadata (file upload handled separately via Serverpod file upload)
  _i2.Future<_i8.Photo> createPhoto(
    String equipmentId,
    String filePath,
    double latitude,
    double longitude,
    DateTime timestamp,
    String capturedBy,
    int fileSize, {
    String? thumbnailPath,
    String? sourceAssetId,
    String? fingerprintSha1,
    String? importBatchId,
    required String importSource,
  }) =>
      caller.callServerEndpoint<_i8.Photo>(
        'photo',
        'createPhoto',
        {
          'equipmentId': equipmentId,
          'filePath': filePath,
          'latitude': latitude,
          'longitude': longitude,
          'timestamp': timestamp,
          'capturedBy': capturedBy,
          'fileSize': fileSize,
          'thumbnailPath': thumbnailPath,
          'sourceAssetId': sourceAssetId,
          'fingerprintSha1': fingerprintSha1,
          'importBatchId': importBatchId,
          'importSource': importSource,
        },
      );

  /// Upload photo file and create metadata
  /// This combines file upload with metadata creation
  _i2.Future<_i8.Photo> uploadPhoto(
    String equipmentId,
    _i9.ByteData fileData,
    String fileName,
    double latitude,
    double longitude,
    DateTime timestamp,
    String capturedBy,
    String importSource,
  ) =>
      caller.callServerEndpoint<_i8.Photo>(
        'photo',
        'uploadPhoto',
        {
          'equipmentId': equipmentId,
          'fileData': fileData,
          'fileName': fileName,
          'latitude': latitude,
          'longitude': longitude,
          'timestamp': timestamp,
          'capturedBy': capturedBy,
          'importSource': importSource,
        },
      );

  /// Get unsynced photos (for sync operations from client to server)
  _i2.Future<List<_i8.Photo>> getUnsyncedPhotos() =>
      caller.callServerEndpoint<List<_i8.Photo>>(
        'photo',
        'getUnsyncedPhotos',
        {},
      );

  /// Mark photo as synced
  _i2.Future<void> markPhotoAsSynced(String uuid) =>
      caller.callServerEndpoint<void>(
        'photo',
        'markPhotoAsSynced',
        {'uuid': uuid},
      );

  /// Delete photo (hard delete from storage and database)
  _i2.Future<void> deletePhoto(String uuid) => caller.callServerEndpoint<void>(
        'photo',
        'deletePhoto',
        {'uuid': uuid},
      );

  /// Get photo file URL (for downloading)
  _i2.Future<String?> getPhotoUrl(String uuid) =>
      caller.callServerEndpoint<String?>(
        'photo',
        'getPhotoUrl',
        {'uuid': uuid},
      );
}

/// Site endpoint for MainSite and SubSite management
/// {@category Endpoint}
class EndpointSite extends _i1.EndpointRef {
  EndpointSite(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'site';

  /// Get all main sites for a company
  _i2.Future<List<_i10.MainSite>> getMainSitesByCompany(String clientId) =>
      caller.callServerEndpoint<List<_i10.MainSite>>(
        'site',
        'getMainSitesByCompany',
        {'clientId': clientId},
      );

  /// Get main site by UUID
  _i2.Future<_i10.MainSite?> getMainSiteByUuid(String uuid) =>
      caller.callServerEndpoint<_i10.MainSite?>(
        'site',
        'getMainSiteByUuid',
        {'uuid': uuid},
      );

  /// Create new main site
  _i2.Future<_i10.MainSite> createMainSite(
    String clientId,
    String name,
    String? address,
    double? latitude,
    double? longitude,
    String createdBy,
  ) =>
      caller.callServerEndpoint<_i10.MainSite>(
        'site',
        'createMainSite',
        {
          'clientId': clientId,
          'name': name,
          'address': address,
          'latitude': latitude,
          'longitude': longitude,
          'createdBy': createdBy,
        },
      );

  /// Update main site
  _i2.Future<_i10.MainSite> updateMainSite(
    String uuid,
    String? name,
    String? address,
    double? latitude,
    double? longitude,
  ) =>
      caller.callServerEndpoint<_i10.MainSite>(
        'site',
        'updateMainSite',
        {
          'uuid': uuid,
          'name': name,
          'address': address,
          'latitude': latitude,
          'longitude': longitude,
        },
      );

  /// Soft delete main site
  _i2.Future<void> deleteMainSite(String uuid) =>
      caller.callServerEndpoint<void>(
        'site',
        'deleteMainSite',
        {'uuid': uuid},
      );

  /// Get all sub sites for a parent (client, main site, or parent subsite)
  _i2.Future<List<_i11.SubSite>> getSubSitesByParent({
    String? clientId,
    String? mainSiteId,
    String? parentSubSiteId,
  }) =>
      caller.callServerEndpoint<List<_i11.SubSite>>(
        'site',
        'getSubSitesByParent',
        {
          'clientId': clientId,
          'mainSiteId': mainSiteId,
          'parentSubSiteId': parentSubSiteId,
        },
      );

  /// Get sub site by UUID
  _i2.Future<_i11.SubSite?> getSubSiteByUuid(String uuid) =>
      caller.callServerEndpoint<_i11.SubSite?>(
        'site',
        'getSubSiteByUuid',
        {'uuid': uuid},
      );

  /// Create new sub site
  _i2.Future<_i11.SubSite> createSubSite(
    String name,
    String? description,
    String createdBy, {
    String? clientId,
    String? mainSiteId,
    String? parentSubSiteId,
  }) =>
      caller.callServerEndpoint<_i11.SubSite>(
        'site',
        'createSubSite',
        {
          'name': name,
          'description': description,
          'createdBy': createdBy,
          'clientId': clientId,
          'mainSiteId': mainSiteId,
          'parentSubSiteId': parentSubSiteId,
        },
      );

  /// Update sub site
  _i2.Future<_i11.SubSite> updateSubSite(
    String uuid,
    String? name,
    String? description,
  ) =>
      caller.callServerEndpoint<_i11.SubSite>(
        'site',
        'updateSubSite',
        {
          'uuid': uuid,
          'name': name,
          'description': description,
        },
      );

  /// Soft delete sub site
  _i2.Future<void> deleteSubSite(String uuid) =>
      caller.callServerEndpoint<void>(
        'site',
        'deleteSubSite',
        {'uuid': uuid},
      );
}

/// Sync endpoint for bidirectional synchronization with conflict resolution
/// {@category Endpoint}
class EndpointSync extends _i1.EndpointRef {
  EndpointSync(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'sync';

  /// Get changes since last sync timestamp
  /// Returns all entities modified after the given timestamp
  _i2.Future<Map<String, dynamic>> getChangesSince(DateTime since) =>
      caller.callServerEndpoint<Map<String, dynamic>>(
        'sync',
        'getChangesSince',
        {'since': since},
      );

  /// Push local changes to server
  /// Handles conflict resolution with last-write-wins strategy
  _i2.Future<Map<String, dynamic>> pushChanges(
          List<Map<String, dynamic>> changes) =>
      caller.callServerEndpoint<Map<String, dynamic>>(
        'sync',
        'pushChanges',
        {'changes': changes},
      );
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
          _i12.Protocol(),
          securityContext: securityContext,
          authenticationKeyManager: authenticationKeyManager,
          streamingConnectionTimeout: streamingConnectionTimeout,
          connectionTimeout: connectionTimeout,
          onFailedCall: onFailedCall,
          onSucceededCall: onSucceededCall,
          disconnectStreamsOnLostInternetConnection:
              disconnectStreamsOnLostInternetConnection,
        ) {
    auth = EndpointAuth(this);
    company = EndpointCompany(this);
    equipment = EndpointEquipment(this);
    folder = EndpointFolder(this);
    photo = EndpointPhoto(this);
    site = EndpointSite(this);
    sync = EndpointSync(this);
  }

  late final EndpointAuth auth;

  late final EndpointCompany company;

  late final EndpointEquipment equipment;

  late final EndpointFolder folder;

  late final EndpointPhoto photo;

  late final EndpointSite site;

  late final EndpointSync sync;

  @override
  Map<String, _i1.EndpointRef> get endpointRefLookup => {
        'auth': auth,
        'company': company,
        'equipment': equipment,
        'folder': folder,
        'photo': photo,
        'site': site,
        'sync': sync,
      };

  @override
  Map<String, _i1.ModuleEndpointCaller> get moduleLookup => {};
}
