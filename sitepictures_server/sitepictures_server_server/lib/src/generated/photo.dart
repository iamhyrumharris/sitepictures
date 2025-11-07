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

/// Photo model with file storage and sync metadata
abstract class Photo implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  Photo._({
    this.id,
    required this.uuid,
    required this.equipmentId,
    required this.filePath,
    this.thumbnailPath,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    required this.capturedBy,
    required this.fileSize,
    required this.isSynced,
    this.syncedAt,
    this.remoteUrl,
    this.sourceAssetId,
    this.fingerprintSha1,
    this.importBatchId,
    required this.importSource,
    required this.createdAt,
  });

  factory Photo({
    int? id,
    required String uuid,
    required String equipmentId,
    required String filePath,
    String? thumbnailPath,
    required double latitude,
    required double longitude,
    required DateTime timestamp,
    required String capturedBy,
    required int fileSize,
    required bool isSynced,
    DateTime? syncedAt,
    String? remoteUrl,
    String? sourceAssetId,
    String? fingerprintSha1,
    String? importBatchId,
    required String importSource,
    required DateTime createdAt,
  }) = _PhotoImpl;

  factory Photo.fromJson(Map<String, dynamic> jsonSerialization) {
    return Photo(
      id: jsonSerialization['id'] as int?,
      uuid: jsonSerialization['uuid'] as String,
      equipmentId: jsonSerialization['equipmentId'] as String,
      filePath: jsonSerialization['filePath'] as String,
      thumbnailPath: jsonSerialization['thumbnailPath'] as String?,
      latitude: (jsonSerialization['latitude'] as num).toDouble(),
      longitude: (jsonSerialization['longitude'] as num).toDouble(),
      timestamp:
          _i1.DateTimeJsonExtension.fromJson(jsonSerialization['timestamp']),
      capturedBy: jsonSerialization['capturedBy'] as String,
      fileSize: jsonSerialization['fileSize'] as int,
      isSynced: jsonSerialization['isSynced'] as bool,
      syncedAt: jsonSerialization['syncedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['syncedAt']),
      remoteUrl: jsonSerialization['remoteUrl'] as String?,
      sourceAssetId: jsonSerialization['sourceAssetId'] as String?,
      fingerprintSha1: jsonSerialization['fingerprintSha1'] as String?,
      importBatchId: jsonSerialization['importBatchId'] as String?,
      importSource: jsonSerialization['importSource'] as String,
      createdAt:
          _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  static final t = PhotoTable();

  static const db = PhotoRepository._();

  @override
  int? id;

  /// UUID for compatibility with Flutter app
  String uuid;

  /// Equipment ID this photo belongs to
  String equipmentId;

  /// File path or storage key
  String filePath;

  /// Thumbnail path or storage key
  String? thumbnailPath;

  /// Latitude coordinate
  double latitude;

  /// Longitude coordinate
  double longitude;

  /// Photo timestamp
  DateTime timestamp;

  /// User who captured this photo
  String capturedBy;

  /// File size in bytes
  int fileSize;

  /// Sync status flag
  bool isSynced;

  /// When the photo was synced
  DateTime? syncedAt;

  /// Remote URL (for downloaded photos)
  String? remoteUrl;

  /// Source asset ID (for gallery imports)
  String? sourceAssetId;

  /// SHA1 fingerprint for deduplication
  String? fingerprintSha1;

  /// Import batch ID (for gallery imports)
  String? importBatchId;

  /// Import source (camera, gallery)
  String importSource;

  /// When the photo was created
  DateTime createdAt;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [Photo]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Photo copyWith({
    int? id,
    String? uuid,
    String? equipmentId,
    String? filePath,
    String? thumbnailPath,
    double? latitude,
    double? longitude,
    DateTime? timestamp,
    String? capturedBy,
    int? fileSize,
    bool? isSynced,
    DateTime? syncedAt,
    String? remoteUrl,
    String? sourceAssetId,
    String? fingerprintSha1,
    String? importBatchId,
    String? importSource,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'uuid': uuid,
      'equipmentId': equipmentId,
      'filePath': filePath,
      if (thumbnailPath != null) 'thumbnailPath': thumbnailPath,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.toJson(),
      'capturedBy': capturedBy,
      'fileSize': fileSize,
      'isSynced': isSynced,
      if (syncedAt != null) 'syncedAt': syncedAt?.toJson(),
      if (remoteUrl != null) 'remoteUrl': remoteUrl,
      if (sourceAssetId != null) 'sourceAssetId': sourceAssetId,
      if (fingerprintSha1 != null) 'fingerprintSha1': fingerprintSha1,
      if (importBatchId != null) 'importBatchId': importBatchId,
      'importSource': importSource,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      if (id != null) 'id': id,
      'uuid': uuid,
      'equipmentId': equipmentId,
      'filePath': filePath,
      if (thumbnailPath != null) 'thumbnailPath': thumbnailPath,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.toJson(),
      'capturedBy': capturedBy,
      'fileSize': fileSize,
      'isSynced': isSynced,
      if (syncedAt != null) 'syncedAt': syncedAt?.toJson(),
      if (remoteUrl != null) 'remoteUrl': remoteUrl,
      if (sourceAssetId != null) 'sourceAssetId': sourceAssetId,
      if (fingerprintSha1 != null) 'fingerprintSha1': fingerprintSha1,
      if (importBatchId != null) 'importBatchId': importBatchId,
      'importSource': importSource,
      'createdAt': createdAt.toJson(),
    };
  }

  static PhotoInclude include() {
    return PhotoInclude._();
  }

  static PhotoIncludeList includeList({
    _i1.WhereExpressionBuilder<PhotoTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<PhotoTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<PhotoTable>? orderByList,
    PhotoInclude? include,
  }) {
    return PhotoIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Photo.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(Photo.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PhotoImpl extends Photo {
  _PhotoImpl({
    int? id,
    required String uuid,
    required String equipmentId,
    required String filePath,
    String? thumbnailPath,
    required double latitude,
    required double longitude,
    required DateTime timestamp,
    required String capturedBy,
    required int fileSize,
    required bool isSynced,
    DateTime? syncedAt,
    String? remoteUrl,
    String? sourceAssetId,
    String? fingerprintSha1,
    String? importBatchId,
    required String importSource,
    required DateTime createdAt,
  }) : super._(
          id: id,
          uuid: uuid,
          equipmentId: equipmentId,
          filePath: filePath,
          thumbnailPath: thumbnailPath,
          latitude: latitude,
          longitude: longitude,
          timestamp: timestamp,
          capturedBy: capturedBy,
          fileSize: fileSize,
          isSynced: isSynced,
          syncedAt: syncedAt,
          remoteUrl: remoteUrl,
          sourceAssetId: sourceAssetId,
          fingerprintSha1: fingerprintSha1,
          importBatchId: importBatchId,
          importSource: importSource,
          createdAt: createdAt,
        );

  /// Returns a shallow copy of this [Photo]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Photo copyWith({
    Object? id = _Undefined,
    String? uuid,
    String? equipmentId,
    String? filePath,
    Object? thumbnailPath = _Undefined,
    double? latitude,
    double? longitude,
    DateTime? timestamp,
    String? capturedBy,
    int? fileSize,
    bool? isSynced,
    Object? syncedAt = _Undefined,
    Object? remoteUrl = _Undefined,
    Object? sourceAssetId = _Undefined,
    Object? fingerprintSha1 = _Undefined,
    Object? importBatchId = _Undefined,
    String? importSource,
    DateTime? createdAt,
  }) {
    return Photo(
      id: id is int? ? id : this.id,
      uuid: uuid ?? this.uuid,
      equipmentId: equipmentId ?? this.equipmentId,
      filePath: filePath ?? this.filePath,
      thumbnailPath:
          thumbnailPath is String? ? thumbnailPath : this.thumbnailPath,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      timestamp: timestamp ?? this.timestamp,
      capturedBy: capturedBy ?? this.capturedBy,
      fileSize: fileSize ?? this.fileSize,
      isSynced: isSynced ?? this.isSynced,
      syncedAt: syncedAt is DateTime? ? syncedAt : this.syncedAt,
      remoteUrl: remoteUrl is String? ? remoteUrl : this.remoteUrl,
      sourceAssetId:
          sourceAssetId is String? ? sourceAssetId : this.sourceAssetId,
      fingerprintSha1:
          fingerprintSha1 is String? ? fingerprintSha1 : this.fingerprintSha1,
      importBatchId:
          importBatchId is String? ? importBatchId : this.importBatchId,
      importSource: importSource ?? this.importSource,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class PhotoTable extends _i1.Table<int?> {
  PhotoTable({super.tableRelation}) : super(tableName: 'photos') {
    uuid = _i1.ColumnString(
      'uuid',
      this,
    );
    equipmentId = _i1.ColumnString(
      'equipmentId',
      this,
    );
    filePath = _i1.ColumnString(
      'filePath',
      this,
    );
    thumbnailPath = _i1.ColumnString(
      'thumbnailPath',
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
    capturedBy = _i1.ColumnString(
      'capturedBy',
      this,
    );
    fileSize = _i1.ColumnInt(
      'fileSize',
      this,
    );
    isSynced = _i1.ColumnBool(
      'isSynced',
      this,
    );
    syncedAt = _i1.ColumnDateTime(
      'syncedAt',
      this,
    );
    remoteUrl = _i1.ColumnString(
      'remoteUrl',
      this,
    );
    sourceAssetId = _i1.ColumnString(
      'sourceAssetId',
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
    importSource = _i1.ColumnString(
      'importSource',
      this,
    );
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
    );
  }

  /// UUID for compatibility with Flutter app
  late final _i1.ColumnString uuid;

  /// Equipment ID this photo belongs to
  late final _i1.ColumnString equipmentId;

  /// File path or storage key
  late final _i1.ColumnString filePath;

  /// Thumbnail path or storage key
  late final _i1.ColumnString thumbnailPath;

  /// Latitude coordinate
  late final _i1.ColumnDouble latitude;

  /// Longitude coordinate
  late final _i1.ColumnDouble longitude;

  /// Photo timestamp
  late final _i1.ColumnDateTime timestamp;

  /// User who captured this photo
  late final _i1.ColumnString capturedBy;

  /// File size in bytes
  late final _i1.ColumnInt fileSize;

  /// Sync status flag
  late final _i1.ColumnBool isSynced;

  /// When the photo was synced
  late final _i1.ColumnDateTime syncedAt;

  /// Remote URL (for downloaded photos)
  late final _i1.ColumnString remoteUrl;

  /// Source asset ID (for gallery imports)
  late final _i1.ColumnString sourceAssetId;

  /// SHA1 fingerprint for deduplication
  late final _i1.ColumnString fingerprintSha1;

  /// Import batch ID (for gallery imports)
  late final _i1.ColumnString importBatchId;

  /// Import source (camera, gallery)
  late final _i1.ColumnString importSource;

  /// When the photo was created
  late final _i1.ColumnDateTime createdAt;

  @override
  List<_i1.Column> get columns => [
        id,
        uuid,
        equipmentId,
        filePath,
        thumbnailPath,
        latitude,
        longitude,
        timestamp,
        capturedBy,
        fileSize,
        isSynced,
        syncedAt,
        remoteUrl,
        sourceAssetId,
        fingerprintSha1,
        importBatchId,
        importSource,
        createdAt,
      ];
}

class PhotoInclude extends _i1.IncludeObject {
  PhotoInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => Photo.t;
}

class PhotoIncludeList extends _i1.IncludeList {
  PhotoIncludeList._({
    _i1.WhereExpressionBuilder<PhotoTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Photo.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => Photo.t;
}

class PhotoRepository {
  const PhotoRepository._();

  /// Returns a list of [Photo]s matching the given query parameters.
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
  Future<List<Photo>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<PhotoTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<PhotoTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<PhotoTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<Photo>(
      where: where?.call(Photo.t),
      orderBy: orderBy?.call(Photo.t),
      orderByList: orderByList?.call(Photo.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [Photo] matching the given query parameters.
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
  Future<Photo?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<PhotoTable>? where,
    int? offset,
    _i1.OrderByBuilder<PhotoTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<PhotoTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<Photo>(
      where: where?.call(Photo.t),
      orderBy: orderBy?.call(Photo.t),
      orderByList: orderByList?.call(Photo.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [Photo] by its [id] or null if no such row exists.
  Future<Photo?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<Photo>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [Photo]s in the list and returns the inserted rows.
  ///
  /// The returned [Photo]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<Photo>> insert(
    _i1.Session session,
    List<Photo> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<Photo>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [Photo] and returns the inserted row.
  ///
  /// The returned [Photo] will have its `id` field set.
  Future<Photo> insertRow(
    _i1.Session session,
    Photo row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<Photo>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [Photo]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<Photo>> update(
    _i1.Session session,
    List<Photo> rows, {
    _i1.ColumnSelections<PhotoTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<Photo>(
      rows,
      columns: columns?.call(Photo.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Photo]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Photo> updateRow(
    _i1.Session session,
    Photo row, {
    _i1.ColumnSelections<PhotoTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<Photo>(
      row,
      columns: columns?.call(Photo.t),
      transaction: transaction,
    );
  }

  /// Deletes all [Photo]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<Photo>> delete(
    _i1.Session session,
    List<Photo> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<Photo>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [Photo].
  Future<Photo> deleteRow(
    _i1.Session session,
    Photo row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Photo>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<Photo>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<PhotoTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<Photo>(
      where: where(Photo.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<PhotoTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<Photo>(
      where: where?.call(Photo.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
