class Equipment {
  final String id;
  final String name;
  final String? parentId;
  final String equipmentType;
  final String? serialNumber;
  final String? manufacturer;
  final String? model;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<Equipment> children;

  Equipment({
    required this.id,
    required this.name,
    this.parentId,
    required this.equipmentType,
    this.serialNumber,
    this.manufacturer,
    this.model,
    this.metadata,
    required this.createdAt,
    this.updatedAt,
    this.children = const [],
  });

  factory Equipment.fromJson(Map<String, dynamic> json) {
    return Equipment(
      id: json['id'] as String,
      name: json['name'] as String,
      parentId: json['parentId'] as String?,
      equipmentType: json['equipmentType'] as String,
      serialNumber: json['serialNumber'] as String?,
      manufacturer: json['manufacturer'] as String?,
      model: json['model'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      children: (json['children'] as List<dynamic>?)
          ?.map((e) => Equipment.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'parentId': parentId,
      'equipmentType': equipmentType,
      'serialNumber': serialNumber,
      'manufacturer': manufacturer,
      'model': model,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'children': children.map((e) => e.toJson()).toList(),
    };
  }

  String get fullPath {
    final List<String> path = [name];
    return path.join(' > ');
  }

  bool get hasChildren => children.isNotEmpty;

  Equipment copyWith({
    String? id,
    String? name,
    String? parentId,
    String? equipmentType,
    String? serialNumber,
    String? manufacturer,
    String? model,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Equipment>? children,
  }) {
    return Equipment(
      id: id ?? this.id,
      name: name ?? this.name,
      parentId: parentId ?? this.parentId,
      equipmentType: equipmentType ?? this.equipmentType,
      serialNumber: serialNumber ?? this.serialNumber,
      manufacturer: manufacturer ?? this.manufacturer,
      model: model ?? this.model,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      children: children ?? this.children,
    );
  }
}