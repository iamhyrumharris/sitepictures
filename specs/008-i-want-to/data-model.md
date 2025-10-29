# Data Model – Photo Import From Device Library

## Entities

### PhotoAsset (existing – extended)

| Field | Type | Notes |
|-------|------|-------|
| `id` | UUID | Primary key (existing) |
| `equipmentId` | UUID | References `Equipment.id`; nullable when staged in Needs Assigned |
| `folderId` | UUID? | References `PhotoFolder.id` when categorized |
| `beforeAfter` | Enum(`before`,`after`,`general`) | Categorization when folderId present |
| `filePath` | String | Absolute path to locally stored photo |
| `thumbnailPath` | String | Cached thumbnail path |
| `capturedAt` | DateTime | Original capture timestamp (preserved from asset metadata) |
| `uploadedAt` | DateTime? | Populated when sync completes |
| `sourceAssetId` | String? | ***New***: Persistent ID from `photo_manager` asset, used for duplicate detection |
| `fingerprintSha1` | String? | ***New***: SHA-1 hash fallback for duplicate detection |
| `importSource` | Enum(`camera`,`gallery`) | ***New***: Distinguish capture origins for analytics |
| `importBatchId` | UUID? | ***New***: Associates photo with `ImportBatch` record |
| `status` | Enum(`pending`,`synced`,`failed`) | Existing sync status |
| `createdAt` | DateTime | Local creation timestamp |
| `updatedAt` | DateTime | Last modified timestamp |

**Validation & Rules**
- `sourceAssetId` must be unique per `equipmentId` + `folderId` combination to prevent duplicates.
- When `fingerprintSha1` exists, enforce uniqueness within same destination context.
- `importSource` defaults to `camera` if not provided; set to `gallery` for imports.
- Maintain immutability of original `capturedAt` and `filePath`; updates create new versions if needed.

### ImportBatch (new)

| Field | Type | Notes |
|-------|------|-------|
| `id` | UUID | Primary key |
| `entryPoint` | Enum(`home`,`all_photos`,`equipment_before`,`equipment_after`,`equipment_general`) |
| `equipmentId` | UUID? | Target equipment (null when staged in Needs Assigned) |
| `folderId` | UUID? | Destination folder when applicable |
| `destinationCategory` | Enum(`before`,`after`,`general`,`needs_assigned`) |
| `selectedCount` | int | Total assets user selected |
| `importedCount` | int | Successfully imported photos |
| `duplicateCount` | int | Photos skipped due to duplicates |
| `failedCount` | int | Photos that failed to import |
| `startedAt` | DateTime | Timestamp when user confirmed import |
| `completedAt` | DateTime? | Null until processing finishes |
| `permissionState` | Enum(`granted`,`limited`,`denied`,`restricted`) | Status at import time |
| `deviceFreeSpaceBytes` | int? | Optional snapshot for diagnostics |

**Relationships**
- `ImportBatch` 1→N `PhotoAsset` via `importBatchId`.
- Batches cascade delete only when all associated photos are removed (preserve audit integrity).

### DestinationContext (existing abstractions clarified)

| Field | Type | Notes |
|-------|------|-------|
| `type` | Enum(`needs_assigned`,`equipment_general`,`equipment_before`,`equipment_after`) |
| `clientId` | UUID | For hierarchy breadcrumb |
| `mainSiteId` | UUID | Hierarchy level 2 |
| `subSiteId` | UUID | Hierarchy level 3 |
| `equipmentId` | UUID | Required unless `type == needs_assigned` |
| `folderId` | UUID? | Present for Before/After destinations |
| `label` | String | User-facing summary (“Client › Site › Equipment”) |

**Rules**
- Destination context is resolved prior to import and remains immutable through batch processing.
- When `type == needs_assigned`, only `clientId` referencing global Needs Assigned client is required.
- Before/After imports require `folderId` and `type` alignment; validation occurs before copying files.

## Supporting Structures

### Duplicate Registry (new table)

| Field | Type | Notes |
|-------|------|-------|
| `photoId` | UUID | FK to `PhotoAsset.id` |
| `sourceAssetId` | String | Asset identifier from gallery |
| `fingerprintSha1` | String | Hash fallback |
| `importedAt` | DateTime | Timestamp of import |

Used to audit duplicate handling decisions. Enables analytics on how often duplicates occur and supports Article IX transparency.

### PermissionAudit (optional log)

| Field | Type | Notes |
|-------|------|-------|
| `id` | UUID | Primary key |
| `status` | Enum(`prompted`,`granted`,`limited`,`denied`,`restricted`) |
| `entryPoint` | Enum (same as ImportBatch.entryPoint) |
| `timestamp` | DateTime | Event time |

Helps monitor permission denial patterns for UX improvements.

## State Transitions

1. **Selected** → `ImportBatch` created with `selectedCount`.
2. For each asset:
   - **Validated** (duplicate check). If duplicate → increment `duplicateCount`, skip file copy.
   - **Copying**: File stream writes to app storage; upon success create `PhotoAsset` linked to batch.
   - **Failed**: Errors recorded (IO, permission revoked mid-flow) → increment `failedCount`.
   - **Completed**: On success, queue sync job and update `importedCount`.
3. Batch `completedAt` set when all assets processed; status summary presented to user.

## Data Integrity Considerations

- Wrap per-photo operations in SQLite transactions to ensure metadata and file path updates stay in sync.
- Maintain local backups of files until sync confirmation; use existing storage safeguards from camera workflow.
- Retry queue references `ImportBatch` ID for resumability if app closes mid-import.
