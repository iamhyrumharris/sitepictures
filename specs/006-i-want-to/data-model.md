# Data Model: Camera Photo Save Functionality

**Feature**: 006-i-want-to | **Date**: 2025-10-13
**Purpose**: Define data structures, relationships, and validation rules for camera save functionality

## Overview

This feature extends the existing photo and folder models to support three save contexts: home Quick Save to global "Needs Assigned", equipment direct save, and folder before/after categorized save. Key additions include a special system client for global "Needs Assigned" and new entities for save workflow state management.

## Entity Diagram

```
┌─────────────────────┐
│     Client          │
│  (EXTENDED)         │
├─────────────────────┤
│ id: String (PK)     │──┐
│ name: String        │  │
│ is_system: Boolean  │◄─┼─ NEW FIELD for global "Needs Assigned"
│ created_by: String  │  │
│ created_at: DateTime│  │
│ is_active: Boolean  │  │
└─────────────────────┘  │
         │               │
         │ 1:N           │
         ▼               │
┌─────────────────────┐  │
│   PhotoFolder       │  │
│   (EXISTING)        │  │
├─────────────────────┤  │
│ id: String (PK)     │  │
│ equipment_id: String│  │ (FK, nullable for global)
│ name: String        │  │
│ work_order: String  │  │
│ created_at: DateTime│  │
│ created_by: String  │  │
│ is_deleted: Boolean │  │
└─────────────────────┘  │
         │               │
         │ N:M           │
         ▼               │
┌─────────────────────┐  │
│   FolderPhoto       │  │
│   (EXISTING)        │  │
├─────────────────────┤  │
│ folder_id: String   │──┘ (FK)
│ photo_id: String    │  (FK)
│ before_after: Enum  │  ('before' | 'after')
│ added_at: DateTime  │
└─────────────────────┘
         │
         │ N:1
         ▼
┌─────────────────────┐
│      Photo          │
│   (EXISTING)        │
├─────────────────────┤
│ id: String (PK)     │
│ equipment_id: String│  (FK)
│ file_path: String   │
│ thumbnail_path: Str?│
│ latitude: Double    │
│ longitude: Double   │
│ timestamp: DateTime │
│ captured_by: String │  (FK to User)
│ file_size: Int      │
│ is_synced: Boolean  │
│ created_at: DateTime│
└─────────────────────┘

NEW ENTITIES:

┌─────────────────────┐
│  QuickSaveItem      │  (Result object, not persisted)
├─────────────────────┤
│ type: Enum          │  ('single_photo' | 'folder')
│ name: String        │  Generated with date format
│ photoIds: List<Str> │
│ folderId: String?   │  If type == folder
│ createdAt: DateTime │
└─────────────────────┘

┌─────────────────────┐
│    SaveContext      │  (Enum, not persisted)
├─────────────────────┤
│ type: Enum          │  ('home' | 'equipment' | 'folder_before' | 'folder_after')
│ equipmentId: Str?   │  If type == equipment or folder_*
│ folderId: String?   │  If type == folder_*
│ beforeAfter: Enum?  │  If type == folder_*
└─────────────────────┘

┌─────────────────────┐
│    SaveResult       │  (Result object, not persisted)
├─────────────────────┤
│ success: Boolean    │
│ successfulCount: Int│
│ failedCount: Int    │
│ savedIds: List<Str> │
│ error: String?      │
│ sessionPreserved: B │
└─────────────────────┘

┌──────────────────────┐
│ EquipmentNavNode    │  (UI state, not persisted)
├──────────────────────┤
│ id: String           │
│ name: String         │
│ type: Enum           │  ('client' | 'site' | 'equipment')
│ parentId: String?    │
│ isSelectable: Bool   │  Only equipment nodes
│ children: List<Node>?│  Lazy loaded
└──────────────────────┘
```

## Entity Specifications

### Client (EXTENDED)

**Purpose**: Represents a client organization; extended to support special system clients like global "Needs Assigned".

