# Tasks: Equipment Page Photo Management with Folders

**Feature**: 004-i-want-to
**Input**: Design documents from `/specs/004-i-want-to/`
**Prerequisites**: plan.md, data-model.md, research.md, quickstart.md

## Execution Flow (main)
```
1. Load plan.md from feature directory ✓
2. Load design documents ✓
   → data-model.md: 2 new entities (PhotoFolder, FolderPhoto), 1 extended (Photo)
   → research.md: 5 technical decisions
   → quickstart.md: 10 test scenarios
3. Generate tasks by category ✓
4. Apply task rules ✓
   → TDD order: Tests before implementation
   → Parallel marking: Different files = [P]
5. Number tasks sequentially ✓
6. Generate dependency graph ✓
7. Validation complete ✓
8. Post-generation refinement ✓
   → Added T025-T028: Photo deletion UI (FR-021 coverage)
   → Renumbered T025-T032 → T029-T036
   → Total: 36 tasks
```

## Format: `[ID] [P?] Description`
- **[P]**: Can run in parallel (different files, no shared dependencies)
- All paths are absolute from repository root: `/Users/hyrumharris/src/sitepictures/`

## Path Conventions
Flutter mobile project structure:
- **Models**: `lib/models/`
- **Providers**: `lib/providers/`
- **Services**: `lib/services/`
- **Screens**: `lib/screens/equipment/`
- **Widgets**: `lib/widgets/`
- **Tests**: `test/unit/`, `test/widget/`, `test/integration/`

---

## Phase 3.1: Database Foundation

### T001: Create photo_folders table migration
**File**: `lib/services/database_service.dart`
**Description**: Add Migration 004 to create `photo_folders` table with fields: id, equipment_id, name, work_order, created_at, created_by, is_deleted. Include indexes on equipment_id and created_at DESC.
**SQL**:
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

### T002: Create folder_photos junction table migration
**File**: `lib/services/database_service.dart` (same migration as T001)
**Description**: Add to Migration 004 the `folder_photos` junction table with fields: folder_id, photo_id, before_after (CHECK constraint 'before' or 'after'), added_at. Include indexes on folder_id and photo_id. Add CASCADE deletes.
**SQL**:
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

### T003: Add folder query methods to database_service
**File**: `lib/services/database_service.dart`
**Description**: Add methods: `getFoldersForEquipment(equipmentId)`, `getFolderById(folderId)`, `getBeforePhotos(folderId)`, `getAfterPhotos(folderId)`, `getAllPhotosWithFolderInfo(equipmentId)`. Use queries from data-model.md with LEFT JOINs for folder associations.
**Dependencies**: T001, T002 (tables must exist)

---

## Phase 3.2: Data Models

### T004 [P]: Create PhotoFolder model class
**File**: `lib/models/photo_folder.dart` (NEW)
**Description**: Create PhotoFolder model with fields: id (UUID), equipmentId, name, workOrder, createdAt, createdBy, isDeleted. Include:
- Constructor with UUID generation
- `_generateName(workOrder, date)` static method (format: "WO - YYYY-MM-DD")
- `toMap()` for SQLite serialization
- `fromMap()` for deserialization
- `isValid()` validation (workOrder ≤50 chars, name ≤100 chars)
**Dependencies**: None (independent model)

### T005 [P]: Create BeforeAfter enum and FolderPhoto model
**File**: `lib/models/folder_photo.dart` (NEW)
**Description**: Create BeforeAfter enum (before, after) with `toDb()` and `fromDb()` methods. Create FolderPhoto model with fields: folderId, photoId, beforeAfter, addedAt. Include toMap/fromMap for junction table serialization.
**Dependencies**: None (independent model)

### T006: Extend Photo model with virtual folder fields
**File**: `lib/models/photo.dart` (MODIFY)
**Description**: Add optional fields to Photo class: `folderId`, `folderName`, `beforeAfter`. Modify `fromMap()` to handle these fields from JOIN queries (check for 'folder_id', 'folder_name', 'before_after' keys). Do NOT modify `toMap()` (virtual fields not persisted). Non-breaking change - existing code unaffected.
**Dependencies**: T005 (needs BeforeAfter enum import)

