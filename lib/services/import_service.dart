import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:uuid/uuid.dart';

import '../models/destination_context.dart';
import '../models/folder_photo.dart';
import '../models/import_batch.dart';
import '../models/photo.dart';
import '../utils/hash_utils.dart';
import 'database_service.dart';
import 'import_repository.dart';
import 'photo_storage_service.dart';

/// Describes an import request originating from any entry point.
class ImportRequest {
  /// Entry point that triggered the flow (home, allPhotos, equipmentBefore, etc.).
  final ImportEntryPoint entryPoint;

  /// Destination context resolved before import begins.
  final DestinationContext destination;

  /// Whether the user explicitly chose Before or After (relevant for equipment tabs).
  final BeforeAfterChoice beforeAfterChoice;

  ImportRequest({
    required this.entryPoint,
    required this.destination,
    required this.beforeAfterChoice,
  });
}

/// Result object summarizing an import batch outcome.
class ImportResult {
  final ImportBatch batch;
  final List<Photo> importedPhotos;
  final List<Photo> duplicates;
  final List<FailedImport> failures;

  ImportResult({
    required this.batch,
    required this.importedPhotos,
    required this.duplicates,
    required this.failures,
  });

  bool get hasFailures => failures.isNotEmpty;
}

class FailedImport {
  final String assetId;
  final ImportFailureReason reason;
  final String? message;

  FailedImport({required this.assetId, required this.reason, this.message});
}

enum ImportFailureReason {
  permissionRevoked,
  storageFull,
  duplicateConflict,
  ioError,
  unsupportedFormat,
}

enum BeforeAfterChoice { before, after, general }

abstract class ImportService {
  /// Ensures the app has photo-library permission.
  ///
  /// Returns `true` when permission is granted or limited (user selected subset),
  /// `false` when denied/restricted.
  Future<bool> ensurePermissions({required ImportEntryPoint entryPoint});

  /// Launches the gallery picker and returns selected asset identifiers.
  ///
  /// Throws [ImportPermissionException] if permissions are not granted.
  /// Returns empty list when user cancels selection.
  Future<List<GalleryAsset>> selectAssets({
    required ImportEntryPoint entryPoint,
    BuildContext? context,
    int maxAssets,
  });

  /// Imports the selected assets into the destination described by [request].
  ///
  /// Responsibilities:
  /// - Create `ImportBatch` record.
  /// - Sequentially process assets, running duplicate checks before file copy.
  /// - Persist new `PhotoAsset` rows with metadata and batch association.
  /// - Queue sync jobs for newly imported photos.
  /// - Emit progress updates via [progressStream].
  ///
  /// Throws:
  /// - [ImportPermissionException] when permissions are revoked mid-flow.
  /// - [InsufficientStorageException] when available free space is below configured threshold.
  Future<ImportResult> importAssets({
    required ImportRequest request,
    required List<GalleryAsset> assets,
  });

  /// Stream of progress updates for UI to display import status.
  Stream<ImportProgress> get progressStream;

  ImportPermissionState get lastPermissionState;
}

class GalleryAsset {
  final String assetId;
  final String? fileName;
  final DateTime? capturedAt;
  final int? fileSizeBytes;

  GalleryAsset({
    required this.assetId,
    this.fileName,
    this.capturedAt,
    this.fileSizeBytes,
  });
}

class ImportProgress {
  final int processed;
  final int total;
  final String? currentAssetId;
  final ImportStage stage;
  final int? elapsedMilliseconds;

  ImportProgress({
    required this.processed,
    required this.total,
    required this.stage,
    this.currentAssetId,
    this.elapsedMilliseconds,
  });
}

enum ImportStage { validating, copying, saving, completed }

class ImportPermissionException implements Exception {
  final String message;

  ImportPermissionException(this.message);
}

class InsufficientStorageException implements Exception {
  final String message;

  InsufficientStorageException(this.message);
}

class ImportServiceImpl implements ImportService {
  ImportServiceImpl({
    required ImportRepository importRepository,
    required DatabaseService databaseService,
    required GlobalKey<NavigatorState> navigatorKey,
  }) : _repository = importRepository,
       _databaseService = databaseService,
       _navigatorKey = navigatorKey;

  final ImportRepository _repository;
  final DatabaseService _databaseService;
  final GlobalKey<NavigatorState> _navigatorKey;
  final Uuid _uuid = const Uuid();

  final StreamController<ImportProgress> _progressController =
      StreamController<ImportProgress>.broadcast();

