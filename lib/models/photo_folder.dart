import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class PhotoFolder {
  final String id;
  final String equipmentId;
  final String name;
  final String workOrder;
  final DateTime createdAt;
  final String createdBy;
  final bool isDeleted;

  PhotoFolder({
    String? id,
    required this.equipmentId,
    required this.workOrder,
    required this.createdBy,
    DateTime? createdAt,
    bool? isDeleted,
    String? name,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now(),
       isDeleted = isDeleted ?? false,
       name = _normalizeName(
         name,
         workOrder,
         createdAt ?? DateTime.now(),
       );

  /// Generate folder name in format: "{work_order} - {YYYY-MM-DD}"
  static String _generateName(String workOrder, DateTime date) {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    return '$workOrder - $dateStr';
  }

  static String _normalizeName(
    String? providedName,
    String workOrder,
    DateTime createdAt,
  ) {
    final trimmed = providedName?.trim();
    if (trimmed != null && trimmed.isNotEmpty) {
      return trimmed;
    }
    return _generateName(workOrder, createdAt);
  }

  /// Validation
  bool isValid() {
    if (workOrder.isEmpty || workOrder.length > 50) return false;
    if (name.isEmpty || name.length > 100) return false;
    if (createdAt.isAfter(DateTime.now())) return false;
    if (equipmentId.isEmpty) return false;
    if (createdBy.isEmpty) return false;
    return true;
  }

  /// Convert to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'equipment_id': equipmentId,
      'name': name,
      'work_order': workOrder,
      'created_at': createdAt.toIso8601String(),
      'created_by': createdBy,
      'is_deleted': isDeleted ? 1 : 0,
    };
  }

  /// Create from database map
  factory PhotoFolder.fromMap(Map<String, dynamic> map) {
    return PhotoFolder(
      id: map['id'],
      equipmentId: map['equipment_id'],
      name: map['name'],
      workOrder: map['work_order'],
      createdBy: map['created_by'],
      createdAt: DateTime.parse(map['created_at']),
      isDeleted: map['is_deleted'] == 1,
    );
  }

  /// Create copy with updates
  PhotoFolder copyWith({
    String? equipmentId,
    String? name,
    String? workOrder,
    String? createdBy,
    DateTime? createdAt,
    bool? isDeleted,
  }) {
    return PhotoFolder(
      id: id,
      equipmentId: equipmentId ?? this.equipmentId,
      name: name ?? this.name,
      workOrder: workOrder ?? this.workOrder,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  @override
  String toString() {
    return 'PhotoFolder{id: $id, name: $name, equipmentId: $equipmentId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PhotoFolder && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
