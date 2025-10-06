import 'package:uuid/uuid.dart';

class Equipment {
  final String id;
  final String? mainSiteId;
  final String? subSiteId;
  final String name;
  final String? serialNumber;
  final String? manufacturer;
  final String? model;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  Equipment({
    String? id,
    this.mainSiteId,
    this.subSiteId,
    required this.name,
    this.serialNumber,
    this.manufacturer,
    this.model,
    required this.createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isActive = true,
  })  : assert(
          (mainSiteId != null) != (subSiteId != null),
          'Equipment must belong to exactly one of MainSite or SubSite (XOR constraint)',
        ),
        id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // Validation
  bool isValid() {
    if (name.isEmpty || name.length > 100) return false;
    if (createdBy.isEmpty) return false;
    // XOR validation: exactly one of mainSiteId or subSiteId must be non-null
    if ((mainSiteId == null) == (subSiteId == null)) return false;
    return true;
  }

  // Get parent site ID (whichever is non-null)
  String get parentSiteId => mainSiteId ?? subSiteId!;

  // Convert to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'main_site_id': mainSiteId,
      'sub_site_id': subSiteId,
      'name': name,
      'serial_number': serialNumber,
      'manufacturer': manufacturer,
      'model': model,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_active': isActive ? 1 : 0,
    };
  }

  // Create from database map
  factory Equipment.fromMap(Map<String, dynamic> map) {
    return Equipment(
      id: map['id'],
      mainSiteId: map['main_site_id'],
      subSiteId: map['sub_site_id'],
      name: map['name'],
      serialNumber: map['serial_number'],
      manufacturer: map['manufacturer'],
      model: map['model'],
      createdBy: map['created_by'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      isActive: map['is_active'] == 1,
    );
  }

  // Create from API JSON
  factory Equipment.fromJson(Map<String, dynamic> json) {
    return Equipment(
      id: json['id'],
      mainSiteId: json['mainSiteId'],
      subSiteId: json['subSiteId'],
      name: json['name'],
      serialNumber: json['serialNumber'],
      manufacturer: json['manufacturer'],
      model: json['model'],
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
      'mainSiteId': mainSiteId,
      'subSiteId': subSiteId,
      'name': name,
      'serialNumber': serialNumber,
      'manufacturer': manufacturer,
      'model': model,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  // Create copy with updates
  Equipment copyWith({
    String? name,
    String? serialNumber,
    String? manufacturer,
    String? model,
    bool? isActive,
  }) {
    return Equipment(
      id: id,
      mainSiteId: mainSiteId,
      subSiteId: subSiteId,
      name: name ?? this.name,
      serialNumber: serialNumber ?? this.serialNumber,
      manufacturer: manufacturer ?? this.manufacturer,
      model: model ?? this.model,
      createdBy: createdBy,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() {
    return 'Equipment{id: $id, name: $name, mainSiteId: $mainSiteId, subSiteId: $subSiteId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Equipment && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}