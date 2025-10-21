import 'dart:async';
import 'dart:collection';

import 'package:flutter_test/flutter_test.dart';

import 'package:sitepictures/models/photo.dart';
import 'package:sitepictures/providers/all_photos_provider.dart';
import 'package:sitepictures/providers/app_state.dart';

class _StubAppState extends AppState {
  _StubAppState(List<Future<List<Photo>>> responses)
    : _responses = Queue.of(responses);

  final Queue<Future<List<Photo>>> _responses;

  @override
  Future<List<Photo>> getAllPhotos({
    int limit = 50,
    int offset = 0,
    DateTime? before,
  }) {
    if (_responses.isEmpty) {
      return Future.value(<Photo>[]);
    }
    return _responses.removeFirst();
  }

  @override
  String? buildLocationSummary(Photo photo) => photo.locationSummary;
}

Photo _buildPhoto(int index, DateTime timestamp) {
  return Photo(
    id: 'photo-$index',
    equipmentId: 'equip-1',
    filePath: '/tmp/photo-$index.jpg',
    latitude: 0,
    longitude: 0,
    timestamp: timestamp,
    capturedBy: 'tester',
    fileSize: 1024,
    isSynced: false,
    createdAt: timestamp,
  );
}

void main() {
  group('AllPhotosProvider', () {
    test('loadInitial populates photos and sets hasMore', () async {
      final now = DateTime.now();
      final stub = _StubAppState([
        Future.value([
          _buildPhoto(1, now),
          _buildPhoto(2, now.subtract(const Duration(minutes: 5))),
        ]),
      ]);

      final provider = AllPhotosProvider(pageSize: 2);
      provider.updateAppState(stub);

      await provider.loadInitial();

      expect(provider.photos, hasLength(2));
      expect(provider.hasMore, isTrue);
      expect(provider.isLoading, isFalse);
      expect(provider.error, isNull);
    });

    test(
      'loadMore appends results and updates hasMore when exhausted',
      () async {
        final now = DateTime.now();
        final stub = _StubAppState([
          Future.value([
            _buildPhoto(1, now),
            _buildPhoto(2, now.subtract(const Duration(minutes: 1))),
          ]),
          Future.value([
            _buildPhoto(3, now.subtract(const Duration(minutes: 2))),
          ]),
        ]);

        final provider = AllPhotosProvider(pageSize: 2);
        provider.updateAppState(stub);

        await provider.loadInitial();
        await provider.loadMore();

        expect(provider.photos, hasLength(3));
        expect(provider.hasMore, isFalse);
        expect(provider.error, isNull);
      },
    );

    test('refresh replaces existing cache', () async {
      final now = DateTime.now();
      final stub = _StubAppState([
        Future.value([_buildPhoto(1, now)]),
        Future.value([
          _buildPhoto(2, now.subtract(const Duration(minutes: 1))),
        ]),
      ]);

      final provider = AllPhotosProvider(pageSize: 2);
      provider.updateAppState(stub);

      await provider.loadInitial();
      expect(provider.photos.first.id, 'photo-1');

      await provider.refresh();
      expect(provider.photos, hasLength(1));
      expect(provider.photos.first.id, 'photo-2');
      expect(provider.hasMore, isFalse);
    });

    test('removePhoto drops cached item and marks as incomplete', () async {
      final now = DateTime.now();
      final provider = AllPhotosProvider(pageSize: 2);
      final stub = _StubAppState([
        Future.value([_buildPhoto(1, now)]),
      ]);
      provider.updateAppState(stub);

      await provider.loadInitial();
      provider.removePhoto('photo-1');

      expect(provider.photos, isEmpty);
      expect(provider.hasMore, isTrue);
    });
  });
}
