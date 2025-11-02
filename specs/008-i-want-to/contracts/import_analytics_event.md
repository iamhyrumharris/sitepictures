# Analytics Contract: gallery_import_logged

## Event Name

`gallery_import_logged`

## Trigger

Emitted once per completed import batch (success or failure) after processing concludes and before user-facing confirmation is shown.

## Payload

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `batchId` | UUID | ✅ | Matches `ImportBatch.id` |
| `entryPoint` | String | ✅ | `home`, `all_photos`, `equipment_before`, `equipment_after`, `equipment_general` |
| `destination` | String | ✅ | Derived from `DestinationContext.type` |
| `permissionStatus` | String | ✅ | `granted`, `limited`, `denied`, `restricted` |
| `selectedCount` | Integer | ✅ | Total assets user confirmed |
| `importedCount` | Integer | ✅ | Successfully imported photos |
| `duplicateCount` | Integer | ✅ | Photos skipped due to duplicate detection |
| `failedCount` | Integer | ✅ | Photos that failed to import |
| `durationMs` | Integer | ✅ | Milliseconds from user confirmation to completion |
| `averageImportMs` | Integer | ✅ | Average per-photo processing time |
| `deviceFreeSpaceBytes` | Integer | ❌ | Snapshot taken at start, if available |
| `errorCodes` | Array\<String> | ❌ | Populated when failures occurred (e.g., `storage_full`, `permission_revoked`) |

## Constraints

- Event must be stored locally and batched for sync to honor Article V (no immediate telemetry without user consent).
- `durationMs` and `averageImportMs` used to validate Success Criteria SC-001 and SC-002.
- When consent is disabled, keep the event locally for diagnostics only; do not transmit externally.
