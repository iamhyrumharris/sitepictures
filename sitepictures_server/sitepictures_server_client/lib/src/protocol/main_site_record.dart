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

abstract class MainSiteRecord implements _i1.SerializableModel {
  MainSiteRecord._({
    this.id,
    required this.mainSiteId,
    required this.clientId,
    required this.name,
    this.address,
    this.latitude,
    this.longitude,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
  });

  factory MainSiteRecord({
    int? id,
    required String mainSiteId,
    required String clientId,
    required String name,
    String? address,
    double? latitude,
    double? longitude,
    required String createdBy,
    required DateTime createdAt,
    required DateTime updatedAt,
    required bool isActive,
  }) = _MainSiteRecordImpl;

  factory MainSiteRecord.fromJson(Map<String, dynamic> jsonSerialization) {
    return MainSiteRecord(
      id: jsonSerialization['id'] as int?,
      mainSiteId: jsonSerialization['mainSiteId'] as String,
      clientId: jsonSerialization['clientId'] as String,
      name: jsonSerialization['name'] as String,
      address: jsonSerialization['address'] as String?,
      latitude: (jsonSerialization['latitude'] as num?)?.toDouble(),
      longitude: (jsonSerialization['longitude'] as num?)?.toDouble(),
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

  String mainSiteId;

  String clientId;

  String name;

  String? address;

  double? latitude;

  double? longitude;

  String createdBy;

  DateTime createdAt;

  DateTime updatedAt;

  bool isActive;

  /// Returns a shallow copy of this [MainSiteRecord]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  MainSiteRecord copyWith({
    int? id,
    String? mainSiteId,
    String? clientId,
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'mainSiteId': mainSiteId,
      'clientId': clientId,
      'name': name,
      if (address != null) 'address': address,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
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

class _MainSiteRecordImpl extends MainSiteRecord {
  _MainSiteRecordImpl({
    int? id,
    required String mainSiteId,
    required String clientId,
    required String name,
    String? address,
    double? latitude,
    double? longitude,
    required String createdBy,
    required DateTime createdAt,
    required DateTime updatedAt,
    required bool isActive,
  }) : super._(
          id: id,
          mainSiteId: mainSiteId,
          clientId: clientId,
          name: name,
          address: address,
          latitude: latitude,
          longitude: longitude,
          createdBy: createdBy,
          createdAt: createdAt,
          updatedAt: updatedAt,
          isActive: isActive,
        );

  /// Returns a shallow copy of this [MainSiteRecord]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  MainSiteRecord copyWith({
    Object? id = _Undefined,
    String? mainSiteId,
    String? clientId,
    String? name,
    Object? address = _Undefined,
    Object? latitude = _Undefined,
    Object? longitude = _Undefined,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return MainSiteRecord(
      id: id is int? ? id : this.id,
      mainSiteId: mainSiteId ?? this.mainSiteId,
      clientId: clientId ?? this.clientId,
      name: name ?? this.name,
      address: address is String? ? address : this.address,
      latitude: latitude is double? ? latitude : this.latitude,
      longitude: longitude is double? ? longitude : this.longitude,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }
}
