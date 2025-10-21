import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sitepictures/main.dart' as app;
import 'package:sitepictures/services/auth_service.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sitepictures/services/database_service.dart';

Future<void> _seedNavigationData() async {
  final dbService = DatabaseService();
  final db = await dbService.database;

  await db.delete('folder_photos');
  await db.delete('photo_folders');
  await db.delete('photos');
  await db.delete('equipment');
  await db.delete('sub_sites');
  await db.delete('main_sites');
  await db.delete('clients', where: 'is_system = 0');
  await db.delete('users');

  final now = DateTime.now().toIso8601String();

  await db.insert('users', {
    'id': 'test-user',
    'email': 'test@user.com',
    'name': 'Test User',
    'role': 'admin',
    'created_at': now,
    'updated_at': now,
    'last_sync_at': now,
  });

  // Ensure global Needs Assigned client exists
  await db.insert('clients', {
    'id': 'GLOBAL_NEEDS_ASSIGNED',
    'name': 'Needs Assigned',
    'description': 'Global holding area for unorganized photos',
    'is_system': 1,
    'created_by': 'test-user',
    'created_at': now,
    'updated_at': now,
    'is_active': 1,
  }, conflictAlgorithm: ConflictAlgorithm.replace);

  await db.insert('clients', {
    'id': 'client-acme',
    'name': 'ACME Industrial',
    'description': 'Industrial manufacturing client',
    'is_system': 0,
    'created_by': 'test-user',
    'created_at': now,
    'updated_at': now,
    'is_active': 1,
  });

  await db.insert('clients', {
    'id': 'client-long',
    'name': 'Client With Very Long Name',
    'description': 'Client used for breadcrumb overflow testing',
    'is_system': 0,
    'created_by': 'test-user',
    'created_at': now,
    'updated_at': now,
    'is_active': 1,
  });

  await db.insert('main_sites', {
    'id': 'site-factory-north',
    'client_id': 'client-acme',
    'name': 'Factory North',
    'address': '123 Industrial Way',
    'latitude': 40.0,
    'longitude': -105.0,
    'created_by': 'test-user',
    'created_at': now,
    'updated_at': now,
    'is_active': 1,
  });

  await db.insert('main_sites', {
    'id': 'site-long',
    'client_id': 'client-long',
    'name': 'Site With Extremely Long Name That Exceeds Width',
    'address': '456 Long Road',
    'latitude': 39.0,
    'longitude': -104.0,
    'created_by': 'test-user',
    'created_at': now,
    'updated_at': now,
    'is_active': 1,
  });

  await db.insert('sub_sites', {
    'id': 'sub-assembly-line',
    'client_id': null,
    'main_site_id': 'site-factory-north',
    'parent_subsite_id': null,
    'name': 'Assembly Line',
    'description': 'Primary assembly area',
    'created_by': 'test-user',
    'created_at': now,
    'updated_at': now,
    'is_active': 1,
  });

  await db.insert('sub_sites', {
    'id': 'sub-long',
    'client_id': null,
    'main_site_id': 'site-long',
    'parent_subsite_id': null,
    'name': 'SubSite With Another Very Long Name',
    'description': 'Extended breadcrumb testing',
    'created_by': 'test-user',
    'created_at': now,
    'updated_at': now,
    'is_active': 1,
  });

  await db.insert('equipment', {
    'id': 'equip-generator-a',
    'client_id': null,
    'main_site_id': 'site-factory-north',
    'sub_site_id': null,
    'name': 'Generator A',
    'serial_number': 'GEN-A-001',
    'manufacturer': 'GenTech',
    'model': 'GT-1000',
    'created_by': 'test-user',
    'created_at': now,
    'updated_at': now,
    'is_active': 1,
  });

  await db.insert('equipment', {
    'id': 'equip-pump-1',
    'client_id': null,
    'main_site_id': null,
    'sub_site_id': 'sub-assembly-line',
    'name': 'Pump #1',
    'serial_number': 'PUMP-001',
    'manufacturer': 'FlowCo',
    'model': 'FC-200',
    'created_by': 'test-user',
    'created_at': now,
    'updated_at': now,
    'is_active': 1,
  });

  await db.insert('equipment', {
    'id': 'equip-long',
    'client_id': null,
    'main_site_id': null,
    'sub_site_id': 'sub-long',
    'name': 'Inspection Drone',
    'serial_number': 'DRONE-001',
    'manufacturer': 'SkyScan',
    'model': 'SS-900',
    'created_by': 'test-user',
    'created_at': now,
    'updated_at': now,
    'is_active': 1,
  });
}

