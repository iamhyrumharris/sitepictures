import 'dart:convert';
import 'package:uuid/uuid.dart';

enum EntityType { photo, client, site, equipment, revision, gpsBoundary }

enum Operation { create, update, delete }

enum SyncStatus { pending, syncing, synced, failed }

class SyncPackage {
  final String id;
  final EntityType entityType;
  final String entityId;
  final Operation operation;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final String deviceId;
  final SyncStatus status;
  final int retryCount;
  final DateTime? lastAttempt;

  SyncPackage({
    String? id,
    required this.entityType,
    required this.entityId,
    required this.operation,
    required this.data,
    required this.timestamp,
    required this.deviceId,
    this.status = SyncStatus.pending,
    this.retryCount = 0,
    this.lastAttempt,
  }) : id = id ?? const Uuid().v4();

  // Convert enum to string for database
  static String entityTypeToString(EntityType type) {
    switch (type) {
      case EntityType.photo:
        return 'Photo';
      case EntityType.client:
        return 'Client';
      case EntityType.site:
        return 'Site';
      case EntityType.equipment:
        return 'Equipment';
      case EntityType.revision:
        return 'Revision';
      case EntityType.gpsBoundary:
        return 'GPSBoundary';
    }
  }

  static EntityType stringToEntityType(String str) {
    switch (str) {
      case 'Photo':
        return EntityType.photo;
      case 'Client':
        return EntityType.client;
      case 'Site':
        return EntityType.site;
      case 'Equipment':
        return EntityType.equipment;
      case 'Revision':
        return EntityType.revision;
      case 'GPSBoundary':
        return EntityType.gpsBoundary;
      default:
        throw ArgumentError('Invalid entity type: $str');
    }
  }

  static String operationToString(Operation op) {
    switch (op) {
      case Operation.create:
        return 'CREATE';
      case Operation.update:
        return 'UPDATE';
      case Operation.delete:
        return 'DELETE';
    }
  }

  static Operation stringToOperation(String str) {
    switch (str) {
      case 'CREATE':
        return Operation.create;
      case 'UPDATE':
        return Operation.update;
      case 'DELETE':
        return Operation.delete;
      default:
        throw ArgumentError('Invalid operation: $str');
    }
  }

  static String statusToString(SyncStatus status) {
    switch (status) {
      case SyncStatus.pending:
        return 'PENDING';
      case SyncStatus.syncing:
        return 'SYNCING';
      case SyncStatus.synced:
        return 'SYNCED';
      case SyncStatus.failed:
        return 'FAILED';
    }
  }

  static SyncStatus stringToStatus(String str) {
    switch (str) {
      case 'PENDING':
        return SyncStatus.pending;
      case 'SYNCING':
        return SyncStatus.syncing;
      case 'SYNCED':
        return SyncStatus.synced;
      case 'FAILED':
        return SyncStatus.failed;
      default:
        throw ArgumentError('Invalid status: $str');
    }
  }

  // Validation
  bool isValid() {
    if (retryCount < 0 || retryCount > 10) return false;
    return true;
  }

  // Convert to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'entity_type': entityTypeToString(entityType),
      'entity_id': entityId,
      'operation': operationToString(operation),
      'data': jsonEncode(data),
      'timestamp': timestamp.toIso8601String(),
      'device_id': deviceId,
      'status': statusToString(status),
      'retry_count': retryCount,
      'last_attempt': lastAttempt?.toIso8601String(),
    };
  }

  // Create from database map
  factory SyncPackage.fromMap(Map<String, dynamic> map) {
    return SyncPackage(
      id: map['id'],
      entityType: stringToEntityType(map['entity_type']),
      entityId: map['entity_id'],
      operation: stringToOperation(map['operation']),
      data: jsonDecode(map['data']),
      timestamp: DateTime.parse(map['timestamp']),
      deviceId: map['device_id'],
      status: stringToStatus(map['status']),
      retryCount: map['retry_count'] ?? 0,
      lastAttempt: map['last_attempt'] != null
          ? DateTime.parse(map['last_attempt'])
          : null,
    );
  }

  // Create copy with updates
  SyncPackage copyWith({
    SyncStatus? status,
    int? retryCount,
    DateTime? lastAttempt,
  }) {
    return SyncPackage(
      id: id,
      entityType: entityType,
      entityId: entityId,
      operation: operation,
      data: data,
      timestamp: timestamp,
      deviceId: deviceId,
      status: status ?? this.status,
      retryCount: retryCount ?? this.retryCount,
      lastAttempt: lastAttempt ?? this.lastAttempt,
    );
  }

  // Convert to JSON for API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'entityType': entityTypeToString(entityType),
      'entityId': entityId,
      'operation': operationToString(operation),
      'data': data,
      'timestamp': timestamp.toIso8601String(),
      'deviceId': deviceId,
      'status': statusToString(status),
      'retryCount': retryCount,
      'lastAttempt': lastAttempt?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'SyncPackage{id: $id, entity: $entityType, operation: $operation}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SyncPackage && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
