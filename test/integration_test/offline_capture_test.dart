import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sitepictures/main.dart' as app;
import 'package:sitepictures/services/database/schema.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';

// Test Story 1: Offline Photo Capture (Sarah's Scenario)
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Offline Photo Capture', () {
    late Database db;

    setUpAll(() async {
      // Initialize test database
      db = await DatabaseSchema.initDatabase();
    });

    tearDownAll(() async {
      await db.close();
    });

    testWidgets('Should capture photo offline with metadata', (WidgetTester tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to Quick Capture mode
      final quickCaptureButton = find.text('Quick Capture');
      expect(quickCaptureButton, findsOneWidget);
      await tester.tap(quickCaptureButton);
      await tester.pumpAndSettle();

      // Take photo (simulated)
      final captureButton = find.byIcon(Icons.camera);
      expect(captureButton, findsOneWidget);
      await tester.tap(captureButton);
      await tester.pumpAndSettle();

      // Add annotation
      final annotationField = find.byType(TextField).first;
      await tester.enterText(annotationField, 'Control panel before modification');
      await tester.pumpAndSettle();

      // Save photo
      final saveButton = find.text('Save');
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      // Verify photo appears in Needs Assignment folder
      final needsAssignmentButton = find.text('Needs Assignment');
      await tester.tap(needsAssignmentButton);
      await tester.pumpAndSettle();

      // Check photo is displayed
      final photoTile = find.text('Control panel before modification');
      expect(photoTile, findsOneWidget);

      // Verify database record
      final photos = await db.query('photos', orderBy: 'created_at DESC', limit: 1);
      expect(photos.isNotEmpty, true);
      expect(photos.first['notes'], 'Control panel before modification');
      expect(photos.first['is_synced'], 0); // Not synced (offline)
    });

    testWidgets('Should store GPS coordinates with photo', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to Quick Capture
      await tester.tap(find.text('Quick Capture'));
      await tester.pumpAndSettle();

      // Take photo
      await tester.tap(find.byIcon(Icons.camera));
      await tester.pumpAndSettle();

      // GPS should be automatically captured (simulated: 42.3601, -71.0589)
      // Save photo
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Verify GPS in database
      final photos = await db.query('photos', orderBy: 'created_at DESC', limit: 1);
      expect(photos.isNotEmpty, true);
      expect(photos.first['latitude'], isNotNull);
      expect(photos.first['longitude'], isNotNull);
    });

    testWidgets('Should complete capture in less than 2 seconds', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Quick Capture'));
      await tester.pumpAndSettle();

      // Measure capture time
      final stopwatch = Stopwatch()..start();

      await tester.tap(find.byIcon(Icons.camera));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      stopwatch.stop();

      // Verify capture completed in less than 2 seconds
      expect(stopwatch.elapsedMilliseconds, lessThan(2000));
    });

    testWidgets('Should save photo with device attribution', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Quick Capture'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.camera));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Verify device ID in database
      final photos = await db.query('photos', orderBy: 'created_at DESC', limit: 1);
      expect(photos.isNotEmpty, true);
      expect(photos.first['device_id'], isNotNull);
    });

    testWidgets('Should handle no network gracefully', (WidgetTester tester) async {
      // This test simulates complete offline mode
      app.main();
      await tester.pumpAndSettle();

      // No network errors should be displayed
      expect(find.text('Network Error'), findsNothing);
      expect(find.text('Connection Failed'), findsNothing);

      // App should function normally
      await tester.tap(find.text('Quick Capture'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.camera), findsOneWidget);
    });
  });
}