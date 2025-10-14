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
- 005-i-want-to: Added Dart 3.8.1 / Flutter SDK 3.24+ + Flutter Framework, provider (state management), go_router (navigation), camera, sqflite
- 005-i-want-to: Added Dart 3.8.1 / Flutter SDK 3.24+ + Flutter Framework, provider (state management), go_router (navigation), camera, sqflite
- 004-i-want-to: Added Dart 3.8.1 / Flutter SDK 3.24+ + sqflite (SQLite), provider (state management), camera, go_router, uuid

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

<!-- MANUAL ADDITIONS START -->
<!-- MANUAL ADDITIONS END -->
