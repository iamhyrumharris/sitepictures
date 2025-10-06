import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sitepictures/main.dart' as app;

/// Integration test for breadcrumb navigation displaying actual page titles
/// Validates FR-014, FR-017 and Scenario 7 from spec.md
///
/// This test verifies that the breadcrumb trail displays actual entity names
/// (e.g., "ABC Corp > Warehouse A > Pump Room") instead of generic labels
/// (e.g., "Client > Site > Equipment")
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Breadcrumb Navigation with Actual Titles', () {
    testWidgets('Breadcrumb displays actual client name on main site screen',
        (WidgetTester tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      // Login if needed
      final loginButton = find.text('Login');
      if (loginButton.evaluate().isNotEmpty) {
        await tester.enterText(
            find.byType(TextField).first, 'tech@test.com');
        await tester.enterText(
            find.byType(TextField).last, 'password123');
        await tester.tap(loginButton);
        await tester.pumpAndSettle();
      }

      // Navigate to first client
      final clientTile = find.byType(ListTile).first;
      expect(clientTile, findsOneWidget);

      // Get the client name from the tile
      final ListTile tile = tester.widget(clientTile);
      final Text titleWidget = tile.title as Text;
      final String clientName = titleWidget.data!;

      // Tap to navigate to client detail
      await tester.tap(clientTile);
      await tester.pumpAndSettle();

      // Navigate to first main site
      final siteTile = find.byType(ListTile).first;
      if (siteTile.evaluate().isNotEmpty) {
        final ListTile siteListTile = tester.widget(siteTile);
        final Text siteTitleWidget = siteListTile.title as Text;
        final String siteName = siteTitleWidget.data!;

        await tester.tap(siteTile);
        await tester.pumpAndSettle();

        // Verify breadcrumb shows actual client name (not "Client")
        expect(find.text(clientName), findsAtLeastNWidgets(1));
        expect(find.text(siteName), findsOneWidget);

        // Verify generic labels are NOT present in breadcrumb
        final breadcrumbArea = find.byWidgetPredicate(
          (widget) => widget.runtimeType.toString() == 'BreadcrumbNavigation',
        );
        if (breadcrumbArea.evaluate().isNotEmpty) {
          // Make sure "Client" and "Site" are not used as labels
          final breadcrumbText = find.descendant(
            of: breadcrumbArea,
            matching: find.text('Client'),
          );
          expect(breadcrumbText, findsNothing,
              reason: 'Breadcrumb should not use generic "Client" label');
        }
      }
    });

    testWidgets(
        'Breadcrumb displays full hierarchy with actual names on subsite screen',
        (WidgetTester tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      // Login if needed
      final loginButton = find.text('Login');
      if (loginButton.evaluate().isNotEmpty) {
        await tester.enterText(
            find.byType(TextField).first, 'tech@test.com');
        await tester.enterText(
            find.byType(TextField).last, 'password123');
        await tester.tap(loginButton);
        await tester.pumpAndSettle();
      }

      // Navigate through hierarchy
      final clientTile = find.byType(ListTile).first;
      final ListTile clientListTile = tester.widget(clientTile);
      final String clientName = (clientListTile.title as Text).data!;

      await tester.tap(clientTile);
      await tester.pumpAndSettle();

      // Find main site
      final siteTile = find.byType(ListTile).first;
      if (siteTile.evaluate().isNotEmpty) {
        final ListTile siteListTile = tester.widget(siteTile);
        final String siteName = (siteListTile.title as Text).data!;

        await tester.tap(siteTile);
        await tester.pumpAndSettle();

        // Look for a subsite (folder icon)
        final subsiteTile = find.byWidgetPredicate(
          (widget) =>
              widget is ListTile &&
              widget.leading is Icon &&
              (widget.leading as Icon).icon == Icons.folder,
        );

        if (subsiteTile.evaluate().isNotEmpty) {
          final ListTile subsiteListTile = tester.widget(subsiteTile);
          final String subsiteName = (subsiteListTile.title as Text).data!;

          await tester.tap(subsiteTile);
          await tester.pumpAndSettle();

          // Verify breadcrumb shows: ClientName > SiteName > SubSiteName
          expect(find.text(clientName), findsAtLeastNWidgets(1));
          expect(find.text(siteName), findsAtLeastNWidgets(1));
          expect(find.text(subsiteName), findsOneWidget);

          // Verify generic labels are NOT present
          expect(find.text('Client'), findsNothing,
              reason: 'Should display actual client name, not "Client"');
          expect(find.text('Main Site'), findsNothing,
              reason: 'Should display actual site name, not "Main Site"');
        }
      }
    });

    testWidgets(
        'Breadcrumb displays complete path with actual names on equipment screen',
        (WidgetTester tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      // Login if needed
      final loginButton = find.text('Login');
      if (loginButton.evaluate().isNotEmpty) {
        await tester.enterText(
            find.byType(TextField).first, 'tech@test.com');
        await tester.enterText(
            find.byType(TextField).last, 'password123');
        await tester.tap(loginButton);
        await tester.pumpAndSettle();
      }

      // Navigate through hierarchy to equipment
      final clientTile = find.byType(ListTile).first;
      final ListTile clientListTile = tester.widget(clientTile);
      final String clientName = (clientListTile.title as Text).data!;

      await tester.tap(clientTile);
      await tester.pumpAndSettle();

      final siteTile = find.byType(ListTile).first;
      if (siteTile.evaluate().isNotEmpty) {
        final ListTile siteListTile = tester.widget(siteTile);
        final String siteName = (siteListTile.title as Text).data!;

        await tester.tap(siteTile);
        await tester.pumpAndSettle();

        // Find equipment (gear icon)
        final equipmentTile = find.byWidgetPredicate(
          (widget) =>
              widget is ListTile &&
              widget.leading is Icon &&
              (widget.leading as Icon).icon == Icons.precision_manufacturing,
        );

        if (equipmentTile.evaluate().isNotEmpty) {
          final ListTile equipmentListTile = tester.widget(equipmentTile);
          final String equipmentName =
              (equipmentListTile.title as Text).data!;

          await tester.tap(equipmentTile);
          await tester.pumpAndSettle();

          // Verify breadcrumb shows full path with actual names
          expect(find.text(clientName), findsAtLeastNWidgets(1));
          expect(find.text(siteName), findsAtLeastNWidgets(1));
          expect(find.text(equipmentName), findsOneWidget);

          // Verify generic labels are NOT present
          expect(find.text('Client'), findsNothing);
          expect(find.text('Site'), findsNothing);
          expect(find.text('Equipment'), findsNothing,
              reason:
                  'Should display actual equipment name, not generic "Equipment"');
        }
      }
    });

    testWidgets('Breadcrumb is horizontally scrollable for long paths',
        (WidgetTester tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      // Login if needed
      final loginButton = find.text('Login');
      if (loginButton.evaluate().isNotEmpty) {
        await tester.enterText(
            find.byType(TextField).first, 'tech@test.com');
        await tester.enterText(
            find.byType(TextField).last, 'password123');
        await tester.tap(loginButton);
        await tester.pumpAndSettle();
      }

      // Navigate to deep hierarchy (client > site > subsite > equipment)
      await tester.tap(find.byType(ListTile).first);
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ListTile).first);
      await tester.pumpAndSettle();

      final subsiteTile = find.byWidgetPredicate(
        (widget) =>
            widget is ListTile &&
            widget.leading is Icon &&
            (widget.leading as Icon).icon == Icons.folder,
      );

      if (subsiteTile.evaluate().isNotEmpty) {
        await tester.tap(subsiteTile);
        await tester.pumpAndSettle();

        final equipmentTile = find.byWidgetPredicate(
          (widget) =>
              widget is ListTile &&
              widget.leading is Icon &&
              (widget.leading as Icon).icon == Icons.precision_manufacturing,
        );

        if (equipmentTile.evaluate().isNotEmpty) {
          await tester.tap(equipmentTile);
          await tester.pumpAndSettle();

          // Find the breadcrumb container (should have horizontal ListView)
          final breadcrumb = find.byWidgetPredicate(
            (widget) =>
                widget is Container &&
                widget.child is ListView &&
                (widget.child as ListView).scrollDirection == Axis.horizontal,
          );

          expect(breadcrumb, findsOneWidget,
              reason: 'Breadcrumb should be horizontally scrollable');
        }
      }
    });

    testWidgets('Tapping breadcrumb segments navigates to that level',
        (WidgetTester tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      // Login if needed
      final loginButton = find.text('Login');
      if (loginButton.evaluate().isNotEmpty) {
        await tester.enterText(
            find.byType(TextField).first, 'tech@test.com');
        await tester.enterText(
            find.byType(TextField).last, 'password123');
        await tester.tap(loginButton);
        await tester.pumpAndSettle();
      }

      // Navigate to client
      final clientTile = find.byType(ListTile).first;
      final ListTile clientListTile = tester.widget(clientTile);
      final String clientName = (clientListTile.title as Text).data!;

      await tester.tap(clientTile);
      await tester.pumpAndSettle();

      // Navigate to site
      await tester.tap(find.byType(ListTile).first);
      await tester.pumpAndSettle();

      // Find and tap the client name in breadcrumb to go back
      final clientInBreadcrumb = find.text(clientName);
      expect(clientInBreadcrumb, findsAtLeastNWidgets(1));

      // Tap the first occurrence (in breadcrumb)
      await tester.tap(clientInBreadcrumb.first);
      await tester.pumpAndSettle();

      // Should be back at client detail screen
      // Verify by checking we can see site list
      expect(find.byType(ListTile), findsWidgets);
    });
  });
}
