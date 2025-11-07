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

/// Import batch tracking for gallery imports
abstract class ImportBatch implements _i1.SerializableModel {
  ImportBatch._({
    this.id,
    required this.uuid,
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
  });

  factory ImportBatch({
    int? id,
    required String uuid,
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
  }) = _ImportBatchImpl;

  factory ImportBatch.fromJson(Map<String, dynamic> jsonSerialization) {
    return ImportBatch(
      id: jsonSerialization['id'] as int?,
      uuid: jsonSerialization['uuid'] as String,
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
    );
  }

  /// Auto-increment ID
  int? id;

  /// UUID for compatibility with Flutter app
  String uuid;

  /// Entry point (equipment, folder)
  String entryPoint;

  /// Equipment ID if applicable
  String? equipmentId;

  /// Folder ID if applicable
  String? folderId;

  /// Destination category
  String destinationCategory;

  /// Number of photos selected
  int selectedCount;

  /// Number of photos imported
  int importedCount;

  /// Number of duplicates found
  int duplicateCount;

  /// Number of failed imports
  int failedCount;

  /// When import started
  DateTime startedAt;

  /// When import completed
  DateTime? completedAt;

  /// Permission state
  String permissionState;

  /// Device free space in bytes
  int? deviceFreeSpaceBytes;

  /// Returns a shallow copy of this [ImportBatch]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ImportBatch copyWith({
    int? id,
    String? uuid,
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
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'uuid': uuid,
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
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ImportBatchImpl extends ImportBatch {
  _ImportBatchImpl({
    int? id,
    required String uuid,
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
  }) : super._(
          id: id,
          uuid: uuid,
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
        );

  /// Returns a shallow copy of this [ImportBatch]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ImportBatch copyWith({
    Object? id = _Undefined,
    String? uuid,
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
  }) {
    return ImportBatch(
      id: id is int? ? id : this.id,
      uuid: uuid ?? this.uuid,
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
    );
  }
}