  ImportPermissionState _lastPermissionState = ImportPermissionState.denied;

  static const _globalNeedsAssignedClientId = 'GLOBAL_NEEDS_ASSIGNED';

  @override
  Stream<ImportProgress> get progressStream => _progressController.stream;

  @override
  ImportPermissionState get lastPermissionState => _lastPermissionState;

  @override
  Future<bool> ensurePermissions({required ImportEntryPoint entryPoint}) async {
    final state = await PhotoManager.requestPermissionExtend();
    if (state == PermissionState.authorized) {
      _lastPermissionState = ImportPermissionState.granted;
      return true;
    }
    if (state == PermissionState.limited) {
      _lastPermissionState = ImportPermissionState.limited;
      return true;
    }
    _lastPermissionState = ImportPermissionState.denied;
    return false;
  }

  @override
  Future<List<GalleryAsset>> selectAssets({
    required ImportEntryPoint entryPoint,
    BuildContext? context,
    int maxAssets = 50,
  }) async {
    final resolvedContext = context ?? _navigatorKey.currentContext;
    if (resolvedContext == null) {
      throw StateError('Navigator context not available for AssetPicker.');
    }

    final permissionOk = await ensurePermissions(entryPoint: entryPoint);
    if (!permissionOk) {
      throw ImportPermissionException('Photo library access is required.');
    }

    if (_lastPermissionState == ImportPermissionState.limited) {
      try {
        await PhotoManager.presentLimited(type: RequestType.image);
      } catch (error) {
        debugPrint('presentLimitedAssetPicker failed: $error');
      }
    }

    final selected = await AssetPicker.pickAssets(
      resolvedContext,
      pickerConfig: AssetPickerConfig(
        maxAssets: maxAssets,
        requestType: RequestType.image,
      ),
    );

    if (selected == null) {
      return [];
    }

    return selected
        .map(
          (entity) => GalleryAsset(
            assetId: entity.id,
            fileName: entity.title,
            capturedAt: entity.createDateTime,
            fileSizeBytes: null,
          ),
        )
        .toList();
  }

