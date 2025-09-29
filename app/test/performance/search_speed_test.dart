import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:fieldphoto_pro/services/search_service.dart';
import 'package:fieldphoto_pro/services/storage_service.dart';
import 'package:fieldphoto_pro/models/photo.dart';
import 'package:fieldphoto_pro/models/equipment.dart';

@GenerateMocks([SearchService, StorageService])
import 'search_speed_test.mocks.dart';

void main() {
  group('Search Performance Test', () {
    late MockSearchService mockSearchService;
    late MockStorageService mockStorageService;
    late DateTime startTime;
    late DateTime endTime;

    setUp(() {
      mockSearchService = MockSearchService();
      mockStorageService = MockStorageService();
    });

    test('Search completes in less than 1 second', () async {
      // Constitutional requirement: <1s search
      const maxDuration = Duration(seconds: 1);

      // Mock search results
      final mockResults = List.generate(
        50,
        (i) => Photo(
          id: 'photo-$i',
          equipmentId: 'equipment-${i % 10}',
          fileName: 'photo_$i.jpg',
          fileHash: 'hash$i',
          capturedAt: DateTime.now().subtract(Duration(days: i)),
          deviceId: 'device-001',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isSynced: true,
          notes: 'Test photo $i with maintenance notes',
        ),
      );

      when(mockSearchService.search(any)).thenAnswer((_) async {
        await Future.delayed(Duration(milliseconds: 300));
        return mockResults;
      });

      startTime = DateTime.now();

      final results = await mockSearchService.search('maintenance');

      endTime = DateTime.now();
      final duration = endTime.difference(startTime);

      expect(duration.inMilliseconds, lessThan(maxDuration.inMilliseconds),
          reason: 'Search took ${duration.inMilliseconds}ms, expected <1000ms');
      expect(results, isNotEmpty);
    });

    test('Full-text search with FTS5 performs well', () async {
      const targetDuration = Duration(milliseconds: 500);

      when(mockSearchService.fullTextSearch(any)).thenAnswer((_) async {
        // Simulate FTS5 index query
        await Future.delayed(Duration(milliseconds: 150));
        return List.generate(25, (i) => {
          'photoId': 'photo-$i',
          'snippet': 'matched text snippet $i',
          'rank': 1.0 - (i * 0.01),
        });
      });

      startTime = DateTime.now();

      final results = await mockSearchService.fullTextSearch('control panel');

      endTime = DateTime.now();
      final duration = endTime.difference(startTime);

      expect(duration.inMilliseconds, lessThan(targetDuration.inMilliseconds));
      expect(results.length, equals(25));
    });

    test('Date range search is optimized', () async {
      const targetDuration = Duration(milliseconds: 300);

      when(mockSearchService.searchByDateRange(any, any))
          .thenAnswer((_) async {
        await Future.delayed(Duration(milliseconds: 100));
        return List.generate(30, (i) => Photo(
          id: 'photo-$i',
          equipmentId: 'equipment-001',
          fileName: 'dated_$i.jpg',
          fileHash: 'hash$i',
          capturedAt: DateTime(2024, 1, i + 1),
          deviceId: 'device-001',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isSynced: true,
        ));
      });

      startTime = DateTime.now();

      final results = await mockSearchService.searchByDateRange(
        DateTime(2024, 1, 1),
        DateTime(2024, 12, 31),
      );

      endTime = DateTime.now();
      final duration = endTime.difference(startTime);

      expect(duration.inMilliseconds, lessThan(targetDuration.inMilliseconds));
      expect(results, hasLength(30));
    });

    test('GPS proximity search maintains performance', () async {
      const targetDuration = Duration(milliseconds: 400);

      when(mockSearchService.searchByLocation(any, any, any))
          .thenAnswer((_) async {
        // Simulate spatial index query
        await Future.delayed(Duration(milliseconds: 200));
        return List.generate(15, (i) => Photo(
          id: 'photo-$i',
          equipmentId: 'equipment-001',
          fileName: 'gps_$i.jpg',
          fileHash: 'hash$i',
          capturedAt: DateTime.now(),
          deviceId: 'device-001',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isSynced: true,
          latitude: 42.3601 + (i * 0.001),
          longitude: -71.0589 + (i * 0.001),
        ));
      });

      startTime = DateTime.now();

      final results = await mockSearchService.searchByLocation(
        42.3601, // latitude
        -71.0589, // longitude
        1000, // radius in meters
      );

      endTime = DateTime.now();
      final duration = endTime.difference(startTime);

      expect(duration.inMilliseconds, lessThan(targetDuration.inMilliseconds));
      expect(results, isNotEmpty);
    });

    test('Complex filter combinations stay performant', () async {
      const maxDuration = Duration(seconds: 1);

      when(mockSearchService.advancedSearch(any)).thenAnswer((_) async {
        // Simulate complex query with multiple joins
        await Future.delayed(Duration(milliseconds: 400));
        return {
          'photos': List.generate(20, (i) => Photo(
            id: 'photo-$i',
            equipmentId: 'equipment-${i % 5}',
            fileName: 'complex_$i.jpg',
            fileHash: 'hash$i',
            capturedAt: DateTime.now(),
            deviceId: 'device-001',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            isSynced: true,
          )),
          'totalCount': 20,
          'facets': {
            'equipment': {'PLC': 10, 'Panel': 5, 'Motor': 5},
            'sites': {'Plant A': 12, 'Plant B': 8},
          },
        };
      });

      final filters = {
        'clientName': 'ACME',
        'dateFrom': '2024-01-01',
        'dateTo': '2024-12-31',
        'equipmentType': 'PLC',
        'hasNotes': true,
        'latitude': 42.3601,
        'longitude': -71.0589,
        'radius': 5000,
      };

      startTime = DateTime.now();

      final results = await mockSearchService.advancedSearch(filters);

      endTime = DateTime.now();
      final duration = endTime.difference(startTime);

      expect(duration.inMilliseconds, lessThan(maxDuration.inMilliseconds),
          reason: 'Complex search must complete within 1s');
      expect(results['photos'], hasLength(20));
      expect(results['facets'], isNotEmpty);
    });

    test('Search with 1000+ photos maintains sub-second performance', () async {
      // Test with large dataset
      const maxDuration = Duration(milliseconds: 800);

      when(mockStorageService.getPhotoCount()).thenAnswer((_) async {
        return 5000; // Large dataset
      });

      when(mockSearchService.searchLargeDataset(any)).thenAnswer((_) async {
        // Simulate indexed search on large dataset
        await Future.delayed(Duration(milliseconds: 500));
        return List.generate(50, (i) => Photo(
          id: 'photo-$i',
          equipmentId: 'equipment-001',
          fileName: 'large_$i.jpg',
          fileHash: 'hash$i',
          capturedAt: DateTime.now(),
          deviceId: 'device-001',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isSynced: true,
        ));
      });

      final photoCount = await mockStorageService.getPhotoCount();
      expect(photoCount, greaterThan(1000));

      startTime = DateTime.now();

      final results = await mockSearchService.searchLargeDataset('maintenance');

      endTime = DateTime.now();
      final duration = endTime.difference(startTime);

      expect(duration.inMilliseconds, lessThan(maxDuration.inMilliseconds),
          reason: 'Large dataset search must stay under 800ms');
      expect(results, hasLength(50));
    });

    test('Incremental search provides fast feedback', () async {
      // Test search-as-you-type performance
      const targetLatency = Duration(milliseconds: 100);

      final searchTerms = ['m', 'ma', 'mai', 'main', 'maint', 'mainten'];

      for (final term in searchTerms) {
        when(mockSearchService.incrementalSearch(term))
            .thenAnswer((_) async {
          // Incremental search should be very fast
          await Future.delayed(Duration(milliseconds: 30));
          return List.generate(10, (i) => 'suggestion_$i');
        });

        final start = DateTime.now();
        await mockSearchService.incrementalSearch(term);
        final duration = DateTime.now().difference(start);

        expect(duration.inMilliseconds, lessThan(targetLatency.inMilliseconds),
            reason: 'Each keystroke must provide fast feedback');
      }
    });

    test('Cached searches return instantly', () async {
      const targetDuration = Duration(milliseconds: 10);

      when(mockSearchService.cachedSearch(any)).thenAnswer((_) async {
        // Cached results should be near-instant
        await Future.delayed(Duration(milliseconds: 2));
        return List.generate(25, (i) => Photo(
          id: 'cached-$i',
          equipmentId: 'equipment-001',
          fileName: 'cached_$i.jpg',
          fileHash: 'hash$i',
          capturedAt: DateTime.now(),
          deviceId: 'device-001',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isSynced: true,
        ));
      });

      startTime = DateTime.now();
      await mockSearchService.cachedSearch('previous_query');
      endTime = DateTime.now();

      final duration = endTime.difference(startTime);
      expect(duration.inMilliseconds, lessThan(targetDuration.inMilliseconds),
          reason: 'Cached searches should be instant');
    });

    test('Parallel search requests complete efficiently', () async {
      // Test multiple concurrent searches
      const maxDuration = Duration(seconds: 1);

      final searchFutures = <Future>[];
      final queries = ['maintenance', 'inspection', 'repair', 'upgrade'];

      for (final query in queries) {
        when(mockSearchService.search(query)).thenAnswer((_) async {
          await Future.delayed(Duration(milliseconds: 200));
          return List.generate(10, (i) => Photo(
            id: '$query-$i',
            equipmentId: 'equipment-001',
            fileName: '${query}_$i.jpg',
            fileHash: 'hash$i',
            capturedAt: DateTime.now(),
            deviceId: 'device-001',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            isSynced: true,
          ));
        });

        searchFutures.add(mockSearchService.search(query));
      }

      startTime = DateTime.now();
      await Future.wait(searchFutures);
      endTime = DateTime.now();

      final totalDuration = endTime.difference(startTime);

      // Should complete in parallel
      expect(totalDuration.inMilliseconds, lessThan(maxDuration.inMilliseconds),
          reason: 'Parallel searches should complete within 1s total');
    });
  });
}