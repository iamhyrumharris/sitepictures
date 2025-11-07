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

/// Import batch tracking for gallery imports
abstract class ImportBatch
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
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

  static final t = ImportBatchTable();

  static const db = ImportBatchRepository._();

  @override
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

  @override
  _i1.Table<int?> get table => t;

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
  Map<String, dynamic> toJsonForProtocol() {
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

  static ImportBatchInclude include() {
    return ImportBatchInclude._();
  }

  static ImportBatchIncludeList includeList({
    _i1.WhereExpressionBuilder<ImportBatchTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ImportBatchTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ImportBatchTable>? orderByList,
    ImportBatchInclude? include,
  }) {
    return ImportBatchIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ImportBatch.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(ImportBatch.t),
      include: include,
    );
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

class ImportBatchTable extends _i1.Table<int?> {
  ImportBatchTable({super.tableRelation}) : super(tableName: 'import_batches') {
    uuid = _i1.ColumnString(
      'uuid',
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
  }

  /// UUID for compatibility with Flutter app
  late final _i1.ColumnString uuid;

  /// Entry point (equipment, folder)
  late final _i1.ColumnString entryPoint;

  /// Equipment ID if applicable
  late final _i1.ColumnString equipmentId;

  /// Folder ID if applicable
  late final _i1.ColumnString folderId;

  /// Destination category
  late final _i1.ColumnString destinationCategory;

  /// Number of photos selected
  late final _i1.ColumnInt selectedCount;

  /// Number of photos imported
  late final _i1.ColumnInt importedCount;

  /// Number of duplicates found
  late final _i1.ColumnInt duplicateCount;

  /// Number of failed imports
  late final _i1.ColumnInt failedCount;

  /// When import started
  late final _i1.ColumnDateTime startedAt;

  /// When import completed
  late final _i1.ColumnDateTime completedAt;

  /// Permission state
  late final _i1.ColumnString permissionState;

  /// Device free space in bytes
  late final _i1.ColumnInt deviceFreeSpaceBytes;

  @override
  List<_i1.Column> get columns => [
        id,
        uuid,
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
      ];
}

class ImportBatchInclude extends _i1.IncludeObject {
  ImportBatchInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => ImportBatch.t;
}

class ImportBatchIncludeList extends _i1.IncludeList {
  ImportBatchIncludeList._({
    _i1.WhereExpressionBuilder<ImportBatchTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(ImportBatch.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => ImportBatch.t;
}

class ImportBatchRepository {
  const ImportBatchRepository._();

  /// Returns a list of [ImportBatch]s matching the given query parameters.
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
  Future<List<ImportBatch>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<ImportBatchTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ImportBatchTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ImportBatchTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<ImportBatch>(
      where: where?.call(ImportBatch.t),
      orderBy: orderBy?.call(ImportBatch.t),
      orderByList: orderByList?.call(ImportBatch.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [ImportBatch] matching the given query parameters.
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
  Future<ImportBatch?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<ImportBatchTable>? where,
    int? offset,
    _i1.OrderByBuilder<ImportBatchTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ImportBatchTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<ImportBatch>(
      where: where?.call(ImportBatch.t),
      orderBy: orderBy?.call(ImportBatch.t),
      orderByList: orderByList?.call(ImportBatch.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [ImportBatch] by its [id] or null if no such row exists.
  Future<ImportBatch?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<ImportBatch>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [ImportBatch]s in the list and returns the inserted rows.
  ///
  /// The returned [ImportBatch]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<ImportBatch>> insert(
    _i1.Session session,
    List<ImportBatch> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<ImportBatch>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [ImportBatch] and returns the inserted row.
  ///
  /// The returned [ImportBatch] will have its `id` field set.
  Future<ImportBatch> insertRow(
    _i1.Session session,
    ImportBatch row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<ImportBatch>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [ImportBatch]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<ImportBatch>> update(
    _i1.Session session,
    List<ImportBatch> rows, {
    _i1.ColumnSelections<ImportBatchTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<ImportBatch>(
      rows,
      columns: columns?.call(ImportBatch.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ImportBatch]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<ImportBatch> updateRow(
    _i1.Session session,
    ImportBatch row, {
    _i1.ColumnSelections<ImportBatchTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<ImportBatch>(
      row,
      columns: columns?.call(ImportBatch.t),
      transaction: transaction,
    );
  }

  /// Deletes all [ImportBatch]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<ImportBatch>> delete(
    _i1.Session session,
    List<ImportBatch> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<ImportBatch>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [ImportBatch].
  Future<ImportBatch> deleteRow(
    _i1.Session session,
    ImportBatch row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<ImportBatch>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<ImportBatch>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<ImportBatchTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<ImportBatch>(
      where: where(ImportBatch.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<ImportBatchTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<ImportBatch>(
      where: where?.call(ImportBatch.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
