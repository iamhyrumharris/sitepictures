import 'package:uuid/uuid.dart';

class DuplicateRegistryEntry {
  final String id;
  final String photoId;
  final String? sourceAssetId;
  final String? fingerprintSha1;
  final DateTime importedAt;

  DuplicateRegistryEntry({
    String? id,
    required this.photoId,
    this.sourceAssetId,
    this.fingerprintSha1,
    DateTime? importedAt,
  }) : id = id ?? const Uuid().v4(),
       importedAt = importedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'photo_id': photoId,
      'source_asset_id': sourceAssetId,
      'fingerprint_sha1': fingerprintSha1,
      'imported_at': importedAt.toIso8601String(),
    };
  }

  factory DuplicateRegistryEntry.fromMap(Map<String, dynamic> map) {
    return DuplicateRegistryEntry(
      id: map['id'] as String,
      photoId: map['photo_id'] as String,
      sourceAssetId: map['source_asset_id'] as String?,
      fingerprintSha1: map['fingerprint_sha1'] as String?,
      importedAt: DateTime.parse(map['imported_at'] as String),
    );
  }
}
