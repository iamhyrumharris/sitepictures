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

abstract class DuplicateRegistryRecord
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  DuplicateRegistryRecord._({
    this.id,
    required this.duplicateId,
    required this.photoId,
    this.sourceAssetId,
    this.fingerprintSha1,
    required this.importedAt,
  });

  factory DuplicateRegistryRecord({
    int? id,
    required String duplicateId,
    required String photoId,
    String? sourceAssetId,
    String? fingerprintSha1,
    required DateTime importedAt,
  }) = _DuplicateRegistryRecordImpl;

  factory DuplicateRegistryRecord.fromJson(
      Map<String, dynamic> jsonSerialization) {
    return DuplicateRegistryRecord(
      id: jsonSerialization['id'] as int?,
      duplicateId: jsonSerialization['duplicateId'] as String,
      photoId: jsonSerialization['photoId'] as String,
      sourceAssetId: jsonSerialization['sourceAssetId'] as String?,
      fingerprintSha1: jsonSerialization['fingerprintSha1'] as String?,
      importedAt:
          _i1.DateTimeJsonExtension.fromJson(jsonSerialization['importedAt']),
    );
  }

  static final t = DuplicateRegistryRecordTable();

  static const db = DuplicateRegistryRecordRepository._();

  @override
  int? id;

  String duplicateId;

  String photoId;

  String? sourceAssetId;

  String? fingerprintSha1;

  DateTime importedAt;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [DuplicateRegistryRecord]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  DuplicateRegistryRecord copyWith({
    int? id,
    String? duplicateId,
    String? photoId,
    String? sourceAssetId,
    String? fingerprintSha1,
    DateTime? importedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'duplicateId': duplicateId,
      'photoId': photoId,
      if (sourceAssetId != null) 'sourceAssetId': sourceAssetId,
      if (fingerprintSha1 != null) 'fingerprintSha1': fingerprintSha1,
      'importedAt': importedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      if (id != null) 'id': id,
      'duplicateId': duplicateId,
      'photoId': photoId,
      if (sourceAssetId != null) 'sourceAssetId': sourceAssetId,
      if (fingerprintSha1 != null) 'fingerprintSha1': fingerprintSha1,
      'importedAt': importedAt.toJson(),
    };
  }

  static DuplicateRegistryRecordInclude include() {
    return DuplicateRegistryRecordInclude._();
  }

  static DuplicateRegistryRecordIncludeList includeList({
    _i1.WhereExpressionBuilder<DuplicateRegistryRecordTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<DuplicateRegistryRecordTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<DuplicateRegistryRecordTable>? orderByList,
    DuplicateRegistryRecordInclude? include,
  }) {
    return DuplicateRegistryRecordIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(DuplicateRegistryRecord.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(DuplicateRegistryRecord.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _DuplicateRegistryRecordImpl extends DuplicateRegistryRecord {
  _DuplicateRegistryRecordImpl({
    int? id,
    required String duplicateId,
    required String photoId,
    String? sourceAssetId,
    String? fingerprintSha1,
    required DateTime importedAt,
  }) : super._(
          id: id,
          duplicateId: duplicateId,
          photoId: photoId,
          sourceAssetId: sourceAssetId,
          fingerprintSha1: fingerprintSha1,
          importedAt: importedAt,
        );

  /// Returns a shallow copy of this [DuplicateRegistryRecord]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  DuplicateRegistryRecord copyWith({
    Object? id = _Undefined,
    String? duplicateId,
    String? photoId,
    Object? sourceAssetId = _Undefined,
    Object? fingerprintSha1 = _Undefined,
    DateTime? importedAt,
  }) {
    return DuplicateRegistryRecord(
      id: id is int? ? id : this.id,
      duplicateId: duplicateId ?? this.duplicateId,
      photoId: photoId ?? this.photoId,
      sourceAssetId:
          sourceAssetId is String? ? sourceAssetId : this.sourceAssetId,
      fingerprintSha1:
          fingerprintSha1 is String? ? fingerprintSha1 : this.fingerprintSha1,
      importedAt: importedAt ?? this.importedAt,
    );
  }
}

class DuplicateRegistryRecordTable extends _i1.Table<int?> {
  DuplicateRegistryRecordTable({super.tableRelation})
      : super(tableName: 'duplicate_registry_records') {
    duplicateId = _i1.ColumnString(
      'duplicateId',
      this,
    );
    photoId = _i1.ColumnString(
      'photoId',
      this,
    );
    sourceAssetId = _i1.ColumnString(
      'sourceAssetId',
      this,
    );
    fingerprintSha1 = _i1.ColumnString(
      'fingerprintSha1',
      this,
    );
    importedAt = _i1.ColumnDateTime(
      'importedAt',
      this,
    );
  }

  late final _i1.ColumnString duplicateId;

  late final _i1.ColumnString photoId;

  late final _i1.ColumnString sourceAssetId;

  late final _i1.ColumnString fingerprintSha1;

  late final _i1.ColumnDateTime importedAt;

  @override
  List<_i1.Column> get columns => [
        id,
        duplicateId,
        photoId,
        sourceAssetId,
        fingerprintSha1,
        importedAt,
      ];
}

class DuplicateRegistryRecordInclude extends _i1.IncludeObject {
  DuplicateRegistryRecordInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => DuplicateRegistryRecord.t;
}

class DuplicateRegistryRecordIncludeList extends _i1.IncludeList {
  DuplicateRegistryRecordIncludeList._({
    _i1.WhereExpressionBuilder<DuplicateRegistryRecordTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(DuplicateRegistryRecord.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => DuplicateRegistryRecord.t;
}

class DuplicateRegistryRecordRepository {
  const DuplicateRegistryRecordRepository._();

  /// Returns a list of [DuplicateRegistryRecord]s matching the given query parameters.
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
  Future<List<DuplicateRegistryRecord>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<DuplicateRegistryRecordTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<DuplicateRegistryRecordTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<DuplicateRegistryRecordTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<DuplicateRegistryRecord>(
      where: where?.call(DuplicateRegistryRecord.t),
      orderBy: orderBy?.call(DuplicateRegistryRecord.t),
      orderByList: orderByList?.call(DuplicateRegistryRecord.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [DuplicateRegistryRecord] matching the given query parameters.
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
  Future<DuplicateRegistryRecord?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<DuplicateRegistryRecordTable>? where,
    int? offset,
    _i1.OrderByBuilder<DuplicateRegistryRecordTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<DuplicateRegistryRecordTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<DuplicateRegistryRecord>(
      where: where?.call(DuplicateRegistryRecord.t),
      orderBy: orderBy?.call(DuplicateRegistryRecord.t),
      orderByList: orderByList?.call(DuplicateRegistryRecord.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [DuplicateRegistryRecord] by its [id] or null if no such row exists.
  Future<DuplicateRegistryRecord?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<DuplicateRegistryRecord>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [DuplicateRegistryRecord]s in the list and returns the inserted rows.
  ///
  /// The returned [DuplicateRegistryRecord]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<DuplicateRegistryRecord>> insert(
    _i1.Session session,
    List<DuplicateRegistryRecord> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<DuplicateRegistryRecord>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [DuplicateRegistryRecord] and returns the inserted row.
  ///
  /// The returned [DuplicateRegistryRecord] will have its `id` field set.
  Future<DuplicateRegistryRecord> insertRow(
    _i1.Session session,
    DuplicateRegistryRecord row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<DuplicateRegistryRecord>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [DuplicateRegistryRecord]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<DuplicateRegistryRecord>> update(
    _i1.Session session,
    List<DuplicateRegistryRecord> rows, {
    _i1.ColumnSelections<DuplicateRegistryRecordTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<DuplicateRegistryRecord>(
      rows,
      columns: columns?.call(DuplicateRegistryRecord.t),
      transaction: transaction,
    );
  }

  /// Updates a single [DuplicateRegistryRecord]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<DuplicateRegistryRecord> updateRow(
    _i1.Session session,
    DuplicateRegistryRecord row, {
    _i1.ColumnSelections<DuplicateRegistryRecordTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<DuplicateRegistryRecord>(
      row,
      columns: columns?.call(DuplicateRegistryRecord.t),
      transaction: transaction,
    );
  }

  /// Deletes all [DuplicateRegistryRecord]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<DuplicateRegistryRecord>> delete(
    _i1.Session session,
    List<DuplicateRegistryRecord> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<DuplicateRegistryRecord>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [DuplicateRegistryRecord].
  Future<DuplicateRegistryRecord> deleteRow(
    _i1.Session session,
    DuplicateRegistryRecord row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<DuplicateRegistryRecord>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<DuplicateRegistryRecord>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<DuplicateRegistryRecordTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<DuplicateRegistryRecord>(
      where: where(DuplicateRegistryRecord.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<DuplicateRegistryRecordTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<DuplicateRegistryRecord>(
      where: where?.call(DuplicateRegistryRecord.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
