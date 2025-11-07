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

/// Equipment model with flexible hierarchy
abstract class Equipment
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  Equipment._({
    this.id,
    required this.uuid,
    this.clientId,
    this.mainSiteId,
    this.subSiteId,
    required this.name,
    this.serialNumber,
    this.manufacturer,
    this.model,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
  });

  factory Equipment({
    int? id,
    required String uuid,
    String? clientId,
    String? mainSiteId,
    String? subSiteId,
    required String name,
    String? serialNumber,
    String? manufacturer,
    String? model,
    required String createdBy,
    required DateTime createdAt,
    required DateTime updatedAt,
    required bool isActive,
  }) = _EquipmentImpl;

  factory Equipment.fromJson(Map<String, dynamic> jsonSerialization) {
    return Equipment(
      id: jsonSerialization['id'] as int?,
      uuid: jsonSerialization['uuid'] as String,
      clientId: jsonSerialization['clientId'] as String?,
      mainSiteId: jsonSerialization['mainSiteId'] as String?,
      subSiteId: jsonSerialization['subSiteId'] as String?,
      name: jsonSerialization['name'] as String,
      serialNumber: jsonSerialization['serialNumber'] as String?,
      manufacturer: jsonSerialization['manufacturer'] as String?,
      model: jsonSerialization['model'] as String?,
      createdBy: jsonSerialization['createdBy'] as String,
      createdAt:
          _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt:
          _i1.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
      isActive: jsonSerialization['isActive'] as bool,
    );
  }

  static final t = EquipmentTable();

  static const db = EquipmentRepository._();

  @override
  int? id;

  /// UUID for compatibility with Flutter app
  String uuid;

  /// Parent client ID (if attached to client)
  String? clientId;

  /// Parent main site ID (if attached to main site)
  String? mainSiteId;

  /// Parent sub site ID (if attached to sub site)
  String? subSiteId;

  /// Equipment name
  String name;

  /// Serial number
  String? serialNumber;

  /// Manufacturer name
  String? manufacturer;

  /// Model name
  String? model;

  /// User who created this equipment
  String createdBy;

  /// When the equipment was created
  DateTime createdAt;

  /// When the equipment was last updated
  DateTime updatedAt;

  /// Active/inactive flag
  bool isActive;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [Equipment]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Equipment copyWith({
    int? id,
    String? uuid,
    String? clientId,
    String? mainSiteId,
    String? subSiteId,
    String? name,
    String? serialNumber,
    String? manufacturer,
    String? model,
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
      if (subSiteId != null) 'subSiteId': subSiteId,
      'name': name,
      if (serialNumber != null) 'serialNumber': serialNumber,
      if (manufacturer != null) 'manufacturer': manufacturer,
      if (model != null) 'model': model,
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
      if (subSiteId != null) 'subSiteId': subSiteId,
      'name': name,
      if (serialNumber != null) 'serialNumber': serialNumber,
      if (manufacturer != null) 'manufacturer': manufacturer,
      if (model != null) 'model': model,
      'createdBy': createdBy,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
      'isActive': isActive,
    };
  }

  static EquipmentInclude include() {
    return EquipmentInclude._();
  }

  static EquipmentIncludeList includeList({
    _i1.WhereExpressionBuilder<EquipmentTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<EquipmentTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<EquipmentTable>? orderByList,
    EquipmentInclude? include,
  }) {
    return EquipmentIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Equipment.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(Equipment.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _EquipmentImpl extends Equipment {
  _EquipmentImpl({
    int? id,
    required String uuid,
    String? clientId,
    String? mainSiteId,
    String? subSiteId,
    required String name,
    String? serialNumber,
    String? manufacturer,
    String? model,
    required String createdBy,
    required DateTime createdAt,
    required DateTime updatedAt,
    required bool isActive,
  }) : super._(
          id: id,
          uuid: uuid,
          clientId: clientId,
          mainSiteId: mainSiteId,
          subSiteId: subSiteId,
          name: name,
          serialNumber: serialNumber,
          manufacturer: manufacturer,
          model: model,
          createdBy: createdBy,
          createdAt: createdAt,
          updatedAt: updatedAt,
          isActive: isActive,
        );

  /// Returns a shallow copy of this [Equipment]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Equipment copyWith({
    Object? id = _Undefined,
    String? uuid,
    Object? clientId = _Undefined,
    Object? mainSiteId = _Undefined,
    Object? subSiteId = _Undefined,
    String? name,
    Object? serialNumber = _Undefined,
    Object? manufacturer = _Undefined,
    Object? model = _Undefined,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return Equipment(
      id: id is int? ? id : this.id,
      uuid: uuid ?? this.uuid,
      clientId: clientId is String? ? clientId : this.clientId,
      mainSiteId: mainSiteId is String? ? mainSiteId : this.mainSiteId,
      subSiteId: subSiteId is String? ? subSiteId : this.subSiteId,
      name: name ?? this.name,
      serialNumber: serialNumber is String? ? serialNumber : this.serialNumber,
      manufacturer: manufacturer is String? ? manufacturer : this.manufacturer,
      model: model is String? ? model : this.model,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }
}

class EquipmentTable extends _i1.Table<int?> {
  EquipmentTable({super.tableRelation}) : super(tableName: 'equipment') {
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
    subSiteId = _i1.ColumnString(
      'subSiteId',
      this,
    );
    name = _i1.ColumnString(
      'name',
      this,
    );
    serialNumber = _i1.ColumnString(
      'serialNumber',
      this,
    );
    manufacturer = _i1.ColumnString(
      'manufacturer',
      this,
    );
    model = _i1.ColumnString(
      'model',
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

  /// Parent sub site ID (if attached to sub site)
  late final _i1.ColumnString subSiteId;

  /// Equipment name
  late final _i1.ColumnString name;

  /// Serial number
  late final _i1.ColumnString serialNumber;

  /// Manufacturer name
  late final _i1.ColumnString manufacturer;

  /// Model name
  late final _i1.ColumnString model;

  /// User who created this equipment
  late final _i1.ColumnString createdBy;

  /// When the equipment was created
  late final _i1.ColumnDateTime createdAt;

  /// When the equipment was last updated
  late final _i1.ColumnDateTime updatedAt;

  /// Active/inactive flag
  late final _i1.ColumnBool isActive;

  @override
  List<_i1.Column> get columns => [
        id,
        uuid,
        clientId,
        mainSiteId,
        subSiteId,
        name,
        serialNumber,
        manufacturer,
        model,
        createdBy,
        createdAt,
        updatedAt,
        isActive,
      ];
}

class EquipmentInclude extends _i1.IncludeObject {
  EquipmentInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => Equipment.t;
}

class EquipmentIncludeList extends _i1.IncludeList {
  EquipmentIncludeList._({
    _i1.WhereExpressionBuilder<EquipmentTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Equipment.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => Equipment.t;
}

class EquipmentRepository {
  const EquipmentRepository._();

  /// Returns a list of [Equipment]s matching the given query parameters.
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
  Future<List<Equipment>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<EquipmentTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<EquipmentTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<EquipmentTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<Equipment>(
      where: where?.call(Equipment.t),
      orderBy: orderBy?.call(Equipment.t),
      orderByList: orderByList?.call(Equipment.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [Equipment] matching the given query parameters.
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
  Future<Equipment?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<EquipmentTable>? where,
    int? offset,
    _i1.OrderByBuilder<EquipmentTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<EquipmentTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<Equipment>(
      where: where?.call(Equipment.t),
      orderBy: orderBy?.call(Equipment.t),
      orderByList: orderByList?.call(Equipment.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [Equipment] by its [id] or null if no such row exists.
  Future<Equipment?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<Equipment>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [Equipment]s in the list and returns the inserted rows.
  ///
  /// The returned [Equipment]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<Equipment>> insert(
    _i1.Session session,
    List<Equipment> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<Equipment>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [Equipment] and returns the inserted row.
  ///
  /// The returned [Equipment] will have its `id` field set.
  Future<Equipment> insertRow(
    _i1.Session session,
    Equipment row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<Equipment>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [Equipment]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<Equipment>> update(
    _i1.Session session,
    List<Equipment> rows, {
    _i1.ColumnSelections<EquipmentTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<Equipment>(
      rows,
      columns: columns?.call(Equipment.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Equipment]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Equipment> updateRow(
    _i1.Session session,
    Equipment row, {
    _i1.ColumnSelections<EquipmentTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<Equipment>(
      row,
      columns: columns?.call(Equipment.t),
      transaction: transaction,
    );
  }

  /// Deletes all [Equipment]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<Equipment>> delete(
    _i1.Session session,
    List<Equipment> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<Equipment>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [Equipment].
  Future<Equipment> deleteRow(
    _i1.Session session,
    Equipment row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Equipment>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<Equipment>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<EquipmentTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<Equipment>(
      where: where(Equipment.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<EquipmentTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<Equipment>(
      where: where?.call(Equipment.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
