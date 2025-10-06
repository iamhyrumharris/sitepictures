import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sitepictures/main.dart' as app;

/// Integration test for search functionality
/// Validates FR-012: Search functionality with app name and search icon
/// Tests quickstart.md Scenario 8
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Search Functionality Integration Test', () {
    testWidgets('Should be able to access search from header',
        (WidgetTester tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      // Verify search icon is visible in header (FR-012)
      expect(find.byIcon(Icons.search), findsOneWidget);

      // Tap search icon
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      // Should navigate to search screen
      expect(find.text('Search'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('Should search for equipment by name',
        (WidgetTester tester) async {
      // Launch app and navigate to search
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      // Enter equipment search query
      await tester.enterText(find.byType(TextField), 'Generator');
      await tester.pumpAndSettle();

      // Should display results
      expect(find.text('Generator A'), findsAtLeastNWidgets(1));

      // Results should be clickable
      final resultTile = find.text('Generator A').first;
      await tester.tap(resultTile);
      await tester.pumpAndSettle();

      // Should navigate to equipment detail screen
      expect(find.text('Equipment Details'), findsOneWidget);
    });

    testWidgets('Should search for clients by name',
        (WidgetTester tester) async {
      // Launch app and navigate to search
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      // Search for client
      await tester.enterText(find.byType(TextField), 'ACME');
      await tester.pumpAndSettle();

      // Should display client results
      expect(find.text('ACME Industrial'), findsAtLeastNWidgets(1));

      // Tap on client result
      await tester.tap(find.text('ACME Industrial').first);
      await tester.pumpAndSettle();

      // Should navigate to client detail
      expect(find.text('Main Sites'), findsOneWidget);
    });

    testWidgets('Should show hierarchical context in search results',
        (WidgetTester tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      // Search for equipment
      await tester.enterText(find.byType(TextField), 'Pump');
      await tester.pumpAndSettle();

      // Results should show hierarchical context
      // e.g., "Pump #1 - Assembly Line - Factory North - ACME Industrial"
      expect(find.byType(ListTile), findsWidgets);

      // Each result should have subtitle showing path
      final listTiles = find.byType(ListTile);
      expect(listTiles, findsAtLeastNWidgets(1));
    });

    testWidgets('Should handle empty search results gracefully',
        (WidgetTester tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      // Search for non-existent item
      await tester.enterText(find.byType(TextField), 'NonExistentEquipment12345');
      await tester.pumpAndSettle();

      // Should show empty state message
      expect(find.text('No results found'), findsOneWidget);
      expect(find.byType(ListTile), findsNothing);
    });

    testWidgets('Should clear search results when query is cleared',
        (WidgetTester tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      // Enter search query
      await tester.enterText(find.byType(TextField), 'Generator');
      await tester.pumpAndSettle();

      // Verify results appear
      expect(find.byType(ListTile), findsWidgets);

      // Clear search query
      await tester.enterText(find.byType(TextField), '');
      await tester.pumpAndSettle();

      // Results should be cleared or show empty state
      expect(find.text('Enter search term'), findsOneWidget);
    });

    testWidgets('Should support incremental search',
        (WidgetTester tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      // Type incrementally
      await tester.enterText(find.byType(TextField), 'G');
      await tester.pumpAndSettle();

      // Should show results starting with G
      expect(find.byType(ListTile), findsWidgets);

      // Type more characters
      await tester.enterText(find.byType(TextField), 'Ge');
      await tester.pumpAndSettle();

      // Results should update
      expect(find.byType(ListTile), findsWidgets);

      // Complete the search
      await tester.enterText(find.byType(TextField), 'Generator');
      await tester.pumpAndSettle();

      // Should show refined results
      expect(find.text('Generator A'), findsAtLeastNWidgets(1));
    });

    testWidgets('Should search across multiple entity types',
        (WidgetTester tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      // Search for term that appears in multiple types
      await tester.enterText(find.byType(TextField), 'Factory');
      await tester.pumpAndSettle();

      // Should display results from different entity types
      // Could be clients, sites, or equipment with "Factory" in name
      expect(find.byType(ListTile), findsWidgets);

      // Results should be grouped or labeled by type
      expect(find.text('Clients'), findsOneWidget);
      expect(find.text('Sites'), findsOneWidget);
      expect(find.text('Equipment'), findsOneWidget);
    });

    testWidgets('Should maintain search state when navigating back',
        (WidgetTester tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      // Enter search query
      await tester.enterText(find.byType(TextField), 'Generator');
      await tester.pumpAndSettle();

      // Tap on a result
      final resultTile = find.text('Generator A').first;
      await tester.tap(resultTile);
      await tester.pumpAndSettle();

      // Navigate back
      await tester.pageBack();
      await tester.pumpAndSettle();

      // Search term should still be present
      expect(find.text('Generator'), findsOneWidget);

      // Results should still be displayed
      expect(find.text('Generator A'), findsAtLeastNWidgets(1));
    });

    testWidgets('Should support case-insensitive search',
        (WidgetTester tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      // Search with lowercase
      await tester.enterText(find.byType(TextField), 'generator');
      await tester.pumpAndSettle();

      // Should match "Generator A" (uppercase G)
      expect(find.text('Generator A'), findsAtLeastNWidgets(1));

      // Clear and try uppercase
      await tester.enterText(find.byType(TextField), 'GENERATOR');
      await tester.pumpAndSettle();

      // Should still match
      expect(find.text('Generator A'), findsAtLeastNWidgets(1));
    });

    testWidgets('Should return results in < 1 second for typical searches',
        (WidgetTester tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      // Measure search performance
      final stopwatch = Stopwatch()..start();

      await tester.enterText(find.byType(TextField), 'Equipment');
      await tester.pumpAndSettle();

      stopwatch.stop();
      final searchTime = stopwatch.elapsedMilliseconds;

      // Should complete in < 1 second (FR-012 implicit requirement)
      expect(
        searchTime,
        lessThan(1000),
        reason: 'Search took ${searchTime}ms, should be < 1000ms',
      );

      print('✓ Search completed in ${searchTime}ms');
    });

    testWidgets('Should display result count',
        (WidgetTester tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      // Perform search
      await tester.enterText(find.byType(TextField), 'Generator');
      await tester.pumpAndSettle();

      // Should show result count
      expect(find.textContaining('results'), findsOneWidget);
      // e.g., "3 results found" or "Found 3 items"
    });

    testWidgets('Search icon should be visible in app header (FR-012)',
        (WidgetTester tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      // Verify "Ziatech" app name is visible (FR-012)
      expect(find.text('Ziatech'), findsOneWidget);

      // Verify search icon in header
      expect(find.byIcon(Icons.search), findsOneWidget);

      // Navigate to different screens and verify search is still accessible
      await tester.tap(find.text('ACME Industrial').first);
      await tester.pumpAndSettle();

      // Search should still be accessible (in app bar or via navigation)
      expect(find.byIcon(Icons.search), findsWidgets);
    });
  });
}
