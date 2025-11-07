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

abstract class MainSiteRecord
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  MainSiteRecord._({
    this.id,
    required this.mainSiteId,
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

  factory MainSiteRecord({
    int? id,
    required String mainSiteId,
    required String clientId,
    required String name,
    String? address,
    double? latitude,
    double? longitude,
    required String createdBy,
    required DateTime createdAt,
    required DateTime updatedAt,
    required bool isActive,
  }) = _MainSiteRecordImpl;

  factory MainSiteRecord.fromJson(Map<String, dynamic> jsonSerialization) {
    return MainSiteRecord(
      id: jsonSerialization['id'] as int?,
      mainSiteId: jsonSerialization['mainSiteId'] as String,
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

  static final t = MainSiteRecordTable();

  static const db = MainSiteRecordRepository._();

  @override
  int? id;

  String mainSiteId;

  String clientId;

  String name;

  String? address;

  double? latitude;

  double? longitude;

  String createdBy;

  DateTime createdAt;

  DateTime updatedAt;

  bool isActive;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [MainSiteRecord]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  MainSiteRecord copyWith({
    int? id,
    String? mainSiteId,
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
      'mainSiteId': mainSiteId,
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
      'mainSiteId': mainSiteId,
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

  static MainSiteRecordInclude include() {
    return MainSiteRecordInclude._();
  }

  static MainSiteRecordIncludeList includeList({
    _i1.WhereExpressionBuilder<MainSiteRecordTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<MainSiteRecordTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<MainSiteRecordTable>? orderByList,
    MainSiteRecordInclude? include,
  }) {
    return MainSiteRecordIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(MainSiteRecord.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(MainSiteRecord.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _MainSiteRecordImpl extends MainSiteRecord {
  _MainSiteRecordImpl({
    int? id,
    required String mainSiteId,
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
          mainSiteId: mainSiteId,
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

  /// Returns a shallow copy of this [MainSiteRecord]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  MainSiteRecord copyWith({
    Object? id = _Undefined,
    String? mainSiteId,
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
    return MainSiteRecord(
      id: id is int? ? id : this.id,
      mainSiteId: mainSiteId ?? this.mainSiteId,
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

class MainSiteRecordTable extends _i1.Table<int?> {
  MainSiteRecordTable({super.tableRelation})
      : super(tableName: 'main_site_records') {
    mainSiteId = _i1.ColumnString(
      'mainSiteId',
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

  late final _i1.ColumnString mainSiteId;

  late final _i1.ColumnString clientId;

  late final _i1.ColumnString name;

  late final _i1.ColumnString address;

  late final _i1.ColumnDouble latitude;

  late final _i1.ColumnDouble longitude;

  late final _i1.ColumnString createdBy;

  late final _i1.ColumnDateTime createdAt;

  late final _i1.ColumnDateTime updatedAt;

  late final _i1.ColumnBool isActive;

  @override
  List<_i1.Column> get columns => [
        id,
        mainSiteId,
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

class MainSiteRecordInclude extends _i1.IncludeObject {
  MainSiteRecordInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => MainSiteRecord.t;
}

class MainSiteRecordIncludeList extends _i1.IncludeList {
  MainSiteRecordIncludeList._({
    _i1.WhereExpressionBuilder<MainSiteRecordTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(MainSiteRecord.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => MainSiteRecord.t;
}

class MainSiteRecordRepository {
  const MainSiteRecordRepository._();

  /// Returns a list of [MainSiteRecord]s matching the given query parameters.
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
  Future<List<MainSiteRecord>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<MainSiteRecordTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<MainSiteRecordTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<MainSiteRecordTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<MainSiteRecord>(
      where: where?.call(MainSiteRecord.t),
      orderBy: orderBy?.call(MainSiteRecord.t),
      orderByList: orderByList?.call(MainSiteRecord.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [MainSiteRecord] matching the given query parameters.
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
  Future<MainSiteRecord?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<MainSiteRecordTable>? where,
    int? offset,
    _i1.OrderByBuilder<MainSiteRecordTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<MainSiteRecordTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<MainSiteRecord>(
      where: where?.call(MainSiteRecord.t),
      orderBy: orderBy?.call(MainSiteRecord.t),
      orderByList: orderByList?.call(MainSiteRecord.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [MainSiteRecord] by its [id] or null if no such row exists.
  Future<MainSiteRecord?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<MainSiteRecord>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [MainSiteRecord]s in the list and returns the inserted rows.
  ///
  /// The returned [MainSiteRecord]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<MainSiteRecord>> insert(
    _i1.Session session,
    List<MainSiteRecord> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<MainSiteRecord>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [MainSiteRecord] and returns the inserted row.
  ///
  /// The returned [MainSiteRecord] will have its `id` field set.
  Future<MainSiteRecord> insertRow(
    _i1.Session session,
    MainSiteRecord row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<MainSiteRecord>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [MainSiteRecord]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<MainSiteRecord>> update(
    _i1.Session session,
    List<MainSiteRecord> rows, {
    _i1.ColumnSelections<MainSiteRecordTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<MainSiteRecord>(
      rows,
      columns: columns?.call(MainSiteRecord.t),
      transaction: transaction,
    );
  }

  /// Updates a single [MainSiteRecord]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<MainSiteRecord> updateRow(
    _i1.Session session,
    MainSiteRecord row, {
    _i1.ColumnSelections<MainSiteRecordTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<MainSiteRecord>(
      row,
      columns: columns?.call(MainSiteRecord.t),
      transaction: transaction,
    );
  }

  /// Deletes all [MainSiteRecord]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<MainSiteRecord>> delete(
    _i1.Session session,
    List<MainSiteRecord> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<MainSiteRecord>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [MainSiteRecord].
  Future<MainSiteRecord> deleteRow(
    _i1.Session session,
    MainSiteRecord row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<MainSiteRecord>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<MainSiteRecord>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<MainSiteRecordTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<MainSiteRecord>(
      where: where(MainSiteRecord.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<MainSiteRecordTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<MainSiteRecord>(
      where: where?.call(MainSiteRecord.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
