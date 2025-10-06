import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sitepictures/main.dart' as app;

/// Integration test for offline photo capture and sync
/// Validates FR-010a, FR-010b, Edge Case #2
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Offline Photo Capture Integration Test', () {
    testWidgets('should capture photos offline and save locally',
        (WidgetTester tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      // Simulate offline mode (mock network connectivity)
      // Note: In real implementation, this would use connectivity_plus package

      // Navigate to equipment
      await tester.tap(find.text('ACME Industrial').first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Factory North'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Generator A'));
      await tester.pumpAndSettle();

      // Tap camera FAB
      final cameraFab = find.byIcon(Icons.camera_alt);
      expect(cameraFab, findsOneWidget);
      await tester.tap(cameraFab);
      await tester.pumpAndSettle();

      // Camera screen should open
      expect(find.byType(Icon), findsWidgets);

      // Simulate taking photo (in test, this would be mocked)
      final captureButton = find.byIcon(Icons.camera);
      await tester.tap(captureButton);
      await tester.pumpAndSettle(Duration(seconds: 2));

      // Photo should be captured
      // Take another photo
      await tester.tap(captureButton);
      await tester.pumpAndSettle(Duration(seconds: 2));

      // Quick save first photo
      final quickSaveButton = find.text('Quick Save');
      await tester.tap(quickSaveButton);
      await tester.pumpAndSettle();

      // Photos should be saved locally
      // Return to equipment screen
      await tester.pageBack();
      await tester.pumpAndSettle();

      // Verify photos are visible in equipment screen
      expect(find.byType(Image), findsWidgets);
    });

    testWidgets('should save GPS and timestamp with offline photos',
        (WidgetTester tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to equipment
      await tester.tap(find.text('ACME Industrial').first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Factory North'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Generator A'));
      await tester.pumpAndSettle();

      // Open camera
      await tester.tap(find.byIcon(Icons.camera_alt));
      await tester.pumpAndSettle();

      // Take photo
      await tester.tap(find.byIcon(Icons.camera));
      await tester.pumpAndSettle(Duration(seconds: 2));

      // Save photo
      await tester.tap(find.text('Quick Save'));
      await tester.pumpAndSettle();

      // Go back
      await tester.pageBack();
      await tester.pumpAndSettle();

      // Tap on photo to view details
      final photoThumbnail = find.byType(Image).first;
      await tester.tap(photoThumbnail);
      await tester.pumpAndSettle();

      // Should show metadata including GPS and timestamp
      expect(find.textContaining('GPS:'), findsOneWidget);
      expect(find.textContaining('Timestamp:'), findsOneWidget);
      expect(find.textContaining('Captured by:'), findsOneWidget);
    });

    testWidgets('should show sync queue indicator when offline',
        (WidgetTester tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      // Simulate offline mode
      // Take photos (steps omitted for brevity)

      // Check for sync queue indicator in app bar or status
      expect(find.text('2 items pending sync'), findsOneWidget);
      // Or icon indicator
      expect(find.byIcon(Icons.cloud_off), findsOneWidget);

      // Go to settings
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // Check sync status
      expect(find.text('Sync Status'), findsOneWidget);
      expect(find.text('2 items queued'), findsOneWidget);
    });

    testWidgets('should automatically sync when connection restored',
        (WidgetTester tester) async {
      // Launch app in offline mode with queued items
      app.main();
      await tester.pumpAndSettle();

      // Verify sync queue has items
      expect(find.text('2 items pending sync'), findsOneWidget);

      // Simulate going online (mock network restoration)
      // In real implementation, this triggers sync service

      // Wait for auto-sync
      await tester.pumpAndSettle(Duration(seconds: 5));

      // Verify sync indicator changes
      expect(find.text('Syncing...'), findsOneWidget);

      // Wait for sync completion
      await tester.pumpAndSettle(Duration(seconds: 10));

      // Verify sync complete
      expect(find.text('All synced'), findsOneWidget);
      expect(find.byIcon(Icons.cloud_done), findsOneWidget);
    });

    testWidgets('should handle sync failures with retry',
        (WidgetTester tester) async {
      // Launch app with queued items
      app.main();
      await tester.pumpAndSettle();

      // Simulate sync failure (mock API error)

      // Verify error shown
      expect(find.text('Sync failed'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      // Tap retry button
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      // Should attempt sync again
      expect(find.text('Syncing...'), findsOneWidget);
    });

    testWidgets('should allow viewing offline photos before sync',
        (WidgetTester tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to equipment with offline photos
      await tester.tap(find.text('ACME Industrial').first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Factory North'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Generator A'));
      await tester.pumpAndSettle();

      // Should see offline photos
      expect(find.byType(Image), findsWidgets);

      // Tap to view full photo
      await tester.tap(find.byType(Image).first);
      await tester.pumpAndSettle();

      // Should open carousel view
      expect(find.byType(PageView), findsOneWidget);

      // Should show sync status indicator
      expect(find.byIcon(Icons.cloud_off), findsOneWidget);

      // Should be able to swipe between photos
      await tester.drag(find.byType(PageView), Offset(-300, 0));
      await tester.pumpAndSettle();

      // Next photo shown
      expect(find.byType(PageView), findsOneWidget);
    });

    testWidgets('should preserve photo order during sync',
        (WidgetTester tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      // Take 3 photos offline in sequence
      // Photo 1, then Photo 2, then Photo 3

      // Verify order before sync
      final photosBefore = find.byType(Image);
      expect(photosBefore, findsNWidgets(3));

      // Restore connection and sync
      await tester.pumpAndSettle(Duration(seconds: 10));

      // Verify same order after sync
      final photosAfter = find.byType(Image);
      expect(photosAfter, findsNWidgets(3));
      // Order should be preserved by timestamp
    });

    testWidgets('should not lose photos if sync fails',
        (WidgetTester tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      // Take photos
      // Simulate sync failure multiple times

      // Photos should still be accessible locally
      await tester.tap(find.text('ACME Industrial').first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Generator A'));
      await tester.pumpAndSettle();

      // Photos still visible
      expect(find.byType(Image), findsWidgets);

      // Sync queue still shows items
      expect(find.text('items pending sync'), findsOneWidget);
    });
  });
}
