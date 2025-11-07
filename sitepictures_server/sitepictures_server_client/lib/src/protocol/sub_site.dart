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

/// Sub site model with flexible hierarchy
abstract class SubSite implements _i1.SerializableModel {
  SubSite._({
    this.id,
    required this.uuid,
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

  factory SubSite({
    int? id,
    required String uuid,
    String? clientId,
    String? mainSiteId,
    String? parentSubSiteId,
    required String name,
    String? description,
    required String createdBy,
    required DateTime createdAt,
    required DateTime updatedAt,
    required bool isActive,
  }) = _SubSiteImpl;

  factory SubSite.fromJson(Map<String, dynamic> jsonSerialization) {
    return SubSite(
      id: jsonSerialization['id'] as int?,
      uuid: jsonSerialization['uuid'] as String,
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

  /// Auto-increment ID
  int? id;

  /// UUID for compatibility with Flutter app
  String uuid;

  /// Parent client ID (if attached to client)
  String? clientId;

  /// Parent main site ID (if attached to main site)
  String? mainSiteId;

  /// Parent subsite ID (if nested subsite)
  String? parentSubSiteId;

  /// Site name
  String name;

  /// Optional description
  String? description;

  /// User who created this site
  String createdBy;

  /// When the site was created
  DateTime createdAt;

  /// When the site was last updated
  DateTime updatedAt;

  /// Active/inactive flag
  bool isActive;

  /// Returns a shallow copy of this [SubSite]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  SubSite copyWith({
    int? id,
    String? uuid,
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
      'uuid': uuid,
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

class _SubSiteImpl extends SubSite {
  _SubSiteImpl({
    int? id,
    required String uuid,
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
          uuid: uuid,
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

  /// Returns a shallow copy of this [SubSite]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  SubSite copyWith({
    Object? id = _Undefined,
    String? uuid,
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
    return SubSite(
      id: id is int? ? id : this.id,
      uuid: uuid ?? this.uuid,
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
