# Quickstart – Photo Import From Device Library

## Goal

Enable technicians to import multiple photos from the device gallery across home, All Photos, and equipment Before/After screens while preserving FieldPhoto Pro’s offline, hierarchical, and data integrity guarantees.

## Prerequisites

1. Install dependencies:
   ```bash
   flutter pub add photo_manager
   flutter pub add wechat_assets_picker
   ```
   (`wechat_assets_picker` is the UI layer recommended by `photo_manager` for multi-select.)
2. Confirm `permission_handler`, `sqflite`, `crypto`, and existing storage services are up to date.

## Implementation Steps (High-Level)

1. **Platform Permissions**
   - iOS: Update `ios/Runner/Info.plist` with `NSPhotoLibraryUsageDescription` and optional `NSPhotoLibraryAddUsageDescription`.
   - Android: Update `android/app/src/main/AndroidManifest.xml` with `READ_MEDIA_IMAGES` (API 33+) and `READ_EXTERNAL_STORAGE` (<= API 32).
   - Provide localized strings describing the need for gallery access.

2. **Permission Flow**
   - Show pre-permission sheet before calling `PhotoManager.requestPermissionExtend()`.
   - Handle `PermissionState.limited` by allowing user to continue with limited selection while offering “Manage Selection” shortcut.
   - On denial, surface modal with “Open Settings” action using `PhotoManager.openSetting()`.

3. **Import Service**
   - Implement `ImportService` contract:
     - Wrap `AssetPicker.pickAssets` to collect `GalleryAsset` metadata.
     - Sequentially copy each asset to app storage while computing SHA-1 fingerprint and storing `sourceAssetId`.
     - Insert `PhotoAsset` rows inside a transaction, linking to `ImportBatch`.
     - Emit `ImportProgress` updates for UI feedback.
     - Queue sync using existing background job infrastructure.

4. **Duplicate Handling**
   - Before copying, check `sourceAssetId` against the destination context (equipment/folder).
   - If duplicate, log to batch, present summary to user, and skip file copy.
   - Fallback to SHA-1 comparison when asset ID missing or changed.

5. **UI Integration**
   - Add Import buttons:
     - Home and All Photos pages: AppBar action with upload icon.
     - Equipment tabs: Tab-level action that opens modal to choose Before/After when needed.
   - Bind buttons to `ImportFlowProvider`. Display progress sheet with cancel/close options.
   - Reuse Needs Assigned move modal post-selection for home/All Photos context.

6. **Feedback & Logging**
   - On completion, show summary (“8 imported, 1 duplicate skipped, 0 failed”).
   - Log `gallery_import_logged` event for analytics (subject to consent).
   - Trigger provider refreshes (Needs Assigned, equipment photo grids, All Photos) to reflect imported images.

## Testing Checklist

- [ ] First-time permission request from home: approve access, import three photos, verify placement via move flow.
- [ ] Denied permission path: decline, receive guidance, open settings, retry without restarting app.
- [ ] Equipment Before tab: choose “Import to Before,” select photos, ensure they appear only in Before gallery.
- [ ] Duplicate detection: import same photo twice; ensure second attempt warns and logs duplicate.
- [ ] Large batch (20 photos): progress indicator updates smoothly, completion <30s.
- [ ] Offline mode: Disable network, run import, confirm success and queued sync entries.
- [ ] Permission limited mode (iOS): Select subset in OS dialog, verify limited selection works and UI offers “Manage Selection.”
- [ ] Failure handling: Force storage-full scenario (simulate) to ensure error messaging and partial success handling.
