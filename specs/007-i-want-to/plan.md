# Implementation Plan: All Photos Gallery

**Branch**: `007-i-want-to` | **Date**: 2025-10-18 | **Spec**: [spec.md](./spec.md)  
**Input**: Feature specification from `/Users/hyrumharris/src/sitepictures/specs/007-i-want-to/spec.md`

## Summary

Deliver a global “All Photos” experience that aggregates every photo the user can access, ordered from newest to oldest, and reachable directly from the primary navigation bar. The plan covers a new data access path in `DatabaseService`, AppState exposure with optional pagination, an `AllPhotosProvider` that caches results, UI routing/state updates to replace the map entry point, and a dedicated gallery screen featuring pull-to-refresh, lazy loading, and quick access to `PhotoViewerScreen`. Supporting work adds a descending timestamp index in SQLite and the Sequelize/PostgreSQL schema, keeps caches in sync after capture or deletion, and (optionally) exposes a paginated `/v1/photos` API endpoint for parity.

## Technical Context

**Language/Version**: Dart 3.8.1 / Flutter SDK 3.24+, Node.js 18+ (API)  
**Primary Dependencies**: Flutter framework, sqflite, provider, go_router, carousel_slider, express, sequelize, pg  
**Storage**: SQLite (sqflite) for on-device metadata, local file system for photo binaries, PostgreSQL via Sequelize for server API  
**Testing**: flutter_test, integration_test (Flutter), jest + supertest (API)  
**Target Platform**: iOS 13+ and Android 8.0+ field devices; optional API for self-hosted backend  
**Project Type**: Mobile application with companion Node/Express API  
**Performance Goals**: All Photos initial batch <2s at 90th percentile (SC-002), infinite scroll maintains 60fps, newest-to-oldest ordering verifiably consistent (SC-003)  
**Constraints**: Offline-first (Article II), one-handed nav access (Article I), map button removal accepted (Clarification), gallery must respect user permissions, low memory utilization with virtualization  
**Scale/Scope**: Global photo feed spanning potentially tens of thousands of records; pagination defaults to app-friendly batch size (e.g., 50) with graceful degradation when datasets grow

## Constitution Check

*GATE: Must pass before detailed design; re-affirm post Phase 1.*

### Article I – Field-First Architecture ✅ PASS
- Replaces unused Map tab with All Photos for faster situational awareness, minimizing taps to reach latest imagery.
- Grid supports one-handed browsing with large touch targets and pull-to-refresh; cache keeps response immediate even offline.

### Article II – Offline Autonomy ✅ PASS
- Gallery sources data from local SQLite via new `DatabaseService` method; optional API feed is additive, not required for core flow.
- Pagination and cache work without connectivity, syncing later through existing background services.

### Article III – Data Integrity Above All ✅ PASS
- Sorting uses stored capture timestamps with upload-time fallback to keep deterministic order.
- Cache invalidation after saves/deletes ensures global gallery reflects authoritative local state without losing photos.

### Article IV – Hierarchical Consistency ✅ PASS
- Each tile renders equipment and optional site/client context derived through JOINs, preserving visibility into hierarchy even in a flattened feed.
- No hierarchy rules are broken; All Photos augments navigation but does not circumvent access rules.

### Article V – Privacy & Security by Design ✅ PASS
- Access control relies on existing permission filters in queries; no new telemetry or external sharing introduced.
- Optional API endpoint will enforce pagination, auth middleware, and rate limits consistent with current security posture.

### Article VI – Performance Primacy ✅ PASS
- Adds descending timestamp index (`idx_photo_timestamp`) locally and remotely; virtualized grid prevents frame drops.
- Lazy loading batches limit memory usage; cache refresh work scheduled off UI thread to maintain responsiveness.

### Article VII – Intuitive Simplicity ✅ PASS
- Navigation label “All Photos” is explicit; pull-to-refresh and infinite scroll mirror existing mobile paradigms.
- Empty, loading, and error states provide clear next steps (“No photos yet”, retry actions).

