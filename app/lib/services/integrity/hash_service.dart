import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

class HashService {
  static HashService? _instance;
  factory HashService() => _instance ??= HashService._internal();
  HashService._internal();

  Future<String> calculateFileHash(File file) async {
    try {
      final bytes = await file.readAsBytes();
      return calculateBytesHash(bytes);
    } catch (e) {
      debugPrint('Error calculating file hash: $e');
      throw HashCalculationException('Failed to calculate file hash: $e');
    }
  }

  String calculateBytesHash(Uint8List bytes) {
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<String> calculateStreamHash(Stream<List<int>> stream) async {
    try {
      final output = AccumulatorSink<Digest>();
      final input = sha256.startChunkedConversion(output);

      await for (final chunk in stream) {
        input.add(chunk);
      }
      input.close();

      return output.events.single.toString();
    } catch (e) {
      debugPrint('Error calculating stream hash: $e');
      throw HashCalculationException('Failed to calculate stream hash: $e');
    }
  }

  Future<bool> verifyFileIntegrity(File file, String expectedHash) async {
    try {
      final actualHash = await calculateFileHash(file);
      return actualHash == expectedHash;
    } catch (e) {
      debugPrint('Error verifying file integrity: $e');
      return false;
    }
  }

  Future<PhotoIntegrityResult> verifyPhotoIntegrity({
    required File photoFile,
    required String expectedHash,
    required Map<String, dynamic> metadata,
  }) async {
    final result = PhotoIntegrityResult();

    try {
      if (!await photoFile.exists()) {
        result.fileExists = false;
        result.isValid = false;
        result.errors.add('Photo file does not exist');
        return result;
      }

      result.fileExists = true;
      final fileSize = await photoFile.length();
      result.fileSize = fileSize;

      if (fileSize == 0) {
        result.isValid = false;
        result.errors.add('Photo file is empty');
        return result;
      }

      if (fileSize > 50 * 1024 * 1024) {
        result.warnings.add('Photo file exceeds 50MB');
      }

      final actualHash = await calculateFileHash(photoFile);
      result.actualHash = actualHash;
      result.expectedHash = expectedHash;
      result.hashMatches = actualHash == expectedHash;

      if (!result.hashMatches) {
        result.isValid = false;
        result.errors.add('Photo hash mismatch - file may be corrupted');
      }

      if (metadata['fileName'] != null) {
        final expectedFileName = metadata['fileName'] as String;
        final actualFileName = photoFile.path.split('/').last;
        if (expectedFileName != actualFileName) {
          result.warnings.add('Filename mismatch: expected $expectedFileName');
        }
      }

      final fileStat = await photoFile.stat();
      if (metadata['capturedAt'] != null) {
        final capturedAt = DateTime.parse(metadata['capturedAt'] as String);
        final timeDiff = fileStat.modified.difference(capturedAt).abs();
        if (timeDiff > const Duration(days: 1)) {
          result.warnings.add('File modification time differs significantly from capture time');
        }
      }

      result.isValid = result.hashMatches && result.errors.isEmpty;
      result.verifiedAt = DateTime.now();

      return result;
    } catch (e) {
      debugPrint('Error during photo integrity verification: $e');
      result.isValid = false;
      result.errors.add('Verification failed: $e');
      return result;
    }
  }

  Future<BatchVerificationResult> verifyBatch(
    List<PhotoVerificationRequest> requests,
  ) async {
    final results = <String, PhotoIntegrityResult>{};
    int successCount = 0;
    int failureCount = 0;

    for (final request in requests) {
      final result = await verifyPhotoIntegrity(
        photoFile: request.file,
        expectedHash: request.expectedHash,
        metadata: request.metadata,
      );

      results[request.photoId] = result;
      if (result.isValid) {
        successCount++;
      } else {
        failureCount++;
      }
    }

    return BatchVerificationResult(
      results: results,
      totalVerified: requests.length,
      successCount: successCount,
      failureCount: failureCount,
      successRate: requests.isNotEmpty ? successCount / requests.length : 0,
    );
  }

  String generateChecksumFromMetadata(Map<String, dynamic> metadata) {
    final sortedKeys = metadata.keys.toList()..sort();
    final buffer = StringBuffer();

    for (final key in sortedKeys) {
      if (key != 'fileHash' && key != 'updatedAt') {
        buffer.write('$key:${metadata[key]};');
      }
    }

    final bytes = utf8.encode(buffer.toString());
    final digest = md5.convert(bytes);
    return digest.toString();
  }

  Future<void> repairCorruptedPhoto({
    required File corruptedFile,
    required File backupFile,
    required String expectedHash,
  }) async {
    try {
      if (!await backupFile.exists()) {
        throw HashRepairException('Backup file does not exist');
      }

      final backupHash = await calculateFileHash(backupFile);
      if (backupHash != expectedHash) {
        throw HashRepairException('Backup file hash does not match expected hash');
      }

      if (await corruptedFile.exists()) {
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final corruptedPath = '${corruptedFile.path}.corrupted.$timestamp';
        await corruptedFile.rename(corruptedPath);
        debugPrint('Moved corrupted file to: $corruptedPath');
      }

      await backupFile.copy(corruptedFile.path);
      debugPrint('Successfully restored photo from backup');
    } catch (e) {
      debugPrint('Error repairing corrupted photo: $e');
      throw HashRepairException('Failed to repair photo: $e');
    }
  }

  Future<HashValidationReport> generateValidationReport(
    List<File> photoFiles,
    Map<String, String> expectedHashes,
  ) async {
    final report = HashValidationReport();
    report.startTime = DateTime.now();

    for (final file in photoFiles) {
      final fileName = file.path.split('/').last;
      final photoId = fileName.split('.').first;
      final expectedHash = expectedHashes[photoId];

      if (expectedHash == null) {
        report.missingHashes.add(photoId);
        continue;
      }

      try {
        final isValid = await verifyFileIntegrity(file, expectedHash);
        if (isValid) {
          report.validFiles.add(photoId);
        } else {
          report.invalidFiles.add(photoId);
        }
      } catch (e) {
        report.errors[photoId] = e.toString();
      }
    }

    report.endTime = DateTime.now();
    report.duration = report.endTime!.difference(report.startTime);
    report.totalFiles = photoFiles.length;
    report.validCount = report.validFiles.length;
    report.invalidCount = report.invalidFiles.length;
    report.missingCount = report.missingHashes.length;
    report.errorCount = report.errors.length;

    return report;
  }
}

class PhotoIntegrityResult {
  bool fileExists = false;
  bool hashMatches = false;
  bool isValid = false;
  int? fileSize;
  String? actualHash;
  String? expectedHash;
  DateTime? verifiedAt;
  List<String> errors = [];
  List<String> warnings = [];
}

class PhotoVerificationRequest {
  final String photoId;
  final File file;
  final String expectedHash;
  final Map<String, dynamic> metadata;

