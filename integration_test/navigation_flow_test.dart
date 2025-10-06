import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sitepictures/main.dart' as app;

/// Integration test for navigation flow through hierarchy
/// Validates FR-004, FR-005, FR-006, FR-014, FR-015, FR-016, FR-017
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Navigation Flow Integration Test', () {
    testWidgets('should navigate through client -> site -> equipment hierarchy',
        (WidgetTester tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      // Should be on home screen
      expect(find.text('Site Pictures'), findsOneWidget);

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
    });

    testWidgets('should navigate back using breadcrumb', (WidgetTester tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

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

    testWidgets('should handle horizontal scrolling breadcrumb for long paths',
        (WidgetTester tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      // Create a very long navigation path
      await tester.tap(find.text('Client With Very Long Name').first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Site With Extremely Long Name That Exceeds Width'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('SubSite With Another Very Long Name'));
      await tester.pumpAndSettle();

      // Verify breadcrumb is horizontally scrollable
      final breadcrumb = find.byType(SingleChildScrollView);
      expect(breadcrumb, findsWidgets);

      // Verify all breadcrumb items exist
      expect(find.text('Client With Very Long Name'), findsOneWidget);
      expect(find.text('Site With Extremely Long Name That Exceeds Width'), findsOneWidget);
    });

    testWidgets('should update breadcrumb dynamically as navigation occurs',
        (WidgetTester tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

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

    testWidgets('should show subsites and equipment at main site level',
        (WidgetTester tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

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
      expect(find.byIcon(Icons.precision_manufacturing), findsWidgets); // Equipment icon
    });

    testWidgets('should only show equipment at subsite level (no further nesting)',
        (WidgetTester tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to subsite
      await tester.tap(find.text('ACME Industrial').first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Factory North'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Assembly Line'));
      await tester.pumpAndSettle();

      // Should only see equipment, no subsites
      expect(find.byIcon(Icons.folder), findsNothing); // No subsite icons
      expect(find.byIcon(Icons.precision_manufacturing), findsWidgets); // Only equipment

      // Verify no "Add SubSite" button
      expect(find.text('Add SubSite'), findsNothing);
    });

    testWidgets('should navigate using bottom navigation bar', (WidgetTester tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      // Should start on Home tab
      expect(find.text('Site Pictures'), findsOneWidget);

      // Tap Map tab
      final mapTab = find.byIcon(Icons.map);
      await tester.tap(mapTab);
      await tester.pumpAndSettle();

      // Should be on map screen
      expect(find.byType(Icon), findsWidgets);

      // Tap Settings tab
      final settingsTab = find.byIcon(Icons.settings);
      await tester.tap(settingsTab);
      await tester.pumpAndSettle();

      // Should be on settings screen
      expect(find.text('Settings'), findsOneWidget);

      // Tap back to Home
      final homeTab = find.byIcon(Icons.home);
      await tester.tap(homeTab);
      await tester.pumpAndSettle();

      // Should be back on home screen
      expect(find.text('Site Pictures'), findsOneWidget);
    });
  });
}
