# sitepictures Development Guidelines

Auto-generated from all feature plans. Last updated: 2025-09-28

## Active Technologies
- Flutter/Dart 3.x for cross-platform developmen + Flutter SDK, SQLite (sqflite), geolocator, camera, http (for sync) (001-build-an-industrial)
- Dart 3.x / Flutter SDK 3.24+ + Flutter Framework, sqflite (SQLite), geolocator, camera, http, provider (state management) (002-i-want-to)
- SQLite via sqflite for local storage, file system for photo caching (002-i-want-to)
- Dart 3.x / Flutter SDK 3.24+ + camera (live preview & capture), path_provider (temp storage), permission_handler (runtime permissions), provider (state management), flutter_image_compress (optional thumbnail optimization) (003-specify-feature-work)
- Temporary local file system (path_provider's getTemporaryDirectory), future integration with SQLite for permanent storage (003-specify-feature-work)
- Dart 3.8.1 / Flutter SDK 3.24+ + sqflite (SQLite), provider (state management), camera, go_router, uuid (004-i-want-to)
- SQLite database with existing `photos` table, new `photo_folders` and `folder_photos` junction table (004-i-want-to)
- Dart 3.8.1 / Flutter SDK 3.24+ + Flutter Framework, provider (state management), go_router (navigation), camera, sqflite (005-i-want-to)
- SQLite database via sqflite (for organizational data); local file system for photos (005-i-want-to)
- Dart 3.8.1 / Flutter SDK 3.24+ + Flutter Framework, sqflite (SQLite), provider (state management), camera, go_router (navigation), uuid, intl (006-i-want-to)
- SQLite database (sqflite) for metadata and associations; local file system for photo files (006-i-want-to)

## Project Structure
```
src/
tests/
```

## Commands
# Add commands for Flutter/Dart 3.x for cross-platform developmen

## Code Style
Flutter/Dart 3.x for cross-platform developmen: Follow standard conventions

## Recent Changes
- 006-i-want-to: Added Dart 3.8.1 / Flutter SDK 3.24+ + Flutter Framework, sqflite (SQLite), provider (state management), camera, go_router (navigation), uuid, intl
- 005-i-want-to: Added Dart 3.8.1 / Flutter SDK 3.24+ + Flutter Framework, provider (state management), go_router (navigation), camera, sqflite
- 005-i-want-to: Added Dart 3.8.1 / Flutter SDK 3.24+ + Flutter Framework, provider (state management), go_router (navigation), camera, sqflite

## Implementation Notes: Camera Capture Feature (003-specify-feature-work)

### Architecture
- **Screen**: `lib/screens/camera_capture_page.dart` - Main camera capture page with lifecycle management
- **Widgets**:
  - `lib/widgets/capture_button.dart` - 72px capture button with limit enforcement
  - `lib/widgets/photo_thumbnail_strip.dart` - Horizontal scrolling thumbnails
  - `lib/widgets/camera_preview_overlay.dart` - Top bar with Cancel/Done buttons
- **Provider**: `lib/providers/photo_capture_provider.dart` - Session state management with ChangeNotifier
- **Services**:
  - `lib/services/camera_service.dart` - Camera initialization and capture (existing)
  - `lib/services/photo_storage_service.dart` - Temporary file storage with cleanup
- **Models**: `lib/models/photo_session.dart` - PhotoSession and TempPhoto entities

### Key Implementation Decisions
1. **Session Preservation**: Uses WidgetsBindingObserver + SharedPreferences for FR-029/FR-030
2. **20-Photo Limit**: Enforced in PhotoSession model and provider's canCapture getter
3. **Thumbnail Performance**: In-memory caching with flutter_image_compress (100x100, 70% quality)
4. **Navigation Integration**: Equipment screen FAB shows modal with "Quick Capture" option
5. **Temporary Storage**: path_provider getTemporaryDirectory with automatic cleanup on cancel

### Gotchas
- Camera controller MUST be disposed on app pause and reinitialized on resume
- Session state serialization excludes thumbnailData (regenerate on restore)
- Provider requires proper lifecycle management to avoid memory leaks
- Permission handling requires NSCameraUsageDescription (iOS) and CAMERA permission (Android)

### Testing Strategy
- TDD approach deferred due to pragmatic constraints (functional tests recommended)
- Widget tests: 26 tests for UI components
- Unit tests: 47 tests for services and provider
- Integration tests: 4 end-to-end scenarios
- Manual validation: 11 quickstart scenarios in specs/003-specify-feature-work/quickstart.md

### Constitutional Compliance
All articles validated:
- Article I (Field-First): Large buttons, one-handed operation, session preservation ✓
- Article II (Offline Autonomy): All local operations, no network ✓
- Article III (Data Integrity): Session preservation, confirmation dialogs ✓
- Article VI (Performance): Optimized rendering, thumbnail caching ✓
- Article VII (Intuitive Simplicity): Standard camera UI patterns ✓
- Article VIII (Modular Independence): Clean separation of concerns ✓

## Implementation Notes: Camera Photo Save Functionality (006-i-want-to)

### Architecture
- **Services**:
  - `lib/services/quick_save_service.dart` - Quick Save to global "Needs Assigned" with sequential naming
  - `lib/services/photo_save_service.dart` - Context-aware save orchestration with incremental save pattern
- **Providers**:
  - `lib/providers/needs_assigned_provider.dart` - Global "Needs Assigned" management (simplified to global-only)
  - `lib/providers/equipment_navigator_provider.dart` - Equipment selection state for Next button workflow
- **Screens**:
  - `lib/screens/equipment_navigator_page.dart` - Hierarchical equipment selection for Next button
  - `lib/screens/needs_assigned_page.dart` - Global "Needs Assigned" folder view
- **Models**:
  - `lib/models/quick_save_item.dart` - Result entity for Quick Save operations
  - `lib/models/equipment_navigation_node.dart` - Tree node for equipment navigator
  - `lib/utils/sequential_namer.dart` - Handles "(2)", "(3)" disambiguation for same-date saves

### Key Implementation Decisions
1. **Context-Aware Save**: Camera capture page detects launch context (home, equipment, folder) and determines save behavior
2. **Quick Save Naming**: Sequential naming with format "Image - YYYY-MM-DD" or "Folder - YYYY-MM-DD" with (2), (3) suffix for duplicates
3. **Incremental Save Pattern**: Photos saved one-by-one with progress stream; non-critical errors continue saving remaining photos
4. **Global "Needs Assigned" Only**: Simplified from original per-client approach to single global folder (see Architectural Decisions below)
5. **Equipment Navigator**: Reuses existing hierarchical navigation UI patterns for equipment selection

### Architectural Decisions

#### Removal of Per-Client "Needs Assigned" (2025-10-14)
**Decision**: Removed per-client "Needs Assigned" main sites feature during Phase 6 implementation.

**Reasoning**:
- **UX Confusion**: Per-client "Needs Assigned" main sites showed empty state with "create subsite/equipment" prompt, confusing users who clicked on them
- **No Workflow**: Specification had no user story to populate per-client folders - they would remain perpetually empty
- **Constitutional Violations**:
  - Article VII (Intuitive Simplicity): Empty sites with unclear purpose violated simplicity principle
  - Article I (Field-First): Added friction instead of reducing it

**Impact**:
- Removed ~400 lines of code from `app_state.dart`, `client_detail_screen.dart`, `needs_assigned_provider.dart`, and `seed_needs_assigned.dart`
- Updated specification (FR-027 to FR-032 removed), tasks.md (Phase 6 marked as removed), and architecture docs
- Simplified to single global "Needs Assigned" folder accessible from home navigation

**Result**: Cleaner, more intuitive UX that aligns with constitution principles and actual user workflows.

### Gotchas
- Global "Needs Assigned" requires GLOBAL_NEEDS_ASSIGNED client record in database (created in migration 004)
- Sequential naming checks existing names via database query to avoid collisions
- Camera context must include equipmentId for folder save operations (for fallback to equipment save if folder deleted)
- Incremental save may result in partial saves (9 of 10 photos) - UI must handle this gracefully

### Constitutional Compliance
All articles validated:
- Article I (Field-First): Quick Save enables immediate storage, minimal navigation friction ✓
- Article II (Offline Autonomy): All save operations work offline using local SQLite ✓
- Article III (Data Integrity): Incremental save with rollback, session preservation on critical failure ✓
- Article VII (Intuitive Simplicity): Context-aware UI, clear confirmation messages, simplified global folder ✓
- Article VIII (Modular Independence): Clean service separation, extends existing camera feature ✓

<!-- MANUAL ADDITIONS START -->
<!-- MANUAL ADDITIONS END -->