  @override
  Future<ImportResult> importAssets({
    required ImportRequest request,
    required List<GalleryAsset> assets,
  }) async {
    if (_lastPermissionState == ImportPermissionState.denied) {
      throw ImportPermissionException('Photo access was not granted.');
    }

    final total = assets.length;
    final stopwatch = Stopwatch()..start();
    if (total == 0) {
      final emptyBatch = await _repository.insertBatch(
        ImportBatch(
          entryPoint: request.entryPoint,
          equipmentId: request.destination.equipmentId,
          folderId: request.destination.folderId,
          destinationCategory: _mapDestination(request.destination),
          selectedCount: 0,
          startedAt: DateTime.now(),
          permissionState: _lastPermissionState,
        ),
      );
      stopwatch.stop();
      _progressController.add(
        ImportProgress(
          processed: 0,
          total: 0,
          stage: ImportStage.completed,
          elapsedMilliseconds: stopwatch.elapsedMilliseconds,
        ),
      );
      return ImportResult(
        batch: emptyBatch.copyWith(completedAt: DateTime.now()),
        importedPhotos: const [],
        duplicates: const [],
        failures: const [],
      );
    }

    final equipmentId = await _resolveEquipmentId(request.destination);
    final beforeAfter = _resolveBeforeAfter(request);
    final resolvedFolderId = await _resolveFolderId(
      request.destination,
      beforeAfter,
      equipmentId,
    );

    final batch = await _repository.insertBatch(
      ImportBatch(
        entryPoint: request.entryPoint,
        equipmentId: equipmentId,
        folderId: resolvedFolderId,
        destinationCategory: _mapDestination(request.destination),
        selectedCount: total,
        startedAt: DateTime.now(),
        permissionState: _lastPermissionState,
      ),
    );

    final imported = <Photo>[];
    final duplicates = <Photo>[];
    final failures = <FailedImport>[];

    var processed = 0;

    for (final asset in assets) {
      processed += 1;
      _progressController.add(
        ImportProgress(
          processed: processed - 1,
          total: total,
          currentAssetId: asset.assetId,
          stage: ImportStage.validating,
          elapsedMilliseconds: stopwatch.elapsedMilliseconds,
        ),
      );

      try {
        final entity = await AssetEntity.fromId(asset.assetId);
        if (entity == null) {
          failures.add(
            FailedImport(
              assetId: asset.assetId,
              reason: ImportFailureReason.unsupportedFormat,
              message: 'Asset is no longer available.',
            ),
          );
          continue;
        }

        final originFile = await entity.originFile;
        if (originFile == null || !await originFile.exists()) {
          failures.add(
            FailedImport(
              assetId: asset.assetId,
              reason: ImportFailureReason.unsupportedFormat,
              message: 'Unable to access original file.',
            ),
          );
          continue;
        }

        final fingerprint = await HashUtils.sha1ForFile(originFile.path);

        final duplicate = await _repository.findDuplicate(
          sourceAssetId: asset.assetId,
          fingerprintSha1: fingerprint,
          equipmentId: equipmentId,
          folderId: resolvedFolderId,
        );
        if (duplicate != null) {
          duplicates.add(duplicate);
          await _repository.insertDuplicateEntry(
            existingPhotoId: duplicate.id,
            sourceAssetId: asset.assetId,
            fingerprintSha1: fingerprint,
          );
          continue;
        }

        _progressController.add(
          ImportProgress(
            processed: processed - 1,
            total: total,
            currentAssetId: asset.assetId,
            stage: ImportStage.copying,
            elapsedMilliseconds: stopwatch.elapsedMilliseconds,
          ),
        );

        final storedPath = await _copyToAppStorage(
          originFile: originFile,
          equipmentId: equipmentId,
          asset: asset,
        );

        final absolutePath = PhotoStorageService.resolveAbsolutePath(
          storedPath,
        );
        final file = File(absolutePath);
        final fileSize = await file.length();

        _progressController.add(
          ImportProgress(
            processed: processed - 1,
            total: total,
            currentAssetId: asset.assetId,
            stage: ImportStage.saving,
            elapsedMilliseconds: stopwatch.elapsedMilliseconds,
          ),
        );

        final photo = Photo(
          equipmentId: equipmentId,
          filePath: storedPath,
          thumbnailPath: null,
          latitude: entity.latitude ?? 0.0,
          longitude: entity.longitude ?? 0.0,
          timestamp: entity.createDateTime,
          capturedBy: 'SYSTEM',
          fileSize: fileSize,
          isSynced: false,
          remoteUrl: null,
          sourceAssetId: asset.assetId,
          fingerprintSha1: fingerprint,
          importBatchId: batch.id,
          importSource: 'gallery',
        );

        final savedPhoto = await _repository.insertPhoto(
          photo: photo,
          folderId: resolvedFolderId,
          beforeAfter: beforeAfter,
        );

        imported.add(savedPhoto);
      } on ImportPermissionException {
        failures.add(
          FailedImport(
            assetId: asset.assetId,
            reason: ImportFailureReason.permissionRevoked,
            message: 'Photo permissions were revoked during import.',
          ),
        );
        break;
      } on InsufficientStorageException catch (e) {
        failures.add(
          FailedImport(
            assetId: asset.assetId,
            reason: ImportFailureReason.storageFull,
            message: e.message,
          ),
        );
      } catch (e) {
        failures.add(
          FailedImport(
            assetId: asset.assetId,
            reason: ImportFailureReason.ioError,
            message: e.toString(),
          ),
        );
      } finally {
        _progressController.add(
          ImportProgress(
            processed: processed,
            total: total,
            currentAssetId: asset.assetId,
            stage: processed == total
                ? ImportStage.completed
                : ImportStage.saving,
            elapsedMilliseconds: stopwatch.elapsedMilliseconds,
          ),
        );
      }
    }

    stopwatch.stop();

    final completedBatch = batch.copyWith(
      importedCount: imported.length,
      duplicateCount: duplicates.length,
      failedCount: failures.length,
      completedAt: DateTime.now(),
    );
    await _repository.updateBatch(completedBatch);

    _progressController.add(
      ImportProgress(
        processed: total,
        total: total,
        stage: ImportStage.completed,
        elapsedMilliseconds: stopwatch.elapsedMilliseconds,
      ),
    );

    return ImportResult(
      batch: completedBatch,
      importedPhotos: imported,
      duplicates: duplicates,
      failures: failures,
    );
  }

