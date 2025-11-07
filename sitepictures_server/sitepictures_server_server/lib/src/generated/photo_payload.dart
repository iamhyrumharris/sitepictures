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
import 'photo_record.dart' as _i2;
import 'dart:typed_data' as _i3;

/// Payload used when uploading or downloading a photo binary.
abstract class PhotoPayload
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  PhotoPayload._({
    required this.record,
    this.bytes,
  });

  factory PhotoPayload({
    required _i2.PhotoRecord record,
    _i3.ByteData? bytes,
  }) = _PhotoPayloadImpl;

  factory PhotoPayload.fromJson(Map<String, dynamic> jsonSerialization) {
    return PhotoPayload(
      record: _i2.PhotoRecord.fromJson(
          (jsonSerialization['record'] as Map<String, dynamic>)),
      bytes: jsonSerialization['bytes'] == null
          ? null
          : _i1.ByteDataJsonExtension.fromJson(jsonSerialization['bytes']),
    );
  }

  _i2.PhotoRecord record;

  _i3.ByteData? bytes;

  /// Returns a shallow copy of this [PhotoPayload]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  PhotoPayload copyWith({
    _i2.PhotoRecord? record,
    _i3.ByteData? bytes,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      'record': record.toJson(),
      if (bytes != null) 'bytes': bytes?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      'record': record.toJsonForProtocol(),
      if (bytes != null) 'bytes': bytes?.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PhotoPayloadImpl extends PhotoPayload {
  _PhotoPayloadImpl({
    required _i2.PhotoRecord record,
    _i3.ByteData? bytes,
  }) : super._(
          record: record,
          bytes: bytes,
        );

  /// Returns a shallow copy of this [PhotoPayload]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  PhotoPayload copyWith({
    _i2.PhotoRecord? record,
    Object? bytes = _Undefined,
  }) {
    return PhotoPayload(
      record: record ?? this.record.copyWith(),
      bytes: bytes is _i3.ByteData? ? bytes : this.bytes?.clone(),
    );
  }
}
