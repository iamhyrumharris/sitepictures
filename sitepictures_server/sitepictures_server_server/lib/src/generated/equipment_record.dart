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

abstract class EquipmentRecord
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  EquipmentRecord._({
    this.id,
    required this.equipmentId,
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

  factory EquipmentRecord({
    int? id,
    required String equipmentId,
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
  }) = _EquipmentRecordImpl;

  factory EquipmentRecord.fromJson(Map<String, dynamic> jsonSerialization) {
    return EquipmentRecord(
      id: jsonSerialization['id'] as int?,
      equipmentId: jsonSerialization['equipmentId'] as String,
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

  static final t = EquipmentRecordTable();

  static const db = EquipmentRecordRepository._();

  @override
  int? id;

  String equipmentId;

  String? clientId;

  String? mainSiteId;

  String? subSiteId;

  String name;

  String? serialNumber;

  String? manufacturer;

  String? model;

  String createdBy;

  DateTime createdAt;

  DateTime updatedAt;

  bool isActive;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [EquipmentRecord]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  EquipmentRecord copyWith({
    int? id,
    String? equipmentId,
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
      'equipmentId': equipmentId,
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
      'equipmentId': equipmentId,
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

  static EquipmentRecordInclude include() {
    return EquipmentRecordInclude._();
  }

  static EquipmentRecordIncludeList includeList({
    _i1.WhereExpressionBuilder<EquipmentRecordTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<EquipmentRecordTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<EquipmentRecordTable>? orderByList,
    EquipmentRecordInclude? include,
  }) {
    return EquipmentRecordIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(EquipmentRecord.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(EquipmentRecord.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _EquipmentRecordImpl extends EquipmentRecord {
  _EquipmentRecordImpl({
    int? id,
    required String equipmentId,
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
          equipmentId: equipmentId,
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

  /// Returns a shallow copy of this [EquipmentRecord]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  EquipmentRecord copyWith({
    Object? id = _Undefined,
    String? equipmentId,
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
    return EquipmentRecord(
      id: id is int? ? id : this.id,
      equipmentId: equipmentId ?? this.equipmentId,
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

class EquipmentRecordTable extends _i1.Table<int?> {
  EquipmentRecordTable({super.tableRelation})
      : super(tableName: 'equipment_records') {
    equipmentId = _i1.ColumnString(
      'equipmentId',
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

  late final _i1.ColumnString equipmentId;

  late final _i1.ColumnString clientId;

  late final _i1.ColumnString mainSiteId;

  late final _i1.ColumnString subSiteId;

  late final _i1.ColumnString name;

  late final _i1.ColumnString serialNumber;

  late final _i1.ColumnString manufacturer;

  late final _i1.ColumnString model;

  late final _i1.ColumnString createdBy;

  late final _i1.ColumnDateTime createdAt;

  late final _i1.ColumnDateTime updatedAt;

  late final _i1.ColumnBool isActive;

  @override
  List<_i1.Column> get columns => [
        id,
        equipmentId,
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

class EquipmentRecordInclude extends _i1.IncludeObject {
  EquipmentRecordInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => EquipmentRecord.t;
}

class EquipmentRecordIncludeList extends _i1.IncludeList {
  EquipmentRecordIncludeList._({
    _i1.WhereExpressionBuilder<EquipmentRecordTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(EquipmentRecord.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => EquipmentRecord.t;
}

class EquipmentRecordRepository {
  const EquipmentRecordRepository._();

  /// Returns a list of [EquipmentRecord]s matching the given query parameters.
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
  Future<List<EquipmentRecord>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<EquipmentRecordTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<EquipmentRecordTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<EquipmentRecordTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<EquipmentRecord>(
      where: where?.call(EquipmentRecord.t),
      orderBy: orderBy?.call(EquipmentRecord.t),
      orderByList: orderByList?.call(EquipmentRecord.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [EquipmentRecord] matching the given query parameters.
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
  Future<EquipmentRecord?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<EquipmentRecordTable>? where,
    int? offset,
    _i1.OrderByBuilder<EquipmentRecordTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<EquipmentRecordTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<EquipmentRecord>(
      where: where?.call(EquipmentRecord.t),
      orderBy: orderBy?.call(EquipmentRecord.t),
      orderByList: orderByList?.call(EquipmentRecord.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [EquipmentRecord] by its [id] or null if no such row exists.
  Future<EquipmentRecord?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<EquipmentRecord>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [EquipmentRecord]s in the list and returns the inserted rows.
  ///
  /// The returned [EquipmentRecord]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<EquipmentRecord>> insert(
    _i1.Session session,
    List<EquipmentRecord> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<EquipmentRecord>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [EquipmentRecord] and returns the inserted row.
  ///
  /// The returned [EquipmentRecord] will have its `id` field set.
  Future<EquipmentRecord> insertRow(
    _i1.Session session,
    EquipmentRecord row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<EquipmentRecord>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [EquipmentRecord]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<EquipmentRecord>> update(
    _i1.Session session,
    List<EquipmentRecord> rows, {
    _i1.ColumnSelections<EquipmentRecordTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<EquipmentRecord>(
      rows,
      columns: columns?.call(EquipmentRecord.t),
      transaction: transaction,
    );
  }

  /// Updates a single [EquipmentRecord]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<EquipmentRecord> updateRow(
    _i1.Session session,
    EquipmentRecord row, {
    _i1.ColumnSelections<EquipmentRecordTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<EquipmentRecord>(
      row,
      columns: columns?.call(EquipmentRecord.t),
      transaction: transaction,
    );
  }

  /// Deletes all [EquipmentRecord]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<EquipmentRecord>> delete(
    _i1.Session session,
    List<EquipmentRecord> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<EquipmentRecord>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [EquipmentRecord].
  Future<EquipmentRecord> deleteRow(
    _i1.Session session,
    EquipmentRecord row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<EquipmentRecord>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<EquipmentRecord>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<EquipmentRecordTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<EquipmentRecord>(
      where: where(EquipmentRecord.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<EquipmentRecordTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<EquipmentRecord>(
      where: where?.call(EquipmentRecord.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