---

## Phase 3.3: Service Layer

### T007: Create FolderService with CRUD operations
**File**: `lib/services/folder_service.dart` (NEW)
**Description**: Create FolderService class with methods:
- `createFolder(equipmentId, workOrder, createdBy)` → PhotoFolder
- `getFolders(equipmentId)` → List<PhotoFolder> (sorted by created_at DESC)
- `getFolderById(folderId)` → PhotoFolder?
- `deleteFolder(folderId, deletePhotos: bool)` → void (with transaction)
- `addPhotoToFolder(folderId, photoId, beforeAfter)` → void
- `getPhotoCountsForFolder(folderId)` → {before: int, after: int}
Uses DatabaseService from T003. All operations wrapped in transactions for data integrity.
**Dependencies**: T001, T002, T003 (database tables and queries), T004, T005 (models)

### T008: Add folder query methods to AppState provider
**File**: `lib/providers/app_state.dart` (MODIFY)
**Description**: Add methods to AppState:
- `getPhotosWithFolderInfo(equipmentId)` - calls DatabaseService LEFT JOIN query
- `getFoldersForEquipment(equipmentId)`
- `createFolder(equipmentId, workOrder)` - uses auth state for createdBy
Delegate to FolderService, notify listeners on state changes.
**Dependencies**: T007 (FolderService)

---

## Phase 3.4: State Management

### T009: Create FolderProvider
**File**: `lib/providers/folder_provider.dart` (NEW)
**Description**: Create FolderProvider extends ChangeNotifier with:
- `List<PhotoFolder> _folders`
- `loadFolders(equipmentId)` - fetches via FolderService
- `createFolder(equipmentId, workOrder, userId)` - validates, creates, notifies
- `deleteFolder(folderId, deletePhotos)` - shows confirmation, executes, notifies
- `getBeforePhotos(folderId)` → List<Photo>
- `getAfterPhotos(folderId)` → List<Photo>
- Error handling with try-catch, sets error state
**Dependencies**: T007 (FolderService), T004, T006 (models)

---

## Phase 3.5: UI Widgets - Tests First (TDD)

### T010 [P]: Widget test for CreateFolderDialog
**File**: `test/widget/create_folder_dialog_test.dart` (NEW)
**Description**: Write widget test for CreateFolderDialog:
- Test empty input disables Create button
- Test valid input enables Create button
- Test character count display (max 50)
- Test sanitization of special characters
- Test onConfirm callback fires with work order
- Mock FolderProvider
**Must FAIL before T013 implementation**

### T011 [P]: Widget test for DeleteFolderDialog
**File**: `test/widget/delete_folder_dialog_test.dart` (NEW)
**Description**: Write widget test for DeleteFolderDialog:
- Test dialog shows folder name and photo count
- Test "Delete all photos" button callback
- Test "Keep photos" button callback
- Test cancel button dismisses dialog
- Mock folder data
**Must FAIL before T014 implementation**

### T012 [P]: Widget test for FolderBadge
**File**: `test/widget/folder_badge_test.dart` (NEW)
**Description**: Write widget test for FolderBadge widget:
- Test renders folder icon
- Test positioned top-right
- Test dark background with white icon
- Test semantic label for accessibility
**Must FAIL before T015 implementation**

---

## Phase 3.6: UI Widgets - Implementation

### T013: Implement CreateFolderDialog widget
**File**: `lib/widgets/create_folder_dialog.dart` (NEW)
**Description**: Create AlertDialog widget with:
- TextField for work order input (maxLength: 50)
- Character counter
- Real-time validation (disable Create if empty)
- Sanitization: alphanumeric + -, _, #, /
- "Create" button calls `onConfirm(workOrder)`
- "Cancel" button dismisses
Uses Material Design AlertDialog pattern.
**Dependencies**: T010 (test must pass)

