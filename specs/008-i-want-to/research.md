# Phase 0 Research – Photo Import From Device Library

## R0.1 – Gallery Import Plugin Selection

- **Decision**: Adopt `photo_manager` for accessing the device photo library with multi-select support.
- **Rationale**: `photo_manager` surfaces the native asset catalog with persistent `AssetEntity` IDs, granular permission handling (including iOS limited access), metadata access (creation time, width, height, file size), and batch selection through `AssetPicker`. It operates fully offline once assets are cached locally and avoids the 10-image soft limit present in `image_picker`. It also provides deferred file access to prevent loading all bytes into memory at once.
- **Alternatives considered**:
  - `image_picker`: Simple API but limited metadata, inconsistent multi-select UX across platforms, and no direct access to original file identifiers—making duplicate detection unreliable.
  - `file_picker`: Broad file access but lacks gallery-focused UX, provides minimal metadata, and requires additional platform setup without offering permission dialogs tailored to photos.

## R0.2 – Permission UX Best Practices

- **Decision**: Use a pre-permission educational sheet before invoking `PhotoManager.requestPermissionExtend()`; on denial, present an in-app dialog with a direct link to settings using `PhotoManager.openSetting()` and surface retry within the import flow.
- **Rationale**: Aligns with Article VII by setting expectations before the OS prompt, gives context for why photo access matters, and leverages `photo_manager`’s permission helpers that differentiate between `authorized`, `limited`, and `denied` states. This approach mirrors Apple and Google design guidance and keeps the user within the import flow when they return from settings.
- **Alternatives considered**:
  - Rely solely on the OS dialog: Fast to implement but fails Article I (confusing for field workers) and Article V (lack of transparency).
  - Using `permission_handler` only: Would require duplicating logic for limited access handling on iOS 14+, whereas `photo_manager` already wraps platform nuances.

## R0.3 – Duplicate Detection Strategy

- **Decision**: Store the source `AssetEntity.id` alongside imported photos and maintain a lightweight SHA-1 fingerprint for fallback comparison; treat a photo as duplicate within the same batch if either the asset ID or fingerprint already exists in the target context.
- **Rationale**: `AssetEntity.id` is stable across sessions for the same media item, enabling O(1) duplicate checks without reading file bytes. SHA-1 (available via the existing `crypto` package) covers edge cases where the asset ID changes (e.g., edited copies) while remaining performant for 1–20 photo batches. This hybrid approach preserves Article III by preventing silent duplicate storage while remaining performant.
- **Alternatives considered**:
  - Hash-only (MD5/SHA) approach: Guarantees correctness but requires full file reads for every check, risking performance regressions on large imports.
  - Metadata heuristic (size + timestamp): Lightweight but prone to false positives when devices adjust timestamps or compress copies.

## R0.4 – Large Batch Import Performance

- **Decision**: Process imports sequentially with an async queue limited to two concurrent file copy operations, streaming bytes directly to the app’s storage path and yielding to the event loop between items. Fetch thumbnails only for UI previews and defer heavy work (compression, sync enqueue) to background isolates after the main copy completes.
- **Rationale**: Keeps memory footprint low (<100MB) even for 50-photo stress tests, avoids blocking the UI thread, and allows progress feedback per photo. Leveraging sequential/low-concurrency processing ensures compliance with Article VI and preserves battery life.
- **Alternatives considered**:
  - Fully concurrent (import all photos in parallel): Faster in theory but risks memory spikes and file descriptor exhaustion on low-end devices.
  - Strict single-threaded blocking copy: Safe but causes perceptible pauses with high-resolution images; interleaving async gaps keeps UI responsive.
