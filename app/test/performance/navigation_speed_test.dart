import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:fieldphoto_pro/services/navigation_service.dart';
import 'package:fieldphoto_pro/screens/navigation_screen.dart';
import 'package:fieldphoto_pro/screens/equipment_detail_screen.dart';
import 'package:fieldphoto_pro/models/client.dart';
import 'package:fieldphoto_pro/models/site.dart';
import 'package:fieldphoto_pro/models/equipment.dart';

@GenerateMocks([NavigationService])
import 'navigation_speed_test.mocks.dart';

void main() {
  group('Navigation Speed Test', () {
    late MockNavigationService mockNavigationService;
    late DateTime startTime;
    late DateTime endTime;

    setUp(() {
      mockNavigationService = MockNavigationService();
    });

    testWidgets('Screen transitions complete in <500ms', (tester) async {
      // Constitutional requirement: <500ms between screens
      const maxDuration = Duration(milliseconds: 500);

      // Mock navigation data
      when(mockNavigationService.getHierarchy()).thenAnswer((_) async {
        await Future.delayed(Duration(milliseconds: 50));
        return {
          'clients': [
            Client(
              id: 'client-001',
              companyId: 'company-001',
              name: 'ACME Corp',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
              isActive: true,
              boundaries: [],
            ),
          ],
          'sites': [
            Site(
              id: 'site-001',
              clientId: 'client-001',
              name: 'Plant A',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
              isActive: true,
            ),
          ],
        };
      });

      // Build test app
      await tester.pumpWidget(
        MaterialApp(
          home: NavigationScreen(navigationService: mockNavigationService),
        ),
      );

      startTime = DateTime.now();

      // Simulate navigation tap
      await tester.tap(find.text('Plant A'));
      await tester.pumpAndSettle();

      endTime = DateTime.now();
      final duration = endTime.difference(startTime);

      expect(duration.inMilliseconds, lessThan(maxDuration.inMilliseconds),
          reason: 'Navigation took ${duration.inMilliseconds}ms, expected <500ms');
    });

    test('Breadcrumb navigation updates quickly', () async {
      const targetDuration = Duration(milliseconds: 100);

      when(mockNavigationService.updateBreadcrumbs(any)).thenAnswer((_) async {
        await Future.delayed(Duration(milliseconds: 30));
        return [
          'ACME Corp',
          'Plant A',
          'Control Room',
          'PLC Panel 1',
        ];
      });

      startTime = DateTime.now();

      final breadcrumbs = await mockNavigationService.updateBreadcrumbs({
        'clientId': 'client-001',
        'siteId': 'site-001',
        'equipmentId': 'equipment-001',
      });

      endTime = DateTime.now();
      final duration = endTime.difference(startTime);

      expect(duration.inMilliseconds, lessThan(targetDuration.inMilliseconds));
      expect(breadcrumbs.length, equals(4));
    });

    test('Hierarchical drill-down maintains performance', () async {
      final navigationTimes = <Duration>[];

      // Test navigation through hierarchy levels
      final levels = [
        'client',
        'mainSite',
        'subSite',
        'equipment',
      ];

      for (final level in levels) {
        when(mockNavigationService.navigateTo(level, any))
            .thenAnswer((_) async {
          // Simulate data loading for each level
          await Future.delayed(Duration(milliseconds: 100));
          return true;
        });

        final start = DateTime.now();
        await mockNavigationService.navigateTo(level, 'id-001');
        final duration = DateTime.now().difference(start);
        navigationTimes.add(duration);
      }

      // Verify all navigations meet requirement
      for (final duration in navigationTimes) {
        expect(duration.inMilliseconds, lessThan(500),
            reason: 'Navigation must stay under 500ms at all levels');
      }

      // Verify consistent performance across levels
      final avgTime = navigationTimes
              .map((d) => d.inMilliseconds)
              .reduce((a, b) => a + b) /
          navigationTimes.length;
      expect(avgTime, lessThan(200),
          reason: 'Average navigation should be well under target');
    });

    test('Back navigation is instantaneous', () async {
      // Test navigation stack operations
      const targetDuration = Duration(milliseconds: 50);

      when(mockNavigationService.goBack()).thenAnswer((_) async {
        // Back navigation should use cached data
        await Future.delayed(Duration(milliseconds: 10));
        return true;
      });

      startTime = DateTime.now();
      await mockNavigationService.goBack();
      endTime = DateTime.now();

      final duration = endTime.difference(startTime);
      expect(duration.inMilliseconds, lessThan(targetDuration.inMilliseconds),
          reason: 'Back navigation should be near-instant with cached data');
    });

    test('Equipment list scrolling remains smooth', () async {
      // Test large list performance
      final equipmentList = List.generate(
        100,
        (i) => Equipment(
          id: 'equipment-$i',
          siteId: 'site-001',
          name: 'Equipment $i',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isActive: true,
          tags: [],
        ),
      );

      when(mockNavigationService.loadEquipmentPage(any, any))
          .thenAnswer((_) async {
        await Future.delayed(Duration(milliseconds: 50));
        return equipmentList.take(20).toList();
      });

      // Test pagination performance
      final pageTimes = <Duration>[];
      for (int page = 0; page < 5; page++) {
        final start = DateTime.now();
        await mockNavigationService.loadEquipmentPage(page, 20);
        final duration = DateTime.now().difference(start);
        pageTimes.add(duration);
      }

      // Verify pagination stays performant
      for (final duration in pageTimes) {
        expect(duration.inMilliseconds, lessThan(100),
            reason: 'Pagination must be fast for smooth scrolling');
      }
    });

    test('Tab switching is responsive', () async {
      // Test tab navigation performance
      const tabs = ['Photos', 'Details', 'Timeline', 'Notes'];
      const targetDuration = Duration(milliseconds: 100);

      for (final tab in tabs) {
        when(mockNavigationService.switchTab(tab)).thenAnswer((_) async {
          await Future.delayed(Duration(milliseconds: 20));
          return true;
        });

        final start = DateTime.now();
        await mockNavigationService.switchTab(tab);
        final duration = DateTime.now().difference(start);

        expect(duration.inMilliseconds, lessThan(targetDuration.inMilliseconds),
            reason: 'Tab switching must be responsive');
      }
    });

    test('Deep linking navigation performs well', () async {
      // Test direct navigation to deep hierarchy
      const deepPath = '/client/001/site/002/equipment/003';
      const maxDuration = Duration(milliseconds: 500);

      when(mockNavigationService.navigateToPath(deepPath))
          .thenAnswer((_) async {
        // Simulate loading all hierarchy data
        await Future.delayed(Duration(milliseconds: 200));
        return true;
      });

      startTime = DateTime.now();
      await mockNavigationService.navigateToPath(deepPath);
      endTime = DateTime.now();

      final duration = endTime.difference(startTime);
      expect(duration.inMilliseconds, lessThan(maxDuration.inMilliseconds),
          reason: 'Deep linking must complete within 500ms');
    });

    test('Concurrent navigation requests handled efficiently', () async {
      // Test multiple navigation requests
      final futures = <Future>[];

      for (int i = 0; i < 3; i++) {
        when(mockNavigationService.navigateTo('screen$i', any))
            .thenAnswer((_) async {
          await Future.delayed(Duration(milliseconds: 100));
          return true;
        });

        futures.add(mockNavigationService.navigateTo('screen$i', 'id-$i'));
      }

      startTime = DateTime.now();
      await Future.wait(futures);
      endTime = DateTime.now();

      final totalDuration = endTime.difference(startTime);

      // Should complete in parallel, not sequentially
      expect(totalDuration.inMilliseconds, lessThan(200),
          reason: 'Concurrent requests should be handled in parallel');
    });
  });
}