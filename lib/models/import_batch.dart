import 'package:uuid/uuid.dart';

enum ImportEntryPoint {
  home('home'),
  allPhotos('all_photos'),
  equipmentBefore('equipment_before'),
  equipmentAfter('equipment_after'),
  equipmentGeneral('equipment_general');

  const ImportEntryPoint(this.dbValue);

  final String dbValue;

  static ImportEntryPoint fromDb(String value) {
    return ImportEntryPoint.values.firstWhere(
      (entry) => entry.dbValue == value,
      orElse: () => ImportEntryPoint.home,
    );
  }
}

enum ImportDestinationCategory {
  needsAssigned('needs_assigned'),
  equipmentBefore('before'),
  equipmentAfter('after'),
  equipmentGeneral('general');

  const ImportDestinationCategory(this.dbValue);

  final String dbValue;

  static ImportDestinationCategory fromDb(String value) {
    return ImportDestinationCategory.values.firstWhere(
      (category) => category.dbValue == value,
      orElse: () => ImportDestinationCategory.needsAssigned,
    );
  }
}

enum ImportPermissionState {
  granted('granted'),
  limited('limited'),
  denied('denied'),
  restricted('restricted');

  const ImportPermissionState(this.dbValue);

  final String dbValue;

  static ImportPermissionState fromDb(String value) {
    return ImportPermissionState.values.firstWhere(
      (state) => state.dbValue == value,
      orElse: () => ImportPermissionState.granted,
    );
  }
}

class ImportBatch {
  final String id;
  final ImportEntryPoint entryPoint;
  final String? equipmentId;
  final String? folderId;
  final ImportDestinationCategory destinationCategory;
  final int selectedCount;
  final int importedCount;
  final int duplicateCount;
  final int failedCount;
  final DateTime startedAt;
  final DateTime? completedAt;
  final ImportPermissionState permissionState;
  final int? deviceFreeSpaceBytes;
  final DateTime updatedAt;

  ImportBatch({
    String? id,
    required this.entryPoint,
    this.equipmentId,
    this.folderId,
    required this.destinationCategory,
    required this.selectedCount,
    this.importedCount = 0,
    this.duplicateCount = 0,
    this.failedCount = 0,
    required this.startedAt,
    this.completedAt,
    required this.permissionState,
    this.deviceFreeSpaceBytes,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        updatedAt = updatedAt ?? DateTime.now();

  ImportBatch copyWith({
    ImportEntryPoint? entryPoint,
    String? equipmentId,
    String? folderId,
    ImportDestinationCategory? destinationCategory,
    int? selectedCount,
    int? importedCount,
    int? duplicateCount,
    int? failedCount,
    DateTime? startedAt,
    DateTime? completedAt,
    ImportPermissionState? permissionState,
    int? deviceFreeSpaceBytes,
    DateTime? updatedAt,
  }) {
    return ImportBatch(
      id: id,
      entryPoint: entryPoint ?? this.entryPoint,
      equipmentId: equipmentId ?? this.equipmentId,
      folderId: folderId ?? this.folderId,
      destinationCategory: destinationCategory ?? this.destinationCategory,
      selectedCount: selectedCount ?? this.selectedCount,
      importedCount: importedCount ?? this.importedCount,
      duplicateCount: duplicateCount ?? this.duplicateCount,
      failedCount: failedCount ?? this.failedCount,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      permissionState: permissionState ?? this.permissionState,
      deviceFreeSpaceBytes: deviceFreeSpaceBytes ?? this.deviceFreeSpaceBytes,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'entry_point': entryPoint.dbValue,
      'equipment_id': equipmentId,
      'folder_id': folderId,
      'destination_category': destinationCategory.dbValue,
      'selected_count': selectedCount,
      'imported_count': importedCount,
      'duplicate_count': duplicateCount,
      'failed_count': failedCount,
      'started_at': startedAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'permission_state': permissionState.dbValue,
      'device_free_space_bytes': deviceFreeSpaceBytes,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory ImportBatch.fromMap(Map<String, dynamic> map) {
    return ImportBatch(
      id: map['id'] as String,
      entryPoint: ImportEntryPoint.fromDb(map['entry_point'] as String),
      equipmentId: map['equipment_id'] as String?,
      folderId: map['folder_id'] as String?,
      destinationCategory: ImportDestinationCategory.fromDb(
        map['destination_category'] as String,
      ),
      selectedCount: map['selected_count'] as int,
      importedCount: map['imported_count'] as int,
      duplicateCount: map['duplicate_count'] as int,
      failedCount: map['failed_count'] as int,
      startedAt: DateTime.parse(map['started_at'] as String),
      completedAt: _parseNullableDate(map['completed_at']),
      permissionState: ImportPermissionState.fromDb(
        map['permission_state'] as String,
      ),
      deviceFreeSpaceBytes: map['device_free_space_bytes'] as int?,
      updatedAt: DateTime.parse(
        (map['updated_at'] as String?) ?? (map['started_at'] as String),
      ),
    );
  }

  Map<String, dynamic> toJson() => toMap();

  factory ImportBatch.fromJson(Map<String, dynamic> json) =>
      ImportBatch.fromMap(json);

  static DateTime? _parseNullableDate(Object? value) {
    if (value == null) {
      return null;
    }
    if (value is DateTime) {
      return value;
    }
    final serialized = value.toString();
    if (serialized.isEmpty) {
      return null;
    }
    return DateTime.parse(serialized);
  }
}
