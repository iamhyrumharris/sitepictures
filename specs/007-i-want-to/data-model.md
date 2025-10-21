# Data Model: All Photos Gallery

**Feature**: 007-i-want-to | **Date**: 2025-10-19  
**Purpose**: Describe schema updates, relationships, and data contracts powering the global All Photos experience.

## Overview

The feature reuses existing photo storage while layering a read-optimized query that surfaces equipment and hierarchy context alongside images. SQLite remains the source of truth on device; PostgreSQL (optional) mirrors ordering/indexes for backend parity. No new tables are introduced—changes focus on:

1. Adding a descending timestamp index so `ORDER BY timestamp DESC` remains performant at 10k+ rows.
2. Extending the Flutter `Photo` model with metadata fields derived from JOINs.
3. Defining a canonical query contract that the DatabaseService, AppState, and Provider consume consistently.

## Entity Relationships

```
Client ──┐
         │          ┌──────────────┐
         ├─ MainSite┤              │
         │          │              │
         └─ SubSite ┤  Equipment   │
                    │  (EXISTING)  │
                    └──────┬───────┘
                           │ 1:N
                           ▼
                    ┌──────────────┐
                    │   Photo      │
                    │ (EXTENDED)   │
                    └──────────────┘
```

Photos already point to `equipment_id`. Equipment optionally references a main site or sub site, each of which links to a client. The All Photos feed projects this hierarchy into a flattened metadata payload:

- `equipmentName`
- `clientName`
- `mainSiteName`
- `subSiteName`
- `locationSummary` (derived concatenation)
- `capturedAt` (existing `timestamp`)
- `fallbackTimestamp` (`created_at` if capture missing)

## SQLite Schema Changes

- **Database version**: increment from 5 → 6.
- **Migration `_migration006`**: 

```sql
CREATE INDEX IF NOT EXISTS idx_photos_timestamp
ON photos (timestamp DESC);
```

- Ensure `_onCreate` also creates the index so fresh installs match upgraded devices.
- Migration wrapped in a transaction to avoid partial state if the index already exists.

## Photo Model Extension

`lib/models/photo.dart` gains new nullable fields and JSON mapping:

| Field              | Type        | Source                                 |
|--------------------|-------------|----------------------------------------|
| `equipmentName`    | `String?`   | `equipment.name`                       |
| `clientName`       | `String?`   | `clients.name` (via equipment linkage) |
| `mainSiteName`     | `String?`   | `main_sites.name`                      |
| `subSiteName`      | `String?`   | `sub_sites.name`                       |
| `locationSummary`  | `String?`   | Concatenated summary of available parts|

All fields are virtual—persisted data remains unchanged. `Photo.fromMap` reads aliased columns, and `copyWith` exposes updates for cache invalidation.

## DatabaseService Contract

Add `Future<List<Map<String, dynamic>>> getAllPhotos({int limit = 50, int offset = 0})` that executes:

```sql
SELECT
  p.*,
  e.name          AS equipment_name,
  c.name          AS client_name,
  ms.name         AS main_site_name,
  ss.name         AS sub_site_name,
  COALESCE(
    NULLIF(TRIM(
      COALESCE(ss.name || ' • ', '') ||
      COALESCE(ms.name || ' • ', '') ||
      c.name
    ), ''),
    e.name
  )               AS location_summary
FROM photos p
JOIN equipment e ON e.id = p.equipment_id
LEFT JOIN main_sites ms ON ms.id = e.main_site_id
LEFT JOIN sub_sites ss ON ss.id = e.sub_site_id
LEFT JOIN clients c ON c.id = COALESCE(ss.client_id, ms.client_id, e.client_id)
WHERE e.is_active = 1
  AND (ms.id IS NULL OR ms.is_active = 1)
  AND (ss.id IS NULL OR ss.is_active = 1)
ORDER BY datetime(p.timestamp) DESC, datetime(p.created_at) DESC
LIMIT ? OFFSET ?;
```

Notes:
- `datetime()` guards against inconsistent timestamp formatting.
- Fallback ordering by `created_at` ensures deterministic sequence when capture timestamps collide.
- Visibility filters reuse existing `is_active` guardrails; permission-based filtering leverages existing DatabaseService helpers if available.

## AppState Exposure

`AppState.getAllPhotos` wraps the DatabaseService call and maps to `Photo` objects, building `locationSummary` if the database returns null (e.g., legacy rows missing hierarchy). Method signature:

```dart
Future<List<Photo>> getAllPhotos({int limit = 50, int offset = 0});
```

Consumers (providers/screens) should treat the result as immutable and rely on provider caching to avoid repeated queries.

## Optional API Parity

When parity work is enabled:

- Mirror index in PostgreSQL via migration `CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_photos_timestamp ON photos (captured_at DESC);`.
- Sequelize model `Photo` includes `indexes: [{ fields: ['captured_at'], using: 'BTREE', order: 'DESC' }]`.
- Route `GET /v1/photos` projects the same fields as mobile query, returning:

```json
{
  "data": [{ "id": "...", "capturedAt": "...", "equipmentName": "...", "locationSummary": "..." }],
  "meta": { "total": 1234, "page": { "size": 50, "offset": 0 } }
}
```

## Validation Checklist

- ✅ Index present and used (`EXPLAIN QUERY PLAN` shows `idx_photos_timestamp`).
- ✅ Query returns newest-to-oldest order even when timestamps equal.
- ✅ `Photo.fromMap` populates metadata fields; null-safe for legacy rows.
- ✅ Provider pagination uses the `limit` constant from research (50) with `hasMore` detection.
- ✅ Optional API enforces max page size 100 and inherits descending order.