**Fields**:
- `id`: String (Primary Key, UUID) - Unique identifier
- `name`: String - Client display name
- `description`: String (nullable) - Optional description
- `is_system`: Boolean - **NEW** - Marks system-managed clients (true for global "Needs Assigned")
- `created_by`: String (Foreign Key to User) - User who created client
- `created_at`: DateTime - Creation timestamp
- `updated_at`: DateTime - Last modification timestamp
- `is_active`: Boolean - Soft delete flag

**Constraints**:
- `name` must be unique across all clients
- `name` length: 1-100 characters
- System clients (is_system = true) cannot be deleted or renamed by users
- Global "Needs Assigned" has fixed id: "GLOBAL_NEEDS_ASSIGNED"

**Validation Rules**:
```dart
bool isValid() {
  if (name.isEmpty || name.length > 100) return false;
  if (createdBy.isEmpty) return false;
  if (createdAt.isAfter(DateTime.now())) return false;
  return true;
}
```

**Indexes**:
- `idx_clients_system`: (is_system, is_active) - Filter out system clients from user lists

**Special Instance**:
```dart
final globalNeedsAssigned = Client(
  id: 'GLOBAL_NEEDS_ASSIGNED',
  name: 'Needs Assigned',
  description: 'Global holding area for unorganized photos',
  isSystem: true,
  createdBy: 'SYSTEM',
  createdAt: DateTime.now(),
  isActive: true,
);
```

---

### PhotoFolder (EXISTING - No Changes)

**Purpose**: Represents a before/after folder for equipment maintenance documentation.

**Fields**: (No changes from feature 004)
- `id`: String (Primary Key, UUID)
- `equipment_id`: String (Foreign Key to Equipment)
- `name`: String - Auto-generated "{work_order} - {YYYY-MM-DD}"
- `work_order`: String - User-provided work order/job number
- `created_at`: DateTime
- `created_by`: String (Foreign Key to User)
- `is_deleted`: Boolean - Soft delete flag

**Note**: For Quick Save folders in global "Needs Assigned", equipment_id will be NULL or reference special equipment under GLOBAL_NEEDS_ASSIGNED client.

---

### Photo (EXISTING - No Changes)

**Purpose**: Represents a single photo with metadata and associations.

**Fields**: (No changes from features 003/004)
- `id`: String (Primary Key, UUID)
- `equipment_id`: String (Foreign Key to Equipment)
- `file_path`: String - Local file system path
- `thumbnail_path`: String (nullable) - Generated thumbnail path
- `latitude`: Double - GPS latitude
- `longitude`: Double - GPS longitude
- `timestamp`: DateTime - Capture timestamp
- `captured_by`: String (Foreign Key to User)
- `file_size`: Int - File size in bytes
- `is_synced`: Boolean - Cloud sync status
- `synced_at`: String (nullable) - ISO timestamp
- `remote_url`: String (nullable) - Cloud URL after sync
- `created_at`: DateTime

**Virtual Fields** (from JOINs, not stored):
- `folderId`: String? - Associated folder ID (from folder_photos junction)
- `folderName`: String? - Associated folder name
- `beforeAfter`: Enum? - Before/after categorization

---

### FolderPhoto (EXISTING - No Changes)

**Purpose**: Junction table associating photos with folders and before/after categorization.

**Fields**: (No changes from feature 004)
- `folder_id`: String (Foreign Key to PhotoFolder, Primary Key part 1)
- `photo_id`: String (Foreign Key to Photo, Primary Key part 2)
- `before_after`: Enum ('before' | 'after') - Categorization
- `added_at`: DateTime - Association timestamp

**Primary Key**: Composite (folder_id, photo_id)

---

### QuickSaveItem (NEW - Not Persisted)

**Purpose**: Result object representing Quick Save operation outcome.

**Fields**:
- `type`: Enum (`single_photo` | `folder`) - Determined by photo count
- `name`: String - Generated name ("Image - YYYY-MM-DD" or "Folder - YYYY-MM-DD")
- `photoIds`: List<String> - IDs of saved photos
- `folderId`: String? - Created folder ID (if type == folder)
- `createdAt`: DateTime - Save timestamp