  PhotoVerificationRequest({
    required this.photoId,
    required this.file,
    required this.expectedHash,
    required this.metadata,
  });
}

class BatchVerificationResult {
  final Map<String, PhotoIntegrityResult> results;
  final int totalVerified;
  final int successCount;
  final int failureCount;
  final double successRate;

  BatchVerificationResult({
    required this.results,
    required this.totalVerified,
    required this.successCount,
    required this.failureCount,
    required this.successRate,
  });
}

class HashValidationReport {
  DateTime startTime = DateTime.now();
  DateTime? endTime;
  Duration? duration;
  int totalFiles = 0;
  int validCount = 0;
  int invalidCount = 0;
  int missingCount = 0;
  int errorCount = 0;
  List<String> validFiles = [];
  List<String> invalidFiles = [];
  List<String> missingHashes = [];
  Map<String, String> errors = {};

  double get successRate => totalFiles > 0 ? validCount / totalFiles : 0;
  bool get hasIssues => invalidCount > 0 || missingCount > 0 || errorCount > 0;
}

class HashCalculationException implements Exception {
  final String message;
  HashCalculationException(this.message);

  @override
  String toString() => 'HashCalculationException: $message';
}

class HashRepairException implements Exception {
  final String message;
  HashRepairException(this.message);

  @override
  String toString() => 'HashRepairException: $message';
}