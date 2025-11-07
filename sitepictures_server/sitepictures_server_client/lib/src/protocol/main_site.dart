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

/// Main site model
abstract class MainSite implements _i1.SerializableModel {
  MainSite._({
    this.id,
    required this.uuid,
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

  factory MainSite({
    int? id,
    required String uuid,
    required String clientId,
    required String name,
    String? address,
    double? latitude,
    double? longitude,
    required String createdBy,
    required DateTime createdAt,
    required DateTime updatedAt,
    required bool isActive,
  }) = _MainSiteImpl;

  factory MainSite.fromJson(Map<String, dynamic> jsonSerialization) {
    return MainSite(
      id: jsonSerialization['id'] as int?,
      uuid: jsonSerialization['uuid'] as String,
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

  /// Auto-increment ID
  int? id;

  /// UUID for compatibility with Flutter app
  String uuid;

  /// Parent client ID
  String clientId;

  /// Site name
  String name;

  /// Optional address
  String? address;

  /// Latitude coordinate
  double? latitude;

  /// Longitude coordinate
  double? longitude;

  /// User who created this site
  String createdBy;

  /// When the site was created
  DateTime createdAt;

  /// When the site was last updated
  DateTime updatedAt;

  /// Active/inactive flag
  bool isActive;

  /// Returns a shallow copy of this [MainSite]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  MainSite copyWith({
    int? id,
    String? uuid,
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
      'uuid': uuid,
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

class _MainSiteImpl extends MainSite {
  _MainSiteImpl({
    int? id,
    required String uuid,
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
          uuid: uuid,
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

  /// Returns a shallow copy of this [MainSite]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  MainSite copyWith({
    Object? id = _Undefined,
    String? uuid,
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
    return MainSite(
      id: id is int? ? id : this.id,
      uuid: uuid ?? this.uuid,
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