### Article VIII – Modular Independence ✅ PASS
- New `AllPhotosProvider` encapsulates feed state; other modules (equipment photos, folders) remain unaffected.
- Database, provider, UI, and optional API layers communicate through clear contracts, enabling isolated testing.

### Article IX – Collaborative Transparency ✅ PASS
- Deletions continue to go through existing confirmation flows and audit logging; gallery reflects updates immediately, avoiding stale representations.
- Optional API response includes pagination cursors suitable for audit/reporting pipelines later.

## Project Structure

### Documentation (this feature)

```
specs/007-i-want-to/
├── spec.md
├── plan.md                          # This document
├── research.md                      # Phase 0 output (NEW)
├── data-model.md                    # Phase 1 output (NEW)
├── quickstart.md                    # Phase 1 output (NEW)
├── contracts/                       # Phase 1 API/UI contracts (NEW dir)
└── checklists/
    └── requirements.md
```

### Source Code (repository root)

```
lib/
├── main.dart                        # Register AllPhotosProvider (MODIFY)
├── router.dart                      # Add /all-photos route, tab index remap (MODIFY)
├── screens/
│   ├── shell_scaffold.dart          # Ensure nav index highlights correctly (MODIFY)
│   ├── all_photos/                  # NEW directory
│   │   └── all_photos_screen.dart   # Global gallery with grid + lazy loading (NEW)
│   ├── equipment/
│   │   └── all_photos_tab.dart      # Consider small refactor to share tile widget (MODIFY)
│   └── photo_viewer_screen.dart     # Invalidate global cache after deletions (MODIFY)
├── widgets/
│   ├── bottom_nav.dart              # Replace Map item with All Photos (MODIFY)
│   └── photo_grid_tile.dart         # Shared tile for equipment/global galleries (NEW, optional refactor)
├── providers/
│   ├── app_state.dart               # Expose paginated global photo fetch (MODIFY)
│   └── all_photos_provider.dart     # Feed caching + pagination controller (NEW)
├── services/
│   ├── database_service.dart        # Add query + migration v6 for idx_photo_timestamp (MODIFY)
│   ├── photo_save_service.dart      # Invalidate cache after saves (MODIFY)
│   └── api_service.dart             # Optional: wire GET /v1/photos (MODIFY)
└── models/
    └── photo.dart                   # Add virtual fields for equipment/site context (MODIFY)

integration_test/
└── all_photos_gallery_test.dart     # End-to-end navigation + refresh (NEW)

test/
├── unit/
│   └── providers/all_photos_provider_test.dart  # Pagination & caching (NEW)
├── widget/
│   └── screens/all_photos_screen_test.dart      # UI states, navigation (NEW)
└── api/
    └── photos_feed.test.js                      # Optional API parity tests (NEW)

api/
├── src/routes/photos.js             # Add GET /v1/photos w/ pagination (MODIFY, optional)
├── src/models/photo.js              # Append timestamp index metadata (MODIFY, optional)
└── src/database/migrations/
    └── 002_add_photo_timestamp_index.sql  # PostgreSQL index (NEW, optional)
```

**Structure Decision**: Maintain Flutter’s existing feature-based organization while introducing a dedicated All Photos directory for the new screen and provider. Shared widgets consolidate repeated gallery tile logic. Optional API adjustments remain confined to the Node/Express layer so mobile and backend can evolve independently, supporting Constitution Article VIII.

## Execution Flow (/plan scope)

1. Load spec and clarifications → confirm FR-001…FR-006 and SC-001…SC-004 drive this plan.  
2. Populate technical context & constitutional alignment (complete).  
3. Define research tasks (Phase 0) for pagination strategy, SQLite indexing, and provider caching patterns.  
4. Outline Phase 1 artifacts (`research.md`, `data-model.md`, `quickstart.md`, contracts) with design decisions.  
5. Decompose implementation into coherent workstreams (data layer, state, UI, cache invalidation, optional API, QA).  
6. Stop prior to generating `tasks.md`; `/speckit.tasks` will convert this plan into executable tasks.

