import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sitepictures/main.dart' as app;
import 'package:sitepictures/services/database_service.dart';

/// Performance test for search functionality
/// Validates Constitution Article VI: Search < 1 second
/// Tests quickstart.md Scenario 10 - Performance Validation
void main() {
  group('Search Performance Test', () {
    late DatabaseService dbService;

    setUpAll(() async {
      dbService = DatabaseService();
      await dbService.database;

      // Seed database with test data for realistic search
      final db = await dbService.database;

      // Create test clients (100 clients)
      for (int i = 0; i < 100; i++) {
        await db.insert('clients', {
          'id': 'client-perf-$i',
          'name': 'Client $i - ${_randomCompanyName(i)}',
          'created_by': 'test-user',
          'created_at': DateTime.now().toIso8601String(),
          'is_active': 1,
        });
      }

      // Create test equipment (500 items)
      for (int i = 0; i < 500; i++) {
        await db.insert('equipment', {
          'id': 'equipment-perf-$i',
          'name': 'Equipment $i - ${_randomEquipmentType(i)}',
          'site_id': 'site-perf-${i % 50}',
          'created_by': 'test-user',
          'created_at': DateTime.now().toIso8601String(),
        });
      }
    });

    tearDownAll() async {
      // Cleanup test data
      final db = await dbService.database;
      await db.delete('clients', where: 'id LIKE ?', whereArgs: ['client-perf-%']);
      await db.delete('equipment', where: 'id LIKE ?', whereArgs: ['equipment-perf-%']);
    });

    testWidgets('Search results should return in less than 1 second',
        (WidgetTester tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to search
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      // Enter search query
      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'Generator');

      // Measure search time
      final stopwatch = Stopwatch()..start();
      await tester.pumpAndSettle();
      stopwatch.stop();

      final searchTime = stopwatch.elapsedMilliseconds;

      // Constitutional requirement: < 1 second (1000ms)
      expect(
        searchTime,
        lessThan(1000),
        reason: 'Search took ${searchTime}ms, exceeds 1000ms limit',
      );

      print('✓ Search completed in ${searchTime}ms (target: <1000ms)');
    });

    testWidgets('Search should handle large result sets efficiently',
        (WidgetTester tester) async {
      // Search for common term that returns many results
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      // Search for "Equipment" - should match many items
      final stopwatch = Stopwatch()..start();
      await tester.enterText(find.byType(TextField), 'Equipment');
      await tester.pumpAndSettle();
      stopwatch.stop();

      final searchTime = stopwatch.elapsedMilliseconds;

      expect(
        searchTime,
        lessThan(1000),
        reason: 'Large result search took ${searchTime}ms',
      );

      // Verify results are displayed
      expect(find.byType(ListTile), findsWidgets);

      print('✓ Large result set search: ${searchTime}ms');
    });

    testWidgets('Incremental search should maintain performance',
        (WidgetTester tester) async {
      // Test typing search query incrementally
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      final searchTerms = ['G', 'Ge', 'Gen', 'Gene', 'Gener', 'Genera', 'Generat', 'Generato', 'Generator'];
      final searchTimes = <int>[];

      for (final term in searchTerms) {
        final stopwatch = Stopwatch()..start();
        await tester.enterText(find.byType(TextField), term);
        await tester.pumpAndSettle();
        stopwatch.stop();

        searchTimes.add(stopwatch.elapsedMilliseconds);

        expect(
          stopwatch.elapsedMilliseconds,
          lessThan(1000),
          reason: 'Incremental search for "$term" took ${stopwatch.elapsedMilliseconds}ms',
        );
      }

      final avgTime = searchTimes.reduce((a, b) => a + b) / searchTimes.length;
      print('✓ Incremental search average: ${avgTime.toStringAsFixed(0)}ms');
      print('  Search times: ${searchTimes.join(", ")}ms');
    });

    testWidgets('Search across multiple entity types should be fast',
        (WidgetTester tester) async {
      // Search should look in clients, sites, equipment
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      // Search for term that appears in multiple types
      final stopwatch = Stopwatch()..start();
      await tester.enterText(find.byType(TextField), 'Industrial');
      await tester.pumpAndSettle();
      stopwatch.stop();

      final searchTime = stopwatch.elapsedMilliseconds;

      expect(
        searchTime,
        lessThan(1000),
        reason: 'Multi-entity search took ${searchTime}ms',
      );

      print('✓ Multi-entity search: ${searchTime}ms');
    });

    testWidgets('Empty search results should return quickly',
        (WidgetTester tester) async {
      // Search for non-existent term
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      final stopwatch = Stopwatch()..start();
      await tester.enterText(find.byType(TextField), 'NonExistentXYZ123');
      await tester.pumpAndSettle();
      stopwatch.stop();

      final searchTime = stopwatch.elapsedMilliseconds;

      expect(
        searchTime,
        lessThan(1000),
        reason: 'Empty result search took ${searchTime}ms',
      );

      // Verify "No results" message appears
      expect(find.text('No results'), findsOneWidget);

      print('✓ Empty result search: ${searchTime}ms');
    });

    testWidgets('Search performance with 1000+ photos in database',
        (WidgetTester tester) async {
      // Seed more photos for stress test
      final db = await dbService.database;

      for (int i = 0; i < 1000; i++) {
        await db.insert('photos', {
          'id': 'photo-perf-$i',
          'equipment_id': 'equipment-perf-${i % 500}',
          'file_path': '/test/path/photo-$i.jpg',
          'latitude': 40.7128 + (i * 0.001),
          'longitude': -74.0060 + (i * 0.001),
          'timestamp': DateTime.now().toIso8601String(),
          'captured_by': 'test-user',
          'file_size': 1024000,
          'is_synced': 0,
        });
      }

      // Perform search
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      final stopwatch = Stopwatch()..start();
      await tester.enterText(find.byType(TextField), 'Equipment');
      await tester.pumpAndSettle();
      stopwatch.stop();

      final searchTime = stopwatch.elapsedMilliseconds;

      expect(
        searchTime,
        lessThan(1000),
        reason: 'Search with 1000+ photos took ${searchTime}ms',
      );

      print('✓ Search with 1000+ photos: ${searchTime}ms');

      // Cleanup
      await db.delete('photos', where: 'id LIKE ?', whereArgs: ['photo-perf-%']);
    });

    testWidgets('Fuzzy search should maintain performance',
        (WidgetTester tester) async {
      // Test partial/fuzzy matching
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      // Search with partial term
      final stopwatch = Stopwatch()..start();
      await tester.enterText(find.byType(TextField), 'Gen'); // Should match "Generator"
      await tester.pumpAndSettle();
      stopwatch.stop();

      final searchTime = stopwatch.elapsedMilliseconds;

      expect(
        searchTime,
        lessThan(1000),
        reason: 'Fuzzy search took ${searchTime}ms',
      );

      // Should find results with "Gen" in them
      expect(find.byType(ListTile), findsWidgets);

      print('✓ Fuzzy search: ${searchTime}ms');
    });

    test('Database search query optimization', () async {
      // Test raw database query performance
      final db = await dbService.database;

      final stopwatch = Stopwatch()..start();

      // Simulate search query across tables
      final results = await db.rawQuery('''
        SELECT 'client' as type, id, name FROM clients WHERE name LIKE ?
        UNION
        SELECT 'equipment' as type, id, name FROM equipment WHERE name LIKE ?
        LIMIT 100
      ''', ['%Generator%', '%Generator%']);

      stopwatch.stop();
      final queryTime = stopwatch.elapsedMilliseconds;

      expect(
        queryTime,
        lessThan(1000),
        reason: 'Database search query took ${queryTime}ms',
      );

      expect(results.length, greaterThan(0));

      print('✓ Database search query: ${queryTime}ms');
      print('  Results: ${results.length} items');
    });
  });
}

// Helper functions for test data generation
String _randomCompanyName(int seed) {
  final companies = ['Corp', 'Industries', 'Services', 'Group', 'LLC', 'Inc'];
  return companies[seed % companies.length];
}

String _randomEquipmentType(int seed) {
  final types = ['Generator', 'Pump', 'Motor', 'Compressor', 'Panel', 'Valve'];
  return '${types[seed % types.length]} Unit';
}
