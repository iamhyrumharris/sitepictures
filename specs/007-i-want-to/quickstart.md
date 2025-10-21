# Quickstart Guide: All Photos Gallery

**Feature**: 007-i-want-to | **Date**: 2025-10-19  
**Audience**: Flutter + Node developers implementing the global All Photos experience

## Overview

This guide walks through wiring the newest-first All Photos gallery from the database layer to UI and optional backend parity. Follow steps sequentially; each builds on previous work and aligns with research decisions R0.1–R0.5.

## Prerequisites

- ✅ Flutter SDK 3.24+ with Dart 3.8.1
- ✅ sqflite, provider, go_router dependencies installed
- ✅ Existing photo capture and equipment hierarchy flows working (features 003/005/006)
- ✅ Optional: Node.js 18+ with PostgreSQL 15 for API parity work

## Step 1 – Database Migration

1. Add `_migration006` in `lib/services/database_service.dart`:
   ```dart
   Future<void> _migration006(Database db) async {
     await db.execute(
       'CREATE INDEX IF NOT EXISTS idx_photos_timestamp ON photos(timestamp DESC);',
     );
   }
   ```
2. Update `_onUpgrade` and `_onCreate` to call `_migration006`.
3. Bump database `version` from 5 to 6.
4. Run existing smoke tests or launch the app to trigger migration; verify via `PRAGMA index_list('photos');`.

## Step 2 – Service & AppState Exposure

1. Implement `DatabaseService.getAllPhotos({int limit = 50, int offset = 0})` returning maps with equipment/client/site metadata (see data-model contract).
2. In `AppState`, add:
   ```dart
   Future<List<Photo>> getAllPhotos({int limit = 50, int offset = 0}) async {
     final rows = await _databaseService.getAllPhotos(limit: limit, offset: offset);
     return rows.map(Photo.fromMap).toList(growable: false);
   }
   ```
3. Provide a helper `String buildLocationSummary(Photo photo)` that merges metadata for UI display.

## Step 3 – Provider Wiring

1. Create `lib/providers/all_photos_provider.dart` with state:
   - `List<Photo> _photos`
   - `bool _isLoading`, `bool _isRefreshing`, `bool _hasMore`, `String? _error`
2. Implement methods:
   - `Future<void> loadInitial()`
   - `Future<void> refresh()`
   - `Future<void> loadMore()`
   - `void invalidate()`
3. Register provider in `lib/main.dart` via `ChangeNotifierProxyProvider<AppState, AllPhotosProvider>`.
4. Add unit tests (`test/unit/providers/all_photos_provider_test.dart`) covering pagination, refresh dedupe, and invalidate behavior.

## Step 4 – UI Implementation

1. Create `lib/screens/all_photos/all_photos_screen.dart`:
   - Wrap in `Consumer<AllPhotosProvider>`
   - Use `RefreshIndicator` + `GridView.builder` with shared `ScrollController`
   - Render loading, empty, error, and populated states
   - Navigate to `PhotoViewerScreen` with selected index
2. Extract `PhotoGridTile` into `lib/widgets/photo_grid_tile.dart` for reuse by equipment tab.
3. Refactor `lib/screens/equipment/all_photos_tab.dart` to reuse `PhotoGridTile` and accept enriched metadata.
4. Add widget tests for loading/empty/populated states (`test/widget/screens/all_photos_screen_test.dart`).

## Step 5 – Navigation Integration

1. Update `lib/widgets/bottom_nav.dart` to replace the Map entry with All Photos label/icon.
2. Adjust `lib/screens/shell_scaffold.dart` tab index mapping so All Photos highlights correctly.
3. Register `/all-photos` in `lib/router.dart`; ensure deep links still route to `/home` by default.
4. Extend widget/integration tests for bottom nav (`test/widget/widgets/bottom_nav_test.dart`) and navigation flow (`integration_test/all_photos_gallery_test.dart`, `integration_test/navigation_all_photos_test.dart`).

## Step 6 – Cache Hooks

- On successful save (`lib/services/photo_save_service.dart`) and deletion (`lib/screens/photo_viewer_screen.dart`), call `context.read<AllPhotosProvider>().invalidate()` (guarding for provider availability).
- Provider should lazily reload on next screen focus to avoid redundant background activity.

## Step 7 – Optional API Parity

1. Create migration `api/src/database/migrations/002_add_photo_timestamp_index.sql` with descending index.
2. Update Sequelize model `api/src/models/photo.js` to include new index metadata.
3. Add route `api/src/routes/photos.js` exposing `/v1/photos` with `page[size]`/`page[offset]`.
4. Write integration tests in `api/tests/integration/photos_feed.test.js` validating order, pagination limits, and rate limiting responses.

## Validation Results (2025-10-19)

- ✅ `flutter test test/unit/providers/all_photos_provider_test.dart test/widget/screens/all_photos_screen_test.dart test/widget/widgets/bottom_nav_test.dart test/performance/navigation_performance_test.dart`
- ✅ `flutter test integration_test/navigation_flow_test.dart`
- ✅ `flutter test integration_test/all_photos_gallery_test.dart`
- ✅ `NODE_OPTIONS=--experimental-vm-modules npm test -- tests/integration/photos_feed.test.js`
- 📌 Manual spot-check: bottom nav highlights All Photos; gallery refresh after delete/save verified on simulator.

Document open items (e.g., breadcrumb seed) before release and re-run the full suites once addressed.

## Post-Implementation

- Update this quickstart with observed load timings (SC-002) and manual QA notes when available.
- Share demo build video focusing on navigation swap and gallery refresh behavior.
