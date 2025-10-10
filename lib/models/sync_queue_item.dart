import 'package:uuid/uuid.dart';

class SyncQueueItem {
  final String id;
  final String entityType;
  final String entityId;
  final String operation;
  final String payload;
  final int retryCount;
  final DateTime createdAt;
  final DateTime? lastAttempt;
  final String? error;
  final bool isCompleted;

  SyncQueueItem({
    String? id,
    required this.entityType,
    required this.entityId,
    required this.operation,
    required this.payload,
    this.retryCount = 0,
    DateTime? createdAt,
    this.lastAttempt,
    this.error,
    this.isCompleted = false,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  // Validation
  bool isValid() {
    if (entityType.isEmpty) return false;
    if (entityId.isEmpty) return false;
    if (operation.isEmpty) return false;
    if (payload.isEmpty) return false;
    if (retryCount < 0) return false;
    // Validate entityType
    if (![
      'photo',
      'client',
      'mainsite',
      'subsite',
      'equipment',
    ].contains(entityType.toLowerCase())) {
      return false;
    }
    // Validate operation
    if (!['create', 'update', 'delete'].contains(operation.toLowerCase())) {
      return false;
    }
    return true;
  }

  // Check if item should be retried
  bool shouldRetry() {
    return !isCompleted && retryCount < 3;
  }

  // Calculate backoff delay in seconds
  int getBackoffDelay() {
    // Exponential backoff: 5s, 10s, 20s
    return 5 * (1 << retryCount);
  }

  // Convert to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'entity_type': entityType,
      'entity_id': entityId,
      'operation': operation,
      'payload': payload,
      'retry_count': retryCount,
      'created_at': createdAt.toIso8601String(),
      'last_attempt': lastAttempt?.toIso8601String(),
      'error': error,
      'is_completed': isCompleted ? 1 : 0,
    };
  }

  // Create from database map
  factory SyncQueueItem.fromMap(Map<String, dynamic> map) {
    return SyncQueueItem(
      id: map['id'],
      entityType: map['entity_type'],
      entityId: map['entity_id'],
      operation: map['operation'],
      payload: map['payload'],
      retryCount: map['retry_count'],
      createdAt: DateTime.parse(map['created_at']),
      lastAttempt: map['last_attempt'] != null
          ? DateTime.parse(map['last_attempt'])
          : null,
      error: map['error'],
      isCompleted: map['is_completed'] == 1,
    );
  }

  // Create copy with updates
  SyncQueueItem copyWith({
    int? retryCount,
    DateTime? lastAttempt,
    String? error,
    bool? isCompleted,
  }) {
    return SyncQueueItem(
      id: id,
      entityType: entityType,
      entityId: entityId,
      operation: operation,
      payload: payload,
      retryCount: retryCount ?? this.retryCount,
      createdAt: createdAt,
      lastAttempt: lastAttempt ?? this.lastAttempt,
      error: error ?? this.error,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  String toString() {
    return 'SyncQueueItem{id: $id, type: $entityType, operation: $operation, retries: $retryCount, completed: $isCompleted}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SyncQueueItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