  Future<String> _copyToAppStorage({
    required File originFile,
    required String equipmentId,
    required GalleryAsset asset,
  }) async {
    await PhotoStorageService.ensureInitialized();
    final docsDir = await getApplicationDocumentsDirectory();
    final photosDir = Directory(p.join(docsDir.path, 'photos', equipmentId));
    if (!await photosDir.exists()) {
      await photosDir.create(recursive: true);
    }

    final timestamp = asset.capturedAt ?? DateTime.now();
    final sanitizedName = (asset.fileName ?? 'import').replaceAll(
      RegExp(r'[^A-Za-z0-9._-]'),
      '_',
    );
    final fileName =
        '${timestamp.microsecondsSinceEpoch}_${sanitizedName.isEmpty ? 'photo' : sanitizedName}';
    final destinationPath = p.join(photosDir.path, fileName);

    try {
      await originFile.copy(destinationPath);
    } on FileSystemException catch (e) {
      if (e.osError?.errorCode == 28 /* ENOSPC */ ) {
        throw InsufficientStorageException('Not enough storage space.');
      }
      rethrow;
    }

    return PhotoStorageService.toStoredPath(destinationPath);
  }

  Future<String> _resolveEquipmentId(DestinationContext destination) async {
    if (destination.type != DestinationType.needsAssigned &&
        destination.equipmentId != null) {
      return destination.equipmentId!;
    }

    final db = await _databaseService.database;
    final existing = await db.query(
      'equipment',
      where: 'client_id = ?',
      whereArgs: [_globalNeedsAssignedClientId],
      limit: 1,
    );
    if (existing.isNotEmpty) {
      return existing.first['id'] as String;
    }

    final equipmentId = _uuid.v4();
    await db.insert('equipment', {
      'id': equipmentId,
      'client_id': _globalNeedsAssignedClientId,
      'main_site_id': null,
      'sub_site_id': null,
      'name': 'Needs Assigned Equipment',
      'serial_number': null,
      'manufacturer': null,
      'model': null,
      'created_by': 'SYSTEM',
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
      'is_active': 1,
    });

    return equipmentId;
  }

  ImportDestinationCategory _mapDestination(DestinationContext destination) {
    switch (destination.type) {
      case DestinationType.needsAssigned:
        return ImportDestinationCategory.needsAssigned;
      case DestinationType.equipmentBefore:
        return ImportDestinationCategory.equipmentBefore;
      case DestinationType.equipmentAfter:
        return ImportDestinationCategory.equipmentAfter;
      case DestinationType.equipmentGeneral:
        return ImportDestinationCategory.equipmentGeneral;
    }
  }

  BeforeAfter? _resolveBeforeAfter(ImportRequest request) {
    switch (request.destination.type) {
      case DestinationType.equipmentBefore:
        return BeforeAfter.before;
      case DestinationType.equipmentAfter:
        return BeforeAfter.after;
      case DestinationType.equipmentGeneral:
      case DestinationType.needsAssigned:
        switch (request.beforeAfterChoice) {
          case BeforeAfterChoice.before:
            return BeforeAfter.before;
          case BeforeAfterChoice.after:
            return BeforeAfter.after;
          case BeforeAfterChoice.general:
            return null;
        }
    }
  }

  Future<String?> _resolveFolderId(
    DestinationContext destination,
    BeforeAfter? beforeAfter,
    String equipmentId,
  ) async {
    if (destination.folderId != null) {
      return destination.folderId;
    }
    if (beforeAfter == null) {
      return null;
    }
    if (destination.type == DestinationType.equipmentBefore ||
        destination.type == DestinationType.equipmentAfter) {
      return await _ensureSystemFolder(equipmentId, beforeAfter);
    }
    return null;
  }

  Future<String> _ensureSystemFolder(
    String equipmentId,
    BeforeAfter category,
  ) async {
    final db = await _databaseService.database;
    final workOrder = category == BeforeAfter.before
        ? '__AUTO_BEFORE__'
        : '__AUTO_AFTER__';
    final existing = await db.query(
      'photo_folders',
      where: 'equipment_id = ? AND work_order = ? AND is_deleted = 0',
      whereArgs: [equipmentId, workOrder],
      limit: 1,
    );
    if (existing.isNotEmpty) {
      return existing.first['id'] as String;
    }

    final folderId = _uuid.v4();
    final name = category == BeforeAfter.before
        ? 'Before Imports'
        : 'After Imports';
    final now = DateTime.now().toIso8601String();

    await db.insert('photo_folders', {
      'id': folderId,
      'equipment_id': equipmentId,
      'name': name,
      'work_order': workOrder,
      'created_at': now,
      'updated_at': now,
      'created_by': 'SYSTEM',
      'is_deleted': 0,
    });

    return folderId;
  }
}
