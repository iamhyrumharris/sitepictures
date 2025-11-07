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

abstract class FolderPhotoRecord implements _i1.SerializableModel {
  FolderPhotoRecord._({
    this.id,
    required this.folderId,
    required this.photoId,
    required this.beforeAfter,
    required this.addedAt,
  });

  factory FolderPhotoRecord({
    int? id,
    required String folderId,
    required String photoId,
    required String beforeAfter,
    required DateTime addedAt,
  }) = _FolderPhotoRecordImpl;

  factory FolderPhotoRecord.fromJson(Map<String, dynamic> jsonSerialization) {
    return FolderPhotoRecord(
      id: jsonSerialization['id'] as int?,
      folderId: jsonSerialization['folderId'] as String,
      photoId: jsonSerialization['photoId'] as String,
      beforeAfter: jsonSerialization['beforeAfter'] as String,
      addedAt: _i1.DateTimeJsonExtension.fromJson(jsonSerialization['addedAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String folderId;

  String photoId;

  String beforeAfter;

  DateTime addedAt;

  /// Returns a shallow copy of this [FolderPhotoRecord]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  FolderPhotoRecord copyWith({
    int? id,
    String? folderId,
    String? photoId,
    String? beforeAfter,
    DateTime? addedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'folderId': folderId,
      'photoId': photoId,
      'beforeAfter': beforeAfter,
      'addedAt': addedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _FolderPhotoRecordImpl extends FolderPhotoRecord {
  _FolderPhotoRecordImpl({
    int? id,
    required String folderId,
    required String photoId,
    required String beforeAfter,
    required DateTime addedAt,
  }) : super._(
          id: id,
          folderId: folderId,
          photoId: photoId,
          beforeAfter: beforeAfter,
          addedAt: addedAt,
        );

  /// Returns a shallow copy of this [FolderPhotoRecord]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  FolderPhotoRecord copyWith({
    Object? id = _Undefined,
    String? folderId,
    String? photoId,
    String? beforeAfter,
    DateTime? addedAt,
  }) {
    return FolderPhotoRecord(
      id: id is int? ? id : this.id,
      folderId: folderId ?? this.folderId,
      photoId: photoId ?? this.photoId,
      beforeAfter: beforeAfter ?? this.beforeAfter,
      addedAt: addedAt ?? this.addedAt,
    );
  }
}
