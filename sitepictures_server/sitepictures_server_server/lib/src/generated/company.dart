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

/// Company/Client model
abstract class Company
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  Company._({
    this.id,
    required this.uuid,
    required this.name,
    this.description,
    required this.isSystem,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
  });

  factory Company({
    int? id,
    required String uuid,
    required String name,
    String? description,
    required bool isSystem,
    required String createdBy,
    required DateTime createdAt,
    required DateTime updatedAt,
    required bool isActive,
  }) = _CompanyImpl;

  factory Company.fromJson(Map<String, dynamic> jsonSerialization) {
    return Company(
      id: jsonSerialization['id'] as int?,
      uuid: jsonSerialization['uuid'] as String,
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

  static final t = CompanyTable();

  static const db = CompanyRepository._();

  @override
  int? id;

  /// UUID for compatibility with Flutter app
  String uuid;

  /// Company name (unique)
  String name;

  /// Optional description
  String? description;

  /// System client flag (for special clients like "Needs Assigned")
  bool isSystem;

  /// User who created this company
  String createdBy;

  /// When the company was created
  DateTime createdAt;

  /// When the company was last updated
  DateTime updatedAt;

  /// Active/inactive flag
  bool isActive;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [Company]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Company copyWith({
    int? id,
    String? uuid,
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
      'uuid': uuid,
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
      'uuid': uuid,
      'name': name,
      if (description != null) 'description': description,
      'isSystem': isSystem,
      'createdBy': createdBy,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
      'isActive': isActive,
    };
  }

  static CompanyInclude include() {
    return CompanyInclude._();
  }

  static CompanyIncludeList includeList({
    _i1.WhereExpressionBuilder<CompanyTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<CompanyTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<CompanyTable>? orderByList,
    CompanyInclude? include,
  }) {
    return CompanyIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Company.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(Company.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CompanyImpl extends Company {
  _CompanyImpl({
    int? id,
    required String uuid,
    required String name,
    String? description,
    required bool isSystem,
    required String createdBy,
    required DateTime createdAt,
    required DateTime updatedAt,
    required bool isActive,
  }) : super._(
          id: id,
          uuid: uuid,
          name: name,
          description: description,
          isSystem: isSystem,
          createdBy: createdBy,
          createdAt: createdAt,
          updatedAt: updatedAt,
          isActive: isActive,
        );

  /// Returns a shallow copy of this [Company]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Company copyWith({
    Object? id = _Undefined,
    String? uuid,
    String? name,
    Object? description = _Undefined,
    bool? isSystem,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return Company(
      id: id is int? ? id : this.id,
      uuid: uuid ?? this.uuid,
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

class CompanyTable extends _i1.Table<int?> {
  CompanyTable({super.tableRelation}) : super(tableName: 'clients') {
    uuid = _i1.ColumnString(
      'uuid',
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

  /// UUID for compatibility with Flutter app
  late final _i1.ColumnString uuid;

  /// Company name (unique)
  late final _i1.ColumnString name;

  /// Optional description
  late final _i1.ColumnString description;

  /// System client flag (for special clients like "Needs Assigned")
  late final _i1.ColumnBool isSystem;

  /// User who created this company
  late final _i1.ColumnString createdBy;

  /// When the company was created
  late final _i1.ColumnDateTime createdAt;

  /// When the company was last updated
  late final _i1.ColumnDateTime updatedAt;

  /// Active/inactive flag
  late final _i1.ColumnBool isActive;

  @override
  List<_i1.Column> get columns => [
        id,
        uuid,
        name,
        description,
        isSystem,
        createdBy,
        createdAt,
        updatedAt,
        isActive,
      ];
}

class CompanyInclude extends _i1.IncludeObject {
  CompanyInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => Company.t;
}

class CompanyIncludeList extends _i1.IncludeList {
  CompanyIncludeList._({
    _i1.WhereExpressionBuilder<CompanyTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Company.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => Company.t;
}

class CompanyRepository {
  const CompanyRepository._();

  /// Returns a list of [Company]s matching the given query parameters.
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
  Future<List<Company>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<CompanyTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<CompanyTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<CompanyTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<Company>(
      where: where?.call(Company.t),
      orderBy: orderBy?.call(Company.t),
      orderByList: orderByList?.call(Company.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [Company] matching the given query parameters.
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
  Future<Company?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<CompanyTable>? where,
    int? offset,
    _i1.OrderByBuilder<CompanyTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<CompanyTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<Company>(
      where: where?.call(Company.t),
      orderBy: orderBy?.call(Company.t),
      orderByList: orderByList?.call(Company.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [Company] by its [id] or null if no such row exists.
  Future<Company?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<Company>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [Company]s in the list and returns the inserted rows.
  ///
  /// The returned [Company]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<Company>> insert(
    _i1.Session session,
    List<Company> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<Company>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [Company] and returns the inserted row.
  ///
  /// The returned [Company] will have its `id` field set.
  Future<Company> insertRow(
    _i1.Session session,
    Company row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<Company>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [Company]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<Company>> update(
    _i1.Session session,
    List<Company> rows, {
    _i1.ColumnSelections<CompanyTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<Company>(
      rows,
      columns: columns?.call(Company.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Company]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Company> updateRow(
    _i1.Session session,
    Company row, {
    _i1.ColumnSelections<CompanyTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<Company>(
      row,
      columns: columns?.call(Company.t),
      transaction: transaction,
    );
  }

  /// Deletes all [Company]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<Company>> delete(
    _i1.Session session,
    List<Company> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<Company>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [Company].
  Future<Company> deleteRow(
    _i1.Session session,
    Company row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Company>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<Company>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<CompanyTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<Company>(
      where: where(Company.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<CompanyTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<Company>(
      where: where?.call(Company.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
