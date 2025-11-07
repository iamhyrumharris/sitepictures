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
import 'client_record.dart' as _i2;
import 'duplicate_registry_record.dart' as _i3;
import 'equipment_record.dart' as _i4;
import 'folder_photo_record.dart' as _i5;
import 'import_batch_record.dart' as _i6;
import 'main_site_record.dart' as _i7;
import 'photo_folder_record.dart' as _i8;
import 'photo_payload.dart' as _i9;
import 'photo_record.dart' as _i10;
import 'sub_site_record.dart' as _i11;
import 'package:sitepictures_server_client/src/protocol/client_record.dart'
    as _i12;
import 'package:sitepictures_server_client/src/protocol/equipment_record.dart'
    as _i13;
import 'package:sitepictures_server_client/src/protocol/photo_folder_record.dart'
    as _i14;
import 'package:sitepictures_server_client/src/protocol/folder_photo_record.dart'
    as _i15;
import 'package:sitepictures_server_client/src/protocol/import_batch_record.dart'
    as _i16;
import 'package:sitepictures_server_client/src/protocol/duplicate_registry_record.dart'
    as _i17;
import 'package:sitepictures_server_client/src/protocol/photo_payload.dart'
    as _i18;
import 'package:sitepictures_server_client/src/protocol/main_site_record.dart'
    as _i19;
import 'package:sitepictures_server_client/src/protocol/sub_site_record.dart'
    as _i20;
