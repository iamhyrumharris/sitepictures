import 'package:uuid/uuid.dart';

class MainSite {
  final String id;
  final String clientId;
  final String name;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  MainSite({
    String? id,
    required this.clientId,
    required this.name,
    this.address,
    this.latitude,
    this.longitude,
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
    if (clientId.isEmpty) return false;
    if (createdBy.isEmpty) return false;
    if (latitude != null && (latitude! < -90 || latitude! > 90)) return false;
    if (longitude != null && (longitude! < -180 || longitude! > 180)) {
      return false;
    }
    return true;
  }

  // Convert to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'client_id': clientId,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_active': isActive ? 1 : 0,
    };
  }

  // Create from database map
  factory MainSite.fromMap(Map<String, dynamic> map) {
    return MainSite(
      id: map['id'],
      clientId: map['client_id'],
      name: map['name'],
      address: map['address'],
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
      createdBy: map['created_by'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      isActive: map['is_active'] == 1,
    );
  }

  // Create from API JSON
  factory MainSite.fromJson(Map<String, dynamic> json) {
    return MainSite(
      id: json['id'],
      clientId: json['clientId'],
      name: json['name'],
      address: json['address'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
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
      'clientId': clientId,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  // Create copy with updates
  MainSite copyWith({
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    bool? isActive,
  }) {
    return MainSite(
      id: id,
      clientId: clientId,
      name: name ?? this.name,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdBy: createdBy,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() {
    return 'MainSite{id: $id, name: $name, clientId: $clientId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MainSite && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class SubSite {
  final String id;
  final String? clientId;
  final String? mainSiteId;
  final String? parentSubSiteId;
  final String name;
  final String? description;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  factory SubSite({
    String? id,
    String? clientId,
    String? mainSiteId,
    String? parentSubSiteId,
    required String name,
    String? description,
    required String createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool isActive = true,
  }) {
    final normalizedClientId = _normalizeId(clientId);
    final normalizedMainSiteId = _normalizeId(mainSiteId);
    final normalizedParentSubSiteId = _normalizeId(parentSubSiteId);

    assert(
      _hasAtMostOneParent(
        normalizedClientId,
        normalizedMainSiteId,
        normalizedParentSubSiteId,
      ),
      'SubSite can belong to at most one of: Client, MainSite, or ParentSubSite',
    );

    return SubSite._(
      id: id ?? const Uuid().v4(),
      clientId: normalizedClientId,
      mainSiteId: normalizedMainSiteId,
      parentSubSiteId: normalizedParentSubSiteId,
      name: name,
      description: description,
      createdBy: createdBy,
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: updatedAt ?? DateTime.now(),
      isActive: isActive,
    );
  }

  SubSite._({
    required this.id,
    required this.clientId,
    required this.mainSiteId,
    required this.parentSubSiteId,
    required this.name,
    this.description,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
  });

  // Validation
  bool isValid() {
    if (name.isEmpty || name.length > 100) return false;
    if (createdBy.isEmpty) return false;
    if (!_hasExactlyOneParent(clientId, mainSiteId, parentSubSiteId)) {
      return false;
    }
    return true;
  }

  static String? _normalizeId(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    return trimmed;
  }

  static int _parentCount(
    String? clientId,
    String? mainSiteId,
    String? parentSubSiteId,
  ) {
    var count = 0;
    if (clientId != null) count++;
    if (mainSiteId != null) count++;
    if (parentSubSiteId != null) count++;
    return count;
  }

  static bool _hasAtMostOneParent(
    String? clientId,
    String? mainSiteId,
    String? parentSubSiteId,
  ) {
    return _parentCount(clientId, mainSiteId, parentSubSiteId) <= 1;
  }

  static bool _hasExactlyOneParent(
    String? clientId,
    String? mainSiteId,
    String? parentSubSiteId,
  ) {
    return _parentCount(clientId, mainSiteId, parentSubSiteId) == 1;
  }

  // Convert to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'client_id': clientId,
      'main_site_id': mainSiteId,
      'parent_subsite_id': parentSubSiteId,
      'name': name,
      'description': description,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_active': isActive ? 1 : 0,
    };
  }

  // Create from database map
  factory SubSite.fromMap(Map<String, dynamic> map) {
    return SubSite(
      id: map['id'],
      clientId: map['client_id'],
      mainSiteId: map['main_site_id'],
      parentSubSiteId: map['parent_subsite_id'],
      name: map['name'],
      description: map['description'],
      createdBy: map['created_by'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      isActive: map['is_active'] == 1,
    );
  }

  // Create from API JSON
  factory SubSite.fromJson(Map<String, dynamic> json) {
    return SubSite(
      id: json['id'],
      clientId: json['clientId'],
      mainSiteId: json['mainSiteId'],
      parentSubSiteId: json['parentSubSiteId'],
      name: json['name'],
      description: json['description'],
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
      'clientId': clientId,
      'mainSiteId': mainSiteId,
      'parentSubSiteId': parentSubSiteId,
      'name': name,
      'description': description,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  // Create copy with updates
  SubSite copyWith({String? name, String? description, bool? isActive}) {
    return SubSite(
      id: id,
      clientId: clientId,
      mainSiteId: mainSiteId,
      parentSubSiteId: parentSubSiteId,
      name: name ?? this.name,
      description: description ?? this.description,
      createdBy: createdBy,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() {
    return 'SubSite{id: $id, name: $name, mainSiteId: $mainSiteId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SubSite && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
