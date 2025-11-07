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

abstract class DuplicateRegistryRecord implements _i1.SerializableModel {
  DuplicateRegistryRecord._({
    this.id,
    required this.duplicateId,
    required this.photoId,
    this.sourceAssetId,
    this.fingerprintSha1,
    required this.importedAt,
  });

  factory DuplicateRegistryRecord({
    int? id,
    required String duplicateId,
    required String photoId,
    String? sourceAssetId,
    String? fingerprintSha1,
    required DateTime importedAt,
  }) = _DuplicateRegistryRecordImpl;

  factory DuplicateRegistryRecord.fromJson(
      Map<String, dynamic> jsonSerialization) {
    return DuplicateRegistryRecord(
      id: jsonSerialization['id'] as int?,
      duplicateId: jsonSerialization['duplicateId'] as String,
      photoId: jsonSerialization['photoId'] as String,
      sourceAssetId: jsonSerialization['sourceAssetId'] as String?,
      fingerprintSha1: jsonSerialization['fingerprintSha1'] as String?,
      importedAt:
          _i1.DateTimeJsonExtension.fromJson(jsonSerialization['importedAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String duplicateId;

  String photoId;

  String? sourceAssetId;

  String? fingerprintSha1;

  DateTime importedAt;

  /// Returns a shallow copy of this [DuplicateRegistryRecord]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  DuplicateRegistryRecord copyWith({
    int? id,
    String? duplicateId,
    String? photoId,
    String? sourceAssetId,
    String? fingerprintSha1,
    DateTime? importedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'duplicateId': duplicateId,
      'photoId': photoId,
      if (sourceAssetId != null) 'sourceAssetId': sourceAssetId,
      if (fingerprintSha1 != null) 'fingerprintSha1': fingerprintSha1,
      'importedAt': importedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _DuplicateRegistryRecordImpl extends DuplicateRegistryRecord {
  _DuplicateRegistryRecordImpl({
    int? id,
    required String duplicateId,
    required String photoId,
    String? sourceAssetId,
    String? fingerprintSha1,
    required DateTime importedAt,
  }) : super._(
          id: id,
          duplicateId: duplicateId,
          photoId: photoId,
          sourceAssetId: sourceAssetId,
          fingerprintSha1: fingerprintSha1,
          importedAt: importedAt,
        );

  /// Returns a shallow copy of this [DuplicateRegistryRecord]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  DuplicateRegistryRecord copyWith({
    Object? id = _Undefined,
    String? duplicateId,
    String? photoId,
    Object? sourceAssetId = _Undefined,
    Object? fingerprintSha1 = _Undefined,
    DateTime? importedAt,
  }) {
    return DuplicateRegistryRecord(
      id: id is int? ? id : this.id,
      duplicateId: duplicateId ?? this.duplicateId,
      photoId: photoId ?? this.photoId,
      sourceAssetId:
          sourceAssetId is String? ? sourceAssetId : this.sourceAssetId,
      fingerprintSha1:
          fingerprintSha1 is String? ? fingerprintSha1 : this.fingerprintSha1,
      importedAt: importedAt ?? this.importedAt,
    );
  }
}
