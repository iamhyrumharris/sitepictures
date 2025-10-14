import 'package:uuid/uuid.dart';

class Client {
  final String id;
  final String name;
  final String? description;
  final bool isSystem;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  Client({
    String? id,
    required this.name,
    this.description,
    this.isSystem = false,
    required this.createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isActive = true,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  // Validation
  bool isValid() {
    if (name.isEmpty || name.length > 100) return false;
    if (description != null && description!.length > 500) return false;
    if (createdBy.isEmpty) return false;
    // Name must be alphanumeric + spaces
    if (!RegExp(r'^[a-zA-Z0-9\s]+$').hasMatch(name)) return false;
    return true;
  }

  // Convert to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'is_system': isSystem ? 1 : 0,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_active': isActive ? 1 : 0,
    };
  }

  // Create from database map
  factory Client.fromMap(Map<String, dynamic> map) {
    return Client(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      isSystem: map['is_system'] == 1,
      createdBy: map['created_by'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      isActive: map['is_active'] == 1,
    );
  }

  // Create from API JSON
  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      isSystem: json['isSystem'] ?? false,
      createdBy: json['createdBy'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      isActive: json['isActive'] ?? true,
    );
  }

  // Convert to JSON for API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'isSystem': isSystem,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  // Create copy with updates
  Client copyWith({String? name, String? description, bool? isActive}) {
    return Client(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      isSystem: isSystem,
      createdBy: createdBy,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() {
    return 'Client{id: $id, name: $name, isActive: $isActive}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Client && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
