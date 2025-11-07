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

/// Canonical record for a photo stored in Postgres.
abstract class PhotoRecord implements _i1.SerializableModel {
  PhotoRecord._({
    this.id,
    required this.clientId,
    required this.equipmentId,
    required this.capturedBy,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    required this.fileSize,
    required this.importSource,
    this.fingerprintSha1,
    this.importBatchId,
    this.remoteUrl,
    this.storagePath,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PhotoRecord({
    int? id,
    required String clientId,
    required String equipmentId,
    required String capturedBy,
    required double latitude,
    required double longitude,
    required DateTime timestamp,
    required int fileSize,
    required String importSource,
    String? fingerprintSha1,
    String? importBatchId,
    String? remoteUrl,
    String? storagePath,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _PhotoRecordImpl;

  factory PhotoRecord.fromJson(Map<String, dynamic> jsonSerialization) {
    return PhotoRecord(
      id: jsonSerialization['id'] as int?,
      clientId: jsonSerialization['clientId'] as String,
      equipmentId: jsonSerialization['equipmentId'] as String,
      capturedBy: jsonSerialization['capturedBy'] as String,
      latitude: (jsonSerialization['latitude'] as num).toDouble(),
      longitude: (jsonSerialization['longitude'] as num).toDouble(),
      timestamp:
          _i1.DateTimeJsonExtension.fromJson(jsonSerialization['timestamp']),
      fileSize: jsonSerialization['fileSize'] as int,
      importSource: jsonSerialization['importSource'] as String,
      fingerprintSha1: jsonSerialization['fingerprintSha1'] as String?,
      importBatchId: jsonSerialization['importBatchId'] as String?,
      remoteUrl: jsonSerialization['remoteUrl'] as String?,
      storagePath: jsonSerialization['storagePath'] as String?,
      createdAt:
          _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt:
          _i1.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String clientId;

  String equipmentId;

  String capturedBy;

  double latitude;

  double longitude;

  DateTime timestamp;

  int fileSize;

  String importSource;

  String? fingerprintSha1;

  String? importBatchId;

  String? remoteUrl;

  String? storagePath;

  DateTime createdAt;

  DateTime updatedAt;

  /// Returns a shallow copy of this [PhotoRecord]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  PhotoRecord copyWith({
    int? id,
    String? clientId,
    String? equipmentId,
    String? capturedBy,
    double? latitude,
    double? longitude,
    DateTime? timestamp,
    int? fileSize,
    String? importSource,
    String? fingerprintSha1,
    String? importBatchId,
    String? remoteUrl,
    String? storagePath,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'clientId': clientId,
      'equipmentId': equipmentId,
      'capturedBy': capturedBy,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.toJson(),
      'fileSize': fileSize,
      'importSource': importSource,
      if (fingerprintSha1 != null) 'fingerprintSha1': fingerprintSha1,
      if (importBatchId != null) 'importBatchId': importBatchId,
      if (remoteUrl != null) 'remoteUrl': remoteUrl,
      if (storagePath != null) 'storagePath': storagePath,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PhotoRecordImpl extends PhotoRecord {
  _PhotoRecordImpl({
    int? id,
    required String clientId,
    required String equipmentId,
    required String capturedBy,
    required double latitude,
    required double longitude,
    required DateTime timestamp,
    required int fileSize,
    required String importSource,
    String? fingerprintSha1,
    String? importBatchId,
    String? remoteUrl,
    String? storagePath,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super._(
          id: id,
          clientId: clientId,
          equipmentId: equipmentId,
          capturedBy: capturedBy,
          latitude: latitude,
          longitude: longitude,
          timestamp: timestamp,
          fileSize: fileSize,
          importSource: importSource,
          fingerprintSha1: fingerprintSha1,
          importBatchId: importBatchId,
          remoteUrl: remoteUrl,
          storagePath: storagePath,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  /// Returns a shallow copy of this [PhotoRecord]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  PhotoRecord copyWith({
    Object? id = _Undefined,
    String? clientId,
    String? equipmentId,
    String? capturedBy,
    double? latitude,
    double? longitude,
    DateTime? timestamp,
    int? fileSize,
    String? importSource,
    Object? fingerprintSha1 = _Undefined,
    Object? importBatchId = _Undefined,
    Object? remoteUrl = _Undefined,
    Object? storagePath = _Undefined,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PhotoRecord(
      id: id is int? ? id : this.id,
      clientId: clientId ?? this.clientId,
      equipmentId: equipmentId ?? this.equipmentId,
      capturedBy: capturedBy ?? this.capturedBy,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      timestamp: timestamp ?? this.timestamp,
      fileSize: fileSize ?? this.fileSize,
      importSource: importSource ?? this.importSource,
      fingerprintSha1:
          fingerprintSha1 is String? ? fingerprintSha1 : this.fingerprintSha1,
      importBatchId:
          importBatchId is String? ? importBatchId : this.importBatchId,
      remoteUrl: remoteUrl is String? ? remoteUrl : this.remoteUrl,
      storagePath: storagePath is String? ? storagePath : this.storagePath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
