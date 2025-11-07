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

/// Photo folder model for organizing photos
abstract class PhotoFolder
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  PhotoFolder._({
    this.id,
    required this.uuid,
    required this.equipmentId,
    required this.name,
    required this.workOrder,
    required this.createdAt,
    required this.createdBy,
    required this.isDeleted,
  });

  factory PhotoFolder({
    int? id,
    required String uuid,
    required String equipmentId,
    required String name,
    required String workOrder,
    required DateTime createdAt,
    required String createdBy,
    required bool isDeleted,
  }) = _PhotoFolderImpl;

  factory PhotoFolder.fromJson(Map<String, dynamic> jsonSerialization) {
    return PhotoFolder(
      id: jsonSerialization['id'] as int?,
      uuid: jsonSerialization['uuid'] as String,
      equipmentId: jsonSerialization['equipmentId'] as String,
      name: jsonSerialization['name'] as String,
      workOrder: jsonSerialization['workOrder'] as String,
      createdAt:
          _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      createdBy: jsonSerialization['createdBy'] as String,
      isDeleted: jsonSerialization['isDeleted'] as bool,
    );
  }

  static final t = PhotoFolderTable();

  static const db = PhotoFolderRepository._();

  @override
  int? id;

  /// UUID for compatibility with Flutter app
  String uuid;

  /// Equipment ID this folder belongs to
  String equipmentId;

  /// Folder name
  String name;

  /// Work order number
  String workOrder;

  /// When the folder was created
  DateTime createdAt;

  /// User who created this folder
  String createdBy;

  /// Soft delete flag
  bool isDeleted;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [PhotoFolder]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  PhotoFolder copyWith({
    int? id,
    String? uuid,
    String? equipmentId,
    String? name,
    String? workOrder,
    DateTime? createdAt,
    String? createdBy,
    bool? isDeleted,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'uuid': uuid,
      'equipmentId': equipmentId,
      'name': name,
      'workOrder': workOrder,
      'createdAt': createdAt.toJson(),
      'createdBy': createdBy,
      'isDeleted': isDeleted,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      if (id != null) 'id': id,
      'uuid': uuid,
      'equipmentId': equipmentId,
      'name': name,
      'workOrder': workOrder,
      'createdAt': createdAt.toJson(),
      'createdBy': createdBy,
      'isDeleted': isDeleted,
    };
  }

  static PhotoFolderInclude include() {
    return PhotoFolderInclude._();
  }

  static PhotoFolderIncludeList includeList({
    _i1.WhereExpressionBuilder<PhotoFolderTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<PhotoFolderTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<PhotoFolderTable>? orderByList,
    PhotoFolderInclude? include,
  }) {
    return PhotoFolderIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PhotoFolder.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(PhotoFolder.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PhotoFolderImpl extends PhotoFolder {
  _PhotoFolderImpl({
    int? id,
    required String uuid,
    required String equipmentId,
    required String name,
    required String workOrder,
    required DateTime createdAt,
    required String createdBy,
    required bool isDeleted,
  }) : super._(
          id: id,
          uuid: uuid,
          equipmentId: equipmentId,
          name: name,
          workOrder: workOrder,
          createdAt: createdAt,
          createdBy: createdBy,
          isDeleted: isDeleted,
        );

  /// Returns a shallow copy of this [PhotoFolder]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  PhotoFolder copyWith({
    Object? id = _Undefined,
    String? uuid,
    String? equipmentId,
    String? name,
    String? workOrder,
    DateTime? createdAt,
    String? createdBy,
    bool? isDeleted,
  }) {
    return PhotoFolder(
      id: id is int? ? id : this.id,
      uuid: uuid ?? this.uuid,
      equipmentId: equipmentId ?? this.equipmentId,
      name: name ?? this.name,
      workOrder: workOrder ?? this.workOrder,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}

class PhotoFolderTable extends _i1.Table<int?> {
  PhotoFolderTable({super.tableRelation}) : super(tableName: 'photo_folders') {
    uuid = _i1.ColumnString(
      'uuid',
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
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
    );
    createdBy = _i1.ColumnString(
      'createdBy',
      this,
    );
    isDeleted = _i1.ColumnBool(
      'isDeleted',
      this,
    );
  }

  /// UUID for compatibility with Flutter app
  late final _i1.ColumnString uuid;

  /// Equipment ID this folder belongs to
  late final _i1.ColumnString equipmentId;

  /// Folder name
  late final _i1.ColumnString name;

  /// Work order number
  late final _i1.ColumnString workOrder;

  /// When the folder was created
  late final _i1.ColumnDateTime createdAt;

  /// User who created this folder
  late final _i1.ColumnString createdBy;

  /// Soft delete flag
  late final _i1.ColumnBool isDeleted;

  @override
  List<_i1.Column> get columns => [
        id,
        uuid,
        equipmentId,
        name,
        workOrder,
        createdAt,
        createdBy,
        isDeleted,
      ];
}

class PhotoFolderInclude extends _i1.IncludeObject {
  PhotoFolderInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => PhotoFolder.t;
}

class PhotoFolderIncludeList extends _i1.IncludeList {
  PhotoFolderIncludeList._({
    _i1.WhereExpressionBuilder<PhotoFolderTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(PhotoFolder.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => PhotoFolder.t;
}

class PhotoFolderRepository {
  const PhotoFolderRepository._();

  /// Returns a list of [PhotoFolder]s matching the given query parameters.
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
  Future<List<PhotoFolder>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<PhotoFolderTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<PhotoFolderTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<PhotoFolderTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<PhotoFolder>(
      where: where?.call(PhotoFolder.t),
      orderBy: orderBy?.call(PhotoFolder.t),
      orderByList: orderByList?.call(PhotoFolder.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [PhotoFolder] matching the given query parameters.
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
  Future<PhotoFolder?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<PhotoFolderTable>? where,
    int? offset,
    _i1.OrderByBuilder<PhotoFolderTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<PhotoFolderTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<PhotoFolder>(
      where: where?.call(PhotoFolder.t),
      orderBy: orderBy?.call(PhotoFolder.t),
      orderByList: orderByList?.call(PhotoFolder.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [PhotoFolder] by its [id] or null if no such row exists.
  Future<PhotoFolder?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<PhotoFolder>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [PhotoFolder]s in the list and returns the inserted rows.
  ///
  /// The returned [PhotoFolder]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<PhotoFolder>> insert(
    _i1.Session session,
    List<PhotoFolder> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<PhotoFolder>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [PhotoFolder] and returns the inserted row.
  ///
  /// The returned [PhotoFolder] will have its `id` field set.
  Future<PhotoFolder> insertRow(
    _i1.Session session,
    PhotoFolder row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<PhotoFolder>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [PhotoFolder]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<PhotoFolder>> update(
    _i1.Session session,
    List<PhotoFolder> rows, {
    _i1.ColumnSelections<PhotoFolderTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<PhotoFolder>(
      rows,
      columns: columns?.call(PhotoFolder.t),
      transaction: transaction,
    );
  }

  /// Updates a single [PhotoFolder]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<PhotoFolder> updateRow(
    _i1.Session session,
    PhotoFolder row, {
    _i1.ColumnSelections<PhotoFolderTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<PhotoFolder>(
      row,
      columns: columns?.call(PhotoFolder.t),
      transaction: transaction,
    );
  }

  /// Deletes all [PhotoFolder]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<PhotoFolder>> delete(
    _i1.Session session,
    List<PhotoFolder> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<PhotoFolder>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [PhotoFolder].
  Future<PhotoFolder> deleteRow(
    _i1.Session session,
    PhotoFolder row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<PhotoFolder>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<PhotoFolder>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<PhotoFolderTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<PhotoFolder>(
      where: where(PhotoFolder.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<PhotoFolderTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<PhotoFolder>(
      where: where?.call(PhotoFolder.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
