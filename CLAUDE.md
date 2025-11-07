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

## Serverpod Backend Architecture (2025-11-06)

### Overview
Integrated Serverpod 2.9.2 as the backend for the sitepictures Flutter application. The backend provides type-safe REST API endpoints, PostgreSQL database, Redis caching, and file storage for photos.

### Project Structure
```
sitepictures_server/
├── sitepictures_server_server/      # Backend server
│   ├── lib/src/
│   │   ├── models/                  # Protocol definitions (YAML)
│   │   ├── generated/               # Auto-generated Dart code
│   │   └── endpoints/               # API endpoints
│   ├── docker-compose.yaml          # PostgreSQL + Redis
│   └── migrations/                  # Database migrations
├── sitepictures_server_client/      # Generated Dart client for Flutter
└── sitepictures_server_flutter/     # Sample app (not used)
```

### Data Models

All models use a dual-ID strategy for compatibility:
- **Database ID**: Auto-increment `int?` for Serverpod operations
- **UUID Field**: `String uuid` for compatibility with Flutter app's SQLite schema

**Models:**
- `User` - Authentication and user management
- `Company` (renamed from Client) - Client/company management
- `MainSite` - Main site/location with GPS coordinates
- `SubSite` - Sub-site with flexible hierarchy (client, main site, or nested)
- `Equipment` - Equipment with flexible placement
- `Photo` - Photo metadata with sync status and file storage integration
- `PhotoFolder` - Photo organization
- `FolderPhoto` - Junction table for folder-photo relationships
- `SyncQueueItem` - Offline sync queue
- `ImportBatch` - Gallery import tracking

### API Endpoints

**AuthEndpoint** (`lib/src/endpoints/auth_endpoint.dart`):
- `login(email, password)` - User authentication
- `register(email, name, password, role)` - User registration
- `getCurrentUser(uuid)` - Get user by UUID
- `logout()` - Logout placeholder

**CompanyEndpoint** (`lib/src/endpoints/company_endpoint.dart`):
- `getAllCompanies(includeSystem)` - List all companies
- `getCompanyByUuid(uuid)` - Get single company
- `createCompany(name, description, createdBy)` - Create new company
- `updateCompany(uuid, name, description)` - Update company
- `deleteCompany(uuid)` - Soft delete company

**SiteEndpoint** (`lib/src/endpoints/site_endpoint.dart`):
- **MainSite**: `getMainSitesByCompany`, `createMainSite`, `updateMainSite`, `deleteMainSite`
- **SubSite**: `getSubSitesByParent`, `createSubSite`, `updateSubSite`, `deleteSubSite`

**EquipmentEndpoint** (`lib/src/endpoints/equipment_endpoint.dart`):
- `getEquipmentByParent(clientId/mainSiteId/subSiteId)` - List equipment
- `createEquipment(...)` - Create equipment with flexible hierarchy
- `updateEquipment`, `deleteEquipment`

**PhotoEndpoint** (`lib/src/endpoints/photo_endpoint.dart`):
- `getPhotosByEquipment(equipmentId, limit, offset)` - Paginated photo list
- `uploadPhoto(equipmentId, fileData, metadata)` - Upload photo with Serverpod storage
- `createPhoto(...)` - Create photo metadata only
- `getUnsyncedPhotos()` - Get photos needing sync
- `markPhotoAsSynced(uuid)` - Mark as synced
- `deletePhoto(uuid)` - Delete photo and file
- `getPhotoUrl(uuid)` - Get temporary download URL

**FolderEndpoint** (`lib/src/endpoints/folder_endpoint.dart`):
- `getFoldersByEquipment(equipmentId)` - List folders
- `createFolder(equipmentId, name, workOrder, createdBy)` - Create folder
- `addPhotoToFolder(folderId, photoId, beforeAfter)` - Add photo
- `getPhotosInFolder(folderId, beforeAfterFilter)` - Get folder photos
- `removePhotoFromFolder`, `deleteFolder`

**SyncEndpoint** (`lib/src/endpoints/sync_endpoint.dart`):
- `getChangesSince(timestamp)` - Pull changes from server
- `pushChanges(changes)` - Push local changes with conflict resolution
- Implements last-write-wins strategy for conflicts

### File Storage

Photos are stored using Serverpod's built-in cloud storage:
- **Storage ID**: `public`
- **Path Format**: `photos/{equipmentId}/{uuid}/{filename}`
- **Features**:
  - Automatic file management
  - Temporary URL generation for downloads
  - File deletion on photo removal

### Database Configuration

**Development** (docker-compose.yaml):
- PostgreSQL: `localhost:8090`
- Redis: `localhost:8091`
- Database: `sitepictures_server`

**Migrations**: Two migrations created
1. `20251106193441725` - Serverpod system tables
2. `20251106195139239` - Application tables (users, clients, photos, etc.)

### Key Design Decisions

1. **Client → Company Rename**: Avoided Serverpod reserved name conflict
2. **Dual-ID Strategy**: Maintains compatibility with existing Flutter SQLite schema
3. **Index Prefixing**: All indexes prefixed with model name (e.g., `user_email_idx`)
4. **File Storage**: Uses Serverpod's built-in storage (can upgrade to S3 later)
5. **Conflict Resolution**: Last-write-wins based on `updatedAt` timestamps
6. **Soft Deletes**: All main entities use `isActive` flag instead of hard deletes

### Next Steps for Integration

1. **Update Flutter App**:
   - Add `serverpod_flutter` dependency to `pubspec.yaml`
   - Replace `ApiService` with Serverpod client
   - Update `SyncService` to use new sync endpoints
   - Keep SQLite for offline storage

2. **Start Server**:
   ```bash
   cd sitepictures_server/sitepictures_server_server
   docker compose up -d
   dart bin/main.dart --apply-migrations
   dart bin/main.dart
   ```

3. **Testing**: Create integration tests for sync flow

### Documentation
- Server README: `sitepictures_server/README.md`
- Serverpod Docs: https://docs.serverpod.dev/

<!-- MANUAL ADDITIONS END -->
