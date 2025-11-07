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

/// Photo folder model for organizing photos
abstract class PhotoFolder implements _i1.SerializableModel {
  PhotoFolder._({
    this.id,
    required this.uuid,
    required this.equipmentId,
    required this.name,
    required this.workOrder,
    required this.createdAt,
    required this.createdBy,
    required this.isDeleted,
  });

  factory PhotoFolder({
    int? id,
    required String uuid,
    required String equipmentId,
    required String name,
    required String workOrder,
    required DateTime createdAt,
    required String createdBy,
    required bool isDeleted,
  }) = _PhotoFolderImpl;

  factory PhotoFolder.fromJson(Map<String, dynamic> jsonSerialization) {
    return PhotoFolder(
      id: jsonSerialization['id'] as int?,
      uuid: jsonSerialization['uuid'] as String,
      equipmentId: jsonSerialization['equipmentId'] as String,
      name: jsonSerialization['name'] as String,
      workOrder: jsonSerialization['workOrder'] as String,
      createdAt:
          _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      createdBy: jsonSerialization['createdBy'] as String,
      isDeleted: jsonSerialization['isDeleted'] as bool,
    );
  }

  /// Auto-increment ID
  int? id;

  /// UUID for compatibility with Flutter app
  String uuid;

  /// Equipment ID this folder belongs to
  String equipmentId;

  /// Folder name
  String name;

  /// Work order number
  String workOrder;

  /// When the folder was created
  DateTime createdAt;

  /// User who created this folder
  String createdBy;

  /// Soft delete flag
  bool isDeleted;

  /// Returns a shallow copy of this [PhotoFolder]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  PhotoFolder copyWith({
    int? id,
    String? uuid,
    String? equipmentId,
    String? name,
    String? workOrder,
    DateTime? createdAt,
    String? createdBy,
    bool? isDeleted,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'uuid': uuid,
      'equipmentId': equipmentId,
      'name': name,
      'workOrder': workOrder,
      'createdAt': createdAt.toJson(),
      'createdBy': createdBy,
      'isDeleted': isDeleted,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PhotoFolderImpl extends PhotoFolder {
  _PhotoFolderImpl({
    int? id,
    required String uuid,
    required String equipmentId,
    required String name,
    required String workOrder,
    required DateTime createdAt,
    required String createdBy,
    required bool isDeleted,
  }) : super._(
          id: id,
          uuid: uuid,
          equipmentId: equipmentId,
          name: name,
          workOrder: workOrder,
          createdAt: createdAt,
          createdBy: createdBy,
          isDeleted: isDeleted,
        );

  /// Returns a shallow copy of this [PhotoFolder]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  PhotoFolder copyWith({
    Object? id = _Undefined,
    String? uuid,
    String? equipmentId,
    String? name,
    String? workOrder,
    DateTime? createdAt,
    String? createdBy,
    bool? isDeleted,
  }) {
    return PhotoFolder(
      id: id is int? ? id : this.id,
      uuid: uuid ?? this.uuid,
      equipmentId: equipmentId ?? this.equipmentId,
      name: name ?? this.name,
      workOrder: workOrder ?? this.workOrder,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
