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

/// Sync queue item for offline operations
abstract class SyncQueueItem
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  SyncQueueItem._({
    this.id,
    required this.uuid,
    required this.entityType,
    required this.entityId,
    required this.operation,
    required this.payload,
    required this.retryCount,
    required this.createdAt,
    this.lastAttempt,
    this.error,
    required this.isCompleted,
  });

  factory SyncQueueItem({
    int? id,
    required String uuid,
    required String entityType,
    required String entityId,
    required String operation,
    required String payload,
    required int retryCount,
    required DateTime createdAt,
    DateTime? lastAttempt,
    String? error,
    required bool isCompleted,
  }) = _SyncQueueItemImpl;

  factory SyncQueueItem.fromJson(Map<String, dynamic> jsonSerialization) {
    return SyncQueueItem(
      id: jsonSerialization['id'] as int?,
      uuid: jsonSerialization['uuid'] as String,
      entityType: jsonSerialization['entityType'] as String,
      entityId: jsonSerialization['entityId'] as String,
      operation: jsonSerialization['operation'] as String,
      payload: jsonSerialization['payload'] as String,
      retryCount: jsonSerialization['retryCount'] as int,
      createdAt:
          _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      lastAttempt: jsonSerialization['lastAttempt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(
              jsonSerialization['lastAttempt']),
      error: jsonSerialization['error'] as String?,
      isCompleted: jsonSerialization['isCompleted'] as bool,
    );
  }

  static final t = SyncQueueItemTable();

  static const db = SyncQueueItemRepository._();

  @override
  int? id;

  /// UUID for compatibility with Flutter app
  String uuid;

  /// Entity type (photo, client, site, equipment)
  String entityType;

  /// Entity ID
  String entityId;

  /// Operation (create, update, delete)
  String operation;

  /// JSON payload
  String payload;

  /// Retry count
  int retryCount;

  /// When the item was created
  DateTime createdAt;

  /// Last attempt timestamp
  DateTime? lastAttempt;

  /// Error message if failed
  String? error;

  /// Completion status
  bool isCompleted;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [SyncQueueItem]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  SyncQueueItem copyWith({
    int? id,
    String? uuid,
    String? entityType,
    String? entityId,
    String? operation,
    String? payload,
    int? retryCount,
    DateTime? createdAt,
    DateTime? lastAttempt,
    String? error,
    bool? isCompleted,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'uuid': uuid,
      'entityType': entityType,
      'entityId': entityId,
      'operation': operation,
      'payload': payload,
      'retryCount': retryCount,
      'createdAt': createdAt.toJson(),
      if (lastAttempt != null) 'lastAttempt': lastAttempt?.toJson(),
      if (error != null) 'error': error,
      'isCompleted': isCompleted,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      if (id != null) 'id': id,
      'uuid': uuid,
      'entityType': entityType,
      'entityId': entityId,
      'operation': operation,
      'payload': payload,
      'retryCount': retryCount,
      'createdAt': createdAt.toJson(),
      if (lastAttempt != null) 'lastAttempt': lastAttempt?.toJson(),
      if (error != null) 'error': error,
      'isCompleted': isCompleted,
    };
  }

  static SyncQueueItemInclude include() {
    return SyncQueueItemInclude._();
  }

  static SyncQueueItemIncludeList includeList({
    _i1.WhereExpressionBuilder<SyncQueueItemTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<SyncQueueItemTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<SyncQueueItemTable>? orderByList,
    SyncQueueItemInclude? include,
  }) {
    return SyncQueueItemIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(SyncQueueItem.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(SyncQueueItem.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _SyncQueueItemImpl extends SyncQueueItem {
  _SyncQueueItemImpl({
    int? id,
    required String uuid,
    required String entityType,
    required String entityId,
    required String operation,
    required String payload,
    required int retryCount,
    required DateTime createdAt,
    DateTime? lastAttempt,
    String? error,
    required bool isCompleted,
  }) : super._(
          id: id,
          uuid: uuid,
          entityType: entityType,
          entityId: entityId,
          operation: operation,
          payload: payload,
          retryCount: retryCount,
          createdAt: createdAt,
          lastAttempt: lastAttempt,
          error: error,
          isCompleted: isCompleted,
        );

  /// Returns a shallow copy of this [SyncQueueItem]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  SyncQueueItem copyWith({
    Object? id = _Undefined,
    String? uuid,
    String? entityType,
    String? entityId,
    String? operation,
    String? payload,
    int? retryCount,
    DateTime? createdAt,
    Object? lastAttempt = _Undefined,
    Object? error = _Undefined,
    bool? isCompleted,
  }) {
    return SyncQueueItem(
      id: id is int? ? id : this.id,
      uuid: uuid ?? this.uuid,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      operation: operation ?? this.operation,
      payload: payload ?? this.payload,
      retryCount: retryCount ?? this.retryCount,
      createdAt: createdAt ?? this.createdAt,
      lastAttempt: lastAttempt is DateTime? ? lastAttempt : this.lastAttempt,
      error: error is String? ? error : this.error,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class SyncQueueItemTable extends _i1.Table<int?> {
  SyncQueueItemTable({super.tableRelation}) : super(tableName: 'sync_queue') {
    uuid = _i1.ColumnString(
      'uuid',
      this,
    );
    entityType = _i1.ColumnString(
      'entityType',
      this,
    );
    entityId = _i1.ColumnString(
      'entityId',
      this,
    );
    operation = _i1.ColumnString(
      'operation',
      this,
    );
    payload = _i1.ColumnString(
      'payload',
      this,
    );
    retryCount = _i1.ColumnInt(
      'retryCount',
      this,
    );
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
    );
    lastAttempt = _i1.ColumnDateTime(
      'lastAttempt',
      this,
    );
    error = _i1.ColumnString(
      'error',
      this,
    );
    isCompleted = _i1.ColumnBool(
      'isCompleted',
      this,
    );
  }

  /// UUID for compatibility with Flutter app
  late final _i1.ColumnString uuid;

  /// Entity type (photo, client, site, equipment)
  late final _i1.ColumnString entityType;

  /// Entity ID
  late final _i1.ColumnString entityId;

  /// Operation (create, update, delete)
  late final _i1.ColumnString operation;

  /// JSON payload
  late final _i1.ColumnString payload;

  /// Retry count
  late final _i1.ColumnInt retryCount;

  /// When the item was created
  late final _i1.ColumnDateTime createdAt;

  /// Last attempt timestamp
  late final _i1.ColumnDateTime lastAttempt;

  /// Error message if failed
  late final _i1.ColumnString error;

  /// Completion status
  late final _i1.ColumnBool isCompleted;

  @override
  List<_i1.Column> get columns => [
        id,
        uuid,
        entityType,
        entityId,
        operation,
        payload,
        retryCount,
        createdAt,
        lastAttempt,
        error,
        isCompleted,
      ];
}

class SyncQueueItemInclude extends _i1.IncludeObject {
  SyncQueueItemInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => SyncQueueItem.t;
}

class SyncQueueItemIncludeList extends _i1.IncludeList {
  SyncQueueItemIncludeList._({
    _i1.WhereExpressionBuilder<SyncQueueItemTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(SyncQueueItem.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => SyncQueueItem.t;
}

class SyncQueueItemRepository {
  const SyncQueueItemRepository._();

  /// Returns a list of [SyncQueueItem]s matching the given query parameters.
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
  Future<List<SyncQueueItem>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<SyncQueueItemTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<SyncQueueItemTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<SyncQueueItemTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<SyncQueueItem>(
      where: where?.call(SyncQueueItem.t),
      orderBy: orderBy?.call(SyncQueueItem.t),
      orderByList: orderByList?.call(SyncQueueItem.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [SyncQueueItem] matching the given query parameters.
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
  Future<SyncQueueItem?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<SyncQueueItemTable>? where,
    int? offset,
    _i1.OrderByBuilder<SyncQueueItemTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<SyncQueueItemTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<SyncQueueItem>(
      where: where?.call(SyncQueueItem.t),
      orderBy: orderBy?.call(SyncQueueItem.t),
      orderByList: orderByList?.call(SyncQueueItem.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [SyncQueueItem] by its [id] or null if no such row exists.
  Future<SyncQueueItem?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<SyncQueueItem>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [SyncQueueItem]s in the list and returns the inserted rows.
  ///
  /// The returned [SyncQueueItem]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<SyncQueueItem>> insert(
    _i1.Session session,
    List<SyncQueueItem> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<SyncQueueItem>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [SyncQueueItem] and returns the inserted row.
  ///
  /// The returned [SyncQueueItem] will have its `id` field set.
  Future<SyncQueueItem> insertRow(
    _i1.Session session,
    SyncQueueItem row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<SyncQueueItem>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [SyncQueueItem]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<SyncQueueItem>> update(
    _i1.Session session,
    List<SyncQueueItem> rows, {
    _i1.ColumnSelections<SyncQueueItemTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<SyncQueueItem>(
      rows,
      columns: columns?.call(SyncQueueItem.t),
      transaction: transaction,
    );
  }

  /// Updates a single [SyncQueueItem]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<SyncQueueItem> updateRow(
    _i1.Session session,
    SyncQueueItem row, {
    _i1.ColumnSelections<SyncQueueItemTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<SyncQueueItem>(
      row,
      columns: columns?.call(SyncQueueItem.t),
      transaction: transaction,
    );
  }

  /// Deletes all [SyncQueueItem]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<SyncQueueItem>> delete(
    _i1.Session session,
    List<SyncQueueItem> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<SyncQueueItem>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [SyncQueueItem].
  Future<SyncQueueItem> deleteRow(
    _i1.Session session,
    SyncQueueItem row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<SyncQueueItem>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<SyncQueueItem>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<SyncQueueItemTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<SyncQueueItem>(
      where: where(SyncQueueItem.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<SyncQueueItemTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<SyncQueueItem>(
      where: where?.call(SyncQueueItem.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
