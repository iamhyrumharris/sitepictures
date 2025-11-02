import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sitepictures/main.dart';
import 'package:sitepictures/services/analytics_logger.dart';
import 'package:sitepictures/services/import_service.dart';
import 'package:sitepictures/models/import_batch.dart';

void main() {
  testWidgets('SitePictures app launches successfully', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      SitePicturesApp(
        importService: _FakeImportService(),
        analyticsLogger: AnalyticsLogger(),
      ),
    );

    // Give time for async initialization
    await tester.pumpAndSettle();

    // Basic test - app should launch without crashing
    expect(find.byType(MaterialApp), findsOneWidget);
  }, skip: true); // Requires database initialization
}

class _FakeImportService implements ImportService {
  @override
  Future<bool> ensurePermissions({required ImportEntryPoint entryPoint}) async {
    throw UnimplementedError();
  }

  @override
  Stream<ImportProgress> get progressStream => const Stream.empty();

  @override
  Future<ImportResult> importAssets({
    required ImportRequest request,
    required List<GalleryAsset> assets,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<List<GalleryAsset>> selectAssets({
    required ImportEntryPoint entryPoint,
    BuildContext? context,
    int maxAssets = 50,
  }) async {
    throw UnimplementedError();
  }

  @override
  ImportPermissionState get lastPermissionState =>
      ImportPermissionState.granted;
}
