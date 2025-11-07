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

abstract class SubSiteRecord implements _i1.SerializableModel {
  SubSiteRecord._({
    this.id,
    required this.subSiteId,
    this.clientId,
    this.mainSiteId,
    this.parentSubSiteId,
    required this.name,
    this.description,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
  });

  factory SubSiteRecord({
    int? id,
    required String subSiteId,
    String? clientId,
    String? mainSiteId,
    String? parentSubSiteId,
    required String name,
    String? description,
    required String createdBy,
    required DateTime createdAt,
    required DateTime updatedAt,
    required bool isActive,
  }) = _SubSiteRecordImpl;

  factory SubSiteRecord.fromJson(Map<String, dynamic> jsonSerialization) {
    return SubSiteRecord(
      id: jsonSerialization['id'] as int?,
      subSiteId: jsonSerialization['subSiteId'] as String,
      clientId: jsonSerialization['clientId'] as String?,
      mainSiteId: jsonSerialization['mainSiteId'] as String?,
      parentSubSiteId: jsonSerialization['parentSubSiteId'] as String?,
      name: jsonSerialization['name'] as String,
      description: jsonSerialization['description'] as String?,
      createdBy: jsonSerialization['createdBy'] as String,
      createdAt:
          _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt:
          _i1.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
      isActive: jsonSerialization['isActive'] as bool,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String subSiteId;

  String? clientId;

  String? mainSiteId;

  String? parentSubSiteId;

  String name;

  String? description;

  String createdBy;

  DateTime createdAt;

  DateTime updatedAt;

  bool isActive;

  /// Returns a shallow copy of this [SubSiteRecord]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  SubSiteRecord copyWith({
    int? id,
    String? subSiteId,
    String? clientId,
    String? mainSiteId,
    String? parentSubSiteId,
    String? name,
    String? description,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'subSiteId': subSiteId,
      if (clientId != null) 'clientId': clientId,
      if (mainSiteId != null) 'mainSiteId': mainSiteId,
      if (parentSubSiteId != null) 'parentSubSiteId': parentSubSiteId,
      'name': name,
      if (description != null) 'description': description,
      'createdBy': createdBy,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
      'isActive': isActive,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _SubSiteRecordImpl extends SubSiteRecord {
  _SubSiteRecordImpl({
    int? id,
    required String subSiteId,
    String? clientId,
    String? mainSiteId,
    String? parentSubSiteId,
    required String name,
    String? description,
    required String createdBy,
    required DateTime createdAt,
    required DateTime updatedAt,
    required bool isActive,
  }) : super._(
          id: id,
          subSiteId: subSiteId,
          clientId: clientId,
          mainSiteId: mainSiteId,
          parentSubSiteId: parentSubSiteId,
          name: name,
          description: description,
          createdBy: createdBy,
          createdAt: createdAt,
          updatedAt: updatedAt,
          isActive: isActive,
        );

  /// Returns a shallow copy of this [SubSiteRecord]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  SubSiteRecord copyWith({
    Object? id = _Undefined,
    String? subSiteId,
    Object? clientId = _Undefined,
    Object? mainSiteId = _Undefined,
    Object? parentSubSiteId = _Undefined,
    String? name,
    Object? description = _Undefined,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return SubSiteRecord(
      id: id is int? ? id : this.id,
      subSiteId: subSiteId ?? this.subSiteId,
      clientId: clientId is String? ? clientId : this.clientId,
      mainSiteId: mainSiteId is String? ? mainSiteId : this.mainSiteId,
      parentSubSiteId:
          parentSubSiteId is String? ? parentSubSiteId : this.parentSubSiteId,
      name: name ?? this.name,
      description: description is String? ? description : this.description,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }
}
