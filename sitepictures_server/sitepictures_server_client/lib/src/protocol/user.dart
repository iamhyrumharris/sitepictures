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

/// User model for authentication and ownership tracking
abstract class User implements _i1.SerializableModel {
  User._({
    this.id,
    required this.uuid,
    required this.email,
    required this.name,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
    this.lastSyncAt,
  });

  factory User({
    int? id,
    required String uuid,
    required String email,
    required String name,
    required String role,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? lastSyncAt,
  }) = _UserImpl;

  factory User.fromJson(Map<String, dynamic> jsonSerialization) {
    return User(
      id: jsonSerialization['id'] as int?,
      uuid: jsonSerialization['uuid'] as String,
      email: jsonSerialization['email'] as String,
      name: jsonSerialization['name'] as String,
      role: jsonSerialization['role'] as String,
      createdAt:
          _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt:
          _i1.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
      lastSyncAt: jsonSerialization['lastSyncAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['lastSyncAt']),
    );
  }

  /// Auto-increment ID
  int? id;

  /// UUID for compatibility with Flutter app
  String uuid;

  /// User email address (unique)
  String email;

  /// User's full name
  String name;

  /// User role (admin, manager, technician, viewer)
  String role;

  /// When the user was created
  DateTime createdAt;

  /// When the user was last updated
  DateTime updatedAt;

  /// Last sync timestamp
  DateTime? lastSyncAt;

  /// Returns a shallow copy of this [User]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  User copyWith({
    int? id,
    String? uuid,
    String? email,
    String? name,
    String? role,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSyncAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'uuid': uuid,
      'email': email,
      'name': name,
      'role': role,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
      if (lastSyncAt != null) 'lastSyncAt': lastSyncAt?.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _UserImpl extends User {
  _UserImpl({
    int? id,
    required String uuid,
    required String email,
    required String name,
    required String role,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? lastSyncAt,
  }) : super._(
          id: id,
          uuid: uuid,
          email: email,
          name: name,
          role: role,
          createdAt: createdAt,
          updatedAt: updatedAt,
          lastSyncAt: lastSyncAt,
        );

  /// Returns a shallow copy of this [User]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  User copyWith({
    Object? id = _Undefined,
    String? uuid,
    String? email,
    String? name,
    String? role,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? lastSyncAt = _Undefined,
  }) {
    return User(
      id: id is int? ? id : this.id,
      uuid: uuid ?? this.uuid,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSyncAt: lastSyncAt is DateTime? ? lastSyncAt : this.lastSyncAt,
    );
  }
}
