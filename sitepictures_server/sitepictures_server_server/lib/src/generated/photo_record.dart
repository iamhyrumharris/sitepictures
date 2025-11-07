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

/// Canonical record for a photo stored in Postgres.
abstract class PhotoRecord
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  PhotoRecord._({
    this.id,
    required this.clientId,
    required this.equipmentId,
    required this.capturedBy,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    required this.fileSize,
    required this.importSource,
    this.fingerprintSha1,
    this.importBatchId,
    this.remoteUrl,
    this.storagePath,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PhotoRecord({
    int? id,
    required String clientId,
    required String equipmentId,
    required String capturedBy,
    required double latitude,
    required double longitude,
    required DateTime timestamp,
    required int fileSize,
    required String importSource,
    String? fingerprintSha1,
    String? importBatchId,
    String? remoteUrl,
    String? storagePath,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _PhotoRecordImpl;

  factory PhotoRecord.fromJson(Map<String, dynamic> jsonSerialization) {
    return PhotoRecord(
      id: jsonSerialization['id'] as int?,
      clientId: jsonSerialization['clientId'] as String,
      equipmentId: jsonSerialization['equipmentId'] as String,
      capturedBy: jsonSerialization['capturedBy'] as String,
      latitude: (jsonSerialization['latitude'] as num).toDouble(),
      longitude: (jsonSerialization['longitude'] as num).toDouble(),
      timestamp:
          _i1.DateTimeJsonExtension.fromJson(jsonSerialization['timestamp']),
      fileSize: jsonSerialization['fileSize'] as int,
      importSource: jsonSerialization['importSource'] as String,
      fingerprintSha1: jsonSerialization['fingerprintSha1'] as String?,
      importBatchId: jsonSerialization['importBatchId'] as String?,
      remoteUrl: jsonSerialization['remoteUrl'] as String?,
      storagePath: jsonSerialization['storagePath'] as String?,
      createdAt:
          _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt:
          _i1.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  static final t = PhotoRecordTable();

  static const db = PhotoRecordRepository._();

  @override
  int? id;

  String clientId;

  String equipmentId;

  String capturedBy;

  double latitude;

  double longitude;

  DateTime timestamp;

  int fileSize;

  String importSource;

  String? fingerprintSha1;

  String? importBatchId;

  String? remoteUrl;

  String? storagePath;

  DateTime createdAt;

  DateTime updatedAt;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [PhotoRecord]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  PhotoRecord copyWith({
    int? id,
    String? clientId,
    String? equipmentId,
    String? capturedBy,
    double? latitude,
    double? longitude,
    DateTime? timestamp,
    int? fileSize,
    String? importSource,
    String? fingerprintSha1,
    String? importBatchId,
    String? remoteUrl,
    String? storagePath,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'clientId': clientId,
      'equipmentId': equipmentId,
      'capturedBy': capturedBy,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.toJson(),
      'fileSize': fileSize,
      'importSource': importSource,
      if (fingerprintSha1 != null) 'fingerprintSha1': fingerprintSha1,
      if (importBatchId != null) 'importBatchId': importBatchId,
      if (remoteUrl != null) 'remoteUrl': remoteUrl,
      if (storagePath != null) 'storagePath': storagePath,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      if (id != null) 'id': id,
      'clientId': clientId,
      'equipmentId': equipmentId,
      'capturedBy': capturedBy,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.toJson(),
      'fileSize': fileSize,
      'importSource': importSource,
      if (fingerprintSha1 != null) 'fingerprintSha1': fingerprintSha1,
      if (importBatchId != null) 'importBatchId': importBatchId,
      if (remoteUrl != null) 'remoteUrl': remoteUrl,
      if (storagePath != null) 'storagePath': storagePath,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  static PhotoRecordInclude include() {
    return PhotoRecordInclude._();
  }

  static PhotoRecordIncludeList includeList({
    _i1.WhereExpressionBuilder<PhotoRecordTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<PhotoRecordTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<PhotoRecordTable>? orderByList,
    PhotoRecordInclude? include,
  }) {
    return PhotoRecordIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PhotoRecord.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(PhotoRecord.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PhotoRecordImpl extends PhotoRecord {
  _PhotoRecordImpl({
    int? id,
    required String clientId,
    required String equipmentId,
    required String capturedBy,
    required double latitude,
    required double longitude,
    required DateTime timestamp,
    required int fileSize,
    required String importSource,
    String? fingerprintSha1,
    String? importBatchId,
    String? remoteUrl,
    String? storagePath,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super._(
          id: id,
          clientId: clientId,
          equipmentId: equipmentId,
          capturedBy: capturedBy,
          latitude: latitude,
          longitude: longitude,
          timestamp: timestamp,
          fileSize: fileSize,
          importSource: importSource,
          fingerprintSha1: fingerprintSha1,
          importBatchId: importBatchId,
          remoteUrl: remoteUrl,
          storagePath: storagePath,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  /// Returns a shallow copy of this [PhotoRecord]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  PhotoRecord copyWith({
    Object? id = _Undefined,
    String? clientId,
    String? equipmentId,
    String? capturedBy,
    double? latitude,
    double? longitude,
    DateTime? timestamp,
    int? fileSize,
    String? importSource,
    Object? fingerprintSha1 = _Undefined,
    Object? importBatchId = _Undefined,
    Object? remoteUrl = _Undefined,
    Object? storagePath = _Undefined,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PhotoRecord(
      id: id is int? ? id : this.id,
      clientId: clientId ?? this.clientId,
      equipmentId: equipmentId ?? this.equipmentId,
      capturedBy: capturedBy ?? this.capturedBy,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      timestamp: timestamp ?? this.timestamp,
      fileSize: fileSize ?? this.fileSize,
      importSource: importSource ?? this.importSource,
      fingerprintSha1:
          fingerprintSha1 is String? ? fingerprintSha1 : this.fingerprintSha1,
      importBatchId:
          importBatchId is String? ? importBatchId : this.importBatchId,
      remoteUrl: remoteUrl is String? ? remoteUrl : this.remoteUrl,
      storagePath: storagePath is String? ? storagePath : this.storagePath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class PhotoRecordTable extends _i1.Table<int?> {
  PhotoRecordTable({super.tableRelation}) : super(tableName: 'photo_records') {
    clientId = _i1.ColumnString(
      'clientId',
      this,
    );
    equipmentId = _i1.ColumnString(
      'equipmentId',
      this,
    );
    capturedBy = _i1.ColumnString(
      'capturedBy',
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
    timestamp = _i1.ColumnDateTime(
      'timestamp',
      this,
    );
    fileSize = _i1.ColumnInt(
      'fileSize',
      this,
    );
    importSource = _i1.ColumnString(
      'importSource',
      this,
    );
    fingerprintSha1 = _i1.ColumnString(
      'fingerprintSha1',
      this,
    );
    importBatchId = _i1.ColumnString(
      'importBatchId',
      this,
    );
    remoteUrl = _i1.ColumnString(
      'remoteUrl',
      this,
    );
    storagePath = _i1.ColumnString(
      'storagePath',
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
  }

  late final _i1.ColumnString clientId;

  late final _i1.ColumnString equipmentId;

  late final _i1.ColumnString capturedBy;

  late final _i1.ColumnDouble latitude;

  late final _i1.ColumnDouble longitude;

  late final _i1.ColumnDateTime timestamp;

  late final _i1.ColumnInt fileSize;

  late final _i1.ColumnString importSource;

  late final _i1.ColumnString fingerprintSha1;

  late final _i1.ColumnString importBatchId;

  late final _i1.ColumnString remoteUrl;

  late final _i1.ColumnString storagePath;

  late final _i1.ColumnDateTime createdAt;

  late final _i1.ColumnDateTime updatedAt;

  @override
  List<_i1.Column> get columns => [
        id,
        clientId,
        equipmentId,
        capturedBy,
        latitude,
        longitude,
        timestamp,
        fileSize,
        importSource,
        fingerprintSha1,
        importBatchId,
        remoteUrl,
        storagePath,
        createdAt,
        updatedAt,
      ];
}

class PhotoRecordInclude extends _i1.IncludeObject {
  PhotoRecordInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => PhotoRecord.t;
}

class PhotoRecordIncludeList extends _i1.IncludeList {
  PhotoRecordIncludeList._({
    _i1.WhereExpressionBuilder<PhotoRecordTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(PhotoRecord.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => PhotoRecord.t;
}

class PhotoRecordRepository {
  const PhotoRecordRepository._();

  /// Returns a list of [PhotoRecord]s matching the given query parameters.
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
  Future<List<PhotoRecord>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<PhotoRecordTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<PhotoRecordTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<PhotoRecordTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<PhotoRecord>(
      where: where?.call(PhotoRecord.t),
      orderBy: orderBy?.call(PhotoRecord.t),
      orderByList: orderByList?.call(PhotoRecord.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [PhotoRecord] matching the given query parameters.
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
  Future<PhotoRecord?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<PhotoRecordTable>? where,
    int? offset,
    _i1.OrderByBuilder<PhotoRecordTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<PhotoRecordTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<PhotoRecord>(
      where: where?.call(PhotoRecord.t),
      orderBy: orderBy?.call(PhotoRecord.t),
      orderByList: orderByList?.call(PhotoRecord.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [PhotoRecord] by its [id] or null if no such row exists.
  Future<PhotoRecord?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<PhotoRecord>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [PhotoRecord]s in the list and returns the inserted rows.
  ///
  /// The returned [PhotoRecord]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<PhotoRecord>> insert(
    _i1.Session session,
    List<PhotoRecord> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<PhotoRecord>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [PhotoRecord] and returns the inserted row.
  ///
  /// The returned [PhotoRecord] will have its `id` field set.
  Future<PhotoRecord> insertRow(
    _i1.Session session,
    PhotoRecord row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<PhotoRecord>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [PhotoRecord]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<PhotoRecord>> update(
    _i1.Session session,
    List<PhotoRecord> rows, {
    _i1.ColumnSelections<PhotoRecordTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<PhotoRecord>(
      rows,
      columns: columns?.call(PhotoRecord.t),
      transaction: transaction,
    );
  }

  /// Updates a single [PhotoRecord]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<PhotoRecord> updateRow(
    _i1.Session session,
    PhotoRecord row, {
    _i1.ColumnSelections<PhotoRecordTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<PhotoRecord>(
      row,
      columns: columns?.call(PhotoRecord.t),
      transaction: transaction,
    );
  }

  /// Deletes all [PhotoRecord]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<PhotoRecord>> delete(
    _i1.Session session,
    List<PhotoRecord> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<PhotoRecord>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [PhotoRecord].
  Future<PhotoRecord> deleteRow(
    _i1.Session session,
    PhotoRecord row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<PhotoRecord>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<PhotoRecord>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<PhotoRecordTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<PhotoRecord>(
      where: where(PhotoRecord.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<PhotoRecordTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<PhotoRecord>(
      where: where?.call(PhotoRecord.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
