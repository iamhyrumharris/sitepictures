import 'package:uuid/uuid.dart';

enum UserRole {
  admin,
  technician,
  viewer;

  String toUpperCase() {
    return name.toUpperCase();
  }

  static UserRole fromString(String role) {
    return UserRole.values.firstWhere(
      (r) => r.name.toLowerCase() == role.toLowerCase(),
      orElse: () => UserRole.viewer,
    );
  }
}

class User {
  final String id;
  final String email;
  final String name;
  final UserRole role;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? lastSyncAt;

  User({
    String? id,
    required this.email,
    required this.name,
    required this.role,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.lastSyncAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // Validation
  bool isValid() {
    if (email.isEmpty || !_isValidEmail(email)) return false;
    if (name.isEmpty) return false;
    return true;
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Permission checks
  bool canCreate() => role == UserRole.admin || role == UserRole.technician;
  bool canEdit() => role == UserRole.admin || role == UserRole.technician;
  bool canDelete() => role == UserRole.admin;
  bool canManageUsers() => role == UserRole.admin;
  bool canView() => true; // All roles can view

  // Convert to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role.toUpperCase(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'last_sync_at': lastSyncAt,
    };
  }

  // Create from database map
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      email: map['email'],
      name: map['name'],
      role: UserRole.fromString(map['role']),
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      lastSyncAt: map['last_sync_at'],
    );
  }

  // Create from API JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      role: UserRole.fromString(json['role']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      lastSyncAt: json['lastSyncAt'],
    );
  }

  // Convert to JSON for API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role.toUpperCase(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'lastSyncAt': lastSyncAt,
    };
  }

  // Create copy with updates
  User copyWith({
    String? email,
    String? name,
    UserRole? role,
    String? lastSyncAt,
  }) {
    return User(
      id: id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
    );
  }

  @override
  String toString() {
    return 'User{id: $id, email: $email, name: $name, role: ${role.name}}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}