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

abstract class EquipmentRecord implements _i1.SerializableModel {
  EquipmentRecord._({
    this.id,
    required this.equipmentId,
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

  factory EquipmentRecord({
    int? id,
    required String equipmentId,
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
  }) = _EquipmentRecordImpl;

  factory EquipmentRecord.fromJson(Map<String, dynamic> jsonSerialization) {
    return EquipmentRecord(
      id: jsonSerialization['id'] as int?,
      equipmentId: jsonSerialization['equipmentId'] as String,
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

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String equipmentId;

  String? clientId;

  String? mainSiteId;

  String? subSiteId;

  String name;

  String? serialNumber;

  String? manufacturer;

  String? model;

  String createdBy;

  DateTime createdAt;

  DateTime updatedAt;

  bool isActive;

  /// Returns a shallow copy of this [EquipmentRecord]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  EquipmentRecord copyWith({
    int? id,
    String? equipmentId,
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
      'equipmentId': equipmentId,
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

class _EquipmentRecordImpl extends EquipmentRecord {
  _EquipmentRecordImpl({
    int? id,
    required String equipmentId,
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
          equipmentId: equipmentId,
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

  /// Returns a shallow copy of this [EquipmentRecord]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  EquipmentRecord copyWith({
    Object? id = _Undefined,
    String? equipmentId,
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
    return EquipmentRecord(
      id: id is int? ? id : this.id,
      equipmentId: equipmentId ?? this.equipmentId,
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