Future<void> _performLogin(WidgetTester tester) async {
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextFormField).at(0), 'test@test.com');
  await tester.enterText(find.byType(TextFormField).at(1), 'test123');
  await tester.tap(find.text('Login'));
  await tester.pumpAndSettle();
  await tester.pump(const Duration(milliseconds: 500));
}

/// Integration test for navigation flow through hierarchy
/// Validates FR-004, FR-005, FR-006, FR-014, FR-015, FR-016, FR-017
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await _seedNavigationData();
    await AuthService().clearCredentials();
  });

  group('Navigation Flow Integration Test', () {
    testWidgets(
      'should navigate through client -> site -> equipment hierarchy',
      (WidgetTester tester) async {
        // Launch app
        app.main();
        await _performLogin(tester);

        // Should be on home screen
        expect(find.text('Ziatech'), findsOneWidget);

        // Verify breadcrumb is empty or shows "Home"
        expect(find.byType(ListView), findsWidgets);

        // Tap on a client
        final clientTile = find.text('ACME Industrial').first;
        expect(clientTile, findsOneWidget);
        await tester.tap(clientTile);
        await tester.pumpAndSettle();

        // Should now show main sites for that client
        expect(find.text('Factory North'), findsOneWidget);

        // Verify breadcrumb shows: ACME Industrial
        expect(find.text('ACME Industrial'), findsOneWidget);

        // Tap on main site
        await tester.tap(find.text('Factory North'));
        await tester.pumpAndSettle();

        // Should show subsites and equipment
        expect(find.text('Assembly Line'), findsOneWidget);
        expect(find.text('Generator A'), findsOneWidget);

        // Verify breadcrumb shows: ACME Industrial > Factory North
        expect(find.text('Factory North'), findsOneWidget);

        // Tap on subsite
        await tester.tap(find.text('Assembly Line'));
        await tester.pumpAndSettle();

        // Should show only equipment (no further subsites)
        expect(find.byIcon(Icons.precision_manufacturing), findsWidgets);

        // Verify breadcrumb shows full path
        expect(find.text('Assembly Line'), findsOneWidget);
      },
    );

    testWidgets('should open All Photos from bottom navigation', (
      WidgetTester tester,
    ) async {
      // Launch app
      app.main();
      await _performLogin(tester);

      // Switch to All Photos tab
      await tester.tap(find.text('All Photos'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Expect All Photos screen content
      expect(find.text('All Photos'), findsWidgets);
      expect(find.text('No photos yet'), findsOneWidget);
    });

    testWidgets('should navigate back using breadcrumb', (
      WidgetTester tester,
    ) async {
      // Launch app
      app.main();
      await _performLogin(tester);

      // Navigate deep into hierarchy
      await tester.tap(find.text('ACME Industrial').first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Factory North'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Assembly Line'));
      await tester.pumpAndSettle();

      // Now at deepest level: Client > Main Site > SubSite
      // Tap on "Factory North" in breadcrumb to go back
      final breadcrumbMainSite = find.text('Factory North').first;
      await tester.tap(breadcrumbMainSite);
      await tester.pumpAndSettle();

      // Should be back at main site screen
      expect(find.text('Assembly Line'), findsOneWidget);
      expect(find.text('Generator A'), findsOneWidget);
    });

    testWidgets(
      'should handle horizontal scrolling breadcrumb for long paths',
      (WidgetTester tester) async {
        // Launch app
        app.main();
        await _performLogin(tester);

        // Create a very long navigation path
        await tester.tap(find.text('Client With Very Long Name').first);
        await tester.pumpAndSettle();

        await tester.tap(
          find.text('Site With Extremely Long Name That Exceeds Width'),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('SubSite With Another Very Long Name'));
        await tester.pumpAndSettle();

        // Verify breadcrumb is horizontally scrollable
        expect(find.byKey(const Key('breadcrumb-scroll')), findsWidgets);

        // Verify all breadcrumb items exist
        expect(find.text('Client With Very Long Name'), findsOneWidget);
        expect(
          find.text('Site With Extremely Long Name That Exceeds Width'),
          findsOneWidget,
        );
      },
    );

    testWidgets('should update breadcrumb dynamically as navigation occurs', (
      WidgetTester tester,
    ) async {
      // Launch app
      app.main();
      await _performLogin(tester);

      // Initial state - no breadcrumb or home breadcrumb
      final initialBreadcrumb = find.byKey(Key('breadcrumb'));
      // May or may not exist on home screen

      // Navigate to client
      await tester.tap(find.text('ACME Industrial').first);
      await tester.pumpAndSettle();

      // Breadcrumb should show client
      expect(find.text('ACME Industrial'), findsOneWidget);

      // Navigate to site
      await tester.tap(find.text('Factory North'));
      await tester.pumpAndSettle();

      // Breadcrumb should now show client > site
      expect(find.text('ACME Industrial'), findsOneWidget);
      expect(find.text('Factory North'), findsOneWidget);

      // Navigate to equipment
      await tester.tap(find.text('Generator A'));
      await tester.pumpAndSettle();

      // Breadcrumb should now show full path
      expect(find.text('ACME Industrial'), findsOneWidget);
      expect(find.text('Factory North'), findsOneWidget);
      expect(find.text('Generator A'), findsOneWidget);
    });

    testWidgets('should show subsites and equipment at main site level', (
      WidgetTester tester,
    ) async {
      // Launch app
      app.main();
      await _performLogin(tester);

      // Navigate to main site
      await tester.tap(find.text('ACME Industrial').first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Factory North'));
      await tester.pumpAndSettle();

      // Should see both subsites and direct equipment
      expect(find.text('Assembly Line'), findsOneWidget); // SubSite
      expect(find.text('Generator A'), findsOneWidget); // Direct equipment

      // Different icons for subsites vs equipment
      expect(find.byIcon(Icons.folder), findsWidgets); // Subsite icon
      expect(
        find.byIcon(Icons.precision_manufacturing),
        findsWidgets,
      ); // Equipment icon
    });

    testWidgets(
      'should only show equipment at subsite level (no further nesting)',
      (WidgetTester tester) async {
        // Launch app
        app.main();
        await _performLogin(tester);

        // Navigate to subsite
        await tester.tap(find.text('ACME Industrial').first);
        await tester.pumpAndSettle();

        await tester.tap(find.text('Factory North'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Assembly Line'));
        await tester.pumpAndSettle();

        // Should only see equipment, no subsites
        expect(find.byIcon(Icons.folder), findsNothing); // No subsite icons
        expect(
          find.byIcon(Icons.precision_manufacturing),
          findsWidgets,
        ); // Only equipment

        // Verify no "Add SubSite" button
        expect(find.text('Add SubSite'), findsNothing);
      },
    );

    testWidgets('should navigate using bottom navigation bar', (
      WidgetTester tester,
    ) async {
      // Launch app
      app.main();
      await _performLogin(tester);

      // Should start on Home tab
      expect(find.text('Ziatech'), findsOneWidget);

      // Tap All Photos tab
      await tester.tap(find.text('All Photos'));
      await tester.pumpAndSettle();

      // Should be on All Photos screen
      expect(find.text('All Photos'), findsWidgets);

      // Tap Settings tab
      final settingsTab = find.byIcon(Icons.settings);
      await tester.tap(settingsTab);
      await tester.pumpAndSettle();

      // Should be on settings screen
      expect(find.text('Settings'), findsWidgets);

      // Tap back to Home
      final homeTab = find.byIcon(Icons.home);
      await tester.tap(homeTab);
      await tester.pumpAndSettle();

      // Should be back on home screen
      expect(find.text('Ziatech'), findsOneWidget);
    });
  });
}
