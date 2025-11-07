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

abstract class PhotoFolderRecord
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  PhotoFolderRecord._({
    this.id,
    required this.folderId,
    required this.equipmentId,
    required this.name,
    required this.workOrder,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
  });

  factory PhotoFolderRecord({
    int? id,
    required String folderId,
    required String equipmentId,
    required String name,
    required String workOrder,
    required String createdBy,
    required DateTime createdAt,
    required DateTime updatedAt,
    required bool isDeleted,
  }) = _PhotoFolderRecordImpl;

  factory PhotoFolderRecord.fromJson(Map<String, dynamic> jsonSerialization) {
    return PhotoFolderRecord(
      id: jsonSerialization['id'] as int?,
      folderId: jsonSerialization['folderId'] as String,
      equipmentId: jsonSerialization['equipmentId'] as String,
      name: jsonSerialization['name'] as String,
      workOrder: jsonSerialization['workOrder'] as String,
      createdBy: jsonSerialization['createdBy'] as String,
      createdAt:
          _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt:
          _i1.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
      isDeleted: jsonSerialization['isDeleted'] as bool,
    );
  }

  static final t = PhotoFolderRecordTable();

  static const db = PhotoFolderRecordRepository._();

  @override
  int? id;

  String folderId;

  String equipmentId;

  String name;

  String workOrder;

  String createdBy;

  DateTime createdAt;

  DateTime updatedAt;

  bool isDeleted;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [PhotoFolderRecord]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  PhotoFolderRecord copyWith({
    int? id,
    String? folderId,
    String? equipmentId,
    String? name,
    String? workOrder,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'folderId': folderId,
      'equipmentId': equipmentId,
      'name': name,
      'workOrder': workOrder,
      'createdBy': createdBy,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
      'isDeleted': isDeleted,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      if (id != null) 'id': id,
      'folderId': folderId,
      'equipmentId': equipmentId,
      'name': name,
      'workOrder': workOrder,
      'createdBy': createdBy,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
      'isDeleted': isDeleted,
    };
  }

  static PhotoFolderRecordInclude include() {
    return PhotoFolderRecordInclude._();
  }

  static PhotoFolderRecordIncludeList includeList({
    _i1.WhereExpressionBuilder<PhotoFolderRecordTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<PhotoFolderRecordTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<PhotoFolderRecordTable>? orderByList,
    PhotoFolderRecordInclude? include,
  }) {
    return PhotoFolderRecordIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PhotoFolderRecord.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(PhotoFolderRecord.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PhotoFolderRecordImpl extends PhotoFolderRecord {
  _PhotoFolderRecordImpl({
    int? id,
    required String folderId,
    required String equipmentId,
    required String name,
    required String workOrder,
    required String createdBy,
    required DateTime createdAt,
    required DateTime updatedAt,
    required bool isDeleted,
  }) : super._(
          id: id,
          folderId: folderId,
          equipmentId: equipmentId,
          name: name,
          workOrder: workOrder,
          createdBy: createdBy,
          createdAt: createdAt,
          updatedAt: updatedAt,
          isDeleted: isDeleted,
        );

  /// Returns a shallow copy of this [PhotoFolderRecord]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  PhotoFolderRecord copyWith({
    Object? id = _Undefined,
    String? folderId,
    String? equipmentId,
    String? name,
    String? workOrder,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
  }) {
    return PhotoFolderRecord(
      id: id is int? ? id : this.id,
      folderId: folderId ?? this.folderId,
      equipmentId: equipmentId ?? this.equipmentId,
      name: name ?? this.name,
      workOrder: workOrder ?? this.workOrder,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}

class PhotoFolderRecordTable extends _i1.Table<int?> {
  PhotoFolderRecordTable({super.tableRelation})
      : super(tableName: 'photo_folder_records') {
    folderId = _i1.ColumnString(
      'folderId',
      this,
    );
    equipmentId = _i1.ColumnString(
      'equipmentId',
      this,
    );
    name = _i1.ColumnString(
      'name',
      this,
    );
    workOrder = _i1.ColumnString(
      'workOrder',
      this,
    );
    createdBy = _i1.ColumnString(
      'createdBy',
      this,
    );
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
    );
    updatedAt = _i1.ColumnDateTime(
      'updatedAt',
      this,
    );
    isDeleted = _i1.ColumnBool(
      'isDeleted',
      this,
    );
  }

  late final _i1.ColumnString folderId;

  late final _i1.ColumnString equipmentId;

  late final _i1.ColumnString name;

  late final _i1.ColumnString workOrder;

  late final _i1.ColumnString createdBy;

  late final _i1.ColumnDateTime createdAt;

  late final _i1.ColumnDateTime updatedAt;

  late final _i1.ColumnBool isDeleted;

  @override
  List<_i1.Column> get columns => [
        id,
        folderId,
        equipmentId,
        name,
        workOrder,
        createdBy,
        createdAt,
        updatedAt,
        isDeleted,
      ];
}

class PhotoFolderRecordInclude extends _i1.IncludeObject {
  PhotoFolderRecordInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => PhotoFolderRecord.t;
}

class PhotoFolderRecordIncludeList extends _i1.IncludeList {
  PhotoFolderRecordIncludeList._({
    _i1.WhereExpressionBuilder<PhotoFolderRecordTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(PhotoFolderRecord.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => PhotoFolderRecord.t;
}

class PhotoFolderRecordRepository {
  const PhotoFolderRecordRepository._();

  /// Returns a list of [PhotoFolderRecord]s matching the given query parameters.
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
  Future<List<PhotoFolderRecord>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<PhotoFolderRecordTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<PhotoFolderRecordTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<PhotoFolderRecordTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<PhotoFolderRecord>(
      where: where?.call(PhotoFolderRecord.t),
      orderBy: orderBy?.call(PhotoFolderRecord.t),
      orderByList: orderByList?.call(PhotoFolderRecord.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [PhotoFolderRecord] matching the given query parameters.
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
  Future<PhotoFolderRecord?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<PhotoFolderRecordTable>? where,
    int? offset,
    _i1.OrderByBuilder<PhotoFolderRecordTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<PhotoFolderRecordTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<PhotoFolderRecord>(
      where: where?.call(PhotoFolderRecord.t),
      orderBy: orderBy?.call(PhotoFolderRecord.t),
      orderByList: orderByList?.call(PhotoFolderRecord.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [PhotoFolderRecord] by its [id] or null if no such row exists.
  Future<PhotoFolderRecord?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<PhotoFolderRecord>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [PhotoFolderRecord]s in the list and returns the inserted rows.
  ///
  /// The returned [PhotoFolderRecord]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<PhotoFolderRecord>> insert(
    _i1.Session session,
    List<PhotoFolderRecord> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<PhotoFolderRecord>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [PhotoFolderRecord] and returns the inserted row.
  ///
  /// The returned [PhotoFolderRecord] will have its `id` field set.
  Future<PhotoFolderRecord> insertRow(
    _i1.Session session,
    PhotoFolderRecord row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<PhotoFolderRecord>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [PhotoFolderRecord]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<PhotoFolderRecord>> update(
    _i1.Session session,
    List<PhotoFolderRecord> rows, {
    _i1.ColumnSelections<PhotoFolderRecordTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<PhotoFolderRecord>(
      rows,
      columns: columns?.call(PhotoFolderRecord.t),
      transaction: transaction,
    );
  }

  /// Updates a single [PhotoFolderRecord]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<PhotoFolderRecord> updateRow(
    _i1.Session session,
    PhotoFolderRecord row, {
    _i1.ColumnSelections<PhotoFolderRecordTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<PhotoFolderRecord>(
      row,
      columns: columns?.call(PhotoFolderRecord.t),
      transaction: transaction,
    );
  }

  /// Deletes all [PhotoFolderRecord]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<PhotoFolderRecord>> delete(
    _i1.Session session,
    List<PhotoFolderRecord> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<PhotoFolderRecord>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [PhotoFolderRecord].
  Future<PhotoFolderRecord> deleteRow(
    _i1.Session session,
    PhotoFolderRecord row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<PhotoFolderRecord>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<PhotoFolderRecord>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<PhotoFolderRecordTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<PhotoFolderRecord>(
      where: where(PhotoFolderRecord.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<PhotoFolderRecordTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<PhotoFolderRecord>(
      where: where?.call(PhotoFolderRecord.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
