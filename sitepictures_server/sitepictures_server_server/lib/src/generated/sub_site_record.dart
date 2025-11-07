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

abstract class SubSiteRecord
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  SubSiteRecord._({
    this.id,
    required this.subSiteId,
    this.clientId,
    this.mainSiteId,
    this.parentSubSiteId,
    required this.name,
    this.description,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
  });

  factory SubSiteRecord({
    int? id,
    required String subSiteId,
    String? clientId,
    String? mainSiteId,
    String? parentSubSiteId,
    required String name,
    String? description,
    required String createdBy,
    required DateTime createdAt,
    required DateTime updatedAt,
    required bool isActive,
  }) = _SubSiteRecordImpl;

  factory SubSiteRecord.fromJson(Map<String, dynamic> jsonSerialization) {
    return SubSiteRecord(
      id: jsonSerialization['id'] as int?,
      subSiteId: jsonSerialization['subSiteId'] as String,
      clientId: jsonSerialization['clientId'] as String?,
      mainSiteId: jsonSerialization['mainSiteId'] as String?,
      parentSubSiteId: jsonSerialization['parentSubSiteId'] as String?,
      name: jsonSerialization['name'] as String,
      description: jsonSerialization['description'] as String?,
      createdBy: jsonSerialization['createdBy'] as String,
      createdAt:
          _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt:
          _i1.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
      isActive: jsonSerialization['isActive'] as bool,
    );
  }

  static final t = SubSiteRecordTable();

  static const db = SubSiteRecordRepository._();

  @override
  int? id;

  String subSiteId;

  String? clientId;

  String? mainSiteId;

  String? parentSubSiteId;

  String name;

  String? description;

  String createdBy;

  DateTime createdAt;

  DateTime updatedAt;

  bool isActive;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [SubSiteRecord]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  SubSiteRecord copyWith({
    int? id,
    String? subSiteId,
    String? clientId,
    String? mainSiteId,
    String? parentSubSiteId,
    String? name,
    String? description,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'subSiteId': subSiteId,
      if (clientId != null) 'clientId': clientId,
      if (mainSiteId != null) 'mainSiteId': mainSiteId,
      if (parentSubSiteId != null) 'parentSubSiteId': parentSubSiteId,
      'name': name,
      if (description != null) 'description': description,
      'createdBy': createdBy,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
      'isActive': isActive,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      if (id != null) 'id': id,
      'subSiteId': subSiteId,
      if (clientId != null) 'clientId': clientId,
      if (mainSiteId != null) 'mainSiteId': mainSiteId,
      if (parentSubSiteId != null) 'parentSubSiteId': parentSubSiteId,
      'name': name,
      if (description != null) 'description': description,
      'createdBy': createdBy,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
      'isActive': isActive,
    };
  }

  static SubSiteRecordInclude include() {
    return SubSiteRecordInclude._();
  }

  static SubSiteRecordIncludeList includeList({
    _i1.WhereExpressionBuilder<SubSiteRecordTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<SubSiteRecordTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<SubSiteRecordTable>? orderByList,
    SubSiteRecordInclude? include,
  }) {
    return SubSiteRecordIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(SubSiteRecord.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(SubSiteRecord.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _SubSiteRecordImpl extends SubSiteRecord {
  _SubSiteRecordImpl({
    int? id,
    required String subSiteId,
    String? clientId,
    String? mainSiteId,
    String? parentSubSiteId,
    required String name,
    String? description,
    required String createdBy,
    required DateTime createdAt,
    required DateTime updatedAt,
    required bool isActive,
  }) : super._(
          id: id,
          subSiteId: subSiteId,
          clientId: clientId,
          mainSiteId: mainSiteId,
          parentSubSiteId: parentSubSiteId,
          name: name,
          description: description,
          createdBy: createdBy,
          createdAt: createdAt,
          updatedAt: updatedAt,
          isActive: isActive,
        );

  /// Returns a shallow copy of this [SubSiteRecord]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  SubSiteRecord copyWith({
    Object? id = _Undefined,
    String? subSiteId,
    Object? clientId = _Undefined,
    Object? mainSiteId = _Undefined,
    Object? parentSubSiteId = _Undefined,
    String? name,
    Object? description = _Undefined,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return SubSiteRecord(
      id: id is int? ? id : this.id,
      subSiteId: subSiteId ?? this.subSiteId,
      clientId: clientId is String? ? clientId : this.clientId,
      mainSiteId: mainSiteId is String? ? mainSiteId : this.mainSiteId,
      parentSubSiteId:
          parentSubSiteId is String? ? parentSubSiteId : this.parentSubSiteId,
      name: name ?? this.name,
      description: description is String? ? description : this.description,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }
}

class SubSiteRecordTable extends _i1.Table<int?> {
  SubSiteRecordTable({super.tableRelation})
      : super(tableName: 'sub_site_records') {
    subSiteId = _i1.ColumnString(
      'subSiteId',
      this,
    );
    clientId = _i1.ColumnString(
      'clientId',
      this,
    );
    mainSiteId = _i1.ColumnString(
      'mainSiteId',
      this,
    );
    parentSubSiteId = _i1.ColumnString(
      'parentSubSiteId',
      this,
    );
    name = _i1.ColumnString(
      'name',
      this,
    );
    description = _i1.ColumnString(
      'description',
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
    isActive = _i1.ColumnBool(
      'isActive',
      this,
    );
  }

  late final _i1.ColumnString subSiteId;

  late final _i1.ColumnString clientId;

  late final _i1.ColumnString mainSiteId;

  late final _i1.ColumnString parentSubSiteId;

  late final _i1.ColumnString name;

  late final _i1.ColumnString description;

  late final _i1.ColumnString createdBy;

  late final _i1.ColumnDateTime createdAt;

  late final _i1.ColumnDateTime updatedAt;

  late final _i1.ColumnBool isActive;

  @override
  List<_i1.Column> get columns => [
        id,
        subSiteId,
        clientId,
        mainSiteId,
        parentSubSiteId,
        name,
        description,
        createdBy,
        createdAt,
        updatedAt,
        isActive,
      ];
}

class SubSiteRecordInclude extends _i1.IncludeObject {
  SubSiteRecordInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => SubSiteRecord.t;
}

class SubSiteRecordIncludeList extends _i1.IncludeList {
  SubSiteRecordIncludeList._({
    _i1.WhereExpressionBuilder<SubSiteRecordTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(SubSiteRecord.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => SubSiteRecord.t;
}

class SubSiteRecordRepository {
  const SubSiteRecordRepository._();

  /// Returns a list of [SubSiteRecord]s matching the given query parameters.
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
  Future<List<SubSiteRecord>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<SubSiteRecordTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<SubSiteRecordTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<SubSiteRecordTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<SubSiteRecord>(
      where: where?.call(SubSiteRecord.t),
      orderBy: orderBy?.call(SubSiteRecord.t),
      orderByList: orderByList?.call(SubSiteRecord.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [SubSiteRecord] matching the given query parameters.
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
  Future<SubSiteRecord?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<SubSiteRecordTable>? where,
    int? offset,
    _i1.OrderByBuilder<SubSiteRecordTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<SubSiteRecordTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<SubSiteRecord>(
      where: where?.call(SubSiteRecord.t),
      orderBy: orderBy?.call(SubSiteRecord.t),
      orderByList: orderByList?.call(SubSiteRecord.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [SubSiteRecord] by its [id] or null if no such row exists.
  Future<SubSiteRecord?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<SubSiteRecord>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [SubSiteRecord]s in the list and returns the inserted rows.
  ///
  /// The returned [SubSiteRecord]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<SubSiteRecord>> insert(
    _i1.Session session,
    List<SubSiteRecord> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<SubSiteRecord>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [SubSiteRecord] and returns the inserted row.
  ///
  /// The returned [SubSiteRecord] will have its `id` field set.
  Future<SubSiteRecord> insertRow(
    _i1.Session session,
    SubSiteRecord row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<SubSiteRecord>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [SubSiteRecord]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<SubSiteRecord>> update(
    _i1.Session session,
    List<SubSiteRecord> rows, {
    _i1.ColumnSelections<SubSiteRecordTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<SubSiteRecord>(
      rows,
      columns: columns?.call(SubSiteRecord.t),
      transaction: transaction,
    );
  }

  /// Updates a single [SubSiteRecord]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<SubSiteRecord> updateRow(
    _i1.Session session,
    SubSiteRecord row, {
    _i1.ColumnSelections<SubSiteRecordTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<SubSiteRecord>(
      row,
      columns: columns?.call(SubSiteRecord.t),
      transaction: transaction,
    );
  }

  /// Deletes all [SubSiteRecord]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<SubSiteRecord>> delete(
    _i1.Session session,
    List<SubSiteRecord> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<SubSiteRecord>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [SubSiteRecord].
  Future<SubSiteRecord> deleteRow(
    _i1.Session session,
    SubSiteRecord row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<SubSiteRecord>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<SubSiteRecord>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<SubSiteRecordTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<SubSiteRecord>(
      where: where(SubSiteRecord.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<SubSiteRecordTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<SubSiteRecord>(
      where: where?.call(SubSiteRecord.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
