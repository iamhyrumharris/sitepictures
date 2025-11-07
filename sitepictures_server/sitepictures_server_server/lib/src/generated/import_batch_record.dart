/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/serverpod.dart' as _i1;

abstract class ImportBatchRecord
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
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

  static final t = ImportBatchRecordTable();

  static const db = ImportBatchRecordRepository._();

  @override
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

  @override
  _i1.Table<int?> get table => t;

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
  Map<String, dynamic> toJsonForProtocol() {
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

  static ImportBatchRecordInclude include() {
    return ImportBatchRecordInclude._();
  }

  static ImportBatchRecordIncludeList includeList({
    _i1.WhereExpressionBuilder<ImportBatchRecordTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ImportBatchRecordTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ImportBatchRecordTable>? orderByList,
    ImportBatchRecordInclude? include,
  }) {
    return ImportBatchRecordIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ImportBatchRecord.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(ImportBatchRecord.t),
      include: include,
    );
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

class ImportBatchRecordTable extends _i1.Table<int?> {
  ImportBatchRecordTable({super.tableRelation})
      : super(tableName: 'import_batch_records') {
    batchId = _i1.ColumnString(
      'batchId',
      this,
    );
    entryPoint = _i1.ColumnString(
      'entryPoint',
      this,
    );
    equipmentId = _i1.ColumnString(
      'equipmentId',
      this,
    );
    folderId = _i1.ColumnString(
      'folderId',
      this,
    );
    destinationCategory = _i1.ColumnString(
      'destinationCategory',
      this,
    );
    selectedCount = _i1.ColumnInt(
      'selectedCount',
      this,
    );
    importedCount = _i1.ColumnInt(
      'importedCount',
      this,
    );
    duplicateCount = _i1.ColumnInt(
      'duplicateCount',
      this,
    );
    failedCount = _i1.ColumnInt(
      'failedCount',
      this,
    );
    startedAt = _i1.ColumnDateTime(
      'startedAt',
      this,
    );
    completedAt = _i1.ColumnDateTime(
      'completedAt',
      this,
    );
    permissionState = _i1.ColumnString(
      'permissionState',
      this,
    );
    deviceFreeSpaceBytes = _i1.ColumnInt(
      'deviceFreeSpaceBytes',
      this,
    );
    updatedAt = _i1.ColumnDateTime(
      'updatedAt',
      this,
    );
  }

  late final _i1.ColumnString batchId;

  late final _i1.ColumnString entryPoint;

  late final _i1.ColumnString equipmentId;

  late final _i1.ColumnString folderId;

  late final _i1.ColumnString destinationCategory;

  late final _i1.ColumnInt selectedCount;

  late final _i1.ColumnInt importedCount;

  late final _i1.ColumnInt duplicateCount;

  late final _i1.ColumnInt failedCount;

  late final _i1.ColumnDateTime startedAt;

  late final _i1.ColumnDateTime completedAt;

  late final _i1.ColumnString permissionState;

  late final _i1.ColumnInt deviceFreeSpaceBytes;

  late final _i1.ColumnDateTime updatedAt;

  @override
  List<_i1.Column> get columns => [
        id,
        batchId,
        entryPoint,
        equipmentId,
        folderId,
        destinationCategory,
        selectedCount,
        importedCount,
        duplicateCount,
        failedCount,
        startedAt,
        completedAt,
        permissionState,
        deviceFreeSpaceBytes,
        updatedAt,
      ];
}

class ImportBatchRecordInclude extends _i1.IncludeObject {
  ImportBatchRecordInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => ImportBatchRecord.t;
}

class ImportBatchRecordIncludeList extends _i1.IncludeList {
  ImportBatchRecordIncludeList._({
    _i1.WhereExpressionBuilder<ImportBatchRecordTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(ImportBatchRecord.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => ImportBatchRecord.t;
}

class ImportBatchRecordRepository {
  const ImportBatchRecordRepository._();

  /// Returns a list of [ImportBatchRecord]s matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order of the items use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// The maximum number of items can be set by [limit]. If no limit is set,
  /// all items matching the query will be returned.
  ///
  /// [offset] defines how many items to skip, after which [limit] (or all)
  /// items are read from the database.
  ///
  /// ```dart
  /// var persons = await Persons.db.find(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.firstName,
  ///   limit: 100,
  /// );
  /// ```
  Future<List<ImportBatchRecord>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<ImportBatchRecordTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ImportBatchRecordTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ImportBatchRecordTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<ImportBatchRecord>(
      where: where?.call(ImportBatchRecord.t),
      orderBy: orderBy?.call(ImportBatchRecord.t),
      orderByList: orderByList?.call(ImportBatchRecord.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [ImportBatchRecord] matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// [offset] defines how many items to skip, after which the next one will be picked.
  ///
  /// ```dart
  /// var youngestPerson = await Persons.db.findFirstRow(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.age,
  /// );
  /// ```
  Future<ImportBatchRecord?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<ImportBatchRecordTable>? where,
    int? offset,
    _i1.OrderByBuilder<ImportBatchRecordTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ImportBatchRecordTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<ImportBatchRecord>(
      where: where?.call(ImportBatchRecord.t),
      orderBy: orderBy?.call(ImportBatchRecord.t),
      orderByList: orderByList?.call(ImportBatchRecord.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [ImportBatchRecord] by its [id] or null if no such row exists.
  Future<ImportBatchRecord?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<ImportBatchRecord>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [ImportBatchRecord]s in the list and returns the inserted rows.
  ///
  /// The returned [ImportBatchRecord]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<ImportBatchRecord>> insert(
    _i1.Session session,
    List<ImportBatchRecord> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<ImportBatchRecord>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [ImportBatchRecord] and returns the inserted row.
  ///
  /// The returned [ImportBatchRecord] will have its `id` field set.
  Future<ImportBatchRecord> insertRow(
    _i1.Session session,
    ImportBatchRecord row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<ImportBatchRecord>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [ImportBatchRecord]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<ImportBatchRecord>> update(
    _i1.Session session,
    List<ImportBatchRecord> rows, {
    _i1.ColumnSelections<ImportBatchRecordTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<ImportBatchRecord>(
      rows,
      columns: columns?.call(ImportBatchRecord.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ImportBatchRecord]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<ImportBatchRecord> updateRow(
    _i1.Session session,
    ImportBatchRecord row, {
    _i1.ColumnSelections<ImportBatchRecordTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<ImportBatchRecord>(
      row,
      columns: columns?.call(ImportBatchRecord.t),
      transaction: transaction,
    );
  }

  /// Deletes all [ImportBatchRecord]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<ImportBatchRecord>> delete(
    _i1.Session session,
    List<ImportBatchRecord> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<ImportBatchRecord>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [ImportBatchRecord].
  Future<ImportBatchRecord> deleteRow(
    _i1.Session session,
    ImportBatchRecord row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<ImportBatchRecord>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<ImportBatchRecord>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<ImportBatchRecordTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<ImportBatchRecord>(
      where: where(ImportBatchRecord.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<ImportBatchRecordTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<ImportBatchRecord>(
      where: where?.call(ImportBatchRecord.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
