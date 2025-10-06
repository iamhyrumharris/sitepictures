import 'package:uuid/uuid.dart';

class Photo {
  final String id;
  final String equipmentId;
  final String filePath;
  final String? thumbnailPath;
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final String capturedBy;
  final int fileSize;
  final bool isSynced;
  final String? syncedAt;
  final String? remoteUrl;
  final DateTime createdAt;

  Photo({
    String? id,
    required this.equipmentId,
    required this.filePath,
    this.thumbnailPath,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    required this.capturedBy,
    required this.fileSize,
    this.isSynced = false,
    this.syncedAt,
    this.remoteUrl,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  // Validation
  bool isValid() {
    if (filePath.isEmpty) return false;
    if (equipmentId.isEmpty) return false;
    if (capturedBy.isEmpty) return false;
    if (timestamp.isAfter(DateTime.now())) return false;
    if (latitude < -90 || latitude > 90) return false;
    if (longitude < -180 || longitude > 180) return false;
    if (fileSize <= 0 || fileSize > 10 * 1024 * 1024) return false; // Max 10MB
    return true;
  }

  // Convert to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'equipment_id': equipmentId,
      'file_path': filePath,
      'thumbnail_path': thumbnailPath,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.toIso8601String(),
      'captured_by': capturedBy,
      'file_size': fileSize,
      'is_synced': isSynced ? 1 : 0,
      'synced_at': syncedAt,
      'remote_url': remoteUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Create from database map
  factory Photo.fromMap(Map<String, dynamic> map) {
    return Photo(
      id: map['id'],
      equipmentId: map['equipment_id'],
      filePath: map['file_path'],
      thumbnailPath: map['thumbnail_path'],
      latitude: map['latitude'].toDouble(),
      longitude: map['longitude'].toDouble(),
      timestamp: DateTime.parse(map['timestamp']),
      capturedBy: map['captured_by'],
      fileSize: map['file_size'],
      isSynced: map['is_synced'] == 1,
      syncedAt: map['synced_at'],
      remoteUrl: map['remote_url'],
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : DateTime.now(),
    );
  }

  // Create from API JSON
  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      id: json['id'],
      equipmentId: json['equipmentId'],
      filePath: json['remoteUrl'] ?? 'remote://${json['id']}',  // Use remote URL or placeholder for synced photos
      thumbnailPath: null,
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      timestamp: DateTime.parse(json['timestamp']),
      capturedBy: json['capturedBy'],
      fileSize: json['fileSize'],
      isSynced: true,
      syncedAt: json['syncedAt'],
      remoteUrl: json['remoteUrl'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  // Convert to JSON for API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'equipmentId': equipmentId,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.toIso8601String(),
      'capturedBy': capturedBy,
      'fileSize': fileSize,
      'remoteUrl': remoteUrl,
    };
  }

  // Create copy with updates
  Photo copyWith({
    String? thumbnailPath,
    bool? isSynced,
    String? syncedAt,
    String? remoteUrl,
  }) {
    return Photo(
      id: id,
      equipmentId: equipmentId,
      filePath: filePath,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      latitude: latitude,
      longitude: longitude,
      timestamp: timestamp,
      capturedBy: capturedBy,
      fileSize: fileSize,
      isSynced: isSynced ?? this.isSynced,
      syncedAt: syncedAt ?? this.syncedAt,
      remoteUrl: remoteUrl ?? this.remoteUrl,
    );
  }

  @override
  String toString() {
    return 'Photo{id: $id, filePath: $filePath, equipmentId: $equipmentId, synced: $isSynced}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Photo && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}