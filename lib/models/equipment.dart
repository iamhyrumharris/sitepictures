import 'package:uuid/uuid.dart';

class Equipment {
  final String id;
  final String siteId;
  final String name;
  final String? equipmentType;
  final String? serialNumber;
  final String? model;
  final String? manufacturer;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  Equipment({
    String? id,
    required this.siteId,
    required this.name,
    this.equipmentType,
    this.serialNumber,
    this.model,
    this.manufacturer,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isActive = true,
  })  : id = id ?? const Uuid().v4(),
        tags = tags ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // Validation
  bool isValid() {
    if (name.isEmpty || name.length > 100) return false;
    if (tags.length > 10) return false;
    for (final tag in tags) {
      if (tag.isEmpty || tag.length > 30) return false;
    }
    return true;
  }

  // Convert to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'site_id': siteId,
      'name': name,
      'equipment_type': equipmentType,
      'serial_number': serialNumber,
      'model': model,
      'manufacturer': manufacturer,
      'tags': tags.join(','),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_active': isActive ? 1 : 0,
    };
  }

  // Create from database map
  factory Equipment.fromMap(Map<String, dynamic> map) {
    return Equipment(
      id: map['id'],
      siteId: map['site_id'],
      name: map['name'],
      equipmentType: map['equipment_type'],
      serialNumber: map['serial_number'],
      model: map['model'],
      manufacturer: map['manufacturer'],
      tags: map['tags'] != null && map['tags'].toString().isNotEmpty
          ? map['tags'].toString().split(',')
          : [],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      isActive: map['is_active'] == 1,
    );
  }

  // Create copy with updates
  Equipment copyWith({
    String? siteId,
    String? name,
    String? equipmentType,
    String? serialNumber,
    String? model,
    String? manufacturer,
    List<String>? tags,
    bool? isActive,
  }) {
    return Equipment(
      id: id,
      siteId: siteId ?? this.siteId,
      name: name ?? this.name,
      equipmentType: equipmentType ?? this.equipmentType,
      serialNumber: serialNumber ?? this.serialNumber,
      model: model ?? this.model,
      manufacturer: manufacturer ?? this.manufacturer,
      tags: tags ?? this.tags,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() {
    return 'Equipment{id: $id, name: $name, type: $equipmentType}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Equipment && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}