**Construction Logic**:
```dart
QuickSaveItem create(List<String> photoIds) {
  final now = DateTime.now();
  final dateStr = DateFormat('yyyy-MM-dd').format(now);

  if (photoIds.length == 1) {
    return QuickSaveItem(
      type: QuickSaveType.singlePhoto,
      name: 'Image - $dateStr',
      photoIds: photoIds,
      folderId: null,
      createdAt: now,
    );
  } else {
    return QuickSaveItem(
      type: QuickSaveType.folder,
      name: 'Folder - $dateStr',
      photoIds: photoIds,
      folderId: _generatedFolderId,
      createdAt: now,
    );
  }
}
```

---

### SaveContext (NEW - Enum/Data Class)

**Purpose**: Encapsulates camera launch context to determine save behavior.

**Fields**:
- `type`: Enum (`home` | `equipment` | `folder_before` | `folder_after`)
- `equipmentId`: String? - Required if type == equipment or folder_*
- `folderId`: String? - Required if type == folder_*
- `beforeAfter`: Enum? - Required if type == folder_* ('before' | 'after')

**Validation**:
```dart
bool isValid() {
  switch (type) {
    case SaveContextType.home:
      return equipmentId == null && folderId == null;
    case SaveContextType.equipment:
      return equipmentId != null && folderId == null;
    case SaveContextType.folderBefore:
    case SaveContextType.folderAfter:
      return equipmentId != null && folderId != null && beforeAfter != null;
  }
}
```

**Factory Constructors**:
```dart
factory SaveContext.home() {
  return SaveContext(type: SaveContextType.home);
}

factory SaveContext.equipment(String equipmentId) {
  return SaveContext(
    type: SaveContextType.equipment,
    equipmentId: equipmentId,
  );
}

factory SaveContext.folderBefore(String equipmentId, String folderId) {
  return SaveContext(
    type: SaveContextType.folderBefore,
    equipmentId: equipmentId,
    folderId: folderId,
    beforeAfter: BeforeAfter.before,
  );
}
```

---

### SaveResult (NEW - Result Object)

**Purpose**: Encapsulates save operation outcome for error handling and user feedback.

**Fields**:
- `success`: Boolean - Overall operation success
- `successfulCount`: Int - Number of photos saved successfully
- `failedCount`: Int - Number of photos that failed to save
- `savedIds`: List<String> - IDs of successfully saved photos
- `error`: String? - Error message (if success == false)
- `sessionPreserved`: Boolean - Whether photo session was preserved for retry

**Factory Constructors**:
```dart
factory SaveResult.complete(List<String> savedIds) {
  return SaveResult(
    success: true,
    successfulCount: savedIds.length,
    failedCount: 0,
    savedIds: savedIds,
    sessionPreserved: false,
  );
}

factory SaveResult.partial({
  required int successful,
  required int failed,
  required List<String> savedIds,
}) {
  return SaveResult(
    success: false,
    successfulCount: successful,
    failedCount: failed,
    savedIds: savedIds,
    sessionPreserved: false,
  );
}

factory SaveResult.criticalFailure({
  required Exception error,
  bool sessionPreserved = true,
}) {
  return SaveResult(
    success: false,
    successfulCount: 0,
    failedCount: 0,
    savedIds: [],
    error: error.toString(),
    sessionPreserved: sessionPreserved,
  );
}
```

**User Message Generation**:
```dart
String getUserMessage() {
  if (success) {
    return '$successfulCount photo${successfulCount > 1 ? 's' : ''} saved';
  } else if (failedCount > 0 && successfulCount > 0) {
    return '$successfulCount of ${successfulCount + failedCount} photos saved';
  } else {
    return 'Save failed: ${error ?? 'Unknown error'}';
  }
}
```

---

### EquipmentNavigationNode (NEW - UI State)

**Purpose**: Represents a node in the hierarchical equipment navigator tree.

**Fields**:
- `id`: String - Entity ID (client_id, site_id, or equipment_id)
- `name`: String - Display name
- `type`: Enum (`client` | `mainSite` | `subSite` | `equipment`)
- `parentId`: String? - Parent node ID (null for root clients)
- `isSelectable`: Boolean - True only for equipment nodes
- `children`: List<EquipmentNavigationNode>? - Lazy-loaded child nodes

