import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/destination_context.dart';
import '../models/import_batch.dart';
import '../services/analytics_logger.dart';
import '../services/import_service.dart';
import '../widgets/permission_education_sheet.dart';
import '../widgets/permission_denied_dialog.dart';

class ImportFlowProvider extends ChangeNotifier {
  ImportFlowProvider({
    required ImportService importService,
    required AnalyticsLogger analyticsLogger,
    GlobalKey<NavigatorState>? navigatorKey,
  }) : _importService = importService,
       _analyticsLogger = analyticsLogger,
       _navigatorKey = navigatorKey,
       _permissionState = importService.lastPermissionState;

  final ImportService _importService;
  final AnalyticsLogger _analyticsLogger;
  GlobalKey<NavigatorState>? _navigatorKey;
  ImportFlowState _state = ImportFlowState.idle;
  ImportEntryPoint? _entryPoint;
  DestinationContext? _destination;
  BeforeAfterChoice _beforeAfterChoice = BeforeAfterChoice.general;
  String? _errorMessage;
  ImportBatch? _lastBatch;
  ImportResult? _lastResult;
  StreamSubscription<ImportProgress>? _progressSubscription;
  ImportPermissionState _permissionState;

  ImportFlowState get state => _state;
  String? get errorMessage => _errorMessage;
  ImportBatch? get lastBatch => _lastBatch;
  ImportResult? get lastResult => _lastResult;
  ImportPermissionState get permissionState => _permissionState;

  Stream<ImportProgress> progress() => _importService.progressStream;

  void configure({
    required ImportEntryPoint entryPoint,
    required DestinationContext defaultDestination,
    BeforeAfterChoice beforeAfterChoice = BeforeAfterChoice.general,
    GlobalKey<NavigatorState>? navigatorKey,
    ImportPermissionState? initialPermissionState,
  }) {
    _entryPoint = entryPoint;
    _destination = defaultDestination;
    _beforeAfterChoice = beforeAfterChoice;
    _navigatorKey ??= navigatorKey;
    _state = ImportFlowState.idle;
    _errorMessage = null;
    _lastBatch = null;
    _lastResult = null;
    if (initialPermissionState != null) {
      _permissionState = initialPermissionState;
    }
    notifyListeners();
  }

  Future<ImportResult?> startImport({BuildContext? pickerContext}) async {
    final entryPoint = _entryPoint;
    final destination = _destination;
    if (entryPoint == null || destination == null) {
      throw StateError(
        'ImportFlowProvider must be configured with entry point and destination.',
      );
    }

    _setState(ImportFlowState.awaitingPermission);

    final dialogContext = pickerContext ?? _navigatorFallbackContext();

    final needsEducation =
        _permissionState == ImportPermissionState.denied ||
        _permissionState == ImportPermissionState.restricted;

    if (needsEducation) {
      final acknowledged = await showPermissionEducationSheet(dialogContext);
      if (acknowledged == false) {
        _setState(ImportFlowState.idle);
        return null;
      }
    }

    final permissionGranted = await _importService.ensurePermissions(
      entryPoint: entryPoint,
    );
    _permissionState = _importService.lastPermissionState;
    await _analyticsLogger.logPermissionEvent(
      entryPoint: entryPoint,
      status: _importService.lastPermissionState,
    );

    if (!permissionGranted) {
      await showPermissionDeniedDialog(dialogContext);
      _errorMessage =
          'Photo access is required to import images. Update permissions in Settings.';
      _setState(ImportFlowState.idle);
      return null;
    }

    _setState(ImportFlowState.selectingAssets);

    List<GalleryAsset> assets;
    try {
      assets = await _importService.selectAssets(
        entryPoint: entryPoint,
        context: pickerContext,
      );
      _permissionState = _importService.lastPermissionState;
    } on ImportPermissionException catch (error) {
      _permissionState = _importService.lastPermissionState;
      await _analyticsLogger.logPermissionEvent(
        entryPoint: entryPoint,
        status: _importService.lastPermissionState,
      );
      await showPermissionDeniedDialog(dialogContext);
      _setError(error.message);
      return null;
    } catch (error) {
      _setError(error.toString());
      return null;
    }

    if (assets.isEmpty) {
      _setState(ImportFlowState.idle);
      return null;
    }

    _setState(ImportFlowState.processing);
    _listenToProgress();

    try {
      final result = await _importService.importAssets(
        request: ImportRequest(
          entryPoint: entryPoint,
          destination: destination,
          beforeAfterChoice: _beforeAfterChoice,
        ),
        assets: assets,
      );

      _lastBatch = result.batch;
      _lastResult = result;
      await _analyticsLogger.logGalleryImport(result);
      _setState(ImportFlowState.completed);
      return result;
    } on ImportPermissionException catch (error) {
      _setError(error.message);
      return null;
    } on InsufficientStorageException catch (error) {
      _setError(error.message);
      return null;
    } catch (error) {
      _setError(error.toString());
      return null;
    } finally {
      await _progressSubscription?.cancel();
      _progressSubscription = null;
    }
  }

  void updateDestination(DestinationContext destination) {
    _destination = destination;
    notifyListeners();
  }

  void updateBeforeAfter(BeforeAfterChoice choice) {
    _beforeAfterChoice = choice;
    notifyListeners();
  }

  void dismissError() {
    _errorMessage = null;
    if (_state == ImportFlowState.error) {
      _state = ImportFlowState.idle;
    }
    notifyListeners();
  }

  void _setState(ImportFlowState nextState) {
    if (_state == nextState) {
      return;
    }
    _state = nextState;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _lastResult = null;
    _setState(ImportFlowState.error);
  }

  void _listenToProgress() {
    _progressSubscription?.cancel();
    _progressSubscription = _importService.progressStream.listen((event) {
      if (_state == ImportFlowState.processing) {
        notifyListeners();
      }
    });
  }

  BuildContext _navigatorFallbackContext() {
    final context = _navigatorKey?.currentContext;
    if (context == null) {
      throw StateError('Navigator context not available for permission sheet.');
    }
    return context;
  }

  @override
  void dispose() {
    _progressSubscription?.cancel();
    super.dispose();
  }
}

enum ImportFlowState {
  idle,
  awaitingPermission,
  selectingAssets,
  processing,
  completed,
  error,
}
