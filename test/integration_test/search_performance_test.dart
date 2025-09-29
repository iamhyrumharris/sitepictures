import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sitepictures/main.dart' as app;
import 'package:sitepictures/services/database/schema.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

// Test Story 5: Search Performance (10-Second Retrieval)
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Search Performance', () {
    late Database db;

    setUpAll(() async {
      db = await DatabaseSchema.initDatabase();
      await _createTestDataset(db);
    });

    tearDownAll(() async {
      await db.close();
    });

    testWidgets('Should search by client name in <1 second',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Open search
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      // Measure search time
      final stopwatch = Stopwatch()..start();

      await tester.enterText(find.byType(TextField), 'ACME');
      await tester.pumpAndSettle();

      stopwatch.stop();

      // Verify search completed in less than 1 second
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));

      // Verify results
      expect(find.text('ACME'), findsWidgets);
    });

    testWidgets('Should search by date range in <1 second',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      // Switch to date filter
      await tester.tap(find.text('Date Range'));
      await tester.pumpAndSettle();

      final stopwatch = Stopwatch()..start();

      // Select date range
      await tester.tap(find.text('Last Month'));
      await tester.pumpAndSettle();

      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
      expect(find.byType(Image), findsWidgets);
    });

    testWidgets('Should search by annotation content in <1 second',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      final stopwatch = Stopwatch()..start();

      await tester.enterText(find.byType(TextField), 'maintenance');
      await tester.pumpAndSettle();

      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
      expect(find.text('maintenance'), findsWidgets);
    });

    testWidgets('Should search by equipment type in <1 second',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      // Switch to equipment filter
      await tester.tap(find.text('Equipment Type'));
      await tester.pumpAndSettle();

      final stopwatch = Stopwatch()..start();

      await tester.tap(find.text('PLC'));
      await tester.pumpAndSettle();

      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
      expect(find.text('PLC'), findsWidgets);
    });

    testWidgets('Should search by GPS proximity in <1 second',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      // Switch to location filter
      await tester.tap(find.text('Near Location'));
      await tester.pumpAndSettle();

      final stopwatch = Stopwatch()..start();

      // Use current location (simulated)
      await tester.tap(find.text('Use Current Location'));
      await tester.pumpAndSettle();

      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
    });

    testWidgets('Should show full hierarchical context in results',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Panel');
      await tester.pumpAndSettle();

      // Results should show full path
      expect(find.textContaining('ACME Corp > Plant A > Control Room'),
             findsWidgets);
    });

    testWidgets('Should handle 1000+ photos efficiently',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      // Search across large dataset
      final stopwatch = Stopwatch()..start();

      await tester.enterText(find.byType(TextField), 'equipment');
      await tester.pumpAndSettle();

      stopwatch.stop();

      // Should still complete in under 1 second even with 1000+ records
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
    });

    testWidgets('Should support combined search filters',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      // Apply multiple filters
      final stopwatch = Stopwatch()..start();

      await tester.enterText(find.byType(TextField), 'PLC');
      await tester.tap(find.text('Last Week'));
      await tester.tap(find.text('Plant A'));
      await tester.pumpAndSettle();

      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
      expect(find.byType(ListTile), findsWidgets);
    });
  });
}

Future<void> _createTestDataset(Database db) async {
  final uuid = const Uuid();

  // Create company and client structure
  final companyId = uuid.v4();
  await db.insert('companies', {
    'id': companyId,
    'name': 'ACME Corp',
    'created_at': DateTime.now().toIso8601String(),
    'updated_at': DateTime.now().toIso8601String(),
  });

  final clientId = uuid.v4();
  await db.insert('clients', {
    'id': clientId,
    'company_id': companyId,
    'name': 'ACME Manufacturing',
    'created_at': DateTime.now().toIso8601String(),
    'updated_at': DateTime.now().toIso8601String(),
  });

  // Create 50 equipment items across multiple sites
  for (int i = 0; i < 50; i++) {
    final siteId = uuid.v4();
    await db.insert('sites', {
      'id': siteId,
      'client_id': clientId,
      'name': 'Site ${i ~/ 10}',
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });

    final equipmentId = uuid.v4();
    final equipmentTypes = ['PLC', 'Panel', 'Motor', 'Pump', 'Valve'];
    await db.insert('equipment', {
      'id': equipmentId,
      'site_id': siteId,
      'name': 'Equipment $i',
      'equipment_type': equipmentTypes[i % 5],
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });

    // Create 20 photos per equipment (1000 total)
    for (int j = 0; j < 20; j++) {
      final photoDate = DateTime.now().subtract(Duration(days: j));
      final notes = j % 3 == 0 ? 'maintenance required' :
                    j % 3 == 1 ? 'inspection complete' : null;

      await db.insert('photos', {
        'id': uuid.v4(),
        'equipment_id': equipmentId,
        'file_name': 'IMG_${i}_$j.jpg',
        'file_hash': 'a' * 64,
        'latitude': 42.3601 + (i * 0.0001),
        'longitude': -71.0589 + (j * 0.0001),
        'captured_at': photoDate.toIso8601String(),
        'notes': notes,
        'device_id': uuid.v4(),
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      // Add to FTS index
      if (notes != null) {
        await db.insert('search_index', {
          'entity_type': 'Photo',
          'entity_id': uuid.v4(),
          'content': notes,
        });
      }
    }
  }
}