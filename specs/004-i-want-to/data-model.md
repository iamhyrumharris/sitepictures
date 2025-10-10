# Data Model: Equipment Page Photo Management with Folders

**Feature**: 004-i-want-to
**Date**: 2025-10-09
**Status**: Complete

## Overview

This document defines the data model for folder-based photo organization. The design extends the existing photo management system with folders and before/after categorization while maintaining offline-first principles and referential integrity.

## Entity Relationship Diagram

```
┌──────────────┐
│  Equipment   │
│              │
│ id (PK)      │
│ name         │
│ ...          │
└──────┬───────┘
       │
       │ 1:N
       │
       ▼
┌──────────────────┐           ┌─────────────────┐
│  PhotoFolder     │           │     Photo       │
│                  │           │                 │
│ id (PK)          │           │ id (PK)         │
│ equipment_id (FK)│           │ equipment_id(FK)│
│ name             │     N:M   │ file_path       │
│ work_order       │◄─────────►│ timestamp       │
│ created_at       │           │ captured_by     │
│ created_by (FK)  │           │ ...             │
│ is_deleted       │           └─────────────────┘
└──────────────────┘                    ▲
                                        │
                                        │
                                        │
                             ┌──────────┴──────────┐
                             │   FolderPhoto       │
                             │   (Junction Table)  │
                             │                     │
                             │ folder_id (FK, PK)  │
                             │ photo_id (FK, PK)   │
                             │ before_after        │
                             │ added_at            │
                             └─────────────────────┘
```

## Entities

### 1. PhotoFolder (NEW)

**Purpose**: Represents a work-order-based organizational container for before/after photo documentation.

**Table Schema**:
```sql
CREATE TABLE photo_folders (
  id TEXT PRIMARY KEY,
  equipment_id TEXT NOT NULL,
  name TEXT NOT NULL,
  work_order TEXT NOT NULL,
  created_at TEXT NOT NULL,
  created_by TEXT NOT NULL,
  is_deleted INTEGER NOT NULL DEFAULT 0,
  FOREIGN KEY (equipment_id) REFERENCES equipment(id) ON DELETE CASCADE,
  FOREIGN KEY (created_by) REFERENCES users(id)
);

CREATE INDEX idx_photo_folders_equipment ON photo_folders(equipment_id);
CREATE INDEX idx_photo_folders_created_at ON photo_folders(created_at DESC);
CREATE INDEX idx_photo_folders_equipment_created ON photo_folders(equipment_id, created_at DESC);
```

**Fields**:

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| `id` | TEXT | PRIMARY KEY | UUID v4 generated client-side |
| `equipment_id` | TEXT | NOT NULL, FK | Equipment this folder belongs to |
| `name` | TEXT | NOT NULL | Display name: "{work_order} - {YYYY-MM-DD}" |
| `work_order` | TEXT | NOT NULL | User-entered work order/job number |
| `created_at` | TEXT | NOT NULL | ISO8601 timestamp of folder creation |
| `created_by` | TEXT | NOT NULL, FK | User ID who created the folder |
| `is_deleted` | INTEGER | NOT NULL, DEFAULT 0 | Soft delete flag for sync (0=active, 1=deleted) |

