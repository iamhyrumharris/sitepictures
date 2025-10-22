import 'package:uuid/uuid.dart';
import 'folder_photo.dart';

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

  // Virtual fields (not stored in database, derived from JOIN queries)
  final String? folderId;
  final String? folderName;
  final BeforeAfter? beforeAfter;
  final String? equipmentName;
  final String? clientName;
  final String? mainSiteName;
  final String? subSiteName;
  final String? locationSummary;

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
    // Virtual fields
    this.folderId,
    this.folderName,
    this.beforeAfter,
    this.equipmentName,
    this.clientName,
    this.mainSiteName,
    this.subSiteName,
    this.locationSummary,
  }) : id = id ?? const Uuid().v4(),
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
      timestamp:
          _parseDate(map['timestamp']) ?? _parseDate(map['created_at'])!,
      capturedBy: map['captured_by'],
      fileSize: map['file_size'],
      isSynced: map['is_synced'] == 1,
      syncedAt: map['synced_at'],
      remoteUrl: map['remote_url'],
      createdAt: _parseDate(map['created_at']) ?? DateTime.now(),
      // Virtual fields from JOIN queries
      folderId: map['folder_id'],
      folderName: map['folder_name'],
      beforeAfter: map['before_after'] != null
          ? BeforeAfter.fromDb(map['before_after'])
          : null,
      equipmentName: map['equipment_name'],
      clientName: map['client_name'],
      mainSiteName: map['main_site_name'],
      subSiteName: map['sub_site_name'],
      locationSummary: map['location_summary'],
    );
  }

  // Create from API JSON
  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      id: json['id'],
      equipmentId: json['equipmentId'],
      filePath:
          json['remoteUrl'] ??
          'remote://${json['id']}', // Use remote URL or placeholder for synced photos
      thumbnailPath: null,
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      timestamp:
          _parseDate(json['timestamp']) ??
          _parseDate(json['createdAt']) ??
          DateTime.now(),
      capturedBy: json['capturedBy'],
      fileSize: json['fileSize'],
      isSynced: true,
      syncedAt: json['syncedAt'],
      remoteUrl: json['remoteUrl'],
      createdAt: _parseDate(json['createdAt']) ?? DateTime.now(),
      equipmentName: json['equipmentName'],
      clientName: json['clientName'],
      mainSiteName: json['mainSiteName'],
      subSiteName: json['subSiteName'],
      locationSummary: json['locationSummary'],
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
      'equipmentName': equipmentName,
      'clientName': clientName,
      'mainSiteName': mainSiteName,
      'subSiteName': subSiteName,
      'locationSummary': locationSummary,
    };
  }

  // Create copy with updates
  Photo copyWith({
    String? thumbnailPath,
    bool? isSynced,
    String? syncedAt,
    String? remoteUrl,
    String? folderId,
    String? folderName,
    BeforeAfter? beforeAfter,
    String? equipmentName,
    String? clientName,
    String? mainSiteName,
    String? subSiteName,
    String? locationSummary,
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
      // Virtual fields
      folderId: folderId ?? this.folderId,
      folderName: folderName ?? this.folderName,
      beforeAfter: beforeAfter ?? this.beforeAfter,
      equipmentName: equipmentName ?? this.equipmentName,
      clientName: clientName ?? this.clientName,
      mainSiteName: mainSiteName ?? this.mainSiteName,
      subSiteName: subSiteName ?? this.subSiteName,
      locationSummary: locationSummary ?? this.locationSummary,
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

  static DateTime? _parseDate(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is DateTime) {
      return value;
    }
    final parsed = value.toString();
    if (parsed.isEmpty) {
      return null;
    }
    return DateTime.parse(parsed);
  }
}
