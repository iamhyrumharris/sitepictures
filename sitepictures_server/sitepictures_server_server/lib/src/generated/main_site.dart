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

/// Main site model
abstract class MainSite
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  MainSite._({
    this.id,
    required this.uuid,
    required this.clientId,
    required this.name,
    this.address,
    this.latitude,
    this.longitude,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
  });

  factory MainSite({
    int? id,
    required String uuid,
    required String clientId,
    required String name,
    String? address,
    double? latitude,
    double? longitude,
    required String createdBy,
    required DateTime createdAt,
    required DateTime updatedAt,
    required bool isActive,
  }) = _MainSiteImpl;

  factory MainSite.fromJson(Map<String, dynamic> jsonSerialization) {
    return MainSite(
      id: jsonSerialization['id'] as int?,
      uuid: jsonSerialization['uuid'] as String,
      clientId: jsonSerialization['clientId'] as String,
      name: jsonSerialization['name'] as String,
      address: jsonSerialization['address'] as String?,
      latitude: (jsonSerialization['latitude'] as num?)?.toDouble(),
      longitude: (jsonSerialization['longitude'] as num?)?.toDouble(),
      createdBy: jsonSerialization['createdBy'] as String,
      createdAt:
          _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt:
          _i1.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
      isActive: jsonSerialization['isActive'] as bool,
    );
  }

  static final t = MainSiteTable();

  static const db = MainSiteRepository._();

  @override
  int? id;

  /// UUID for compatibility with Flutter app
  String uuid;

  /// Parent client ID
  String clientId;

  /// Site name
  String name;

  /// Optional address
  String? address;

  /// Latitude coordinate
  double? latitude;

  /// Longitude coordinate
  double? longitude;

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

  /// Returns a shallow copy of this [MainSite]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  MainSite copyWith({
    int? id,
    String? uuid,
    String? clientId,
    String? name,
    String? address,
    double? latitude,
    double? longitude,
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
      'clientId': clientId,
      'name': name,
      if (address != null) 'address': address,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
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
      'clientId': clientId,
      'name': name,
      if (address != null) 'address': address,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      'createdBy': createdBy,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
      'isActive': isActive,
    };
  }

  static MainSiteInclude include() {
    return MainSiteInclude._();
  }

  static MainSiteIncludeList includeList({
    _i1.WhereExpressionBuilder<MainSiteTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<MainSiteTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<MainSiteTable>? orderByList,
    MainSiteInclude? include,
  }) {
    return MainSiteIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(MainSite.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(MainSite.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _MainSiteImpl extends MainSite {
  _MainSiteImpl({
    int? id,
    required String uuid,
    required String clientId,
    required String name,
    String? address,
    double? latitude,
    double? longitude,
    required String createdBy,
    required DateTime createdAt,
    required DateTime updatedAt,
    required bool isActive,
  }) : super._(
          id: id,
          uuid: uuid,
          clientId: clientId,
          name: name,
          address: address,
          latitude: latitude,
          longitude: longitude,
          createdBy: createdBy,
          createdAt: createdAt,
          updatedAt: updatedAt,
          isActive: isActive,
        );

  /// Returns a shallow copy of this [MainSite]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  MainSite copyWith({
    Object? id = _Undefined,
    String? uuid,
    String? clientId,
    String? name,
    Object? address = _Undefined,
    Object? latitude = _Undefined,
    Object? longitude = _Undefined,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return MainSite(
      id: id is int? ? id : this.id,
      uuid: uuid ?? this.uuid,
      clientId: clientId ?? this.clientId,
      name: name ?? this.name,
      address: address is String? ? address : this.address,
      latitude: latitude is double? ? latitude : this.latitude,
      longitude: longitude is double? ? longitude : this.longitude,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }
}

class MainSiteTable extends _i1.Table<int?> {
  MainSiteTable({super.tableRelation}) : super(tableName: 'main_sites') {
    uuid = _i1.ColumnString(
      'uuid',
      this,
    );
    clientId = _i1.ColumnString(
      'clientId',
      this,
    );
    name = _i1.ColumnString(
      'name',
      this,
    );
    address = _i1.ColumnString(
      'address',
      this,
    );
    latitude = _i1.ColumnDouble(
      'latitude',
      this,
    );
    longitude = _i1.ColumnDouble(
      'longitude',
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

  /// Parent client ID
  late final _i1.ColumnString clientId;

  /// Site name
  late final _i1.ColumnString name;

  /// Optional address
  late final _i1.ColumnString address;

  /// Latitude coordinate
  late final _i1.ColumnDouble latitude;

  /// Longitude coordinate
  late final _i1.ColumnDouble longitude;

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
        name,
        address,
        latitude,
        longitude,
        createdBy,
        createdAt,
        updatedAt,
        isActive,
      ];
}

class MainSiteInclude extends _i1.IncludeObject {
  MainSiteInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => MainSite.t;
}

class MainSiteIncludeList extends _i1.IncludeList {
  MainSiteIncludeList._({
    _i1.WhereExpressionBuilder<MainSiteTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(MainSite.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => MainSite.t;
}

class MainSiteRepository {
  const MainSiteRepository._();

  /// Returns a list of [MainSite]s matching the given query parameters.
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
  Future<List<MainSite>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<MainSiteTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<MainSiteTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<MainSiteTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<MainSite>(
      where: where?.call(MainSite.t),
      orderBy: orderBy?.call(MainSite.t),
      orderByList: orderByList?.call(MainSite.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [MainSite] matching the given query parameters.
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
  Future<MainSite?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<MainSiteTable>? where,
    int? offset,
    _i1.OrderByBuilder<MainSiteTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<MainSiteTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<MainSite>(
      where: where?.call(MainSite.t),
      orderBy: orderBy?.call(MainSite.t),
      orderByList: orderByList?.call(MainSite.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [MainSite] by its [id] or null if no such row exists.
  Future<MainSite?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<MainSite>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [MainSite]s in the list and returns the inserted rows.
  ///
  /// The returned [MainSite]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<MainSite>> insert(
    _i1.Session session,
    List<MainSite> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<MainSite>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [MainSite] and returns the inserted row.
  ///
  /// The returned [MainSite] will have its `id` field set.
  Future<MainSite> insertRow(
    _i1.Session session,
    MainSite row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<MainSite>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [MainSite]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<MainSite>> update(
    _i1.Session session,
    List<MainSite> rows, {
    _i1.ColumnSelections<MainSiteTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<MainSite>(
      rows,
      columns: columns?.call(MainSite.t),
      transaction: transaction,
    );
  }

  /// Updates a single [MainSite]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<MainSite> updateRow(
    _i1.Session session,
    MainSite row, {
    _i1.ColumnSelections<MainSiteTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<MainSite>(
      row,
      columns: columns?.call(MainSite.t),
      transaction: transaction,
    );
  }

  /// Deletes all [MainSite]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<MainSite>> delete(
    _i1.Session session,
    List<MainSite> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<MainSite>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [MainSite].
  Future<MainSite> deleteRow(
    _i1.Session session,
    MainSite row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<MainSite>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<MainSite>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<MainSiteTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<MainSite>(
      where: where(MainSite.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<MainSiteTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<MainSite>(
      where: where?.call(MainSite.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
