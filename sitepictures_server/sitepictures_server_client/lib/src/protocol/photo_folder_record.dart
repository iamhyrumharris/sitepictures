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

abstract class PhotoFolderRecord implements _i1.SerializableModel {
  PhotoFolderRecord._({
    this.id,
    required this.folderId,
    required this.equipmentId,
    required this.name,
    required this.workOrder,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
  });

  factory PhotoFolderRecord({
    int? id,
    required String folderId,
    required String equipmentId,
    required String name,
    required String workOrder,
    required String createdBy,
    required DateTime createdAt,
    required DateTime updatedAt,
    required bool isDeleted,
  }) = _PhotoFolderRecordImpl;

  factory PhotoFolderRecord.fromJson(Map<String, dynamic> jsonSerialization) {
    return PhotoFolderRecord(
      id: jsonSerialization['id'] as int?,
      folderId: jsonSerialization['folderId'] as String,
      equipmentId: jsonSerialization['equipmentId'] as String,
      name: jsonSerialization['name'] as String,
      workOrder: jsonSerialization['workOrder'] as String,
      createdBy: jsonSerialization['createdBy'] as String,
      createdAt:
          _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt:
          _i1.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
      isDeleted: jsonSerialization['isDeleted'] as bool,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String folderId;

  String equipmentId;

  String name;

  String workOrder;

  String createdBy;

  DateTime createdAt;

  DateTime updatedAt;

  bool isDeleted;

  /// Returns a shallow copy of this [PhotoFolderRecord]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  PhotoFolderRecord copyWith({
    int? id,
    String? folderId,
    String? equipmentId,
    String? name,
    String? workOrder,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'folderId': folderId,
      'equipmentId': equipmentId,
      'name': name,
      'workOrder': workOrder,
      'createdBy': createdBy,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
      'isDeleted': isDeleted,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PhotoFolderRecordImpl extends PhotoFolderRecord {
  _PhotoFolderRecordImpl({
    int? id,
    required String folderId,
    required String equipmentId,
    required String name,
    required String workOrder,
    required String createdBy,
    required DateTime createdAt,
    required DateTime updatedAt,
    required bool isDeleted,
  }) : super._(
          id: id,
          folderId: folderId,
          equipmentId: equipmentId,
          name: name,
          workOrder: workOrder,
          createdBy: createdBy,
          createdAt: createdAt,
          updatedAt: updatedAt,
          isDeleted: isDeleted,
        );

  /// Returns a shallow copy of this [PhotoFolderRecord]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  PhotoFolderRecord copyWith({
    Object? id = _Undefined,
    String? folderId,
    String? equipmentId,
    String? name,
    String? workOrder,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
  }) {
    return PhotoFolderRecord(
      id: id is int? ? id : this.id,
      folderId: folderId ?? this.folderId,
      equipmentId: equipmentId ?? this.equipmentId,
      name: name ?? this.name,
      workOrder: workOrder ?? this.workOrder,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