**Lazy Loading Pattern**:
```dart
Future<void> loadChildren() async {
  if (children != null) return; // Already loaded

  switch (type) {
    case NodeType.client:
      children = await _loadSitesForClient(id);
      break;
    case NodeType.mainSite:
    case NodeType.subSite:
      children = await _loadEquipmentForSite(id);
      break;
    case NodeType.equipment:
      children = []; // Equipment has no children
      break;
  }
}
```

---

## State Transitions

### Photo Save Workflow States

```
        [Camera Session Active]
                 │
                 ▼
        [User Taps Done Button]
                 │
                 ├─── Home Context ───┐
                 │                    ▼
                 │         [Display Quick Save / Next Modal]
                 │                    │
                 │         ┌──────────┴──────────┐
                 │         │                     │
                 │         ▼                     ▼
                 │   [Quick Save]          [Next → Equipment Navigator]
                 │         │                     │
                 │         ▼                     ▼
                 │   [Incremental Save]     [User Selects Equipment]
                 │                               │
                 │                               ▼
                 ├─── Equipment Context ───[Direct Save to Equipment]
                 │                               │
                 │                               ▼
                 ├─── Folder Before/After ───[Direct Save to Folder + Category]
                 │
                 ▼
        [Save Operation Running]
                 │
     ┌───────────┴───────────┐
     │                       │
     ▼                       ▼
[Non-Critical Error]   [Critical Error]
     │                       │
     ▼                       ▼
[Continue Saving]      [Rollback + Preserve Session]
     │                       │
     ▼                       ▼
[Partial Success]      [Save Failed - Retry Available]
     │                       │
     └───────────┬───────────┘
                 ▼
        [Display Result + Confirmation]
                 │
                 ▼
        [Return to Origin Screen]
```

### Save Result States

- **Idle**: No save operation active
- **Validating**: Checking storage space and context validity
- **Saving**: Incremental save in progress (emits progress events)
- **Success**: All photos saved successfully
- **PartialSuccess**: Some photos saved, some failed (non-critical errors)
- **CriticalFailure**: Save rolled back, session preserved for retry
- **Retry**: User initiated retry after failure

---

## Database Schema Changes

### Migration 004: Global "Needs Assigned" Support

```sql
-- Add system flag to clients table
ALTER TABLE clients ADD COLUMN is_system INTEGER DEFAULT 0;

-- Create global "Needs Assigned" client
INSERT INTO clients (
  id,
  name,
  description,
  is_system,
  created_by,
  created_at,
  updated_at,
  is_active
) VALUES (
  'GLOBAL_NEEDS_ASSIGNED',
  'Needs Assigned',
  'Global holding area for unorganized photos',
  1,
  'SYSTEM',
  datetime('now'),
  datetime('now'),
  1
);

-- Index for filtering out system clients
CREATE INDEX idx_clients_system ON clients(is_system, is_active);
```

**No other schema changes required** - Existing tables support all save workflows:
- `photos` table: Stores photo metadata with equipment_id
- `photo_folders` table: Stores folder metadata
- `folder_photos` junction: Associates photos with folders and before/after category

---

## Query Patterns

### Get All Photos for Global "Needs Assigned"

```sql
SELECT p.*
FROM photos p
JOIN equipment e ON p.equipment_id = e.id
WHERE e.client_id = 'GLOBAL_NEEDS_ASSIGNED'
ORDER BY p.timestamp DESC;
```

### Check for Existing Quick Save Name (Sequential Numbering)

```sql
SELECT name
FROM photo_folders
WHERE equipment_id IN (
  SELECT id FROM equipment WHERE client_id = 'GLOBAL_NEEDS_ASSIGNED'
)
AND name LIKE 'Folder - 2025-10-13%'
ORDER BY name DESC;
```

### Load Equipment Navigator Root (All Active Clients except System)

```sql
SELECT id, name
FROM clients
WHERE is_active = 1
AND is_system = 0
ORDER BY name ASC;
```

### Load Equipment for Site (Equipment Navigator)

```sql
SELECT id, name, serial_number
FROM equipment
WHERE main_site_id = ? OR sub_site_id = ?
AND is_active = 1
ORDER BY name ASC;
```

### Incremental Save Photo with Folder Association (Transaction)

