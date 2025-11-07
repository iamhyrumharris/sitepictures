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

abstract class ClientRecord implements _i1.SerializableModel {
  ClientRecord._({
    this.id,
    required this.clientId,
    required this.name,
    this.description,
    required this.isSystem,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
  });

  factory ClientRecord({
    int? id,
    required String clientId,
    required String name,
    String? description,
    required bool isSystem,
    required String createdBy,
    required DateTime createdAt,
    required DateTime updatedAt,
    required bool isActive,
  }) = _ClientRecordImpl;

  factory ClientRecord.fromJson(Map<String, dynamic> jsonSerialization) {
    return ClientRecord(
      id: jsonSerialization['id'] as int?,
      clientId: jsonSerialization['clientId'] as String,
      name: jsonSerialization['name'] as String,
      description: jsonSerialization['description'] as String?,
      isSystem: jsonSerialization['isSystem'] as bool,
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

  String clientId;

  String name;

  String? description;

  bool isSystem;

  String createdBy;

  DateTime createdAt;

  DateTime updatedAt;

  bool isActive;

  /// Returns a shallow copy of this [ClientRecord]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ClientRecord copyWith({
    int? id,
    String? clientId,
    String? name,
    String? description,
    bool? isSystem,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'clientId': clientId,
      'name': name,
      if (description != null) 'description': description,
      'isSystem': isSystem,
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

class _ClientRecordImpl extends ClientRecord {
  _ClientRecordImpl({
    int? id,
    required String clientId,
    required String name,
    String? description,
    required bool isSystem,
    required String createdBy,
    required DateTime createdAt,
    required DateTime updatedAt,
    required bool isActive,
  }) : super._(
          id: id,
          clientId: clientId,
          name: name,
          description: description,
          isSystem: isSystem,
          createdBy: createdBy,
          createdAt: createdAt,
          updatedAt: updatedAt,
          isActive: isActive,
        );

  /// Returns a shallow copy of this [ClientRecord]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ClientRecord copyWith({
    Object? id = _Undefined,
    String? clientId,
    String? name,
    Object? description = _Undefined,
    bool? isSystem,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return ClientRecord(
      id: id is int? ? id : this.id,
      clientId: clientId ?? this.clientId,
      name: name ?? this.name,
      description: description is String? ? description : this.description,
      isSystem: isSystem ?? this.isSystem,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }
}
