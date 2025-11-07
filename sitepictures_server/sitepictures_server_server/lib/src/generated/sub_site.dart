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

/// Sub site model with flexible hierarchy
abstract class SubSite
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  SubSite._({
    this.id,
    required this.uuid,
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

  factory SubSite({
    int? id,
    required String uuid,
    String? clientId,
    String? mainSiteId,
    String? parentSubSiteId,
    required String name,
    String? description,
    required String createdBy,
    required DateTime createdAt,
    required DateTime updatedAt,
    required bool isActive,
  }) = _SubSiteImpl;

  factory SubSite.fromJson(Map<String, dynamic> jsonSerialization) {
    return SubSite(
      id: jsonSerialization['id'] as int?,
      uuid: jsonSerialization['uuid'] as String,
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

  static final t = SubSiteTable();

  static const db = SubSiteRepository._();

  @override
  int? id;

  /// UUID for compatibility with Flutter app
  String uuid;

  /// Parent client ID (if attached to client)
  String? clientId;

  /// Parent main site ID (if attached to main site)
  String? mainSiteId;

  /// Parent subsite ID (if nested subsite)
  String? parentSubSiteId;

  /// Site name
  String name;

  /// Optional description
  String? description;

  /// User who created this site
  String createdBy;

  /// When the site was created
  DateTime createdAt;

  /// When the site was last updated
  DateTime updatedAt;

  /// Active/inactive flag
  bool isActive;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [SubSite]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  SubSite copyWith({
    int? id,
    String? uuid,
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
      'uuid': uuid,
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
      'uuid': uuid,
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

  static SubSiteInclude include() {
    return SubSiteInclude._();
  }

  static SubSiteIncludeList includeList({
    _i1.WhereExpressionBuilder<SubSiteTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<SubSiteTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<SubSiteTable>? orderByList,
    SubSiteInclude? include,
  }) {
    return SubSiteIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(SubSite.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(SubSite.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _SubSiteImpl extends SubSite {
  _SubSiteImpl({
    int? id,
    required String uuid,
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
          uuid: uuid,
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

  /// Returns a shallow copy of this [SubSite]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  SubSite copyWith({
    Object? id = _Undefined,
    String? uuid,
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
    return SubSite(
      id: id is int? ? id : this.id,
      uuid: uuid ?? this.uuid,
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

class SubSiteTable extends _i1.Table<int?> {
  SubSiteTable({super.tableRelation}) : super(tableName: 'sub_sites') {
    uuid = _i1.ColumnString(
      'uuid',
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

  /// UUID for compatibility with Flutter app
  late final _i1.ColumnString uuid;

  /// Parent client ID (if attached to client)
  late final _i1.ColumnString clientId;

  /// Parent main site ID (if attached to main site)
  late final _i1.ColumnString mainSiteId;

  /// Parent subsite ID (if nested subsite)
  late final _i1.ColumnString parentSubSiteId;

  /// Site name
  late final _i1.ColumnString name;

  /// Optional description
  late final _i1.ColumnString description;

  /// User who created this site
  late final _i1.ColumnString createdBy;

  /// When the site was created
  late final _i1.ColumnDateTime createdAt;

  /// When the site was last updated
  late final _i1.ColumnDateTime updatedAt;

  /// Active/inactive flag
  late final _i1.ColumnBool isActive;

  @override
  List<_i1.Column> get columns => [
        id,
        uuid,
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

class SubSiteInclude extends _i1.IncludeObject {
  SubSiteInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => SubSite.t;
}

class SubSiteIncludeList extends _i1.IncludeList {
  SubSiteIncludeList._({
    _i1.WhereExpressionBuilder<SubSiteTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(SubSite.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => SubSite.t;
}

class SubSiteRepository {
  const SubSiteRepository._();

  /// Returns a list of [SubSite]s matching the given query parameters.
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
  Future<List<SubSite>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<SubSiteTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<SubSiteTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<SubSiteTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<SubSite>(
      where: where?.call(SubSite.t),
      orderBy: orderBy?.call(SubSite.t),
      orderByList: orderByList?.call(SubSite.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [SubSite] matching the given query parameters.
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
  Future<SubSite?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<SubSiteTable>? where,
    int? offset,
    _i1.OrderByBuilder<SubSiteTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<SubSiteTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<SubSite>(
      where: where?.call(SubSite.t),
      orderBy: orderBy?.call(SubSite.t),
      orderByList: orderByList?.call(SubSite.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [SubSite] by its [id] or null if no such row exists.
  Future<SubSite?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<SubSite>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [SubSite]s in the list and returns the inserted rows.
  ///
  /// The returned [SubSite]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<SubSite>> insert(
    _i1.Session session,
    List<SubSite> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<SubSite>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [SubSite] and returns the inserted row.
  ///
  /// The returned [SubSite] will have its `id` field set.
  Future<SubSite> insertRow(
    _i1.Session session,
    SubSite row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<SubSite>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [SubSite]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<SubSite>> update(
    _i1.Session session,
    List<SubSite> rows, {
    _i1.ColumnSelections<SubSiteTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<SubSite>(
      rows,
      columns: columns?.call(SubSite.t),
      transaction: transaction,
    );
  }

  /// Updates a single [SubSite]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<SubSite> updateRow(
    _i1.Session session,
    SubSite row, {
    _i1.ColumnSelections<SubSiteTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<SubSite>(
      row,
      columns: columns?.call(SubSite.t),
      transaction: transaction,
    );
  }

  /// Deletes all [SubSite]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<SubSite>> delete(
    _i1.Session session,
    List<SubSite> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<SubSite>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [SubSite].
  Future<SubSite> deleteRow(
    _i1.Session session,
    SubSite row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<SubSite>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<SubSite>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<SubSiteTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<SubSite>(
      where: where(SubSite.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<SubSiteTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<SubSite>(
      where: where?.call(SubSite.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
