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

/// Equipment model with flexible hierarchy
abstract class Equipment implements _i1.SerializableModel {
  Equipment._({
    this.id,
    required this.uuid,
    this.clientId,
    this.mainSiteId,
    this.subSiteId,
    required this.name,
    this.serialNumber,
    this.manufacturer,
    this.model,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
  });

  factory Equipment({
    int? id,
    required String uuid,
    String? clientId,
    String? mainSiteId,
    String? subSiteId,
    required String name,
    String? serialNumber,
    String? manufacturer,
    String? model,
    required String createdBy,
    required DateTime createdAt,
    required DateTime updatedAt,
    required bool isActive,
  }) = _EquipmentImpl;

  factory Equipment.fromJson(Map<String, dynamic> jsonSerialization) {
    return Equipment(
      id: jsonSerialization['id'] as int?,
      uuid: jsonSerialization['uuid'] as String,
      clientId: jsonSerialization['clientId'] as String?,
      mainSiteId: jsonSerialization['mainSiteId'] as String?,
      subSiteId: jsonSerialization['subSiteId'] as String?,
      name: jsonSerialization['name'] as String,
      serialNumber: jsonSerialization['serialNumber'] as String?,
      manufacturer: jsonSerialization['manufacturer'] as String?,
      model: jsonSerialization['model'] as String?,
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

  /// Parent sub site ID (if attached to sub site)
  String? subSiteId;

  /// Equipment name
  String name;

  /// Serial number
  String? serialNumber;

  /// Manufacturer name
  String? manufacturer;

  /// Model name
  String? model;

  /// User who created this equipment
  String createdBy;

  /// When the equipment was created
  DateTime createdAt;

  /// When the equipment was last updated
  DateTime updatedAt;

  /// Active/inactive flag
  bool isActive;

  /// Returns a shallow copy of this [Equipment]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Equipment copyWith({
    int? id,
    String? uuid,
    String? clientId,
    String? mainSiteId,
    String? subSiteId,
    String? name,
    String? serialNumber,
    String? manufacturer,
    String? model,
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
      if (subSiteId != null) 'subSiteId': subSiteId,
      'name': name,
      if (serialNumber != null) 'serialNumber': serialNumber,
      if (manufacturer != null) 'manufacturer': manufacturer,
      if (model != null) 'model': model,
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

class _EquipmentImpl extends Equipment {
  _EquipmentImpl({
    int? id,
    required String uuid,
    String? clientId,
    String? mainSiteId,
    String? subSiteId,
    required String name,
    String? serialNumber,
    String? manufacturer,
    String? model,
    required String createdBy,
    required DateTime createdAt,
    required DateTime updatedAt,
    required bool isActive,
  }) : super._(
          id: id,
          uuid: uuid,
          clientId: clientId,
          mainSiteId: mainSiteId,
          subSiteId: subSiteId,
          name: name,
          serialNumber: serialNumber,
          manufacturer: manufacturer,
          model: model,
          createdBy: createdBy,
          createdAt: createdAt,
          updatedAt: updatedAt,
          isActive: isActive,
        );

  /// Returns a shallow copy of this [Equipment]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Equipment copyWith({
    Object? id = _Undefined,
    String? uuid,
    Object? clientId = _Undefined,
    Object? mainSiteId = _Undefined,
    Object? subSiteId = _Undefined,
    String? name,
    Object? serialNumber = _Undefined,
    Object? manufacturer = _Undefined,
    Object? model = _Undefined,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return Equipment(
      id: id is int? ? id : this.id,
      uuid: uuid ?? this.uuid,
      clientId: clientId is String? ? clientId : this.clientId,
      mainSiteId: mainSiteId is String? ? mainSiteId : this.mainSiteId,
      subSiteId: subSiteId is String? ? subSiteId : this.subSiteId,
      name: name ?? this.name,
      serialNumber: serialNumber is String? ? serialNumber : this.serialNumber,
      manufacturer: manufacturer is String? ? manufacturer : this.manufacturer,
      model: model is String? ? model : this.model,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }
}
