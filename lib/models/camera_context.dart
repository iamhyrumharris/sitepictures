/// Camera context types for determining save button display
enum CameraContextType {
  home, // Launched from home screen
  equipmentAllPhotos, // Launched from equipment "All Photos" tab
  equipmentBefore, // Launched from folder "Capture Before" button
  equipmentAfter, // Launched from folder "Capture After" button
}

/// Encapsulates camera launch context for context-aware UI
class CameraContext {
  final CameraContextType type;
  final String? equipmentId; // For equipment contexts
  final String? folderId; // For before/after contexts
  final String? beforeAfter; // 'before' or 'after' for folder contexts

  const CameraContext({
    required this.type,
    this.equipmentId,
    this.folderId,
    this.beforeAfter,
  });

  /// Factory: Create from navigation extra map
  factory CameraContext.fromMap(Map<String, dynamic> map) {
    final contextStr = map['context'] as String?;
    final equipmentId = map['equipmentId'] as String?;
    final folderId = map['folderId'] as String?;
    final beforeAfter = map['beforeAfter'] as String?;

    // Determine type based on context string
    if (contextStr == 'equipment-all-photos' && equipmentId != null) {
      return CameraContext(
        type: CameraContextType.equipmentAllPhotos,
        equipmentId: equipmentId,
      );
    } else if (contextStr == 'equipment-before' && folderId != null) {
      return CameraContext(
        type: CameraContextType.equipmentBefore,
        folderId: folderId,
        beforeAfter: 'before',
      );
    } else if (contextStr == 'equipment-after' && folderId != null) {
      return CameraContext(
        type: CameraContextType.equipmentAfter,
        folderId: folderId,
        beforeAfter: 'after',
      );
    }

    // Default to home context
    return const CameraContext(type: CameraContextType.home);
  }

  /// Convert to map for navigation
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    switch (type) {
      case CameraContextType.home:
        map['context'] = 'home';
        break;
      case CameraContextType.equipmentAllPhotos:
        map['context'] = 'equipment-all-photos';
        map['equipmentId'] = equipmentId;
        break;
      case CameraContextType.equipmentBefore:
        map['context'] = 'equipment-before';
        map['folderId'] = folderId;
        map['beforeAfter'] = 'before';
        break;
      case CameraContextType.equipmentAfter:
        map['context'] = 'equipment-after';
        map['folderId'] = folderId;
        map['beforeAfter'] = 'after';
        break;
    }

    return map;
  }

  /// Validation
  bool isValid() {
    switch (type) {
      case CameraContextType.home:
        return true;
      case CameraContextType.equipmentAllPhotos:
        return equipmentId != null && equipmentId!.isNotEmpty;
      case CameraContextType.equipmentBefore:
      case CameraContextType.equipmentAfter:
        return folderId != null && folderId!.isNotEmpty;
    }
  }
}
