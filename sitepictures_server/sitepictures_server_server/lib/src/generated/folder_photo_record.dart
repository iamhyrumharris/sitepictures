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

abstract class FolderPhotoRecord
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  FolderPhotoRecord._({
    this.id,
    required this.folderId,
    required this.photoId,
    required this.beforeAfter,
    required this.addedAt,
  });

  factory FolderPhotoRecord({
    int? id,
    required String folderId,
    required String photoId,
    required String beforeAfter,
    required DateTime addedAt,
  }) = _FolderPhotoRecordImpl;

  factory FolderPhotoRecord.fromJson(Map<String, dynamic> jsonSerialization) {
    return FolderPhotoRecord(
      id: jsonSerialization['id'] as int?,
      folderId: jsonSerialization['folderId'] as String,
      photoId: jsonSerialization['photoId'] as String,
      beforeAfter: jsonSerialization['beforeAfter'] as String,
      addedAt: _i1.DateTimeJsonExtension.fromJson(jsonSerialization['addedAt']),
    );
  }

  static final t = FolderPhotoRecordTable();

  static const db = FolderPhotoRecordRepository._();

  @override
  int? id;

  String folderId;

  String photoId;

  String beforeAfter;

  DateTime addedAt;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [FolderPhotoRecord]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  FolderPhotoRecord copyWith({
    int? id,
    String? folderId,
    String? photoId,
    String? beforeAfter,
    DateTime? addedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'folderId': folderId,
      'photoId': photoId,
      'beforeAfter': beforeAfter,
      'addedAt': addedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      if (id != null) 'id': id,
      'folderId': folderId,
      'photoId': photoId,
      'beforeAfter': beforeAfter,
      'addedAt': addedAt.toJson(),
    };
  }

  static FolderPhotoRecordInclude include() {
    return FolderPhotoRecordInclude._();
  }

  static FolderPhotoRecordIncludeList includeList({
    _i1.WhereExpressionBuilder<FolderPhotoRecordTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<FolderPhotoRecordTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<FolderPhotoRecordTable>? orderByList,
    FolderPhotoRecordInclude? include,
  }) {
    return FolderPhotoRecordIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(FolderPhotoRecord.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(FolderPhotoRecord.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _FolderPhotoRecordImpl extends FolderPhotoRecord {
  _FolderPhotoRecordImpl({
    int? id,
    required String folderId,
    required String photoId,
    required String beforeAfter,
    required DateTime addedAt,
  }) : super._(
          id: id,
          folderId: folderId,
          photoId: photoId,
          beforeAfter: beforeAfter,
          addedAt: addedAt,
        );

  /// Returns a shallow copy of this [FolderPhotoRecord]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  FolderPhotoRecord copyWith({
    Object? id = _Undefined,
    String? folderId,
    String? photoId,
    String? beforeAfter,
    DateTime? addedAt,
  }) {
    return FolderPhotoRecord(
      id: id is int? ? id : this.id,
      folderId: folderId ?? this.folderId,
      photoId: photoId ?? this.photoId,
      beforeAfter: beforeAfter ?? this.beforeAfter,
      addedAt: addedAt ?? this.addedAt,
    );
  }
}

class FolderPhotoRecordTable extends _i1.Table<int?> {
  FolderPhotoRecordTable({super.tableRelation})
      : super(tableName: 'folder_photo_records') {
    folderId = _i1.ColumnString(
      'folderId',
      this,
    );
    photoId = _i1.ColumnString(
      'photoId',
      this,
    );
    beforeAfter = _i1.ColumnString(
      'beforeAfter',
      this,
    );
    addedAt = _i1.ColumnDateTime(
      'addedAt',
      this,
    );
  }

  late final _i1.ColumnString folderId;

  late final _i1.ColumnString photoId;

  late final _i1.ColumnString beforeAfter;

  late final _i1.ColumnDateTime addedAt;

  @override
  List<_i1.Column> get columns => [
        id,
        folderId,
        photoId,
        beforeAfter,
        addedAt,
      ];
}

class FolderPhotoRecordInclude extends _i1.IncludeObject {
  FolderPhotoRecordInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => FolderPhotoRecord.t;
}

class FolderPhotoRecordIncludeList extends _i1.IncludeList {
  FolderPhotoRecordIncludeList._({
    _i1.WhereExpressionBuilder<FolderPhotoRecordTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(FolderPhotoRecord.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => FolderPhotoRecord.t;
}

class FolderPhotoRecordRepository {
  const FolderPhotoRecordRepository._();

  /// Returns a list of [FolderPhotoRecord]s matching the given query parameters.
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
  Future<List<FolderPhotoRecord>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<FolderPhotoRecordTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<FolderPhotoRecordTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<FolderPhotoRecordTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<FolderPhotoRecord>(
      where: where?.call(FolderPhotoRecord.t),
      orderBy: orderBy?.call(FolderPhotoRecord.t),
      orderByList: orderByList?.call(FolderPhotoRecord.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [FolderPhotoRecord] matching the given query parameters.
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
  Future<FolderPhotoRecord?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<FolderPhotoRecordTable>? where,
    int? offset,
    _i1.OrderByBuilder<FolderPhotoRecordTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<FolderPhotoRecordTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<FolderPhotoRecord>(
      where: where?.call(FolderPhotoRecord.t),
      orderBy: orderBy?.call(FolderPhotoRecord.t),
      orderByList: orderByList?.call(FolderPhotoRecord.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [FolderPhotoRecord] by its [id] or null if no such row exists.
  Future<FolderPhotoRecord?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<FolderPhotoRecord>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [FolderPhotoRecord]s in the list and returns the inserted rows.
  ///
  /// The returned [FolderPhotoRecord]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<FolderPhotoRecord>> insert(
    _i1.Session session,
    List<FolderPhotoRecord> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<FolderPhotoRecord>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [FolderPhotoRecord] and returns the inserted row.
  ///
  /// The returned [FolderPhotoRecord] will have its `id` field set.
  Future<FolderPhotoRecord> insertRow(
    _i1.Session session,
    FolderPhotoRecord row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<FolderPhotoRecord>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [FolderPhotoRecord]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<FolderPhotoRecord>> update(
    _i1.Session session,
    List<FolderPhotoRecord> rows, {
    _i1.ColumnSelections<FolderPhotoRecordTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<FolderPhotoRecord>(
      rows,
      columns: columns?.call(FolderPhotoRecord.t),
      transaction: transaction,
    );
  }

  /// Updates a single [FolderPhotoRecord]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<FolderPhotoRecord> updateRow(
    _i1.Session session,
    FolderPhotoRecord row, {
    _i1.ColumnSelections<FolderPhotoRecordTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<FolderPhotoRecord>(
      row,
      columns: columns?.call(FolderPhotoRecord.t),
      transaction: transaction,
    );
  }

  /// Deletes all [FolderPhotoRecord]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<FolderPhotoRecord>> delete(
    _i1.Session session,
    List<FolderPhotoRecord> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<FolderPhotoRecord>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [FolderPhotoRecord].
  Future<FolderPhotoRecord> deleteRow(
    _i1.Session session,
    FolderPhotoRecord row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<FolderPhotoRecord>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<FolderPhotoRecord>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<FolderPhotoRecordTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<FolderPhotoRecord>(
      where: where(FolderPhotoRecord.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<FolderPhotoRecordTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<FolderPhotoRecord>(
      where: where?.call(FolderPhotoRecord.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