**Validation Rules**:
- `name`: Max 100 characters, format enforced by application
- `work_order`: Max 50 characters, sanitized (alphanumeric + -, _, #, /)
- `created_at`: Must be <= current time
- `is_deleted`: Only 0 or 1

**Business Rules**:
- **FR-008b**: Name format: `${work_order} - ${created_at.format('yyyy-MM-DD')}`
- **FR-011**: Folders ordered by `created_at DESC` (newest first)
- Deletion sets `is_deleted = 1` initially, hard delete after sync confirmation
- Duplicate work_order on same date: Append UUID suffix to name

**Dart Model**:
```dart
class PhotoFolder {
  final String id;
  final String equipmentId;
  final String name;
  final String workOrder;
  final DateTime createdAt;
  final String createdBy;
  final bool isDeleted;

  PhotoFolder({
    String? id,
    required this.equipmentId,
    required this.workOrder,
    required this.createdBy,
    DateTime? createdAt,
    bool? isDeleted,
  })  : id = id ?? Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        isDeleted = isDeleted ?? false,
        name = _generateName(workOrder, createdAt ?? DateTime.now());

  static String _generateName(String workOrder, DateTime date) {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    return '$workOrder - $dateStr';
  }

  Map<String, dynamic> toMap() { /* ... */ }
  factory PhotoFolder.fromMap(Map<String, dynamic> map) { /* ... */ }
}
```

---

### 2. FolderPhoto (NEW - Junction Table)

**Purpose**: Many-to-many relationship between folders and photos with before/after categorization.

**Table Schema**:
```sql
CREATE TABLE folder_photos (
  folder_id TEXT NOT NULL,
  photo_id TEXT NOT NULL,
  before_after TEXT NOT NULL CHECK(before_after IN ('before', 'after')),
  added_at TEXT NOT NULL,
  PRIMARY KEY (folder_id, photo_id),
  FOREIGN KEY (folder_id) REFERENCES photo_folders(id) ON DELETE CASCADE,
  FOREIGN KEY (photo_id) REFERENCES photos(id) ON DELETE CASCADE
);

CREATE INDEX idx_folder_photos_folder ON folder_photos(folder_id);
CREATE INDEX idx_folder_photos_photo ON folder_photos(photo_id);
```

**Fields**:

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| `folder_id` | TEXT | NOT NULL, PK, FK | Folder containing this photo |
| `photo_id` | TEXT | NOT NULL, PK, FK | Photo in this folder |
| `before_after` | TEXT | NOT NULL, CHECK | Categorization: "before" or "after" |
| `added_at` | TEXT | NOT NULL | ISO8601 timestamp when photo added to folder |

**Validation Rules**:
- `before_after`: Must be exactly "before" or "after" (CHECK constraint)
- Composite PK: Each photo can appear in folder at most once
- Cascading deletes: Remove association if folder OR photo deleted

**Business Rules**:
- **FR-014**: Photos captured in Before tab → `before_after = 'before'`
- **FR-015**: Photos captured in After tab → `before_after = 'after'`
- **FR-016**: `before_after` value immutable after creation (no switching)
- **FR-010b**: Folder deletion with "Keep photos" → DELETE FROM folder_photos WHERE folder_id = ?
- **FR-010c**: Folder deletion with "Delete photos" → ON DELETE CASCADE handles cleanup

**Dart Model**:
```dart
enum BeforeAfter {
  before,
  after;

  String toDb() => name; // "before" or "after"
  static BeforeAfter fromDb(String value) => BeforeAfter.values.byName(value);
}

class FolderPhoto {
  final String folderId;
  final String photoId;
  final BeforeAfter beforeAfter;
  final DateTime addedAt;

  FolderPhoto({
    required this.folderId,
    required this.photoId,
    required this.beforeAfter,
    DateTime? addedAt,
  }) : addedAt = addedAt ?? DateTime.now();

  Map<String, dynamic> toMap() { /* ... */ }
  factory FolderPhoto.fromMap(Map<String, dynamic> map) { /* ... */ }
}
```

---

### 3. Photo (MODIFIED)

**Purpose**: Extend existing photo entity with virtual folder association fields (no schema change).

**Existing Table Schema** (unchanged):
```sql
CREATE TABLE photos (
  id TEXT PRIMARY KEY,
  equipment_id TEXT NOT NULL,
  file_path TEXT NOT NULL,
  thumbnail_path TEXT,
  latitude REAL NOT NULL,
  longitude REAL NOT NULL,
  timestamp TEXT NOT NULL,
  captured_by TEXT NOT NULL,
  file_size INTEGER NOT NULL,
  is_synced INTEGER NOT NULL DEFAULT 0,
  synced_at TEXT,
  remote_url TEXT,
  created_at TEXT NOT NULL,
  FOREIGN KEY (equipment_id) REFERENCES equipment(id) ON DELETE CASCADE,
  FOREIGN KEY (captured_by) REFERENCES users(id)
);
-- Existing indexes unchanged
```

**New Virtual Fields** (computed at query time, not stored):

| Field | Type | Source | Description |
|-------|------|--------|-------------|
| `folderId` | String? | LEFT JOIN folder_photos | Folder ID if photo is in a folder, null if standalone |
| `folderName` | String? | LEFT JOIN photo_folders | Folder display name for UI, null if standalone |
| `beforeAfter` | BeforeAfter? | folder_photos.before_after | Categorization if in folder |

**Query for All Photos Tab** (FR-005, FR-005a):
```sql
SELECT
  p.*,
  fp.folder_id AS folder_id,
  pf.name AS folder_name,
  fp.before_after AS before_after
FROM photos p
LEFT JOIN folder_photos fp ON p.id = fp.photo_id
LEFT JOIN photo_folders pf ON fp.folder_id = pf.id
WHERE p.equipment_id = ?
  AND (pf.is_deleted IS NULL OR pf.is_deleted = 0)
ORDER BY p.timestamp DESC;
```

**Modified Dart Model**:
```dart
class Photo {
  // Existing fields (unchanged)
  final String id;
  final String equipmentId;
  final String filePath;
  // ... (all existing fields)

  // NEW: Virtual fields (not in database)
  final String? folderId;
  final String? folderName;
  final BeforeAfter? beforeAfter;

  Photo({
    // ... existing constructor params
    this.folderId,  // NEW
    this.folderName,  // NEW
    this.beforeAfter,  // NEW
  });

  // Modified fromMap to handle JOIN results
  factory Photo.fromMap(Map<String, dynamic> map) {
    return Photo(
      // ... existing field mapping
      folderId: map['folder_id'],  // NEW
      folderName: map['folder_name'],  // NEW
      beforeAfter: map['before_after'] != null
        ? BeforeAfter.fromDb(map['before_after'])
        : null,  // NEW
    );
  }

  // Existing toMap unchanged (virtual fields not persisted)
}
```

---

### 4. Equipment (EXISTING - No Changes)

The existing Equipment entity remains unchanged. Folders are associated via `photo_folders.equipment_id` foreign key.

---

## Database Migrations

### Migration 004: Add Folder Tables

**File**: `lib/services/database_service.dart` (add to migrations list)

**SQL**:
```sql
-- Migration 004: Photo Folders
-- Feature: 004-i-want-to
-- Date: 2025-10-09

BEGIN TRANSACTION;

-- Create photo_folders table
CREATE TABLE IF NOT EXISTS photo_folders (
  id TEXT PRIMARY KEY,
  equipment_id TEXT NOT NULL,
  name TEXT NOT NULL,
  work_order TEXT NOT NULL,
  created_at TEXT NOT NULL,
  created_by TEXT NOT NULL,
  is_deleted INTEGER NOT NULL DEFAULT 0,
  FOREIGN KEY (equipment_id) REFERENCES equipment(id) ON DELETE CASCADE,
  FOREIGN KEY (created_by) REFERENCES users(id)
);

CREATE INDEX idx_photo_folders_equipment ON photo_folders(equipment_id);
CREATE INDEX idx_photo_folders_created_at ON photo_folders(created_at DESC);
CREATE INDEX idx_photo_folders_equipment_created ON photo_folders(equipment_id, created_at DESC);

-- Create folder_photos junction table
CREATE TABLE IF NOT EXISTS folder_photos (
  folder_id TEXT NOT NULL,
  photo_id TEXT NOT NULL,
  before_after TEXT NOT NULL CHECK(before_after IN ('before', 'after')),
  added_at TEXT NOT NULL,
  PRIMARY KEY (folder_id, photo_id),
  FOREIGN KEY (folder_id) REFERENCES photo_folders(id) ON DELETE CASCADE,
  FOREIGN KEY (photo_id) REFERENCES photos(id) ON DELETE CASCADE
);

CREATE INDEX idx_folder_photos_folder ON folder_photos(folder_id);
CREATE INDEX idx_folder_photos_photo ON folder_photos(photo_id);

COMMIT;
```

**Rollback** (if needed):
```sql
BEGIN TRANSACTION;
DROP TABLE IF EXISTS folder_photos;
DROP TABLE IF EXISTS photo_folders;
COMMIT;
```

**Testing**:
- Verify tables created successfully
- Test foreign key constraints (insert valid/invalid references)
- Test CHECK constraint on before_after field
- Verify cascade deletes work correctly

---

## Query Patterns

### Common Queries

1. **List folders for equipment** (Folders Tab - FR-006, FR-011)
```sql
SELECT
  pf.*,
  COUNT(fp.photo_id) AS photo_count
FROM photo_folders pf
LEFT JOIN folder_photos fp ON pf.id = fp.folder_id
WHERE pf.equipment_id = ?
  AND pf.is_deleted = 0
GROUP BY pf.id
ORDER BY pf.created_at DESC;
```

2. **Get folder with photo counts** (Folder Detail Screen)
```sql
SELECT
  pf.*,
  COUNT(CASE WHEN fp.before_after = 'before' THEN 1 END) AS before_count,
  COUNT(CASE WHEN fp.before_after = 'after' THEN 1 END) AS after_count
FROM photo_folders pf
LEFT JOIN folder_photos fp ON pf.id = fp.folder_id
WHERE pf.id = ?
GROUP BY pf.id;
```

3. **Get before photos for folder** (FR-014)
```sql
SELECT p.*
FROM photos p
JOIN folder_photos fp ON p.id = fp.photo_id
WHERE fp.folder_id = ?
  AND fp.before_after = 'before'
ORDER BY p.timestamp DESC;
```

4. **Get after photos for folder** (FR-015)
```sql
SELECT p.*
FROM photos p
JOIN folder_photos fp ON p.id = fp.photo_id
WHERE fp.folder_id = ?
  AND fp.before_after = 'after'
ORDER BY p.timestamp DESC;
```

5. **Add photo to folder**
```sql
INSERT INTO folder_photos (folder_id, photo_id, before_after, added_at)
VALUES (?, ?, ?, ?);
```

6. **Delete folder (keep photos)** (FR-010b)
```sql
BEGIN TRANSACTION;
DELETE FROM folder_photos WHERE folder_id = ?;
UPDATE photo_folders SET is_deleted = 1 WHERE id = ?;
COMMIT;
```

7. **Delete folder (delete photos)** (FR-010c)
```sql
BEGIN TRANSACTION;
DELETE FROM photos WHERE id IN (
  SELECT photo_id FROM folder_photos WHERE folder_id = ?
);
-- CASCADE will delete folder_photos entries
UPDATE photo_folders SET is_deleted = 1 WHERE id = ?;
COMMIT;
```

---

## Data Integrity Rules

### Constraints

1. **Referential Integrity**
   - All `equipment_id` foreign keys must reference valid equipment
   - All `created_by` foreign keys must reference valid users
   - Junction table maintains bidirectional integrity (folder ↔ photo)

2. **Cascading Deletes**
   - Delete equipment → CASCADE delete folders → CASCADE delete folder_photos
   - Delete photo → CASCADE delete folder_photos entry
   - Delete folder → CASCADE delete folder_photos entries
   - User deletion: Prevent if folders exist (data preservation)

3. **Enum Constraints**
   - `before_after`: CHECK constraint ensures only 'before' or 'after'
   - `is_deleted`: Application ensures only 0 or 1

### Validation

**Application-Level** (Dart):
```dart
// PhotoFolder validation
bool isValid() {
  if (workOrder.isEmpty || workOrder.length > 50) return false;
  if (name.length > 100) return false;
  if (createdAt.isAfter(DateTime.now())) return false;
  return true;
}

// FolderPhoto validation
bool isValid() {
  if (folderId.isEmpty || photoId.isEmpty) return false;
  if (addedAt.isAfter(DateTime.now())) return false;
  return true;
}
```

**Database-Level** (SQL):
- CHECK constraints on enum fields
- NOT NULL constraints on required fields
- Foreign key constraints for relationships
- Primary key constraints prevent duplicates

---

## Performance Considerations

### Indexing Strategy

1. **Primary lookups**: Composite index on `(equipment_id, created_at DESC)` for folders tab
2. **Junction table**: Indexes on both `folder_id` and `photo_id` for bidirectional queries
3. **Avoid**: Index on `name` (rarely searched, high cardinality)

### Query Optimization

- **All Photos Tab**: LEFT JOIN adds ~5ms overhead (acceptable)
- **Folder List**: GROUP BY with COUNT aggregates < 10ms for 20 folders
- **Photo List**: Direct JOIN with WHERE clause < 10ms for 50 photos

### Memory Footprint

- PhotoFolder object: ~200 bytes
- FolderPhoto record: ~100 bytes
- Average per equipment: 15 folders × 200 + 50 associations × 100 = 8KB (negligible)

---

## Sync Considerations

**Offline-First Behavior**:
- All folder operations execute locally immediately
- Sync queue items created for:
  - Folder creation: `{ type: 'folder_create', folder: {...} }`
  - Folder deletion: `{ type: 'folder_delete', folderId: '...', deletePhotos: true/false }`
  - Photo association: `{ type: 'folder_photo_add', folderId: '...', photoId: '...', beforeAfter: '...' }`

**Conflict Resolution**:
- Folder creation: Server assigns canonical ID, client updates local reference
- Folder deletion: Server timestamp wins (if recreated remotely, resurrect locally)
- Photo associations: Last-write-wins based on `added_at` timestamp

**Future API Contracts** (deferred):
- POST /api/folders - Create folder
- DELETE /api/folders/:id - Delete folder
- POST /api/folders/:id/photos - Add photo to folder
- GET /api/equipment/:id/folders - Sync folder list

---

## Testing Strategy

### Unit Tests

1. **PhotoFolder model**:
   - Test name generation (work order + date format)
   - Validate field constraints
   - Test toMap/fromMap round-trip

2. **FolderPhoto model**:
   - Test before/after enum conversion
   - Validate composite key uniqueness
   - Test toMap/fromMap round-trip

3. **Database migrations**:
   - Test migration execution (up)
   - Test rollback (down)
   - Verify foreign key constraints

### Integration Tests

1. **Folder CRUD**:
   - Create folder → verify in database
   - List folders → verify ordering (FR-011)
   - Delete folder (keep photos) → verify orphaning
   - Delete folder (delete photos) → verify cascade

2. **Photo associations**:
   - Add photo to folder → verify junction table
   - Query before photos → verify filter
   - Query after photos → verify filter
   - All Photos tab → verify LEFT JOIN results

### Performance Tests

- Measure folder list query time (target: < 10ms)
- Measure All Photos JOIN query time (target: < 15ms)
- Measure folder deletion transaction time (target: < 50ms)

---

## Alignment with Requirements

| Requirement | Data Model Support |
|-------------|-------------------|
| FR-006: Display folders for equipment | `photo_folders.equipment_id` FK, indexed |
| FR-008: Prompt for work order | `photo_folders.work_order` field |
| FR-008a: Auto-append date | `photo_folders.name` format, `created_at` field |
| FR-010: Delete folders | `is_deleted` soft delete, transaction support |
| FR-010a: Deletion dialog options | Junction table allows orphaning or cascade |
| FR-011: Folders ordered newest first | `created_at DESC` index |
| FR-012: Before/After tabs | `folder_photos.before_after` enum |
| FR-014/FR-015: Separate before/after | CHECK constraint, query filters |
| FR-016: No intermixing | Enforced by before_after field immutability |
| FR-019: Maintain folder association | `folder_photos` junction table |
| FR-020: Maintain before/after designation | `before_after` field persistence |

---

**Status**: Data model complete and validated. Ready for Phase 1 contracts and quickstart scenarios.
