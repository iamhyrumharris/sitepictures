/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;

/// Sync queue item for offline operations
abstract class SyncQueueItem implements _i1.SerializableModel {
  SyncQueueItem._({
    this.id,
    required this.uuid,
    required this.entityType,
    required this.entityId,
    required this.operation,
    required this.payload,
    required this.retryCount,
    required this.createdAt,
    this.lastAttempt,
    this.error,
    required this.isCompleted,
  });

  factory SyncQueueItem({
    int? id,
    required String uuid,
    required String entityType,
    required String entityId,
    required String operation,
    required String payload,
    required int retryCount,
    required DateTime createdAt,
    DateTime? lastAttempt,
    String? error,
    required bool isCompleted,
  }) = _SyncQueueItemImpl;

  factory SyncQueueItem.fromJson(Map<String, dynamic> jsonSerialization) {
    return SyncQueueItem(
      id: jsonSerialization['id'] as int?,
      uuid: jsonSerialization['uuid'] as String,
      entityType: jsonSerialization['entityType'] as String,
      entityId: jsonSerialization['entityId'] as String,
      operation: jsonSerialization['operation'] as String,
      payload: jsonSerialization['payload'] as String,
      retryCount: jsonSerialization['retryCount'] as int,
      createdAt:
          _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      lastAttempt: jsonSerialization['lastAttempt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(
              jsonSerialization['lastAttempt']),
      error: jsonSerialization['error'] as String?,
      isCompleted: jsonSerialization['isCompleted'] as bool,
    );
  }

  /// Auto-increment ID
  int? id;

  /// UUID for compatibility with Flutter app
  String uuid;

  /// Entity type (photo, client, site, equipment)
  String entityType;

  /// Entity ID
  String entityId;

  /// Operation (create, update, delete)
  String operation;

  /// JSON payload
  String payload;

  /// Retry count
  int retryCount;

  /// When the item was created
  DateTime createdAt;

  /// Last attempt timestamp
  DateTime? lastAttempt;

  /// Error message if failed
  String? error;

  /// Completion status
  bool isCompleted;

  /// Returns a shallow copy of this [SyncQueueItem]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  SyncQueueItem copyWith({
    int? id,
    String? uuid,
    String? entityType,
    String? entityId,
    String? operation,
    String? payload,
    int? retryCount,
    DateTime? createdAt,
    DateTime? lastAttempt,
    String? error,
    bool? isCompleted,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'uuid': uuid,
      'entityType': entityType,
      'entityId': entityId,
      'operation': operation,
      'payload': payload,
      'retryCount': retryCount,
      'createdAt': createdAt.toJson(),
      if (lastAttempt != null) 'lastAttempt': lastAttempt?.toJson(),
      if (error != null) 'error': error,
      'isCompleted': isCompleted,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _SyncQueueItemImpl extends SyncQueueItem {
  _SyncQueueItemImpl({
    int? id,
    required String uuid,
    required String entityType,
    required String entityId,
    required String operation,
    required String payload,
    required int retryCount,
    required DateTime createdAt,
    DateTime? lastAttempt,
    String? error,
    required bool isCompleted,
  }) : super._(
          id: id,
          uuid: uuid,
          entityType: entityType,
          entityId: entityId,
          operation: operation,
          payload: payload,
          retryCount: retryCount,
          createdAt: createdAt,
          lastAttempt: lastAttempt,
          error: error,
          isCompleted: isCompleted,
        );

  /// Returns a shallow copy of this [SyncQueueItem]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  SyncQueueItem copyWith({
    Object? id = _Undefined,
    String? uuid,
    String? entityType,
    String? entityId,
    String? operation,
    String? payload,
    int? retryCount,
    DateTime? createdAt,
    Object? lastAttempt = _Undefined,
    Object? error = _Undefined,
    bool? isCompleted,
  }) {
    return SyncQueueItem(
      id: id is int? ? id : this.id,
      uuid: uuid ?? this.uuid,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      operation: operation ?? this.operation,
      payload: payload ?? this.payload,
      retryCount: retryCount ?? this.retryCount,
      createdAt: createdAt ?? this.createdAt,
      lastAttempt: lastAttempt is DateTime? ? lastAttempt : this.lastAttempt,
      error: error is String? ? error : this.error,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
