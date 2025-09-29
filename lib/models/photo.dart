import 'package:uuid/uuid.dart';

class Photo {
  final String id;
  final String equipmentId;
  final String? revisionId;
  final String fileName;
  final String fileHash;
  final double? latitude;
  final double? longitude;
  final DateTime capturedAt;
  final String? notes;
  final String deviceId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isSynced;

  Photo({
    String? id,
    required this.equipmentId,
    this.revisionId,
    required this.fileName,
    required this.fileHash,
    this.latitude,
    this.longitude,
    required this.capturedAt,
    this.notes,
    required this.deviceId,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isSynced = false,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // Validation
  bool isValid() {
    if (fileName.isEmpty) return false;
    if (fileHash.length != 64) return false;
    if (capturedAt.isAfter(DateTime.now())) return false;
    if (latitude != null && (latitude! < -90 || latitude! > 90)) return false;
    if (longitude != null && (longitude! < -180 || longitude! > 180)) return false;
    return true;
  }

  // Convert to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'equipment_id': equipmentId,
      'revision_id': revisionId,
      'file_name': fileName,
      'file_hash': fileHash,
      'latitude': latitude,
      'longitude': longitude,
      'captured_at': capturedAt.toIso8601String(),
      'notes': notes,
      'device_id': deviceId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_synced': isSynced ? 1 : 0,
    };
  }

  // Create from database map
  factory Photo.fromMap(Map<String, dynamic> map) {
    return Photo(
      id: map['id'],
      equipmentId: map['equipment_id'],
      revisionId: map['revision_id'],
      fileName: map['file_name'],
      fileHash: map['file_hash'],
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
      capturedAt: DateTime.parse(map['captured_at']),
      notes: map['notes'],
      deviceId: map['device_id'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      isSynced: map['is_synced'] == 1,
    );
  }

  // Create copy with updates
  Photo copyWith({
    String? equipmentId,
    String? revisionId,
    String? fileName,
    String? fileHash,
    double? latitude,
    double? longitude,
    DateTime? capturedAt,
    String? notes,
    String? deviceId,
    bool? isSynced,
  }) {
    return Photo(
      id: id,
      equipmentId: equipmentId ?? this.equipmentId,
      revisionId: revisionId ?? this.revisionId,
      fileName: fileName ?? this.fileName,
      fileHash: fileHash ?? this.fileHash,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      capturedAt: capturedAt ?? this.capturedAt,
      notes: notes ?? this.notes,
      deviceId: deviceId ?? this.deviceId,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      isSynced: isSynced ?? this.isSynced,
    );
  }

  @override
  String toString() {
    return 'Photo{id: $id, fileName: $fileName, equipmentId: $equipmentId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Photo && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}