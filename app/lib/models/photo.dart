import 'dart:io';

class Photo {
  final String id;
  final String filePath;
  final DateTime capturedAt;
  final double? latitude;
  final double? longitude;
  final String? equipmentId;
  final String? notes;
  final bool needsSync;
  final String? thumbnailPath;
  final Map<String, dynamic>? metadata;

  Photo({
    required this.id,
    required this.filePath,
    required this.capturedAt,
    this.latitude,
    this.longitude,
    this.equipmentId,
    this.notes,
    this.needsSync = true,
    this.thumbnailPath,
    this.metadata,
  });

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      id: json['id'] as String,
      filePath: json['filePath'] as String,
      capturedAt: DateTime.parse(json['capturedAt'] as String),
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
      equipmentId: json['equipmentId'] as String?,
      notes: json['notes'] as String?,
      needsSync: json['needsSync'] as bool? ?? true,
      thumbnailPath: json['thumbnailPath'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'filePath': filePath,
      'capturedAt': capturedAt.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'equipmentId': equipmentId,
      'notes': notes,
      'needsSync': needsSync,
      'thumbnailPath': thumbnailPath,
      'metadata': metadata,
    };
  }

  File get file => File(filePath);

  File? get thumbnailFile => thumbnailPath != null ? File(thumbnailPath!) : null;

  bool get hasLocation => latitude != null && longitude != null;

  Photo copyWith({
    String? id,
    String? filePath,
    DateTime? capturedAt,
    double? latitude,
    double? longitude,
    String? equipmentId,
    String? notes,
    bool? needsSync,
    String? thumbnailPath,
    Map<String, dynamic>? metadata,
  }) {
    return Photo(
      id: id ?? this.id,
      filePath: filePath ?? this.filePath,
      capturedAt: capturedAt ?? this.capturedAt,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      equipmentId: equipmentId ?? this.equipmentId,
      notes: notes ?? this.notes,
      needsSync: needsSync ?? this.needsSync,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      metadata: metadata ?? this.metadata,
    );
  }
}