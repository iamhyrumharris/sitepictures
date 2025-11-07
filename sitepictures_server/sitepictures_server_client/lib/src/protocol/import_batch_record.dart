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

abstract class ImportBatchRecord implements _i1.SerializableModel {
  ImportBatchRecord._({
    this.id,
    required this.batchId,
    required this.entryPoint,
    this.equipmentId,
    this.folderId,
    required this.destinationCategory,
    required this.selectedCount,
    required this.importedCount,
    required this.duplicateCount,
    required this.failedCount,
    required this.startedAt,
    this.completedAt,
    required this.permissionState,
    this.deviceFreeSpaceBytes,
    required this.updatedAt,
  });

  factory ImportBatchRecord({
    int? id,
    required String batchId,
    required String entryPoint,
    String? equipmentId,
    String? folderId,
    required String destinationCategory,
    required int selectedCount,
    required int importedCount,
    required int duplicateCount,
    required int failedCount,
    required DateTime startedAt,
    DateTime? completedAt,
    required String permissionState,
    int? deviceFreeSpaceBytes,
    required DateTime updatedAt,
  }) = _ImportBatchRecordImpl;

  factory ImportBatchRecord.fromJson(Map<String, dynamic> jsonSerialization) {
    return ImportBatchRecord(
      id: jsonSerialization['id'] as int?,
      batchId: jsonSerialization['batchId'] as String,
      entryPoint: jsonSerialization['entryPoint'] as String,
      equipmentId: jsonSerialization['equipmentId'] as String?,
      folderId: jsonSerialization['folderId'] as String?,
      destinationCategory: jsonSerialization['destinationCategory'] as String,
      selectedCount: jsonSerialization['selectedCount'] as int,
      importedCount: jsonSerialization['importedCount'] as int,
      duplicateCount: jsonSerialization['duplicateCount'] as int,
      failedCount: jsonSerialization['failedCount'] as int,
      startedAt:
          _i1.DateTimeJsonExtension.fromJson(jsonSerialization['startedAt']),
      completedAt: jsonSerialization['completedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(
              jsonSerialization['completedAt']),
      permissionState: jsonSerialization['permissionState'] as String,
      deviceFreeSpaceBytes: jsonSerialization['deviceFreeSpaceBytes'] as int?,
      updatedAt:
          _i1.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String batchId;

  String entryPoint;

  String? equipmentId;

  String? folderId;

  String destinationCategory;

  int selectedCount;

  int importedCount;

  int duplicateCount;

  int failedCount;

  DateTime startedAt;

  DateTime? completedAt;

  String permissionState;

  int? deviceFreeSpaceBytes;

  DateTime updatedAt;

  /// Returns a shallow copy of this [ImportBatchRecord]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ImportBatchRecord copyWith({
    int? id,
    String? batchId,
    String? entryPoint,
    String? equipmentId,
    String? folderId,
    String? destinationCategory,
    int? selectedCount,
    int? importedCount,
    int? duplicateCount,
    int? failedCount,
    DateTime? startedAt,
    DateTime? completedAt,
    String? permissionState,
    int? deviceFreeSpaceBytes,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'batchId': batchId,
      'entryPoint': entryPoint,
      if (equipmentId != null) 'equipmentId': equipmentId,
      if (folderId != null) 'folderId': folderId,
      'destinationCategory': destinationCategory,
      'selectedCount': selectedCount,
      'importedCount': importedCount,
      'duplicateCount': duplicateCount,
      'failedCount': failedCount,
      'startedAt': startedAt.toJson(),
      if (completedAt != null) 'completedAt': completedAt?.toJson(),
      'permissionState': permissionState,
      if (deviceFreeSpaceBytes != null)
        'deviceFreeSpaceBytes': deviceFreeSpaceBytes,
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ImportBatchRecordImpl extends ImportBatchRecord {
  _ImportBatchRecordImpl({
    int? id,
    required String batchId,
    required String entryPoint,
    String? equipmentId,
    String? folderId,
    required String destinationCategory,
    required int selectedCount,
    required int importedCount,
    required int duplicateCount,
    required int failedCount,
    required DateTime startedAt,
    DateTime? completedAt,
    required String permissionState,
    int? deviceFreeSpaceBytes,
    required DateTime updatedAt,
  }) : super._(
          id: id,
          batchId: batchId,
          entryPoint: entryPoint,
          equipmentId: equipmentId,
          folderId: folderId,
          destinationCategory: destinationCategory,
          selectedCount: selectedCount,
          importedCount: importedCount,
          duplicateCount: duplicateCount,
          failedCount: failedCount,
          startedAt: startedAt,
          completedAt: completedAt,
          permissionState: permissionState,
          deviceFreeSpaceBytes: deviceFreeSpaceBytes,
          updatedAt: updatedAt,
        );

  /// Returns a shallow copy of this [ImportBatchRecord]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ImportBatchRecord copyWith({
    Object? id = _Undefined,
    String? batchId,
    String? entryPoint,
    Object? equipmentId = _Undefined,
    Object? folderId = _Undefined,
    String? destinationCategory,
    int? selectedCount,
    int? importedCount,
    int? duplicateCount,
    int? failedCount,
    DateTime? startedAt,
    Object? completedAt = _Undefined,
    String? permissionState,
    Object? deviceFreeSpaceBytes = _Undefined,
    DateTime? updatedAt,
  }) {
    return ImportBatchRecord(
      id: id is int? ? id : this.id,
      batchId: batchId ?? this.batchId,
      entryPoint: entryPoint ?? this.entryPoint,
      equipmentId: equipmentId is String? ? equipmentId : this.equipmentId,
      folderId: folderId is String? ? folderId : this.folderId,
      destinationCategory: destinationCategory ?? this.destinationCategory,
      selectedCount: selectedCount ?? this.selectedCount,
      importedCount: importedCount ?? this.importedCount,
      duplicateCount: duplicateCount ?? this.duplicateCount,
      failedCount: failedCount ?? this.failedCount,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt is DateTime? ? completedAt : this.completedAt,
      permissionState: permissionState ?? this.permissionState,
      deviceFreeSpaceBytes: deviceFreeSpaceBytes is int?
          ? deviceFreeSpaceBytes
          : this.deviceFreeSpaceBytes,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
