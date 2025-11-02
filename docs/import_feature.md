# Import Feature Playbook

## Entry Points
- **Home screen** (`ImportEntryPoint.home`) — lets the user choose an equipment destination before importing.
- **All Photos screen** (`ImportEntryPoint.allPhotos`) — mirrors the home flow and keeps the global gallery fresh.
- **Equipment context**
  - General equipment gallery (`ImportEntryPoint.equipmentGeneral`)
  - Folder-level Before tab (`ImportEntryPoint.equipmentBefore`)
  - Folder-level After tab (`ImportEntryPoint.equipmentAfter`)

## Flow Summary
1. Import button triggers permission education sheet (`permission_education_sheet.dart`).
2. PhotoManager permissions requested; limited access presents OS-managed picker.
3. Asset selection via `AssetPicker`; duplicates filtered by `sourceAssetId`/SHA1.
4. Destination handling
   - Equipment destination picker mirrors the Needs Assigned move flow (select equipment, choose existing folder, or create a new one for Before/After).
   - Equipment Before/After import → targets the active folder tab (auto-provisioned system folders remain a fallback when no folder is provided).
5. Progress sheet displays stage updates, elapsed time, and logs analytics (`gallery_import_logged`).
6. Completion refreshes all impacted views (Needs Assigned, global All Photos, folder detail tabs).

## Permissions
- Pre-permission education clarifies intent.
- Denial dialog offers in-app "Open Settings" link and resumes gracefully.
- Limited access: `PhotoManager.presentLimited` shortcut accessible from picker.
- Every permission attempt logged via `permission_prompt_logged`.

## Analytics & Telemetry
- `gallery_import_logged`: batch + outcome metrics (duration, counts, error codes).
- `permission_prompt_logged`: records entry point, status, timestamp.
- Events buffered in `AnalyticsLogger.pendingEvents` for later batching.

## Performance Notes
- Import batches capture `startedAt`/`completedAt`; average per-photo time recorded.
- SHA-1 streaming avoids loading whole files; duplicates short-circuit quickly.
- Automatic folder provisioning ensures constant-time lookups for before/after routes.

## Testing Inventory
- Widget: home import button flow, before/after choice modals, progress sheet summary.
- Integration scaffolds: shared library import (manual), permission recovery (manual).
- Manual QA: Follow quickstart checklist after running `flutter pub get`, ensure iOS/Android builds succeed.

## Next Steps
- Run `integration_test/import_permission_recovery_test.dart` on device to verify denied→settings→resume.
- Monitor analytics payload backlog and forward to consent-aware sink when ready.