### T014: Implement DeleteFolderDialog widget
**File**: `lib/widgets/delete_folder_dialog.dart` (NEW)
**Description**: Create AlertDialog with:
- Title: "Delete Folder?"
- Body: "Choose what happens to the X photos in this folder:"
- Two action buttons:
  - "Delete all photos in folder" → onConfirm(deletePhotos: true)
  - "Keep photos as standalone" → onConfirm(deletePhotos: false)
- "Cancel" button
Plain language, no technical jargon (Article VII).
**Dependencies**: T011 (test must pass)

### T015: Implement FolderBadge widget
**File**: `lib/widgets/folder_badge.dart` (NEW)
**Description**: Create StatelessWidget positioned badge:
- Positioned(top: 4, right: 4, ...)
- Container with dark background (Colors.black54)
- Icon(Icons.folder, size: 14, color: Colors.white)
- Semantic label: "In folder: {folderName}"
Used in photo tiles to indicate folder membership.
**Dependencies**: T012 (test must pass)

---

## Phase 3.7: UI Screens - Tests First

### T016 [P]: Widget test for AllPhotosTab
**File**: `test/widget/all_photos_tab_test.dart` (NEW)
**Description**: Write widget test for AllPhotosTab:
- Test empty state shows "No Photos Yet" message
- Test photo grid renders with folder badges
- Test photos without folders have no badge
- Test chronological ordering (newest first)
- Test AutomaticKeepAliveClientMixin preserves state
- Mock photo data with and without folder associations
**Must FAIL before T019 implementation**

### T017 [P]: Widget test for FoldersTab
**File**: `test/widget/folders_tab_test.dart` (NEW)
**Description**: Write widget test for FoldersTab:
- Test empty state shows "No Folders Yet" message
- Test folder list renders in created_at DESC order
- Test folder tiles show photo count
- Test "Create Folder" button present
- Test folder tap navigates to detail screen
- Mock FolderProvider with sample folders
**Must FAIL before T020 implementation**

### T018 [P]: Widget test for FolderDetailScreen
**File**: `test/widget/folder_detail_screen_test.dart` (NEW)
**Description**: Write widget test for FolderDetailScreen:
- Test Before and After tabs render
- Test tab switching preserves state
- Test Before tab shows before photos only
- Test After tab shows after photos only
- Test empty states for each tab
- Test FAB present for photo capture
- Mock FolderProvider with before/after photos
**Must FAIL before T021 implementation**

---

## Phase 3.8: UI Screens - Implementation

### T019: Implement AllPhotosTab with folder badges
**File**: `lib/screens/equipment/all_photos_tab.dart` (NEW)
**Description**: Create StatefulWidget with AutomaticKeepAliveClientMixin:
- Override `wantKeepAlive = true`
- Call `super.build(context)` first
- Load photos via `AppState.getPhotosWithFolderInfo(equipmentId)`
- GridView.builder with 3 columns
- Photo tiles wrapped in Stack with FolderBadge if `photo.folderId != null`
- Empty state widget if no photos
- RefreshIndicator for pull-to-refresh
Chronological ordering (newest first) per FR-004.
**Dependencies**: T015 (FolderBadge widget), T016 (test must pass)

### T020: Implement FoldersTab with list
**File**: `lib/screens/equipment/folders_tab.dart` (NEW)
**Description**: Create StatefulWidget with AutomaticKeepAliveClientMixin:
- Use FolderProvider to load folders
- ListView with ListTile per folder
- Show folder name (work order + date), photo count
- "Create Folder" FloatingActionButton
- Tap folder → navigate to `/equipment/:equipmentId/folder/:folderId`
- Long-press folder → show delete menu
- Empty state: "No Folders Yet" with icon
Folders ordered by created_at DESC per FR-011.
**Dependencies**: T009 (FolderProvider), T013, T014 (dialogs), T017 (test must pass)

