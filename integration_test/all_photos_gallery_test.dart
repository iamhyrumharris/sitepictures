import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';

import 'package:sitepictures/models/photo.dart';
import 'package:sitepictures/providers/all_photos_provider.dart';
import 'package:sitepictures/providers/app_state.dart';
import 'package:sitepictures/screens/all_photos/all_photos_screen.dart';
import 'package:sitepictures/screens/photo_viewer_screen.dart';
import 'package:sitepictures/widgets/photo_grid_tile.dart';

class _IntegrationStubAppState extends AppState {
  _IntegrationStubAppState(List<Future<List<Photo>>> responses)
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

Photo _buildPhoto(String id, DateTime timestamp) {
  return Photo(
    id: id,
    equipmentId: 'equip-1',
    filePath: '/tmp/$id.jpg',
    latitude: 0,
    longitude: 0,
    timestamp: timestamp,
    capturedBy: 'tester',
    fileSize: 1024,
    equipmentName: 'Equipment $id',
    locationSummary: 'Location $id',
    createdAt: timestamp,
  );
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('All Photos orders newest first and opens viewer', (
    tester,
  ) async {
    final now = DateTime.now();
    final photos = <Photo>[
      _buildPhoto('photo-newest', now),
      _buildPhoto('photo-older', now.subtract(const Duration(minutes: 10))),
    ];

    final provider = AllPhotosProvider(pageSize: 50);
    provider.updateAppState(_IntegrationStubAppState([Future.value(photos)]));

    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const AllPhotosScreen(),
        ),
        GoRoute(
          path: '/photo-viewer',
          builder: (context, state) {
            final extras = state.extra as Map<String, dynamic>?;
            final list = extras?['photos'] as List<Photo>? ?? <Photo>[];
            final index = extras?['initialIndex'] as int? ?? 0;
            return PhotoViewerScreen(photos: list, initialIndex: index);
          },
        ),
      ],
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [ChangeNotifierProvider.value(value: provider)],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    await tester.pumpAndSettle();

    final tiles = tester.widgetList(find.byType(PhotoGridTile)).toList();
    expect(tiles, isNotEmpty);
    final firstTile = tiles.first as PhotoGridTile;
    expect(firstTile.photo.id, 'photo-newest');

    await tester.tap(find.byType(PhotoGridTile).first);
    await tester.pumpAndSettle();

    expect(find.byType(PhotoViewerScreen), findsOneWidget);
  });
}
