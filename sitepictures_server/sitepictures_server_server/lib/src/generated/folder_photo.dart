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

/// Junction table for folder-photo relationships
abstract class FolderPhoto
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  FolderPhoto._({
    this.id,
    required this.folderId,
    required this.photoId,
    required this.beforeAfter,
    required this.addedAt,
  });

  factory FolderPhoto({
    int? id,
    required String folderId,
    required String photoId,
    required String beforeAfter,
    required DateTime addedAt,
  }) = _FolderPhotoImpl;

  factory FolderPhoto.fromJson(Map<String, dynamic> jsonSerialization) {
    return FolderPhoto(
      id: jsonSerialization['id'] as int?,
      folderId: jsonSerialization['folderId'] as String,
      photoId: jsonSerialization['photoId'] as String,
      beforeAfter: jsonSerialization['beforeAfter'] as String,
      addedAt: _i1.DateTimeJsonExtension.fromJson(jsonSerialization['addedAt']),
    );
  }

  static final t = FolderPhotoTable();

  static const db = FolderPhotoRepository._();

  @override
  int? id;

  /// Folder ID
  String folderId;

  /// Photo ID
  String photoId;

  /// Before or after indicator
  String beforeAfter;

  /// When the photo was added to folder
  DateTime addedAt;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [FolderPhoto]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  FolderPhoto copyWith({
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

  static FolderPhotoInclude include() {
    return FolderPhotoInclude._();
  }

  static FolderPhotoIncludeList includeList({
    _i1.WhereExpressionBuilder<FolderPhotoTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<FolderPhotoTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<FolderPhotoTable>? orderByList,
    FolderPhotoInclude? include,
  }) {
    return FolderPhotoIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(FolderPhoto.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(FolderPhoto.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _FolderPhotoImpl extends FolderPhoto {
  _FolderPhotoImpl({
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

  /// Returns a shallow copy of this [FolderPhoto]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  FolderPhoto copyWith({
    Object? id = _Undefined,
    String? folderId,
    String? photoId,
    String? beforeAfter,
    DateTime? addedAt,
  }) {
    return FolderPhoto(
      id: id is int? ? id : this.id,
      folderId: folderId ?? this.folderId,
      photoId: photoId ?? this.photoId,
      beforeAfter: beforeAfter ?? this.beforeAfter,
      addedAt: addedAt ?? this.addedAt,
    );
  }
}

class FolderPhotoTable extends _i1.Table<int?> {
  FolderPhotoTable({super.tableRelation}) : super(tableName: 'folder_photos') {
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

  /// Folder ID
  late final _i1.ColumnString folderId;

  /// Photo ID
  late final _i1.ColumnString photoId;

  /// Before or after indicator
  late final _i1.ColumnString beforeAfter;

  /// When the photo was added to folder
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

class FolderPhotoInclude extends _i1.IncludeObject {
  FolderPhotoInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => FolderPhoto.t;
}

class FolderPhotoIncludeList extends _i1.IncludeList {
  FolderPhotoIncludeList._({
    _i1.WhereExpressionBuilder<FolderPhotoTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(FolderPhoto.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => FolderPhoto.t;
}

class FolderPhotoRepository {
  const FolderPhotoRepository._();

  /// Returns a list of [FolderPhoto]s matching the given query parameters.
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
  Future<List<FolderPhoto>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<FolderPhotoTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<FolderPhotoTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<FolderPhotoTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<FolderPhoto>(
      where: where?.call(FolderPhoto.t),
      orderBy: orderBy?.call(FolderPhoto.t),
      orderByList: orderByList?.call(FolderPhoto.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [FolderPhoto] matching the given query parameters.
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
  Future<FolderPhoto?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<FolderPhotoTable>? where,
    int? offset,
    _i1.OrderByBuilder<FolderPhotoTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<FolderPhotoTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<FolderPhoto>(
      where: where?.call(FolderPhoto.t),
      orderBy: orderBy?.call(FolderPhoto.t),
      orderByList: orderByList?.call(FolderPhoto.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [FolderPhoto] by its [id] or null if no such row exists.
  Future<FolderPhoto?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<FolderPhoto>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [FolderPhoto]s in the list and returns the inserted rows.
  ///
  /// The returned [FolderPhoto]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<FolderPhoto>> insert(
    _i1.Session session,
    List<FolderPhoto> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<FolderPhoto>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [FolderPhoto] and returns the inserted row.
  ///
  /// The returned [FolderPhoto] will have its `id` field set.
  Future<FolderPhoto> insertRow(
    _i1.Session session,
    FolderPhoto row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<FolderPhoto>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [FolderPhoto]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<FolderPhoto>> update(
    _i1.Session session,
    List<FolderPhoto> rows, {
    _i1.ColumnSelections<FolderPhotoTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<FolderPhoto>(
      rows,
      columns: columns?.call(FolderPhoto.t),
      transaction: transaction,
    );
  }

  /// Updates a single [FolderPhoto]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<FolderPhoto> updateRow(
    _i1.Session session,
    FolderPhoto row, {
    _i1.ColumnSelections<FolderPhotoTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<FolderPhoto>(
      row,
      columns: columns?.call(FolderPhoto.t),
      transaction: transaction,
    );
  }

  /// Deletes all [FolderPhoto]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<FolderPhoto>> delete(
    _i1.Session session,
    List<FolderPhoto> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<FolderPhoto>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [FolderPhoto].
  Future<FolderPhoto> deleteRow(
    _i1.Session session,
    FolderPhoto row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<FolderPhoto>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<FolderPhoto>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<FolderPhotoTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<FolderPhoto>(
      where: where(FolderPhoto.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<FolderPhotoTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<FolderPhoto>(
      where: where?.call(FolderPhoto.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