import 'package:serverpod_auth_client/serverpod_auth_client.dart' as _i21;
export 'client_record.dart';
export 'duplicate_registry_record.dart';
export 'equipment_record.dart';
export 'folder_photo_record.dart';
export 'import_batch_record.dart';
export 'main_site_record.dart';
export 'photo_folder_record.dart';
export 'photo_payload.dart';
export 'photo_record.dart';
export 'sub_site_record.dart';
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
    if (t == _i2.ClientRecord) {
      return _i2.ClientRecord.fromJson(data) as T;
    }
    if (t == _i3.DuplicateRegistryRecord) {
      return _i3.DuplicateRegistryRecord.fromJson(data) as T;
    }
    if (t == _i4.EquipmentRecord) {
      return _i4.EquipmentRecord.fromJson(data) as T;
    }
    if (t == _i5.FolderPhotoRecord) {
      return _i5.FolderPhotoRecord.fromJson(data) as T;
    }
    if (t == _i6.ImportBatchRecord) {
      return _i6.ImportBatchRecord.fromJson(data) as T;
    }
    if (t == _i7.MainSiteRecord) {
      return _i7.MainSiteRecord.fromJson(data) as T;
    }
    if (t == _i8.PhotoFolderRecord) {
      return _i8.PhotoFolderRecord.fromJson(data) as T;
    }
    if (t == _i9.PhotoPayload) {
      return _i9.PhotoPayload.fromJson(data) as T;
    }
    if (t == _i10.PhotoRecord) {
      return _i10.PhotoRecord.fromJson(data) as T;
    }
    if (t == _i11.SubSiteRecord) {
      return _i11.SubSiteRecord.fromJson(data) as T;
    }
    if (t == _i1.getType<_i2.ClientRecord?>()) {
      return (data != null ? _i2.ClientRecord.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i3.DuplicateRegistryRecord?>()) {
      return (data != null ? _i3.DuplicateRegistryRecord.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i4.EquipmentRecord?>()) {
      return (data != null ? _i4.EquipmentRecord.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i5.FolderPhotoRecord?>()) {
      return (data != null ? _i5.FolderPhotoRecord.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i6.ImportBatchRecord?>()) {
      return (data != null ? _i6.ImportBatchRecord.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i7.MainSiteRecord?>()) {
      return (data != null ? _i7.MainSiteRecord.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i8.PhotoFolderRecord?>()) {
      return (data != null ? _i8.PhotoFolderRecord.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i9.PhotoPayload?>()) {
      return (data != null ? _i9.PhotoPayload.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i10.PhotoRecord?>()) {
      return (data != null ? _i10.PhotoRecord.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i11.SubSiteRecord?>()) {
      return (data != null ? _i11.SubSiteRecord.fromJson(data) : null) as T;
    }
    if (t == List<_i12.ClientRecord>) {
      return (data as List)
          .map((e) => deserialize<_i12.ClientRecord>(e))
          .toList() as T;
    }
    if (t == List<_i13.EquipmentRecord>) {
      return (data as List)
          .map((e) => deserialize<_i13.EquipmentRecord>(e))
          .toList() as T;
    }
    if (t == List<_i14.PhotoFolderRecord>) {
      return (data as List)
          .map((e) => deserialize<_i14.PhotoFolderRecord>(e))
          .toList() as T;
    }
    if (t == List<_i15.FolderPhotoRecord>) {
      return (data as List)
          .map((e) => deserialize<_i15.FolderPhotoRecord>(e))
          .toList() as T;
    }
    if (t == List<_i16.ImportBatchRecord>) {
      return (data as List)
          .map((e) => deserialize<_i16.ImportBatchRecord>(e))
          .toList() as T;
    }
    if (t == List<_i17.DuplicateRegistryRecord>) {
      return (data as List)
          .map((e) => deserialize<_i17.DuplicateRegistryRecord>(e))
          .toList() as T;
    }
    if (t == List<_i18.PhotoPayload>) {
      return (data as List)
          .map((e) => deserialize<_i18.PhotoPayload>(e))
          .toList() as T;
    }
    if (t == List<_i19.MainSiteRecord>) {
      return (data as List)
          .map((e) => deserialize<_i19.MainSiteRecord>(e))
          .toList() as T;
    }
    if (t == List<_i20.SubSiteRecord>) {
      return (data as List)
          .map((e) => deserialize<_i20.SubSiteRecord>(e))
          .toList() as T;
    }
    try {
      return _i21.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;
    if (data is _i2.ClientRecord) {
      return 'ClientRecord';
    }
    if (data is _i3.DuplicateRegistryRecord) {
      return 'DuplicateRegistryRecord';
    }
    if (data is _i4.EquipmentRecord) {
      return 'EquipmentRecord';
    }
    if (data is _i5.FolderPhotoRecord) {
      return 'FolderPhotoRecord';
    }
    if (data is _i6.ImportBatchRecord) {
      return 'ImportBatchRecord';
    }
    if (data is _i7.MainSiteRecord) {
      return 'MainSiteRecord';
    }
    if (data is _i8.PhotoFolderRecord) {
      return 'PhotoFolderRecord';
    }
    if (data is _i9.PhotoPayload) {
      return 'PhotoPayload';
    }
    if (data is _i10.PhotoRecord) {
      return 'PhotoRecord';
    }
    if (data is _i11.SubSiteRecord) {
      return 'SubSiteRecord';
    }
    className = _i21.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth.$className';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'ClientRecord') {
      return deserialize<_i2.ClientRecord>(data['data']);
    }
    if (dataClassName == 'DuplicateRegistryRecord') {
      return deserialize<_i3.DuplicateRegistryRecord>(data['data']);
    }
    if (dataClassName == 'EquipmentRecord') {
      return deserialize<_i4.EquipmentRecord>(data['data']);
    }
    if (dataClassName == 'FolderPhotoRecord') {
      return deserialize<_i5.FolderPhotoRecord>(data['data']);
    }
    if (dataClassName == 'ImportBatchRecord') {
      return deserialize<_i6.ImportBatchRecord>(data['data']);
    }
    if (dataClassName == 'MainSiteRecord') {
      return deserialize<_i7.MainSiteRecord>(data['data']);
    }
    if (dataClassName == 'PhotoFolderRecord') {
      return deserialize<_i8.PhotoFolderRecord>(data['data']);
    }
    if (dataClassName == 'PhotoPayload') {
      return deserialize<_i9.PhotoPayload>(data['data']);
    }
    if (dataClassName == 'PhotoRecord') {
      return deserialize<_i10.PhotoRecord>(data['data']);
    }
    if (dataClassName == 'SubSiteRecord') {
      return deserialize<_i11.SubSiteRecord>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth.')) {
      data['className'] = dataClassName.substring(15);
      return _i21.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }
}
