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

/// Photo model with file storage and sync metadata
abstract class Photo implements _i1.SerializableModel {
  Photo._({
    this.id,
    required this.uuid,
    required this.equipmentId,
    required this.filePath,
    this.thumbnailPath,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    required this.capturedBy,
    required this.fileSize,
    required this.isSynced,
    this.syncedAt,
    this.remoteUrl,
    this.sourceAssetId,
    this.fingerprintSha1,
    this.importBatchId,
    required this.importSource,
    required this.createdAt,
  });

  factory Photo({
    int? id,
    required String uuid,
    required String equipmentId,
    required String filePath,
    String? thumbnailPath,
    required double latitude,
    required double longitude,
    required DateTime timestamp,
    required String capturedBy,
    required int fileSize,
    required bool isSynced,
    DateTime? syncedAt,
    String? remoteUrl,
    String? sourceAssetId,
    String? fingerprintSha1,
    String? importBatchId,
    required String importSource,
    required DateTime createdAt,
  }) = _PhotoImpl;

  factory Photo.fromJson(Map<String, dynamic> jsonSerialization) {
    return Photo(
      id: jsonSerialization['id'] as int?,
      uuid: jsonSerialization['uuid'] as String,
      equipmentId: jsonSerialization['equipmentId'] as String,
      filePath: jsonSerialization['filePath'] as String,
      thumbnailPath: jsonSerialization['thumbnailPath'] as String?,
      latitude: (jsonSerialization['latitude'] as num).toDouble(),
      longitude: (jsonSerialization['longitude'] as num).toDouble(),
      timestamp:
          _i1.DateTimeJsonExtension.fromJson(jsonSerialization['timestamp']),
      capturedBy: jsonSerialization['capturedBy'] as String,
      fileSize: jsonSerialization['fileSize'] as int,
      isSynced: jsonSerialization['isSynced'] as bool,
      syncedAt: jsonSerialization['syncedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['syncedAt']),
      remoteUrl: jsonSerialization['remoteUrl'] as String?,
      sourceAssetId: jsonSerialization['sourceAssetId'] as String?,
      fingerprintSha1: jsonSerialization['fingerprintSha1'] as String?,
      importBatchId: jsonSerialization['importBatchId'] as String?,
      importSource: jsonSerialization['importSource'] as String,
      createdAt:
          _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  /// Auto-increment ID
  int? id;

  /// UUID for compatibility with Flutter app
  String uuid;

  /// Equipment ID this photo belongs to
  String equipmentId;

  /// File path or storage key
  String filePath;

  /// Thumbnail path or storage key
  String? thumbnailPath;

  /// Latitude coordinate
  double latitude;

  /// Longitude coordinate
  double longitude;

  /// Photo timestamp
  DateTime timestamp;

  /// User who captured this photo
  String capturedBy;

  /// File size in bytes
  int fileSize;

  /// Sync status flag
  bool isSynced;

  /// When the photo was synced
  DateTime? syncedAt;

  /// Remote URL (for downloaded photos)
  String? remoteUrl;

  /// Source asset ID (for gallery imports)
  String? sourceAssetId;

  /// SHA1 fingerprint for deduplication
  String? fingerprintSha1;

  /// Import batch ID (for gallery imports)
  String? importBatchId;

  /// Import source (camera, gallery)
  String importSource;

  /// When the photo was created
  DateTime createdAt;

  /// Returns a shallow copy of this [Photo]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Photo copyWith({
    int? id,
    String? uuid,
    String? equipmentId,
    String? filePath,
    String? thumbnailPath,
    double? latitude,
    double? longitude,
    DateTime? timestamp,
    String? capturedBy,
    int? fileSize,
    bool? isSynced,
    DateTime? syncedAt,
    String? remoteUrl,
    String? sourceAssetId,
    String? fingerprintSha1,
    String? importBatchId,
    String? importSource,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'uuid': uuid,
      'equipmentId': equipmentId,
      'filePath': filePath,
      if (thumbnailPath != null) 'thumbnailPath': thumbnailPath,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.toJson(),
      'capturedBy': capturedBy,
      'fileSize': fileSize,
      'isSynced': isSynced,
      if (syncedAt != null) 'syncedAt': syncedAt?.toJson(),
      if (remoteUrl != null) 'remoteUrl': remoteUrl,
      if (sourceAssetId != null) 'sourceAssetId': sourceAssetId,
      if (fingerprintSha1 != null) 'fingerprintSha1': fingerprintSha1,
      if (importBatchId != null) 'importBatchId': importBatchId,
      'importSource': importSource,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PhotoImpl extends Photo {
  _PhotoImpl({
    int? id,
    required String uuid,
    required String equipmentId,
    required String filePath,
    String? thumbnailPath,
    required double latitude,
    required double longitude,
    required DateTime timestamp,
    required String capturedBy,
    required int fileSize,
    required bool isSynced,
    DateTime? syncedAt,
    String? remoteUrl,
    String? sourceAssetId,
    String? fingerprintSha1,
    String? importBatchId,
    required String importSource,
    required DateTime createdAt,
  }) : super._(
          id: id,
          uuid: uuid,
          equipmentId: equipmentId,
          filePath: filePath,
          thumbnailPath: thumbnailPath,
          latitude: latitude,
          longitude: longitude,
          timestamp: timestamp,
          capturedBy: capturedBy,
          fileSize: fileSize,
          isSynced: isSynced,
          syncedAt: syncedAt,
          remoteUrl: remoteUrl,
          sourceAssetId: sourceAssetId,
          fingerprintSha1: fingerprintSha1,
          importBatchId: importBatchId,
          importSource: importSource,
          createdAt: createdAt,
        );

  /// Returns a shallow copy of this [Photo]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Photo copyWith({
    Object? id = _Undefined,
    String? uuid,
    String? equipmentId,
    String? filePath,
    Object? thumbnailPath = _Undefined,
    double? latitude,
    double? longitude,
    DateTime? timestamp,
    String? capturedBy,
    int? fileSize,
    bool? isSynced,
    Object? syncedAt = _Undefined,
    Object? remoteUrl = _Undefined,
    Object? sourceAssetId = _Undefined,
    Object? fingerprintSha1 = _Undefined,
    Object? importBatchId = _Undefined,
    String? importSource,
    DateTime? createdAt,
  }) {
    return Photo(
      id: id is int? ? id : this.id,
      uuid: uuid ?? this.uuid,
      equipmentId: equipmentId ?? this.equipmentId,
      filePath: filePath ?? this.filePath,
      thumbnailPath:
          thumbnailPath is String? ? thumbnailPath : this.thumbnailPath,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      timestamp: timestamp ?? this.timestamp,
      capturedBy: capturedBy ?? this.capturedBy,
      fileSize: fileSize ?? this.fileSize,
      isSynced: isSynced ?? this.isSynced,
      syncedAt: syncedAt is DateTime? ? syncedAt : this.syncedAt,
      remoteUrl: remoteUrl is String? ? remoteUrl : this.remoteUrl,
      sourceAssetId:
          sourceAssetId is String? ? sourceAssetId : this.sourceAssetId,
      fingerprintSha1:
          fingerprintSha1 is String? ? fingerprintSha1 : this.fingerprintSha1,
      importBatchId:
          importBatchId is String? ? importBatchId : this.importBatchId,
      importSource: importSource ?? this.importSource,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