```sql
BEGIN TRANSACTION;

-- Insert photo
INSERT INTO photos (
  id, equipment_id, file_path, latitude, longitude,
  timestamp, captured_by, file_size, created_at
) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?);

-- Insert folder-photo association (if folder save)
INSERT INTO folder_photos (
  folder_id, photo_id, before_after, added_at
) VALUES (?, ?, ?, ?);

COMMIT;
```

---

## Validation Summary

### Client Entity Validation
- ✅ Name uniqueness enforced by database unique index
- ✅ System clients (is_system = true) protected from user deletion/editing
- ✅ Global "Needs Assigned" client created on database initialization

### Photo Save Validation
- ✅ Storage space checked before save operation (FR-050)
- ✅ SaveContext validity checked (equipmentId/folderId present when required)
- ✅ Equipment/folder existence verified before save
- ✅ GPS coordinates within valid range (-90 to 90 lat, -180 to 180 long)
- ✅ File size <= 10MB per photo

### Sequential Naming Validation
- ✅ Date format always YYYY-MM-DD (ISO 8601)
- ✅ Sequential numbers increment correctly from existing max
- ✅ Name collision impossible (checked before insert)

### Referential Integrity
- ✅ Foreign key constraints enforced at database level
- ✅ Cascade delete: Deleting folder deletes folder_photos entries
- ✅ Orphan prevention: Photos always associated with valid equipment

---

## Performance Considerations

### Indexes for Quick Lookup
- `idx_clients_system`: Fast filtering of system clients
- `idx_photo_equipment`: Fast photo queries by equipment (existing)
- `idx_folder_photos_folder`: Fast folder photo queries (existing)

### Batch Operations
- Quick Save multi-photo: Use batch insert for photos and folder_photos
- Thumbnail generation: Background processing, doesn't block save

### Lazy Loading
- Equipment navigator: Load children only when parent node expanded
- Folder photos: Load only when folder opened (not for folder list view)

---

## Testing Data Model

### Unit Test Fixtures

**Global "Needs Assigned" Client**:
```dart
final testGlobalClient = Client(
  id: 'TEST_GLOBAL_NEEDS_ASSIGNED',
  name: 'Test Needs Assigned',
  isSystem: true,
  createdBy: 'TEST_USER',
  createdAt: DateTime(2025, 10, 13),
  isActive: true,
);
```

**Quick Save Item (Single Photo)**:
```dart
final testQuickSaveItem = QuickSaveItem(
  type: QuickSaveType.singlePhoto,
  name: 'Image - 2025-10-13',
  photoIds: ['photo-123'],
  folderId: null,
  createdAt: DateTime(2025, 10, 13, 14, 30),
);
```

**Save Context (Home)**:
```dart
final testHomeContext = SaveContext.home();
assert(testHomeContext.isValid());
```

**Save Result (Partial Success)**:
```dart
final testPartialResult = SaveResult.partial(
  successful: 9,
  failed: 1,
  savedIds: ['photo-1', 'photo-2', ..., 'photo-9'],
);
assert(testPartialResult.getUserMessage() == '9 of 10 photos saved');
```

---

## Migration Path

### For Existing Installations

1. **Run Migration 004**: Add is_system column to clients table
2. **Seed Global Client**: Insert GLOBAL_NEEDS_ASSIGNED client record
3. **Create Index**: Add idx_clients_system index
4. **Update Client Lists**: Filter `WHERE is_system = 0` in all client queries

### Backward Compatibility

- ✅ No breaking changes to existing models (Photo, PhotoFolder, FolderPhoto)
- ✅ Existing photos and folders remain accessible
- ✅ Client filtering change (is_system = 0) maintains existing UX

### Rollback Plan

If migration 004 needs rollback:
```sql
-- Remove global client
DELETE FROM clients WHERE id = 'GLOBAL_NEEDS_ASSIGNED';

-- Drop index
DROP INDEX IF EXISTS idx_clients_system;

-- Remove column (SQLite requires table recreation)
-- Use ALTER TABLE RENAME + CREATE + INSERT + DROP pattern
```

---

## Conclusion

Data model extends existing schema minimally (single column + special record) while enabling comprehensive save functionality. All entities validated, relationships defined, and performance optimized for offline-first field operation.