## Phase 0: Research & Unknowns

Focus on gathering best practices before coding:
- **R0.1** – Validate sqflite performance for large ordered queries and determine ideal page size (e.g., 50 vs 100) under mobile memory constraints.
- **R0.2** – Confirm Flutter virtualization strategies (e.g., `GridView.builder` + `ScrollController` vs `SliverGrid` in `CustomScrollView`) for smooth infinite scroll with image thumbnails.
- **R0.3** – Investigate Provider patterns for cache invalidation and background refresh without triggering rebuild storms.
- **R0.4** – Review SQLite descending index creation syntax compatibility across iOS/Android (ensure `CREATE INDEX ... DESC` works uniformly).
- **R0.5** – (Optional API) Benchmark Sequelize pagination techniques (offset vs cursor) to decide initial implementation and how to guard with rate limits.

Deliverable: `research.md` summarizing findings, chosen defaults (page size, pagination style), and trade-offs.

## Phase 1: Design & Contracts

Translate research into concrete design artifacts:
- **D1.1 – Data Model (`data-model.md`)**: Document new query contract for global photos (fields returned, ordering rule, join path for equipment/site names, pagination parameters). Include SQLite schema update (version bump to 6) and PostgreSQL index definition.
- **D1.2 – Provider Contract (`contracts/`)**: Specify `AllPhotosProvider` public API (`loadInitial`, `loadMore`, `refresh`, `invalidate`, state fields). Define error/loading state handling and cache persistence expectations.
- **D1.3 – UI Blueprint (`quickstart.md`)**: Sketch navigation updates (bottom nav layout, route mapping), All Photos grid layout, empty/loading state copy, and PhotoViewer integration.
- **D1.4 – API Contract (optional)**: If backend parity pursued, define request/response schema for `GET /v1/photos` including query params (`page[size]`, `page[offset]` or `cursor`) and response metadata.
- **D1.5 – Constitution Re-check**: Ensure designs keep offline-first, performance, and hierarchy context intact before implementation.

## Phase 2: Implementation Outline

### 1. Data Layer Enhancements
- **SQLite schema**:  
  - Increment database version to 6; add `_migration006` creating `idx_photo_timestamp ON photos(timestamp DESC)` plus fallback creation in `_onCreate`.  
  - Ensure migration is idempotent (use `IF NOT EXISTS`) for safety.
- **DatabaseService API**:  
  - Implement `Future<List<Map<String, dynamic>>> getAllPhotos({int limit = 50, int offset = 0})` performing a JOIN to equipment, main_sites, sub_sites, and clients to surface context fields while filtering by visibility rules (respect inactive flags, user permissions if stored).  
  - Accept optional `DateTime? before` to support keyset pagination later (document even if not initially used).
- **AppState exposure**:  
  - Add `Future<List<Photo>> getAllPhotos({int limit = 50, int offset = 0})` that calls the service, maps to `Photo` (extending model for `equipmentName`, `clientName`, etc.), and bubbles errors through existing error handler.  
  - Provide helper to compute `locationSummary` composed from available hierarchy strings.

### 2. State Management (`AllPhotosProvider`)
- Implement provider storing `List<Photo>`, `bool isLoading`, `bool isRefreshing`, `bool hasMore`, `String? error`.
- Methods:  
  - `loadInitial()` loads first page, caches results, sets `hasMore` via page size check.  
  - `refresh()` resets offset and reloads.  
  - `loadMore()` appends next batch if `hasMore` true and not already loading.  
  - `invalidate()` flags cache stale; optionally auto-refresh when screen resumes.  
- Use `ChangeNotifierProxyProvider<AppState, AllPhotosProvider>` in `main.dart` to inject AppState dependency.
- Provide lightweight in-memory throttling to avoid duplicate parallel fetches.

