import 'dart:typed_data';

/// Represents a temporary photo in a capture session (before saving to database)
class TempPhoto {
  /// Unique identifier for the temp photo (UUID v4 format)
  final String id;

  /// Absolute path to photo file in temp storage
  final String filePath;

  /// When the photo was captured
  final DateTime captureTimestamp;

  /// Order in capture sequence (0-indexed)
  final int displayOrder;

  /// Cached thumbnail bytes (100x100, JPEG 70%) - optional for performance
  final Uint8List? thumbnailData;

  TempPhoto({
    required this.id,
    required this.filePath,
    required this.captureTimestamp,
    required this.displayOrder,
    this.thumbnailData,
  }) {
    if (id.isEmpty) throw ArgumentError('TempPhoto id cannot be empty');
    if (filePath.isEmpty) throw ArgumentError('TempPhoto filePath cannot be empty');
    if (displayOrder < 0) throw ArgumentError('TempPhoto displayOrder must be >= 0');
    if (captureTimestamp.isAfter(DateTime.now())) {
      throw ArgumentError('TempPhoto captureTimestamp cannot be in the future');
    }
  }

  /// Serialize to JSON for session preservation (FR-029/FR-030)
  Map<String, dynamic> toJson() => {
        'id': id,
        'filePath': filePath,
        'captureTimestamp': captureTimestamp.toIso8601String(),
        'displayOrder': displayOrder,
      };

  /// Deserialize from JSON for session restoration
  factory TempPhoto.fromJson(Map<String, dynamic> json) => TempPhoto(
        id: json['id'] as String,
        filePath: json['filePath'] as String,
        captureTimestamp: DateTime.parse(json['captureTimestamp'] as String),
        displayOrder: json['displayOrder'] as int,
        thumbnailData: null, // Regenerate after restore
      );

  TempPhoto copyWith({
    String? id,
    String? filePath,
    DateTime? captureTimestamp,
    int? displayOrder,
    Uint8List? thumbnailData,
  }) {
    return TempPhoto(
      id: id ?? this.id,
      filePath: filePath ?? this.filePath,
      captureTimestamp: captureTimestamp ?? this.captureTimestamp,
      displayOrder: displayOrder ?? this.displayOrder,
      thumbnailData: thumbnailData ?? this.thumbnailData,
    );
  }
}

/// Session status enum
enum SessionStatus {
  inProgress,  // Active capture session
  completed,   // User pressed Done + selected Next/Quick Save
  cancelled,   // User pressed Cancel and confirmed
}

/// Exception thrown when trying to add photo beyond 20-photo limit
class SessionPhotoLimitException implements Exception {
  final String message;
  SessionPhotoLimitException(this.message);
  @override
  String toString() => message;
}

/// Exception thrown on invalid session state transitions
class InvalidSessionStateException implements Exception {
  final String message;
  InvalidSessionStateException(this.message);
  @override
  String toString() => message;
}

/// Represents a collection of photos captured in a single camera session
class PhotoSession {
  /// Unique identifier for the session (UUID v4 format)
  final String id;

  /// Ordered list of captured photos
  final List<TempPhoto> photos;

  /// When the session was initiated
  final DateTime startTime;

  /// Current session state
  SessionStatus status;

  /// Maximum photos allowed (constant = 20 per FR-027)
  static const int maxPhotos = 20;

  PhotoSession({
    required this.id,
    List<TempPhoto>? photos,
    DateTime? startTime,
    this.status = SessionStatus.inProgress,
  })  : photos = photos ?? [],
        startTime = startTime ?? DateTime.now() {
    if (id.isEmpty) throw ArgumentError('PhotoSession id cannot be empty');
    if (this.photos.length > maxPhotos) {
      throw ArgumentError('PhotoSession cannot have more than $maxPhotos photos');
    }
  }

  /// Check if session is at photo limit (FR-027, FR-027a)
  bool get isAtLimit => photos.length >= maxPhotos;

  /// Check if session has any photos
  bool get hasPhotos => photos.isNotEmpty;

  /// Get photo count
  int get photoCount => photos.length;

  /// Add photo to session (FR-005, FR-007, FR-008)
  void addPhoto(TempPhoto photo) {
    if (photos.length >= maxPhotos) {
      throw SessionPhotoLimitException('Cannot exceed $maxPhotos photos');
    }
    if (status != SessionStatus.inProgress) {
      throw InvalidSessionStateException('Cannot add photo to $status session');
    }
    photos.add(photo);
  }

  /// Remove photo from session (FR-010)
  void removePhoto(String photoId) {
    if (status != SessionStatus.inProgress) {
      throw InvalidSessionStateException('Cannot remove photo from $status session');
    }
    photos.removeWhere((p) => p.id == photoId);
    _reindexDisplayOrder(); // Maintain sequential ordering
  }

  /// Complete session (FR-013, FR-014, FR-015)
  void complete() {
    if (status != SessionStatus.inProgress) {
      throw InvalidSessionStateException('Can only complete inProgress session');
    }
    status = SessionStatus.completed;
  }

  /// Cancel session (FR-018, FR-020)
  void cancel() {
    if (status != SessionStatus.inProgress) {
      throw InvalidSessionStateException('Can only cancel inProgress session');
    }
    status = SessionStatus.cancelled;
  }

  /// Reindex photos after deletion to maintain sequential displayOrder
  void _reindexDisplayOrder() {
    for (int i = 0; i < photos.length; i++) {
      photos[i] = photos[i].copyWith(displayOrder: i);
    }
  }

  /// Serialize to JSON for session preservation (FR-029/FR-030)
  Map<String, dynamic> toJson() => {
        'id': id,
        'photos': photos.map((p) => p.toJson()).toList(),
        'startTime': startTime.toIso8601String(),
        'status': status.name,
      };

  /// Deserialize from JSON for session restoration
  factory PhotoSession.fromJson(Map<String, dynamic> json) {
    return PhotoSession(
      id: json['id'] as String,
      photos: (json['photos'] as List)
          .map((p) => TempPhoto.fromJson(p as Map<String, dynamic>))
          .toList(),
      startTime: DateTime.parse(json['startTime'] as String),
      status: SessionStatus.values.byName(json['status'] as String),
    );
  }
}
