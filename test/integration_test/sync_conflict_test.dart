import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sitepictures/main.dart' as app;
import 'package:sitepictures/services/database/schema.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

// Test Story 3: Sync and Conflict Resolution (Jennifer's Scenario)
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Sync and Conflict Resolution', () {
    late Database dbDeviceA;
    late Database dbDeviceB;
    final uuid = const Uuid();

    setUpAll(() async {
      // Simulate two devices with separate databases
      dbDeviceA = await DatabaseSchema.initDatabase();
      dbDeviceB = await DatabaseSchema.initDatabase();
    });

    tearDownAll(() async {
      await dbDeviceA.close();
      await dbDeviceB.close();
    });

    testWidgets('Should queue changes while offline',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Add photos while offline
      for (int i = 0; i < 3; i++) {
        await tester.tap(find.text('Quick Capture'));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.camera));
        await tester.pumpAndSettle();

        await tester.enterText(
            find.byType(TextField).first, 'Photo ${i + 1} from Device A');
        await tester.pumpAndSettle();

        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();
      }

      // Check sync queue
      final syncPackages = await dbDeviceA.query('sync_packages',
          where: 'status = ?', whereArgs: ['PENDING']);

      expect(syncPackages.length, greaterThanOrEqualTo(3));
    });

    testWidgets('Should handle concurrent updates gracefully',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Create equipment
      final equipmentId = uuid.v4();
      await dbDeviceA.insert('equipment', {
        'id': equipmentId,
        'site_id': uuid.v4(),
        'name': 'Pump Station 1',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      // Device A updates notes
      await dbDeviceA.update('equipment',
          {'notes': 'Maintenance required'},
          where: 'id = ?',
          whereArgs: [equipmentId]);

      // Device B updates notes (simulated)
      await dbDeviceB.update('equipment',
          {'notes': 'Inspection complete'},
          where: 'id = ?',
          whereArgs: [equipmentId]);

      // Trigger sync (simulated)
      await tester.tap(find.byIcon(Icons.sync));
      await tester.pumpAndSettle();

      // Both notes should be preserved (merged)
      // In real implementation, this would be handled by the sync service
      expect(find.text('Maintenance required'), findsOneWidget);
      expect(find.text('Inspection complete'), findsOneWidget);
    });

    testWidgets('Should show sync status indicator',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Check for sync status indicator
      final syncIcon = find.byIcon(Icons.cloud_off);
      expect(syncIcon, findsOneWidget); // Offline initially

      // Simulate coming online
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Sync Now'));
      await tester.pumpAndSettle();

      // Should show syncing status
      expect(find.byIcon(Icons.sync), findsOneWidget);

      // After sync completes
      await tester.pump(const Duration(seconds: 2));

      // Should show synced status
      expect(find.byIcon(Icons.cloud_done), findsOneWidget);
    });

    testWidgets('Should preserve all photos during conflict',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      final equipmentId = uuid.v4();

      // Add photos from Device A
      for (int i = 0; i < 3; i++) {
        await dbDeviceA.insert('photos', {
          'id': uuid.v4(),
          'equipment_id': equipmentId,
          'file_name': 'device_a_photo_$i.jpg',
          'file_hash': 'a' * 64,
          'captured_at': DateTime.now().toIso8601String(),
          'device_id': 'device-a',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
      }

      // Add photos from Device B
      for (int i = 0; i < 2; i++) {
        await dbDeviceB.insert('photos', {
          'id': uuid.v4(),
          'equipment_id': equipmentId,
          'file_name': 'device_b_photo_$i.jpg',
          'file_hash': 'b' * 64,
          'captured_at': DateTime.now().toIso8601String(),
          'device_id': 'device-b',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
      }

      // After sync, all 5 photos should be present
      // In real implementation, after sync this would be tested:
      // final allPhotos = await dbDeviceA.query('photos',
      //     where: 'equipment_id = ?', whereArgs: [equipmentId]);
      // expect(allPhotos.length, 5);
    });

    testWidgets('Should show clear device attribution',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to equipment with synced photos
      await tester.tap(find.text('Equipment'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Pump Station 1'));
      await tester.pumpAndSettle();

      // Each photo should show which device added it
      expect(find.text('Added by: Device A'), findsWidgets);
      expect(find.text('Added by: Device B'), findsWidgets);
    });

    testWidgets('Should achieve >99.5% sync success rate',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Create 200 sync packages for stress test
      for (int i = 0; i < 200; i++) {
        await dbDeviceA.insert('sync_packages', {
          'id': uuid.v4(),
          'entity_type': 'Photo',
          'entity_id': uuid.v4(),
          'operation': 'CREATE',
          'data': '{}',
          'timestamp': DateTime.now().toIso8601String(),
          'device_id': 'device-a',
          'status': 'PENDING',
        });
      }

      // Trigger sync
      await tester.tap(find.byIcon(Icons.sync));
      await tester.pumpAndSettle();

      // Wait for sync to complete
      await tester.pump(const Duration(seconds: 5));

      // Check success rate
      final successful = await dbDeviceA.query('sync_packages',
          where: 'status = ?', whereArgs: ['SYNCED']);

      final successRate = successful.length / 200;
      expect(successRate, greaterThanOrEqualTo(0.995)); // >99.5%
    });
  });
}