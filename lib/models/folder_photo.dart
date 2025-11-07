/// Enum for before/after categorization
enum BeforeAfter {
  before,
  after;

  /// Convert to database string
  String toDb() => name;

  /// Create from database string
  static BeforeAfter fromDb(String value) {
    return BeforeAfter.values.byName(value);
  }
}

class FolderPhoto {
  final String folderId;
  final String photoId;
  final BeforeAfter beforeAfter;
  final DateTime addedAt;

  FolderPhoto({
    required this.folderId,
    required this.photoId,
    required this.beforeAfter,
    DateTime? addedAt,
  }) : addedAt = addedAt ?? DateTime.now();

  /// Validation
  bool isValid() {
    if (folderId.isEmpty) return false;
    if (photoId.isEmpty) return false;
    if (addedAt.isAfter(DateTime.now())) return false;
    return true;
  }

  /// Convert to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'folder_id': folderId,
      'photo_id': photoId,
      'before_after': beforeAfter.toDb(),
      'added_at': addedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'folderId': folderId,
      'photoId': photoId,
      'beforeAfter': beforeAfter.toDb(),
      'addedAt': addedAt.toIso8601String(),
    };
  }

  /// Create from database map
  factory FolderPhoto.fromMap(Map<String, dynamic> map) {
    return FolderPhoto(
      folderId: map['folder_id'],
      photoId: map['photo_id'],
      beforeAfter: BeforeAfter.fromDb(map['before_after']),
      addedAt: DateTime.parse(map['added_at']),
    );
  }

  factory FolderPhoto.fromJson(Map<String, dynamic> json) {
    return FolderPhoto(
      folderId: json['folderId'] as String,
      photoId: json['photoId'] as String,
      beforeAfter: BeforeAfter.fromDb(json['beforeAfter'] as String),
      addedAt: DateTime.parse(json['addedAt'] as String),
    );
  }

  @override
  String toString() {
    return 'FolderPhoto{folderId: $folderId, photoId: $photoId, beforeAfter: $beforeAfter}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FolderPhoto &&
        other.folderId == folderId &&
        other.photoId == photoId;
  }

  @override
  int get hashCode => Object.hash(folderId, photoId);
}
