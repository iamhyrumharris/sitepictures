import 'dart:async';
import 'dart:io';

import 'package:crypto/crypto.dart';

/// Utility helpers for computing SHA-1 fingerprints without loading an entire
/// file into memory. This keeps imports responsive even for large images.
class HashUtils {
  /// Calculates the SHA-1 digest for a file at [filePath] by streaming it.
  static Future<String> sha1ForFile(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw FileSystemException('File not found for hashing', filePath);
    }
    final stream = file.openRead();
    return sha1ForStream(stream);
  }

  /// Calculates the SHA-1 digest for a byte [stream].
  static Future<String> sha1ForStream(Stream<List<int>> stream) async {
    final digest = await sha1.bind(stream).first;
    return digest.toString();
  }

  /// Calculates the SHA-1 digest for raw [bytes].
  static String sha1ForBytes(List<int> bytes) {
    return sha1.convert(bytes).toString();
  }
}
