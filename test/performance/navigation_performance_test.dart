import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sitepictures/main.dart' as app;

/// Performance test for navigation transitions
/// Validates Constitution Article VI: Navigation < 500ms
/// Tests quickstart.md Scenario 10 - Performance Validation
void main() {
  group('Navigation Performance Test', skip: 'Database initialization needs sqflite_common_ffi setup', () {
    testWidgets('Screen transitions should complete in less than 500ms',
        (WidgetTester tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      // Measure home to client transition
      final stopwatch = Stopwatch()..start();

      // Tap on client
      final clientTile = find.text('ACME Industrial').first;
      await tester.tap(clientTile);
      await tester.pumpAndSettle();

      stopwatch.stop();
      final transitionTime = stopwatch.elapsedMilliseconds;

      // Constitutional requirement: < 500ms
      expect(
        transitionTime,
        lessThan(500),
        reason: 'Home → Client transition took ${transitionTime}ms, exceeds 500ms limit',
      );

      print('✓ Home → Client transition: ${transitionTime}ms (target: <500ms)');
    });

    testWidgets('Deep navigation path should maintain performance',
        (WidgetTester tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      final transitionTimes = <String, int>{};

      // Home → Client
      var stopwatch = Stopwatch()..start();
      await tester.tap(find.text('ACME Industrial').first);
      await tester.pumpAndSettle();
      stopwatch.stop();
      transitionTimes['Home → Client'] = stopwatch.elapsedMilliseconds;

      // Client → Main Site
      stopwatch = Stopwatch()..start();
      await tester.tap(find.text('Factory North'));
      await tester.pumpAndSettle();
      stopwatch.stop();
      transitionTimes['Client → Main Site'] = stopwatch.elapsedMilliseconds;

      // Main Site → SubSite
      stopwatch = Stopwatch()..start();
      await tester.tap(find.text('Assembly Line'));
      await tester.pumpAndSettle();
      stopwatch.stop();
      transitionTimes['Main Site → SubSite'] = stopwatch.elapsedMilliseconds;

      // SubSite → Equipment
      stopwatch = Stopwatch()..start();
      await tester.tap(find.text('Pump #1'));
      await tester.pumpAndSettle();
      stopwatch.stop();
      transitionTimes['SubSite → Equipment'] = stopwatch.elapsedMilliseconds;

      // Verify all transitions meet requirement
      transitionTimes.forEach((route, time) {
        expect(
          time,
          lessThan(500),
          reason: '$route transition took ${time}ms, exceeds 500ms limit',
        );
        print('✓ $route: ${time}ms');
      });

      final avgTime = transitionTimes.values.reduce((a, b) => a + b) / transitionTimes.length;
      print('✓ Average navigation time: ${avgTime.toStringAsFixed(0)}ms');
      expect(avgTime, lessThan(500));
    });

    testWidgets('Back navigation should be as fast as forward navigation',
        (WidgetTester tester) async {
      // Launch app and navigate deep
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('ACME Industrial').first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Factory North'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Assembly Line'));
      await tester.pumpAndSettle();

      // Measure back navigation
      final stopwatch = Stopwatch()..start();
      await tester.pageBack();
      await tester.pumpAndSettle();
      stopwatch.stop();

      final backTime = stopwatch.elapsedMilliseconds;

      expect(
        backTime,
        lessThan(500),
        reason: 'Back navigation took ${backTime}ms, exceeds 500ms limit',
      );

      print('✓ Back navigation: ${backTime}ms');
    });

    testWidgets('Breadcrumb navigation should be fast',
        (WidgetTester tester) async {
      // Launch app and navigate deep
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('ACME Industrial').first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Factory North'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Assembly Line'));
      await tester.pumpAndSettle();

      // Tap on breadcrumb to jump back
      final stopwatch = Stopwatch()..start();
      final breadcrumbClient = find.text('ACME Industrial').first;
      await tester.tap(breadcrumbClient);
      await tester.pumpAndSettle();
      stopwatch.stop();

      final jumpTime = stopwatch.elapsedMilliseconds;

      expect(
        jumpTime,
        lessThan(500),
        reason: 'Breadcrumb jump took ${jumpTime}ms, exceeds 500ms limit',
      );

      print('✓ Breadcrumb jump navigation: ${jumpTime}ms');
    });

    testWidgets('Bottom navigation tab switching should be instant',
        (WidgetTester tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      // Test tab switching
      final tabSwitchTimes = <String, int>{};

      // Home → Map
      var stopwatch = Stopwatch()..start();
      await tester.tap(find.text('Map'));
      await tester.pumpAndSettle();
      stopwatch.stop();
      tabSwitchTimes['Home → Map'] = stopwatch.elapsedMilliseconds;

      // Map → Settings
      stopwatch = Stopwatch()..start();
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      stopwatch.stop();
      tabSwitchTimes['Map → Settings'] = stopwatch.elapsedMilliseconds;

      // Settings → Home
      stopwatch = Stopwatch()..start();
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();
      stopwatch.stop();
      tabSwitchTimes['Settings → Home'] = stopwatch.elapsedMilliseconds;

      // All tab switches should be < 500ms (ideally much faster)
      tabSwitchTimes.forEach((route, time) {
        expect(
          time,
          lessThan(500),
          reason: '$route switch took ${time}ms, exceeds 500ms limit',
        );
        print('✓ $route: ${time}ms');
      });
    });

    testWidgets('Search screen navigation should be fast',
        (WidgetTester tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      // Tap search icon
      final stopwatch = Stopwatch()..start();
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();
      stopwatch.stop();

      final searchNavTime = stopwatch.elapsedMilliseconds;

      expect(
        searchNavTime,
        lessThan(500),
        reason: 'Search screen navigation took ${searchNavTime}ms',
      );

      print('✓ Search screen navigation: ${searchNavTime}ms');
    });

    testWidgets('Camera screen launch should be fast (from equipment)',
        (WidgetTester tester) async {
      // Launch app and navigate to equipment
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('ACME Industrial').first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Factory North'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Generator A'));
      await tester.pumpAndSettle();

      // Launch camera
      final stopwatch = Stopwatch()..start();
      await tester.tap(find.byIcon(Icons.camera_alt));
      await tester.pumpAndSettle();
      stopwatch.stop();

      final cameraLaunchTime = stopwatch.elapsedMilliseconds;

      expect(
        cameraLaunchTime,
        lessThan(500),
        reason: 'Camera launch took ${cameraLaunchTime}ms, exceeds 500ms limit',
      );

      print('✓ Camera screen launch: ${cameraLaunchTime}ms');
    });

    testWidgets('Navigation performance should not degrade with data volume',
        (WidgetTester tester) async {
      // This test would need to seed database with large amount of data
      // Then measure navigation performance

      // Launch app
      app.main();
      await tester.pumpAndSettle();

      // Navigate through hierarchy with loaded data
      final stopwatch = Stopwatch()..start();

      await tester.tap(find.text('ACME Industrial').first);
      await tester.pumpAndSettle();

      stopwatch.stop();
      final navTime = stopwatch.elapsedMilliseconds;

      expect(
        navTime,
        lessThan(500),
        reason: 'Navigation with data took ${navTime}ms',
      );

      print('✓ Navigation with data: ${navTime}ms');
    });

    testWidgets('60 FPS UI rendering during navigation',
        (WidgetTester tester) async {
      // Flutter test framework can measure frame rendering
      app.main();
      await tester.pumpAndSettle();

      // Track frame times during navigation
      final List<Duration> frameDurations = [];

      // Start recording
      tester.binding.addPersistentFrameCallback((duration) {
        frameDurations.add(duration);
      });

      // Navigate
      await tester.tap(find.text('ACME Industrial').first);
      await tester.pumpAndSettle();

      // 60 FPS = 16.67ms per frame
      // We should not exceed 16.67ms for smooth rendering
      final slowFrames = frameDurations.where((d) => d.inMilliseconds > 17);

      if (slowFrames.isNotEmpty) {
        print('⚠ Found ${slowFrames.length} slow frames during navigation');
        print('  Slow frames: ${slowFrames.map((d) => "${d.inMilliseconds}ms").join(", ")}');
      } else {
        print('✓ All frames rendered at 60 FPS (no frames > 16.67ms)');
      }

      // Allow some slow frames, but most should be < 17ms
      expect(
        slowFrames.length / frameDurations.length,
        lessThan(0.1),
        reason: 'Too many slow frames: ${slowFrames.length}/${frameDurations.length}',
      );
    });
  });
}
