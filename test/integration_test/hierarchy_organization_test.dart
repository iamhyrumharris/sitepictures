import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sitepictures/main.dart' as app;
import 'package:sitepictures/services/database/schema.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

// Test Story 2: Hierarchical Organization (Mike's Equipment History)
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Hierarchical Organization', () {
    late Database db;

    setUpAll(() async {
      db = await DatabaseSchema.initDatabase();
      await _setupTestHierarchy(db);
    });

    tearDownAll(() async {
      await db.close();
    });

    testWidgets('Should display hierarchical navigation breadcrumbs',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to equipment
      await tester.tap(find.text('ACME Corp'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Plant A'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Control Room'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('PLC Panel 1'));
      await tester.pumpAndSettle();

      // Verify breadcrumbs
      expect(find.text('ACME Corp > Plant A > Control Room > PLC Panel 1'),
             findsOneWidget);
    });

    testWidgets('Should display photos in chronological order',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to equipment with photos
      await _navigateToEquipment(tester, 'PLC Panel 1');

      // Verify photos are displayed in chronological order
      final photoTiles = find.byType(ListTile);
      expect(photoTiles, findsNWidgets(5));

      // Check order (newest first)
      final photos = await db.query('photos',
        where: 'equipment_id = ?',
        orderBy: 'captured_at DESC');

      expect(photos.length, 5);
    });

    testWidgets('Should support revision folders',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await _navigateToEquipment(tester, 'PLC Panel 1');

      // Check revision folders
      expect(find.text('2023-Installation'), findsOneWidget);
      expect(find.text('2024-Upgrade'), findsOneWidget);
      expect(find.text('2025-Maintenance'), findsOneWidget);

      // Tap on revision folder
      await tester.tap(find.text('2024-Upgrade'));
      await tester.pumpAndSettle();

      // Verify photos in revision
      final revisionPhotos = find.byType(Image);
      expect(revisionPhotos, findsWidgets);
    });

    testWidgets('Should show equipment timeline visualization',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await _navigateToEquipment(tester, 'PLC Panel 1');

      // Switch to timeline view
      final timelineButton = find.byIcon(Icons.timeline);
      await tester.tap(timelineButton);
      await tester.pumpAndSettle();

      // Verify timeline markers
      expect(find.text('2023'), findsOneWidget);
      expect(find.text('2024'), findsOneWidget);
      expect(find.text('2025'), findsOneWidget);
    });

    testWidgets('Should search equipment by name',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Open search
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      // Search for equipment
      await tester.enterText(find.byType(TextField), 'PLC Panel');
      await tester.pumpAndSettle();

      // Verify search results
      expect(find.text('PLC Panel 1'), findsOneWidget);
      expect(find.text('Control Room > PLC Panel 1'), findsOneWidget);
    });

    testWidgets('Should handle nested site hierarchy',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate through site hierarchy
      await tester.tap(find.text('ACME Corp'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Plant A'));
      await tester.pumpAndSettle();

      // Main site should have sub-sites
      expect(find.text('Control Room'), findsOneWidget);
      expect(find.text('Pump Station'), findsOneWidget);
    });
  });
}

Future<void> _setupTestHierarchy(Database db) async {
  final uuid = const Uuid();

  // Create company
  final companyId = uuid.v4();
  await db.insert('companies', {
    'id': companyId,
    'name': 'ACME Corp',
    'settings': '{}',
    'created_at': DateTime.now().toIso8601String(),
    'updated_at': DateTime.now().toIso8601String(),
  });

  // Create client
  final clientId = uuid.v4();
  await db.insert('clients', {
    'id': clientId,
    'company_id': companyId,
    'name': 'ACME Manufacturing',
    'created_at': DateTime.now().toIso8601String(),
    'updated_at': DateTime.now().toIso8601String(),
  });

  // Create main site
  final mainSiteId = uuid.v4();
  await db.insert('sites', {
    'id': mainSiteId,
    'client_id': clientId,
    'name': 'Plant A',
    'created_at': DateTime.now().toIso8601String(),
    'updated_at': DateTime.now().toIso8601String(),
  });

  // Create sub-site
  final subSiteId = uuid.v4();
  await db.insert('sites', {
    'id': subSiteId,
    'client_id': clientId,
    'parent_site_id': mainSiteId,
    'name': 'Control Room',
    'created_at': DateTime.now().toIso8601String(),
    'updated_at': DateTime.now().toIso8601String(),
  });

  // Create equipment
  final equipmentId = uuid.v4();
  await db.insert('equipment', {
    'id': equipmentId,
    'site_id': subSiteId,
    'name': 'PLC Panel 1',
    'equipment_type': 'PLC',
    'created_at': DateTime.now().toIso8601String(),
    'updated_at': DateTime.now().toIso8601String(),
  });

  // Create revision folders
  final revisions = [
    {'name': '2023-Installation', 'year': 2023},
    {'name': '2024-Upgrade', 'year': 2024},
    {'name': '2025-Maintenance', 'year': 2025},
  ];

  for (final rev in revisions) {
    final revId = uuid.v4();
    await db.insert('revisions', {
      'id': revId,
      'equipment_id': equipmentId,
      'name': rev['name'],
      'created_at': DateTime(rev['year'] as int, 1, 1).toIso8601String(),
      'created_by': uuid.v4(),
    });

    // Add sample photos to each revision
    await db.insert('photos', {
      'id': uuid.v4(),
      'equipment_id': equipmentId,
      'revision_id': revId,
      'file_name': 'IMG_${rev['year']}.jpg',
      'file_hash': 'a' * 64,
      'captured_at': DateTime(rev['year'] as int, 6, 15).toIso8601String(),
      'device_id': uuid.v4(),
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });
  }
}

Future<void> _navigateToEquipment(WidgetTester tester, String equipmentName) async {
  await tester.tap(find.text('ACME Corp'));
  await tester.pumpAndSettle();

  await tester.tap(find.text('Plant A'));
  await tester.pumpAndSettle();

  await tester.tap(find.text('Control Room'));
  await tester.pumpAndSettle();

  await tester.tap(find.text(equipmentName));
  await tester.pumpAndSettle();
}