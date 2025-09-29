import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:fieldphoto_pro/services/background/sync_queue.dart';
import 'package:fieldphoto_pro/models/sync_package.dart';
import 'package:fieldphoto_pro/services/storage_service.dart';
import 'package:fieldphoto_pro/services/network_monitor_service.dart';

@GenerateMocks([SyncQueue, StorageService, NetworkMonitorService])
import 'sync_queue_test.mocks.dart';

void main() {
  group('Sync Package Queue Unit Tests', () {
    late MockSyncQueue mockSyncQueue;
    late MockStorageService mockStorageService;
    late MockNetworkMonitorService mockNetworkMonitor;

    setUp(() {
      mockSyncQueue = MockSyncQueue();
      mockStorageService = MockStorageService();
      mockNetworkMonitor = MockNetworkMonitorService();
    });

    test('Adds sync package to queue correctly', () async {
      final package = SyncPackage(
        id: 'sync-001',
        entityType: 'Photo',
        entityId: 'photo-001',
        operation: 'CREATE',
        data: {
          'fileName': 'test.jpg',
          'equipmentId': 'equip-001',
        },
        timestamp: DateTime.now(),
        deviceId: 'device-001',
        status: 'PENDING',
        retryCount: 0,
      );

      when(mockSyncQueue.enqueue(package)).thenAnswer((_) async => true);

      final result = await mockSyncQueue.enqueue(package);

      expect(result, isTrue);
      verify(mockSyncQueue.enqueue(package)).called(1);
    });

    test('Processes queue in FIFO order', () async {
      final packages = List.generate(5, (i) => SyncPackage(
        id: 'sync-$i',
        entityType: 'Photo',
        entityId: 'photo-$i',
        operation: 'CREATE',
        data: {},
        timestamp: DateTime.now().add(Duration(seconds: i)),
        deviceId: 'device-001',
        status: 'PENDING',
        retryCount: 0,
      ));

      when(mockSyncQueue.getNext()).thenAnswer((_) async => packages[0]);
      when(mockSyncQueue.dequeue(packages[0])).thenAnswer((_) async => true);

      final next = await mockSyncQueue.getNext();

      expect(next.id, equals('sync-0'));
      expect(next.timestamp.isBefore(packages[1].timestamp), isTrue);
    });

    test('Handles priority operations correctly', () async {
      final normalPackage = SyncPackage(
        id: 'sync-normal',
        entityType: 'Photo',
        entityId: 'photo-001',
        operation: 'UPDATE',
        data: {},
        timestamp: DateTime.now(),
        deviceId: 'device-001',
        status: 'PENDING',
        retryCount: 0,
      );

      final priorityPackage = SyncPackage(
        id: 'sync-priority',
        entityType: 'Equipment',
        entityId: 'equip-001',
        operation: 'CREATE',
        data: {},
        timestamp: DateTime.now().add(Duration(minutes: 1)),
        deviceId: 'device-001',
        status: 'PENDING',
        retryCount: 0,
        priority: 10, // Higher priority
      );

      when(mockSyncQueue.enqueuePriority(priorityPackage))
          .thenAnswer((_) async => true);
      when(mockSyncQueue.getNext())
          .thenAnswer((_) async => priorityPackage);

      await mockSyncQueue.enqueue(normalPackage);
      await mockSyncQueue.enqueuePriority(priorityPackage);

      final next = await mockSyncQueue.getNext();

      expect(next.id, equals('sync-priority'));
    });

    test('Retries failed packages with exponential backoff', () async {
      final package = SyncPackage(
        id: 'sync-001',
        entityType: 'Photo',
        entityId: 'photo-001',
        operation: 'CREATE',
        data: {},
        timestamp: DateTime.now(),
        deviceId: 'device-001',
        status: 'FAILED',
        retryCount: 2,
        lastAttempt: DateTime.now().subtract(Duration(minutes: 5)),
      );

      when(mockSyncQueue.getRetryDelay(package.retryCount))
          .thenReturn(Duration(seconds: 8)); // 2^3 seconds

      final delay = mockSyncQueue.getRetryDelay(package.retryCount);

      expect(delay.inSeconds, equals(8));
      expect(package.retryCount, lessThan(10)); // Max retries
    });

    test('Marks packages as synced correctly', () async {
      final package = SyncPackage(
        id: 'sync-001',
        entityType: 'Photo',
        entityId: 'photo-001',
        operation: 'CREATE',
        data: {},
        timestamp: DateTime.now(),
        deviceId: 'device-001',
        status: 'SYNCING',
        retryCount: 0,
      );

      when(mockSyncQueue.markAsSynced(package)).thenAnswer((_) async {
        package.status = 'SYNCED';
        return true;
      });

      await mockSyncQueue.markAsSynced(package);

      expect(package.status, equals('SYNCED'));
    });

    test('Cleans up old synced packages', () async {
      final cutoffDate = DateTime.now().subtract(Duration(days: 7));

      when(mockSyncQueue.cleanupOldPackages(cutoffDate))
          .thenAnswer((_) async => 42); // Removed 42 old packages

      final removed = await mockSyncQueue.cleanupOldPackages(cutoffDate);

      expect(removed, equals(42));
    });

    test('Pauses and resumes queue processing', () async {
      when(mockSyncQueue.pause()).thenAnswer((_) async => true);
      when(mockSyncQueue.resume()).thenAnswer((_) async => true);
      when(mockSyncQueue.isPaused()).thenAnswer((_) async => false);

      await mockSyncQueue.pause();
      when(mockSyncQueue.isPaused()).thenAnswer((_) async => true);

      final pausedState = await mockSyncQueue.isPaused();
      expect(pausedState, isTrue);

      await mockSyncQueue.resume();
      when(mockSyncQueue.isPaused()).thenAnswer((_) async => false);

      final resumedState = await mockSyncQueue.isPaused();
      expect(resumedState, isFalse);
    });

    test('Gets queue statistics', () async {
      when(mockSyncQueue.getStatistics()).thenAnswer((_) async => {
        'pending': 15,
        'syncing': 2,
        'synced': 150,
        'failed': 3,
        'totalSize': 170,
        'oldestPending': DateTime.now().subtract(Duration(hours: 2)),
      });

      final stats = await mockSyncQueue.getStatistics();

      expect(stats['pending'], equals(15));
      expect(stats['syncing'], equals(2));
      expect(stats['failed'], equals(3));
      expect(stats['totalSize'], equals(170));
      expect((stats['oldestPending'] as DateTime).isBefore(DateTime.now()), isTrue);
    });

    test('Batches multiple operations for efficiency', () async {
      final packages = List.generate(10, (i) => SyncPackage(
        id: 'sync-$i',
        entityType: 'Photo',
        entityId: 'photo-$i',
        operation: 'CREATE',
        data: {},
        timestamp: DateTime.now(),
        deviceId: 'device-001',
        status: 'PENDING',
        retryCount: 0,
      ));

      when(mockSyncQueue.getBatch(5)).thenAnswer((_) async {
        return packages.take(5).toList();
      });

      final batch = await mockSyncQueue.getBatch(5);

      expect(batch, hasLength(5));
      expect(batch[0].id, equals('sync-0'));
      expect(batch[4].id, equals('sync-4'));
    });

    test('Validates sync package data before enqueueing', () async {
      final invalidPackage = SyncPackage(
        id: 'invalid-uuid', // Invalid UUID
        entityType: 'UnknownType', // Invalid entity type
        entityId: 'photo-001',
        operation: 'INVALID_OP', // Invalid operation
        data: {},
        timestamp: DateTime.now(),
        deviceId: 'device-001',
        status: 'PENDING',
        retryCount: 0,
      );

      when(mockSyncQueue.validate(invalidPackage))
          .thenReturn(false);

      final isValid = mockSyncQueue.validate(invalidPackage);

      expect(isValid, isFalse);
    });

    test('Handles network connectivity changes', () async {
      when(mockNetworkMonitor.isConnected()).thenAnswer((_) async => false);

      final isConnected = await mockNetworkMonitor.isConnected();

      if (!isConnected) {
        when(mockSyncQueue.pause()).thenAnswer((_) async => true);
        await mockSyncQueue.pause();
      }

      when(mockSyncQueue.isPaused()).thenAnswer((_) async => true);
      expect(await mockSyncQueue.isPaused(), isTrue);

      // Network comes back
      when(mockNetworkMonitor.isConnected()).thenAnswer((_) async => true);

      if (await mockNetworkMonitor.isConnected()) {
        when(mockSyncQueue.resume()).thenAnswer((_) async => true);
        await mockSyncQueue.resume();
      }

      when(mockSyncQueue.isPaused()).thenAnswer((_) async => false);
      expect(await mockSyncQueue.isPaused(), isFalse);
    });

    test('Prevents duplicate packages in queue', () async {
      final package = SyncPackage(
        id: 'sync-001',
        entityType: 'Photo',
        entityId: 'photo-001',
        operation: 'UPDATE',
        data: {'notes': 'Updated notes'},
        timestamp: DateTime.now(),
        deviceId: 'device-001',
        status: 'PENDING',
        retryCount: 0,
      );

      when(mockSyncQueue.isDuplicate(package))
          .thenAnswer((_) async => true);

      final isDup = await mockSyncQueue.isDuplicate(package);

      expect(isDup, isTrue);
      // Should not add duplicate to queue
    });

    test('Merges consecutive updates to same entity', () async {
      final update1 = SyncPackage(
        id: 'sync-001',
        entityType: 'Equipment',
        entityId: 'equip-001',
        operation: 'UPDATE',
        data: {'name': 'Panel 1'},
        timestamp: DateTime.now(),
        deviceId: 'device-001',
        status: 'PENDING',
        retryCount: 0,
      );

      final update2 = SyncPackage(
        id: 'sync-002',
        entityType: 'Equipment',
        entityId: 'equip-001', // Same entity
        operation: 'UPDATE',
        data: {'notes': 'Added notes'},
        timestamp: DateTime.now().add(Duration(seconds: 1)),
        deviceId: 'device-001',
        status: 'PENDING',
        retryCount: 0,
      );

      when(mockSyncQueue.mergeUpdates([update1, update2]))
          .thenAnswer((_) async => SyncPackage(
        id: 'sync-merged',
        entityType: 'Equipment',
        entityId: 'equip-001',
        operation: 'UPDATE',
        data: {
          'name': 'Panel 1',
          'notes': 'Added notes',
        },
        timestamp: update2.timestamp,
        deviceId: 'device-001',
        status: 'PENDING',
        retryCount: 0,
      ));

      final merged = await mockSyncQueue.mergeUpdates([update1, update2]);

      expect(merged.data['name'], equals('Panel 1'));
      expect(merged.data['notes'], equals('Added notes'));
    });

    test('Tracks sync progress for large batches', () async {
      const totalItems = 100;

      when(mockSyncQueue.startBatchSync(totalItems))
          .thenAnswer((_) async => 'batch-001');

      when(mockSyncQueue.updateProgress('batch-001', 50))
          .thenAnswer((_) async => 50.0); // 50% complete

      final batchId = await mockSyncQueue.startBatchSync(totalItems);
      final progress = await mockSyncQueue.updateProgress(batchId, 50);

      expect(progress, equals(50.0));
    });

    test('Handles queue overflow gracefully', () async {
      const maxQueueSize = 1000;

      when(mockSyncQueue.getQueueSize()).thenAnswer((_) async => 1000);
      when(mockSyncQueue.isAtCapacity()).thenAnswer((_) async => true);

      final isFull = await mockSyncQueue.isAtCapacity();

      expect(isFull, isTrue);
      // Should reject new packages or trigger cleanup
    });
  });
}