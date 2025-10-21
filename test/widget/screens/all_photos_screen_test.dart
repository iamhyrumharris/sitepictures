import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:sitepictures/models/photo.dart';
import 'package:sitepictures/providers/all_photos_provider.dart';
import 'package:sitepictures/providers/app_state.dart';
import 'package:sitepictures/screens/all_photos/all_photos_screen.dart';
import 'package:sitepictures/widgets/photo_grid_tile.dart';

class _WidgetStubAppState extends AppState {
  _WidgetStubAppState(List<Future<List<Photo>>> responses)
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
  String? buildLocationSummary(Photo photo) =>
      photo.locationSummary ?? photo.equipmentName;
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
    fileSize: 512,
    equipmentName: 'Equipment $index',
    locationSummary: 'Location $index',
    createdAt: timestamp,
  );
}

void main() {
  testWidgets('shows loading indicator while fetching', (tester) async {
    final completer = Completer<List<Photo>>();
    final provider = AllPhotosProvider(pageSize: 2);
    provider.updateAppState(_WidgetStubAppState([completer.future]));

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const MaterialApp(home: AllPhotosScreen()),
      ),
    );

    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    completer.complete(<Photo>[]);
    await tester.pumpAndSettle();
  });

  testWidgets('renders empty state when no photos are returned', (
    tester,
  ) async {
    final provider = AllPhotosProvider(pageSize: 2);
    provider.updateAppState(_WidgetStubAppState([Future.value(<Photo>[])]));

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const MaterialApp(home: AllPhotosScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('No photos yet'), findsOneWidget);
  });

  testWidgets('shows newest photos and allows grid rendering', (tester) async {
    final now = DateTime.now();
    final photos = [
      _buildPhoto(1, now),
      _buildPhoto(2, now.subtract(const Duration(minutes: 1))),
    ];

    final provider = AllPhotosProvider(pageSize: 2);
    provider.updateAppState(_WidgetStubAppState([Future.value(photos)]));

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const MaterialApp(home: AllPhotosScreen()),
      ),
    );

    await tester.pumpAndSettle();

    final tiles = tester.widgetList(find.byType(PhotoGridTile)).toList();
    expect(tiles.length, 2);
    final firstTile = tiles.first as PhotoGridTile;
    expect(firstTile.photo.id, 'photo-1');
  });
}
