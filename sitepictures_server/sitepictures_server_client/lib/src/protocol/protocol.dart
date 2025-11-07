/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;
import 'company.dart' as _i2;
import 'equipment.dart' as _i3;
import 'folder_photo.dart' as _i4;
import 'import_batch.dart' as _i5;
import 'main_site.dart' as _i6;
import 'photo.dart' as _i7;
import 'photo_folder.dart' as _i8;
import 'sub_site.dart' as _i9;
import 'sync_queue_item.dart' as _i10;
import 'user.dart' as _i11;
import 'package:sitepictures_server_client/src/protocol/company.dart' as _i12;
import 'package:sitepictures_server_client/src/protocol/equipment.dart' as _i13;
import 'package:sitepictures_server_client/src/protocol/photo_folder.dart'
    as _i14;
import 'package:sitepictures_server_client/src/protocol/folder_photo.dart'
    as _i15;
import 'package:sitepictures_server_client/src/protocol/photo.dart' as _i16;
import 'package:sitepictures_server_client/src/protocol/main_site.dart' as _i17;
import 'package:sitepictures_server_client/src/protocol/sub_site.dart' as _i18;
export 'company.dart';
export 'equipment.dart';
export 'folder_photo.dart';
export 'import_batch.dart';
export 'main_site.dart';
export 'photo.dart';
export 'photo_folder.dart';
export 'sub_site.dart';
export 'sync_queue_item.dart';
export 'user.dart';
export 'client.dart';

class Protocol extends _i1.SerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._();

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;
    if (t == _i2.Company) {
      return _i2.Company.fromJson(data) as T;
    }
    if (t == _i3.Equipment) {
      return _i3.Equipment.fromJson(data) as T;
    }
    if (t == _i4.FolderPhoto) {
      return _i4.FolderPhoto.fromJson(data) as T;
    }
    if (t == _i5.ImportBatch) {
      return _i5.ImportBatch.fromJson(data) as T;
    }
    if (t == _i6.MainSite) {
      return _i6.MainSite.fromJson(data) as T;
    }
    if (t == _i7.Photo) {
      return _i7.Photo.fromJson(data) as T;
    }
    if (t == _i8.PhotoFolder) {
      return _i8.PhotoFolder.fromJson(data) as T;
    }
    if (t == _i9.SubSite) {
      return _i9.SubSite.fromJson(data) as T;
    }
    if (t == _i10.SyncQueueItem) {
      return _i10.SyncQueueItem.fromJson(data) as T;
    }
    if (t == _i11.User) {
      return _i11.User.fromJson(data) as T;
    }
    if (t == _i1.getType<_i2.Company?>()) {
      return (data != null ? _i2.Company.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i3.Equipment?>()) {
      return (data != null ? _i3.Equipment.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i4.FolderPhoto?>()) {
      return (data != null ? _i4.FolderPhoto.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i5.ImportBatch?>()) {
      return (data != null ? _i5.ImportBatch.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i6.MainSite?>()) {
      return (data != null ? _i6.MainSite.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i7.Photo?>()) {
      return (data != null ? _i7.Photo.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i8.PhotoFolder?>()) {
      return (data != null ? _i8.PhotoFolder.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i9.SubSite?>()) {
      return (data != null ? _i9.SubSite.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i10.SyncQueueItem?>()) {
      return (data != null ? _i10.SyncQueueItem.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i11.User?>()) {
      return (data != null ? _i11.User.fromJson(data) : null) as T;
    }
    if (t == List<_i12.Company>) {
      return (data as List).map((e) => deserialize<_i12.Company>(e)).toList()
          as T;
    }
    if (t == List<_i13.Equipment>) {
      return (data as List).map((e) => deserialize<_i13.Equipment>(e)).toList()
          as T;
    }
    if (t == List<_i14.PhotoFolder>) {
      return (data as List)
          .map((e) => deserialize<_i14.PhotoFolder>(e))
          .toList() as T;
    }
    if (t == List<_i15.FolderPhoto>) {
      return (data as List)
          .map((e) => deserialize<_i15.FolderPhoto>(e))
          .toList() as T;
    }
    if (t == List<_i16.Photo>) {
      return (data as List).map((e) => deserialize<_i16.Photo>(e)).toList()
          as T;
    }
    if (t == List<_i17.MainSite>) {
      return (data as List).map((e) => deserialize<_i17.MainSite>(e)).toList()
          as T;
    }
    if (t == List<_i18.SubSite>) {
      return (data as List).map((e) => deserialize<_i18.SubSite>(e)).toList()
          as T;
    }
    if (t == Map<String, dynamic>) {
      return (data as Map).map((k, v) =>
          MapEntry(deserialize<String>(k), deserialize<dynamic>(v))) as T;
    }
    if (t == List<Map<String, dynamic>>) {
      return (data as List)
          .map((e) => deserialize<Map<String, dynamic>>(e))
          .toList() as T;
    }
    return super.deserialize<T>(data, t);
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;
    if (data is _i2.Company) {
      return 'Company';
    }
    if (data is _i3.Equipment) {
      return 'Equipment';
    }
    if (data is _i4.FolderPhoto) {
      return 'FolderPhoto';
    }
    if (data is _i5.ImportBatch) {
      return 'ImportBatch';
    }
    if (data is _i6.MainSite) {
      return 'MainSite';
    }
    if (data is _i7.Photo) {
      return 'Photo';
    }
    if (data is _i8.PhotoFolder) {
      return 'PhotoFolder';
    }
    if (data is _i9.SubSite) {
      return 'SubSite';
    }
    if (data is _i10.SyncQueueItem) {
      return 'SyncQueueItem';
    }
    if (data is _i11.User) {
      return 'User';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'Company') {
      return deserialize<_i2.Company>(data['data']);
    }
    if (dataClassName == 'Equipment') {
      return deserialize<_i3.Equipment>(data['data']);
    }
    if (dataClassName == 'FolderPhoto') {
      return deserialize<_i4.FolderPhoto>(data['data']);
    }
    if (dataClassName == 'ImportBatch') {
      return deserialize<_i5.ImportBatch>(data['data']);
    }
    if (dataClassName == 'MainSite') {
      return deserialize<_i6.MainSite>(data['data']);
    }
    if (dataClassName == 'Photo') {
      return deserialize<_i7.Photo>(data['data']);
    }
    if (dataClassName == 'PhotoFolder') {
      return deserialize<_i8.PhotoFolder>(data['data']);
    }
    if (dataClassName == 'SubSite') {
      return deserialize<_i9.SubSite>(data['data']);
    }
    if (dataClassName == 'SyncQueueItem') {
      return deserialize<_i10.SyncQueueItem>(data['data']);
    }
    if (dataClassName == 'User') {
      return deserialize<_i11.User>(data['data']);
    }
    return super.deserializeByClassName(data);
  }
}
