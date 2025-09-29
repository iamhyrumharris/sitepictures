import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sitepictures/main.dart' as app;
import 'package:sitepictures/services/database/schema.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

// Test Story 4: GPS Boundary Detection
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('GPS Boundary Detection', () {
    late Database db;

    setUpAll(() async {
      db = await DatabaseSchema.initDatabase();
      await _setupBoundaries(db);
    });

    tearDownAll(() async {
      await db.close();
    });

    testWidgets('Should auto-assign photo within boundary',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Take photo at coordinates within Factory Site A boundary
      await tester.tap(find.text('Quick Capture'));
      await tester.pumpAndSettle();

      // GPS coordinates will be simulated as 42.3605, -71.0590 (within boundary)
      await tester.tap(find.byIcon(Icons.camera));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Photo should be auto-assigned to Factory Site A
      expect(find.text('Assigned to: Factory Site A'), findsOneWidget);
    });

    testWidgets('Should place photo in Needs Assignment when outside boundaries',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Take photo at coordinates outside all boundaries
      // Simulated GPS: 42.3650, -71.0600 (outside)
      await tester.tap(find.text('Quick Capture'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.camera));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Photo should go to Needs Assignment
      await tester.tap(find.text('Needs Assignment'));
      await tester.pumpAndSettle();

      expect(find.text('Unassigned Photos'), findsOneWidget);
    });

    testWidgets('Should handle overlapping boundaries with priority',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Take photo at coordinates within overlapping boundaries
      await tester.tap(find.text('Quick Capture'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.camera));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Should be assigned to higher priority boundary
      expect(find.text('Assigned to: Control Room Area'), findsOneWidget);
    });

    testWidgets('Should show GPS accuracy indicator',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Quick Capture'));
      await tester.pumpAndSettle();

      // GPS accuracy indicator should be visible
      final accuracyIndicator = find.byIcon(Icons.gps_fixed);
      expect(accuracyIndicator, findsOneWidget);
    });

    testWidgets('Should allow manual boundary creation',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to settings
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // Open boundary management
      await tester.tap(find.text('GPS Boundaries'));
      await tester.pumpAndSettle();

      // Add new boundary
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Fill boundary details
      await tester.enterText(
          find.byKey(const Key('boundary-name')), 'New Test Area');
      await tester.enterText(
          find.byKey(const Key('boundary-radius')), '250');

      // Save boundary
      await tester.tap(find.text('Save Boundary'));
      await tester.pumpAndSettle();

      // Verify boundary was created
      expect(find.text('New Test Area'), findsOneWidget);
    });

    testWidgets('Should maintain >99% GPS accuracy',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Take multiple photos at known locations
      const testLocations = [
        {'lat': 42.3601, 'lng': -71.0589, 'expected': 'Factory Site A'},
        {'lat': 42.3605, 'lng': -71.0590, 'expected': 'Factory Site A'},
        {'lat': 42.3610, 'lng': -71.0595, 'expected': 'Control Room Area'},
      ];

      int correctAssignments = 0;

      for (final location in testLocations) {
        await tester.tap(find.text('Quick Capture'));
        await tester.pumpAndSettle();

        // Simulate GPS at specified location
        await tester.tap(find.byIcon(Icons.camera));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();

        // Check if correctly assigned
        if (find.text('Assigned to: ${location['expected']}').evaluate().isNotEmpty) {
          correctAssignments++;
        }
      }

      // Verify >99% accuracy
      final accuracy = correctAssignments / testLocations.length;
      expect(accuracy, greaterThanOrEqualTo(0.99));
    });
  });
}

Future<void> _setupBoundaries(Database db) async {
  final uuid = const Uuid();

  // Create Factory Site A boundary
  await db.insert('gps_boundaries', {
    'id': uuid.v4(),
    'client_id': uuid.v4(),
    'name': 'Factory Site A',
    'center_latitude': 42.3601,
    'center_longitude': -71.0589,
    'radius_meters': 500,
    'priority': 1,
    'created_at': DateTime.now().toIso8601String(),
    'updated_at': DateTime.now().toIso8601String(),
  });

  // Create Control Room Area boundary (overlapping, higher priority)
  await db.insert('gps_boundaries', {
    'id': uuid.v4(),
    'site_id': uuid.v4(),
    'name': 'Control Room Area',
    'center_latitude': 42.3605,
    'center_longitude': -71.0590,
    'radius_meters': 100,
    'priority': 2,
    'created_at': DateTime.now().toIso8601String(),
    'updated_at': DateTime.now().toIso8601String(),
  });
}