### 3. UI & Navigation Updates
- **Bottom navigation**: Swap Map tab for All Photos icon/text in `lib/widgets/bottom_nav.dart`; update `onTap` to route `/all-photos`. Adjust index mapping in `ShellScaffold` to highlight the right tab.
- **Routing**: Introduce `/all-photos` route in `router.dart`, update index detection logic, and remove temporary Map placeholder route. Ensure deep links and `initialLocation` still route to `/home` for authenticated users.
- **AllPhotosScreen** (`lib/screens/all_photos/all_photos_screen.dart`):  
  - Compose `ChangeNotifierProvider` (if not globally provided) or rely on ancestor provider from `main.dart`.  
  - Build `Scaffold` with `AppBar` containing optional filters (future-proof).  
  - Use `RefreshIndicator` + `CustomScrollView`/`GridView.builder` with `ScrollController` to trigger `loadMore()` when near bottom.  
  - Each tile uses shared widget (possibly extracted from equipment tab) showing thumbnail, equipment name, location summary, timestamp.  
  - Handle loading, empty, and error states gracefully.  
  - On tap, push `/photo-viewer` with the cached photo list + index.  
  - Support pull-to-refresh per SC-001 and spec Edge Cases (empty dataset message).
- **Shared widget extraction**: Factor repeated tile layout between equipment tab and All Photos to `widgets/photo_grid_tile.dart`, accepting metadata flags (folder badges, location summary).

### 4. Cache Invalidation Hooks
- **Photo save flow**: After successful `PhotoSaveService.saveToEquipment`, call `context.read<AllPhotosProvider>().invalidate()` (guard if provider unavailable). Possibly extend `SaveResult` consumer to trigger refresh asynchronously.  
- **Photo deletion**: In `PhotoViewerScreen` and equipment-level delete flows, notify provider to remove deleted item or mark stale. For immediate UX, consider directly removing from provider cache when photo ID matches.  
- **Needs Assigned provider**: Ensure global invalidation does not regress existing features; coordinate so both providers can refresh independently without race conditions.

### 5. Optional API Parity
- **Route**: Add `router.get('/', async (req, res) => {...})` in `api/src/routes/photos.js` to serve paginated metadata ordered by `captured_at DESC`. Accept `page[size]` (max cap, e.g., 100) and `page[offset]` or `cursor`.  
- **Index**: Create `api/src/database/migrations/002_add_photo_timestamp_index.sql` with `CREATE INDEX IF NOT EXISTS idx_photo_timestamp ON photos (captured_at DESC);`. Update Sequelize `Photo` model `indexes` array accordingly.  
- **Service**: If API layer uses service module, encapsulate query there for reuse/testing. Enforce rate limiter (reuse global limiter or add route-specific).  
- **Tests**: Add jest + supertest coverage verifying default pagination, explicit page size, and order consistency.

### 6. Validation & QA
- **Unit tests**:  
  - Provider tests verifying pagination, refresh, and invalidate behaviors (mock AppState).  
  - DatabaseService test using sqflite in-memory DB to assert ordering and limit/offset interplay.  
- **Widget tests**:  
  - `AllPhotosScreen` loading -> populated -> empty states.  
  - Bottom nav highlighting after switching to All Photos.  
- **Integration tests**:  
  - Add `integration_test/all_photos_gallery_test.dart` covering navigation, pull-to-refresh, lazy load triggered at bottom, and PhotoViewer navigation.  
  - Extend existing capture integration to assert new photo appears in All Photos after save (within test timeframe).  
- **Manual QA checklist**: offline vs online, large dataset performance, deletion path, orientation changes, provider cleanup on logout.  
- **Success criteria verification**: Measure load time on test dataset (simulate 500 photos) to confirm SC-002, inspect sort order for SC-003, gather feedback instrumentation for SC-004 (post-launch survey or proxy metric).

## Complexity Tracking

*No constitutional violations anticipated; section currently not required. Document here if future decisions break a gate.*
