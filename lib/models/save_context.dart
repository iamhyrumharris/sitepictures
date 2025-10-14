/// Save context enumeration for camera capture workflows
enum SaveContextType {
  home,
  equipment,
  folderBefore,
  folderAfter,
}

/// Encapsulates camera launch context to determine save behavior
class SaveContext {
  final SaveContextType type;
  final String? equipmentId;
  final String? folderId;
  final String? beforeAfter; // 'before' or 'after'

  SaveContext({
    required this.type,
    this.equipmentId,
    this.folderId,
    this.beforeAfter,
  });

  /// Factory constructor for home context (Quick Save / Next button)
  factory SaveContext.home() {
    return SaveContext(type: SaveContextType.home);
  }

  /// Factory constructor for equipment context (direct save to All Photos)
  factory SaveContext.equipment(String equipmentId) {
    return SaveContext(
      type: SaveContextType.equipment,
      equipmentId: equipmentId,
    );
  }

  /// Factory constructor for folder before context
  factory SaveContext.folderBefore(String equipmentId, String folderId) {
    return SaveContext(
      type: SaveContextType.folderBefore,
      equipmentId: equipmentId,
      folderId: folderId,
      beforeAfter: 'before',
    );
  }

  /// Factory constructor for folder after context
  factory SaveContext.folderAfter(String equipmentId, String folderId) {
    return SaveContext(
      type: SaveContextType.folderAfter,
      equipmentId: equipmentId,
      folderId: folderId,
      beforeAfter: 'after',
    );
  }

  /// Validate that context has required fields for its type
  bool isValid() {
    switch (type) {
      case SaveContextType.home:
        return equipmentId == null && folderId == null;
      case SaveContextType.equipment:
        return equipmentId != null && folderId == null;
      case SaveContextType.folderBefore:
      case SaveContextType.folderAfter:
        return equipmentId != null && folderId != null && beforeAfter != null;
    }
  }

  @override
  String toString() {
    return 'SaveContext(type: $type, equipmentId: $equipmentId, folderId: $folderId, beforeAfter: $beforeAfter)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SaveContext &&
        other.type == type &&
        other.equipmentId == equipmentId &&
        other.folderId == folderId &&
        other.beforeAfter == beforeAfter;
  }

  @override
  int get hashCode {
    return Object.hash(type, equipmentId, folderId, beforeAfter);
  }
}
