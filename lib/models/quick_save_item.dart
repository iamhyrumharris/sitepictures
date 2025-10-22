/// Quick Save type enumeration
enum QuickSaveType {
  singlePhoto, // 1 photo → "Image - YYYY-MM-DD"
  folder, // 2+ photos → "YYYY-MM-DD HH-mm"
}

/// Result entity for Quick Save operations
class QuickSaveItem {
  final QuickSaveType type;
  final String name;
  final List<String> photoIds;
  final String? folderId;
  final DateTime createdAt;

  QuickSaveItem({
    required this.type,
    required this.name,
    required this.photoIds,
    this.folderId,
    required this.createdAt,
  });

  /// Create QuickSaveItem from photo count and date
  factory QuickSaveItem.fromPhotoCount({
    required int photoCount,
    required List<String> photoIds,
    required String baseName,
    String? folderId,
  }) {
    final type = photoCount == 1 ? QuickSaveType.singlePhoto : QuickSaveType.folder;

    return QuickSaveItem(
      type: type,
      name: baseName,
      photoIds: photoIds,
      folderId: folderId,
      createdAt: DateTime.now(),
    );
  }

  /// Check if this is a folder (multiple photos)
  bool get isFolder => type == QuickSaveType.folder;

  /// Check if this is a single photo
  bool get isSinglePhoto => type == QuickSaveType.singlePhoto;

  @override
  String toString() {
    return 'QuickSaveItem(type: $type, name: $name, photoIds: ${photoIds.length}, folderId: $folderId, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QuickSaveItem &&
        other.type == type &&
        other.name == name &&
        _listEquals(other.photoIds, photoIds) &&
        other.folderId == folderId &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      type,
      name,
      Object.hashAll(photoIds),
      folderId,
      createdAt,
    );
  }

  // Helper for list equality
  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
