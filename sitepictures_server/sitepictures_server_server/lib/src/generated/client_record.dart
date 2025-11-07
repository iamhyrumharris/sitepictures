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

abstract class ClientRecord
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  ClientRecord._({
    this.id,
    required this.clientId,
    required this.name,
    this.description,
    required this.isSystem,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
  });

  factory ClientRecord({
    int? id,
    required String clientId,
    required String name,
    String? description,
    required bool isSystem,
    required String createdBy,
    required DateTime createdAt,
    required DateTime updatedAt,
    required bool isActive,
  }) = _ClientRecordImpl;

  factory ClientRecord.fromJson(Map<String, dynamic> jsonSerialization) {
    return ClientRecord(
      id: jsonSerialization['id'] as int?,
      clientId: jsonSerialization['clientId'] as String,
      name: jsonSerialization['name'] as String,
      description: jsonSerialization['description'] as String?,
      isSystem: jsonSerialization['isSystem'] as bool,
      createdBy: jsonSerialization['createdBy'] as String,
      createdAt:
          _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt:
          _i1.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
      isActive: jsonSerialization['isActive'] as bool,
    );
  }

  static final t = ClientRecordTable();

  static const db = ClientRecordRepository._();

  @override
  int? id;

  String clientId;

  String name;

  String? description;

  bool isSystem;

  String createdBy;

  DateTime createdAt;

  DateTime updatedAt;

  bool isActive;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [ClientRecord]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ClientRecord copyWith({
    int? id,
    String? clientId,
    String? name,
    String? description,
    bool? isSystem,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'clientId': clientId,
      'name': name,
      if (description != null) 'description': description,
      'isSystem': isSystem,
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
      'clientId': clientId,
      'name': name,
      if (description != null) 'description': description,
      'isSystem': isSystem,
      'createdBy': createdBy,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
      'isActive': isActive,
    };
  }

  static ClientRecordInclude include() {
    return ClientRecordInclude._();
  }

  static ClientRecordIncludeList includeList({
    _i1.WhereExpressionBuilder<ClientRecordTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ClientRecordTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ClientRecordTable>? orderByList,
    ClientRecordInclude? include,
  }) {
    return ClientRecordIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ClientRecord.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(ClientRecord.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ClientRecordImpl extends ClientRecord {
  _ClientRecordImpl({
    int? id,
    required String clientId,
    required String name,
    String? description,
    required bool isSystem,
    required String createdBy,
    required DateTime createdAt,
    required DateTime updatedAt,
    required bool isActive,
  }) : super._(
          id: id,
          clientId: clientId,
          name: name,
          description: description,
          isSystem: isSystem,
          createdBy: createdBy,
          createdAt: createdAt,
          updatedAt: updatedAt,
          isActive: isActive,
        );

  /// Returns a shallow copy of this [ClientRecord]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ClientRecord copyWith({
    Object? id = _Undefined,
    String? clientId,
    String? name,
    Object? description = _Undefined,
    bool? isSystem,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return ClientRecord(
      id: id is int? ? id : this.id,
      clientId: clientId ?? this.clientId,
      name: name ?? this.name,
      description: description is String? ? description : this.description,
      isSystem: isSystem ?? this.isSystem,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }
}

class ClientRecordTable extends _i1.Table<int?> {
  ClientRecordTable({super.tableRelation})
      : super(tableName: 'client_records') {
    clientId = _i1.ColumnString(
      'clientId',
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
    isSystem = _i1.ColumnBool(
      'isSystem',
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

  late final _i1.ColumnString clientId;

  late final _i1.ColumnString name;

  late final _i1.ColumnString description;

  late final _i1.ColumnBool isSystem;

  late final _i1.ColumnString createdBy;

  late final _i1.ColumnDateTime createdAt;

  late final _i1.ColumnDateTime updatedAt;

  late final _i1.ColumnBool isActive;

  @override
  List<_i1.Column> get columns => [
        id,
        clientId,
        name,
        description,
        isSystem,
        createdBy,
        createdAt,
        updatedAt,
        isActive,
      ];
}

class ClientRecordInclude extends _i1.IncludeObject {
  ClientRecordInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => ClientRecord.t;
}

class ClientRecordIncludeList extends _i1.IncludeList {
  ClientRecordIncludeList._({
    _i1.WhereExpressionBuilder<ClientRecordTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(ClientRecord.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => ClientRecord.t;
}

class ClientRecordRepository {
  const ClientRecordRepository._();

  /// Returns a list of [ClientRecord]s matching the given query parameters.
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
  Future<List<ClientRecord>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<ClientRecordTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ClientRecordTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ClientRecordTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<ClientRecord>(
      where: where?.call(ClientRecord.t),
      orderBy: orderBy?.call(ClientRecord.t),
      orderByList: orderByList?.call(ClientRecord.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [ClientRecord] matching the given query parameters.
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
  Future<ClientRecord?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<ClientRecordTable>? where,
    int? offset,
    _i1.OrderByBuilder<ClientRecordTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ClientRecordTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<ClientRecord>(
      where: where?.call(ClientRecord.t),
      orderBy: orderBy?.call(ClientRecord.t),
      orderByList: orderByList?.call(ClientRecord.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [ClientRecord] by its [id] or null if no such row exists.
  Future<ClientRecord?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<ClientRecord>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [ClientRecord]s in the list and returns the inserted rows.
  ///
  /// The returned [ClientRecord]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<ClientRecord>> insert(
    _i1.Session session,
    List<ClientRecord> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<ClientRecord>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [ClientRecord] and returns the inserted row.
  ///
  /// The returned [ClientRecord] will have its `id` field set.
  Future<ClientRecord> insertRow(
    _i1.Session session,
    ClientRecord row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<ClientRecord>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [ClientRecord]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<ClientRecord>> update(
    _i1.Session session,
    List<ClientRecord> rows, {
    _i1.ColumnSelections<ClientRecordTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<ClientRecord>(
      rows,
      columns: columns?.call(ClientRecord.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ClientRecord]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<ClientRecord> updateRow(
    _i1.Session session,
    ClientRecord row, {
    _i1.ColumnSelections<ClientRecordTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<ClientRecord>(
      row,
      columns: columns?.call(ClientRecord.t),
      transaction: transaction,
    );
  }

  /// Deletes all [ClientRecord]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<ClientRecord>> delete(
    _i1.Session session,
    List<ClientRecord> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<ClientRecord>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [ClientRecord].
  Future<ClientRecord> deleteRow(
    _i1.Session session,
    ClientRecord row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<ClientRecord>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<ClientRecord>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<ClientRecordTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<ClientRecord>(
      where: where(ClientRecord.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<ClientRecordTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<ClientRecord>(
      where: where?.call(ClientRecord.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