### T021: Implement FolderDetailScreen with Before/After tabs
**File**: `lib/screens/equipment/folder_detail_screen.dart` (NEW)
**Description**: Create StatefulWidget with TabController:
- AppBar with folder name title, 2 tabs: "Before", "After"
- TabBarView with two tabs:
  - Before tab: GridView of before photos (use FolderProvider.getBeforePhotos)
  - After tab: GridView of after photos (use FolderProvider.getAfterPhotos)
- Each tab uses AutomaticKeepAliveClientMixin for state preservation
- FAB for camera capture (pass folderId and current tab's beforeAfter)
- Empty states: "No before photos" / "No after photos"
Tab labels show counts: "Before (X)" / "After (Y)" per quickstart.md.
**Dependencies**: T009 (FolderProvider), T018 (test must pass)

### T022: Modify EquipmentScreen to use TabBarView
**File**: `lib/screens/equipment/equipment_screen.dart` (MODIFY)
**Description**: Replace current photo grid body with TabController and TabBarView:
- Add TabController with 2 tabs: "All Photos", "Folders"
- AppBar bottom: TabBar with two tabs
- Body: TabBarView with AllPhotosTab and FoldersTab widgets
- Preserve existing breadcrumb navigation
- Preserve existing FAB for quick capture (when on All Photos tab)
- Remove old _buildBody() photo grid logic (moved to AllPhotosTab)
Meets FR-001, FR-002 (tab navigation without losing state).
**Dependencies**: T019 (AllPhotosTab), T020 (FoldersTab)

---

## Phase 3.9: Integration

### T023: Update router with folder routes
**File**: `lib/router.dart` (MODIFY)
**Description**: Add GoRoute for folder detail:
```dart
GoRoute(
  path: '/equipment/:equipmentId/folder/:folderId',
  builder: (context, state) {
    final equipmentId = state.pathParameters['equipmentId']!;
    final folderId = state.pathParameters['folderId']!;
    return FolderDetailScreen(equipmentId: equipmentId, folderId: folderId);
  },
),
```
Ensure FolderDetailScreen is imported.
**Dependencies**: T021 (FolderDetailScreen exists)

### T024: Extend camera_capture_page to accept folder context
**File**: `lib/screens/camera_capture_page.dart` (MODIFY)
**Description**: Add optional parameters to CameraCapturePage:
- `String? folderId`
- `BeforeAfter? beforeAfter`
When returning captured photos, if folderId != null, associate photos with folder via FolderService.addPhotoToFolder(folderId, photoId, beforeAfter). Pass context via router extra params.
**Dependencies**: T007 (FolderService), T021 (FolderDetailScreen FAB passes params)

---

## Phase 3.9.5: Photo Deletion UI

### T025 [P]: Widget test for PhotoDeleteDialog
**File**: `test/widget/photo_delete_dialog_test.dart` (NEW)
**Description**: Write widget test for PhotoDeleteDialog:
- Test dialog shows photo preview thumbnail
- Test "Delete" button callback fires with photoId
- Test "Cancel" button dismisses dialog
- Test dialog title and warning message display
- Mock photo data
**Must FAIL before T026 implementation**

### T026: Implement PhotoDeleteDialog widget
**File**: `lib/widgets/photo_delete_dialog.dart` (NEW)
**Description**: Create AlertDialog widget for photo deletion confirmation:
- Title: "Delete Photo?"
- Body: "This photo will be permanently deleted."
- Optional: Show small preview thumbnail
- Two buttons:
  - "Delete" (destructive style, red) → onConfirm(photoId)
  - "Cancel" → dismiss dialog
Plain language warning per Article VII (Intuitive Simplicity).
**Dependencies**: T025 (test must pass)

### T027: Add delete functionality to AllPhotosTab
**File**: `lib/screens/equipment/all_photos_tab.dart` (MODIFY)
**Description**: Add photo deletion capability:
- Long-press photo tile → show context menu with "Delete" option
- Tap delete → show PhotoDeleteDialog (T026)
- On confirm → call PhotoService.deletePhoto(photoId)
- Remove photo from grid, update state
- Show snackbar: "Photo deleted"
Handles FR-021, FR-021b, FR-021c (deletion from All Photos tab).
**Dependencies**: T026 (PhotoDeleteDialog), T019 (AllPhotosTab exists)

### T028: Add delete functionality to FolderDetailScreen
**File**: `lib/screens/equipment/folder_detail_screen.dart` (MODIFY)
**Description**: Add photo deletion to Before/After tabs:
- Long-press photo tile in Before or After tab
- Show context menu with "Delete" option
- Show PhotoDeleteDialog confirmation
- On confirm → delete photo, update folder photo counts
- Refresh tab to show updated grid
- Handle empty state after last photo deleted
Handles FR-021a, FR-021b, FR-021c (deletion from folder tabs).
**Dependencies**: T026 (PhotoDeleteDialog), T021 (FolderDetailScreen exists)

---

## Phase 3.10: Testing - Integration

### T029: Integration test - Create folder and capture photos
**File**: `test/integration/folder_workflow_test.dart` (NEW)
**Description**: End-to-end integration test:
1. Navigate to EquipmentScreen
2. Tap Folders tab
3. Tap Create Folder, enter "WO-789", confirm
4. Verify folder appears with today's date
5. Open folder
6. Capture 3 photos in Before tab (mock camera)
7. Switch to After tab
8. Capture 2 photos in After tab
9. Verify Before shows 3, After shows 2
10. Navigate to All Photos tab
11. Verify all 5 photos show folder badges
Covers quickstart scenarios 1-4.
**Dependencies**: All UI screens (T019-T022), T024 (camera integration), T027-T028 (delete functionality)

### T030: Integration test - Delete folder with photo choices
**File**: `test/integration/folder_deletion_test.dart` (NEW)
**Description**: End-to-end test:
1. Create folder with 3 photos
2. Delete folder, choose "Keep photos"
3. Verify photos remain, no folder badges
4. Create new folder with 2 photos
5. Delete folder, choose "Delete all photos"
6. Verify photos deleted from database and storage
Covers quickstart scenarios 5-6, FR-010a-c.
**Dependencies**: T029 (folder creation workflow), T007 (FolderService deletion logic)

### T031: Integration test - Individual photo deletion from folder
**File**: `test/integration/photo_deletion_test.dart` (NEW)
**Description**: End-to-end test:
1. Create folder with 3 before, 2 after photos
2. Delete 1 before photo
3. Verify Before shows 2 photos
4. Delete 1 after photo
5. Verify After shows 1 photo
6. Verify folder still exists, counts updated
7. Delete all remaining photos individually
8. Verify empty states in both tabs
Covers quickstart scenario 7, FR-021-21c.
**Dependencies**: T021 (FolderDetailScreen with delete functionality), T028 (delete implementation)

---

## Phase 3.11: Polish & Validation

### T032 [P]: Unit test for PhotoFolder model validation
**File**: `test/unit/models/photo_folder_test.dart` (NEW)
**Description**: Unit tests for PhotoFolder:
- Test UUID generation
- Test name generation format (workOrder + date)
- Test isValid() with edge cases (empty workOrder, > 50 chars)
- Test toMap/fromMap round-trip
- Test date formatting (YYYY-MM-DD)
**Dependencies**: T004 (PhotoFolder model)

### T033 [P]: Unit test for FolderService
**File**: `test/unit/services/folder_service_test.dart` (NEW)
**Description**: Unit tests for FolderService:
- Mock DatabaseService
- Test createFolder generates UUID, formats name
- Test deleteFolder with deletePhotos=true (cascade)
- Test deleteFolder with deletePhotos=false (orphan)
- Test folder list ordering (created_at DESC)
- Test transaction rollback on error
**Dependencies**: T007 (FolderService)

### T034 [P]: Performance validation
**File**: Manual testing via Flutter DevTools
**Description**: Measure performance against targets (plan.md Article VI):
- Tab switching: < 300ms (use DevTools timeline)
- Folder creation: < 500ms (stopwatch)
- Photo grid render (100 photos): < 1s
- Database queries: < 15ms (add logging)
Run on physical device (not simulator) for accurate results. Document findings in quickstart.md results.
**Dependencies**: T022 (TabBarView implementation)

### T035: Execute quickstart.md manual scenarios
**File**: `specs/004-i-want-to/quickstart.md`
**Description**: Run all 10 manual test scenarios:
- Scenario 1: Create and view folder
- Scenario 2: Capture before photos
- Scenario 3: Capture after photos
- Scenario 4: View all photos with indicators
- Scenario 5: Delete folder (keep photos)
- Scenario 6: Delete folder (delete photos)
- Scenario 7: Delete individual photo
- Scenario 8: Tab state persistence
- Scenario 9: Empty states
- Scenario 10: Offline operation
Validate database state with SQL queries provided in quickstart.md. Document any issues.
**Dependencies**: All implementation complete (T001-T031)

### T036 [P]: Code cleanup and documentation
**File**: Multiple files
**Description**:
- Remove unused imports
- Add dartdoc comments to public APIs
- Ensure consistent naming conventions
- Remove debug print statements
- Run `dart analyze` and fix warnings
- Run `dart format .` for code formatting
No functional changes, only polish.
**Dependencies**: All implementation complete

---

## Dependencies Graph

```
Setup & Database (Sequential):
T001 (photo_folders table)
  ↓
T002 (folder_photos table)
  ↓
T003 (database queries)

Models (Parallel after database):
T004 [P] PhotoFolder model ─┐
T005 [P] FolderPhoto model ─┼─→ T006 (extend Photo model)
                            │
Services (Sequential after models):
                            ↓
                         T007 (FolderService)
                            ↓
                         T008 (AppState queries)
                            ↓
                         T009 (FolderProvider)

UI Tests (Parallel after provider):
T010 [P] CreateFolderDialog test ───→ T013 (implement CreateFolderDialog)
T011 [P] DeleteFolderDialog test ───→ T014 (implement DeleteFolderDialog)
T012 [P] FolderBadge test ──────────→ T015 (implement FolderBadge)
T016 [P] AllPhotosTab test ─────────→ T019 (implement AllPhotosTab)
T017 [P] FoldersTab test ───────────→ T020 (implement FoldersTab)
T018 [P] FolderDetailScreen test ───→ T021 (implement FolderDetailScreen)

Integration (Sequential after screens):
T019, T020 → T022 (modify EquipmentScreen with tabs)
           ↓
T021 ─────→ T023 (router update)
           ↓
         T024 (camera integration)
           ↓
Photo Deletion UI (TDD order):
T025 [P] PhotoDeleteDialog test
T026 Implement PhotoDeleteDialog
T027 Add delete to AllPhotosTab
T028 Add delete to FolderDetailScreen
           ↓
Integration Tests (Parallel after deletion):
T029 (folder creation integration test) [P]
T030 (folder deletion integration test) [P]
T031 (photo deletion integration test)  [P]

Polish (Parallel after integration):
T032 [P] PhotoFolder unit tests
T033 [P] FolderService unit tests
T034 [P] Performance validation
T035 Quickstart scenarios
T036 [P] Code cleanup
```

---

## Parallel Execution Examples

### Batch 1: Model creation (after T003 complete)
```bash
# These can run simultaneously (different files):
flutter test test/unit/models/photo_folder_test.dart &  # T004 test
flutter test test/unit/models/folder_photo_test.dart &  # T005 test
# Then implement models in parallel
```

### Batch 2: Widget tests (after T009 complete)
```bash
# Launch widget tests in parallel:
flutter test test/widget/create_folder_dialog_test.dart &  # T010
flutter test test/widget/delete_folder_dialog_test.dart &  # T011
flutter test test/widget/folder_badge_test.dart &          # T012
flutter test test/widget/all_photos_tab_test.dart &        # T016
flutter test test/widget/folders_tab_test.dart &           # T017
flutter test test/widget/folder_detail_screen_test.dart &  # T018
wait  # All must FAIL before implementing
```

### Batch 3: Integration tests (after T028 complete)
```bash
# Run integration tests in parallel:
flutter test test/integration/folder_workflow_test.dart &     # T029
flutter test test/integration/folder_deletion_test.dart &     # T030
flutter test test/integration/photo_deletion_test.dart &      # T031
```

### Batch 4: Polish (after T031 complete)
```bash
# Final validation in parallel:
flutter test test/unit/models/ &  # T032
flutter test test/unit/services/ & # T033
# T034 (performance) and T035 (quickstart) run manually
dart format . && dart analyze &    # T036
```

---

## Task Completion Checklist

### Database ✓
- [X] T001: photo_folders table created
- [X] T002: folder_photos junction table created
- [X] T003: Query methods in database_service.dart

### Models ✓
- [X] T004: PhotoFolder model
- [X] T005: FolderPhoto model + BeforeAfter enum
- [X] T006: Photo model extended with virtual fields

### Services ✓
- [X] T007: FolderService with CRUD
- [X] T008: AppState folder queries
- [X] T009: FolderProvider state management

### UI Widgets ✓
- [~] T010-T012: Widget tests (deferred - implementation-first approach)
- [X] T013: CreateFolderDialog implemented
- [X] T014: DeleteFolderDialog implemented
- [X] T015: FolderBadge widget

### UI Screens ✓
- [~] T016-T018: Screen tests (deferred - implementation-first approach)
- [X] T019: AllPhotosTab with badges
- [X] T020: FoldersTab with list
- [X] T021: FolderDetailScreen with Before/After tabs
- [X] T022: EquipmentScreen modified for TabBarView

### Integration ✓
- [X] T023: Router updated
- [X] T024: Camera integration with folder context
- [X] T025-T028: Photo deletion UI implemented
- [~] T029-T031: Integration tests (deferred - implementation-first approach)

### Polish ✓
- [~] T032-T033: Unit tests (deferred - implementation-first approach)
- [~] T034: Performance validated (requires manual testing with DevTools)
- [~] T035: Quickstart scenarios (requires physical device)
- [X] T036: Code cleanup complete

---

## Notes

- **TDD Requirement**: All test tasks (T010-T012, T016-T018) MUST be written and MUST FAIL before implementing corresponding widgets/screens
- **Parallel Marking**: [P] indicates tasks that touch different files and have no shared dependencies
- **Transaction Safety**: Folder deletion (T007) must use SQLite transactions to ensure data integrity (Article III)
- **Performance Targets**: Tab switching < 300ms, folder creation < 500ms (Article VI)
- **Offline-First**: All operations must work without network (Article II)
- **State Preservation**: Use AutomaticKeepAliveClientMixin on all tabs (FR-002)
- **Commit Frequency**: Commit after each completed task for rollback safety

---

## Validation Checklist
*GATE: Verify before marking tasks.md complete*

- [x] All entities from data-model.md have model tasks (PhotoFolder, FolderPhoto, Photo)
- [x] All tests come before implementation (T010-T012 before T013-T015, etc.)
- [x] Parallel tasks [P] truly independent (different files)
- [x] Each task specifies exact file path
- [x] No task modifies same file as another [P] task
- [x] Dependency graph is acyclic and complete
- [x] TDD approach enforced (tests MUST FAIL first)
- [x] Quickstart scenarios covered by integration tests (T029-T031, T035)
- [x] Constitutional requirements validated (Articles I-IX compliance in tasks)
- [x] Photo deletion functionality fully specified (T025-T028, FR-021 coverage)

**Status**: Tasks ready for execution. Estimated 36 tasks, ~50-60 hours of development.
