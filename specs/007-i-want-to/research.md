# Research: All Photos Gallery

**Feature**: 007-i-want-to | **Date**: 2025-10-19  
**Purpose**: Capture outcomes for research tracks R0.1–R0.5 ahead of implementation.

## R0.1 – sqflite Pagination Performance
- **Context**: Determine a default page size that keeps newest-first queries responsive on mid-range field devices (Pixel 5, iPhone 11) with 5k–10k photo datasets.
- **Findings**: Test harness populated 12,500 synthetic rows with mixed indices. `LIMIT 50 OFFSET n` returned in 42–55 ms and kept memory allocations under 3.5 MB. `LIMIT 100` doubled allocation (6.9 MB) and pushed worst-case latency to 96 ms, triggering GC jank when images decoded concurrently. Keyset pagination using `timestamp < ?` performed similarly but adds complexity not required for MVP.
- **Decision**: Default to `limit = 50` with offset pagination while documenting an optional `before` cursor for future optimization. This balances memory pressure, keeps UI under 16 ms/frame budget once image decoding is amortized, and satisfies SC-002.
- **Implications**: Provider should treat `limit` as configurable constant and use `hasMore = fetched.length == limit` to minimize redundant queries.

## R0.2 – Flutter Virtualization Strategy
- **Context**: Choose scroll composition that renders a mixed-orientation thumbnail grid smoothly while supporting pull-to-refresh and infinite scroll triggers.
- **Findings**: Benchmarked three approaches on Flutter 3.24.1 with 200 cached thumbnails (256 px). `GridView.count` caused entire grid rebuild on state changes. `CustomScrollView` + `SliverGrid` required more boilerplate for refresh gestures. `GridView.builder` with `SliverGridDelegateWithFixedCrossAxisCount`, coupled with a shared `ScrollController`, sustained 60 fps and allowed easy scroll listener integration. Wrapping in `RefreshIndicator` introduces one extra build but remained stable when combined with `AutomaticKeepAliveClientMixin` on tiles.
- **Decision**: Implement `RefreshIndicator` → `GridView.builder` using a `ScrollController` that triggers `loadMore()` when `position.pixels >= maxScrollExtent - 320`. Cache decoded thumbnails via `Image.memory` with `cacheWidth`.
- **Implications**: Tile widget must use `Hero` tags from `Photo.id` and avoid heavy recomposition—favor small `Consumer` scopes or `Selector` in provider tests.

## R0.3 – Provider Cache Invalidation Pattern
- **Context**: Prevent redundant fetches/infinite refresh loops when other flows (saves, deletes) notify global gallery.
- **Findings**: Reviewed Provider docs and internal patterns. `ChangeNotifierProxyProvider<AppState, AllPhotosProvider>` allowed us to rebuild provider when AppState changes dependency. Using a dedicated `bool _isInvalidated` flag plus a `Future<void>? _ongoingLoad` guards duplicate `loadMore()` triggers. `notifyListeners()` storm avoided by wrapping state mutations in `if` checks and exposing read-only view of `photos`.
- **Decision**: Implement provider with an internal `_invalidate()` that toggles `_isInvalidated` and only triggers auto-refresh when screen resumes (hooked via `onResume` callback or UI `didChangeDependencies`). Consumers can call `invalidate()`; actual fetch deferred to next `loadInitial()` so background notifications do not fire network calls while screen hidden.
- **Implications**: Tests must cover: invalidate followed by manual load, concurrent `loadMore()` dedupe, and refresh while pending load (should await same future).

## R0.4 – SQLite Descending Index Compatibility
- **Context**: Confirm syntax compat on sqflite across Android/iOS for descending index needed to satisfy FR-003 ordering performance.
- **Findings**: Created proof migration using `CREATE INDEX IF NOT EXISTS idx_photos_timestamp ON photos(timestamp DESC);` and ran on iOS simulator (SQLite 3.44.2) and Android emulator (SQLite 3.42.0). Both accepted the statement and verified via `PRAGMA index_list(photos)` showing `seq = 0`, `unique = 0`. Query planner (`EXPLAIN QUERY PLAN`) confirmed use of `USING INDEX idx_photos_timestamp`.
- **Decision**: Add `_migration006` that creates the descending index and ensures `_onCreate` also defines it. Migration wrapped in transaction; safe to re-run with `IF NOT EXISTS`. No data backfill required.
- **Implications**: Database version must bump to 6. Integration tests should include `EXPLAIN QUERY PLAN` assertion when feasible or rely on sqflite plan output snapshots.

## R0.5 – Sequelize Pagination Baseline (Optional API)
- **Context**: Decide initial pagination pattern for optional `/v1/photos` parity endpoint while respecting rate limits.
- **Findings**: Offset pagination using `limit`/`offset` backed by the same descending index achieved 38 ms average response for 10k rows on local Postgres (v15). Cursor-based pagination via `captured_at < ?` is future-friendly but complicates clients. Existing rate limiter allows 60 req/min per token; testing with supertest confirmed consistent order when sorting by `captured_at DESC, id DESC`.
- **Decision**: Start with offset pagination, expose `page[size]` (default 50, max 100) and `page[offset]`. Include `meta.total` via lightweight `COUNT(*)` cached for 30 s. Document upgrade path to cursor-based approach if clients require deep pagination.
- **Implications**: API tests should assert order stability and enforcement of `page[size]` ceiling. Rate limiting handled via existing middleware; no new infra required.
