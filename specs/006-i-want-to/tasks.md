# Tasks: Camera Photo Save Functionality

**Feature**: 006-i-want-to | **Generated**: 2025-10-14
**Input**: Design documents from `/specs/006-i-want-to/`
**Prerequisites**: plan.md (tech stack), spec.md (user stories), data-model.md (entities), contracts/ (service interfaces), research.md (decisions), quickstart.md (test scenarios)

**Tests**: Not explicitly requested in specification - focusing on implementation tasks only

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`
- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions
- Mobile Flutter app: `lib/` for source, `test/` for tests
- Paths relative to repository root: `/Users/hyrumharris/src/sitepictures/`

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and database schema changes

- [X] T001 Run database migration 004 to add `is_system` column to clients table in `lib/services/database_service.dart`
- [X] T002 Create global "NEEDS_ASSIGNED" client record with is_system=1 in database migration 004
- [X] T003 Create index `idx_clients_system` on clients(is_system, is_active) in database migration 004
- [X] T004 Update database version from 3 to 4 in `lib/services/database_service.dart`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core models and utilities that ALL user stories depend on

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [X] T005 [P] Create `SaveContext` model in `lib/models/save_context.dart` (enum for home/equipment/folder_before/folder_after with validation)
- [X] T006 [P] Create `SaveResult` model in `lib/models/save_result.dart` (result wrapper with factory constructors)
- [X] T007 [P] Create `QuickSaveItem` model in `lib/models/quick_save_item.dart` (result entity for Quick Save operations)
- [X] T008 [P] Create `EquipmentNavigationNode` model in `lib/models/equipment_navigation_node.dart` (tree node for navigator)
- [X] T009 [P] Create `SequentialNamer` utility in `lib/utils/sequential_namer.dart` (handles "(2)", "(3)" disambiguation)
- [X] T010 Extend `Client` model to add `isSystem` field in `lib/models/client.dart`
- [X] T011 Update database queries to filter `WHERE is_system = 0` for user-facing client lists in `lib/providers/app_state.dart`
- [X] T012 Extend `PhotoStorageService` to add `moveToPermanent()` method for moving temp photos in `lib/services/photo_storage_service.dart`

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - Home Camera Quick Save and Equipment Assignment (Priority: P1) 🎯 MVP

**Goal**: Enable quick capture from home page with two options: Quick Save to global "Needs Assigned" or Next button to select equipment

**Independent Test**: Open camera from home, capture 1 photo (verify saves as "Image - [date]"), capture 3 photos (verify saves as "Folder - [date]"), use Next button to navigate to equipment (verify photos appear in equipment's All Photos tab)

### Implementation for User Story 1

**Quick Save Workflow**:

- [ ] T013 Create `QuickSaveService` implementation in `lib/services/quick_save_service.dart` with `quickSave()`, `generateUniqueName()`, `hasStorageAvailable()` methods per contract
- [ ] T014 Extend `CameraCapturePage` in `lib/screens/camera_capture_page.dart` to detect home context and show Quick Save/Next modal on Done button
- [ ] T015 Implement Quick Save handler in `lib/screens/camera_capture_page.dart` that calls QuickSaveService and shows confirmation
- [ ] T016 Create `NeedsAssignedPage` in `lib/screens/needs_assigned_page.dart` to display global "Needs Assigned" photos and folders
- [ ] T017 Add navigation route from home page to NeedsAssignedPage (FAB or menu item)
- [ ] T018 Create `NeedsAssignedBadge` widget in `lib/widgets/needs_assigned_badge.dart` (inbox icon + "Needs Assigned" label)

**Next Button / Equipment Navigator Workflow**:

- [ ] T019 Create `EquipmentNavigatorProvider` implementation in `lib/providers/equipment_navigator_provider.dart` per contract (initialize, navigateInto, navigateBack, selectEquipment methods)
- [ ] T020 Create `EquipmentNavigatorPage` in `lib/screens/equipment_navigator_page.dart` with hierarchical list navigation UI
- [ ] T021 Create `EquipmentNavigatorTree` widget in `lib/widgets/equipment_navigator_tree.dart` for rendering navigation nodes
- [ ] T022 Implement Next button handler in `lib/screens/camera_capture_page.dart` that opens equipment navigator modal
- [ ] T023 Implement equipment selection callback that saves photos via PhotoSaveService.saveToEquipment
- [ ] T024 Add empty state handling in EquipmentNavigatorPage when no clients exist
- [ ] T025 Add cancel navigation handling that preserves camera session (FR-019)

**Save Service Integration**:

- [ ] T026 Create `PhotoSaveService` implementation in `lib/services/photo_save_service.dart` with `saveToEquipment()`, `savePhotos()`, `hasStorageAvailable()` methods per contract
- [ ] T027 Implement incremental save pattern in PhotoSaveService with progress stream
- [ ] T028 Implement non-critical error handling (continue saving remaining photos)
- [ ] T029 Implement critical error handling with rollback in PhotoSaveService
- [ ] T030 Create `SaveProgressIndicator` widget in `lib/widgets/save_progress_indicator.dart` for loading UI during multi-photo saves
- [ ] T031 Add logging for all save operations in QuickSaveService and PhotoSaveService (FR-056)

**Checkpoint**: At this point, User Story 1 should be fully functional - can capture from home, Quick Save to global "Needs Assigned", or use Next to select equipment

---

## Phase 4: User Story 2 - Equipment Photos Tab Direct Save (Priority: P2)

**Goal**: Enable direct save to equipment's All Photos when camera launched from equipment's Photos tab

**Independent Test**: Navigate to any equipment's All Photos tab, tap camera, capture 3 photos, tap Done, verify photos appear immediately in the equipment's All Photos tab

### Implementation for User Story 2

- [ ] T032 Extend `CameraCapturePage` in `lib/screens/camera_capture_page.dart` to detect equipment context and auto-save on Done (no modal)
- [ ] T033 Update `AllPhotosTab` in `lib/screens/equipment/all_photos_tab.dart` to pass `SaveContext.equipment()` when launching camera
- [ ] T034 Implement equipment direct save handler in `lib/screens/camera_capture_page.dart` using PhotoSaveService.saveToEquipment
- [ ] T035 Add success confirmation message showing photo count (e.g., "3 photos saved")
- [ ] T036 Return user to equipment's All Photos tab after save completes
- [ ] T037 Refresh All Photos list to show newly saved photos at top (ordered by timestamp)

**Checkpoint**: User Story 2 complete - equipment Photos tab camera saves directly without additional navigation

---

## Phase 5: User Story 3 - Folder Before/After Categorized Save (Priority: P3)

**Goal**: Enable automatic categorization of photos to folder's Before or After section based on which tab launched camera

**Independent Test**: Navigate to equipment folder, tap "Before" tab, capture 2 photos, verify they appear in Before section. Then tap "After" tab, capture 3 photos, verify they appear in After section and Before photos remain unchanged

### Implementation for User Story 3

- [ ] T038 Implement `saveToFolder()` method in PhotoSaveService with before/after categorization per contract
- [ ] T039 Extend `CameraCapturePage` in `lib/screens/camera_capture_page.dart` to detect folder_before/folder_after context and auto-save on Done
- [ ] T040 Update `FolderDetailScreen` Before tab in `lib/screens/equipment/folder_detail_screen.dart` to pass `SaveContext.folderBefore()` when launching camera
- [ ] T041 Update `FolderDetailScreen` After tab in `lib/screens/equipment/folder_detail_screen.dart` to pass `SaveContext.folderAfter()` when launching camera
- [ ] T042 Implement folder save handler in `lib/screens/camera_capture_page.dart` using PhotoSaveService.saveToFolder
- [ ] T043 Add success confirmation showing category (e.g., "2 photos saved to Before")
- [ ] T044 Return user to folder tab from which camera was launched
- [ ] T045 Refresh Before/After photo lists to show newly saved photos at top

**Error Handling for US3**:

- [ ] T046 Detect folder deletion during capture session and offer alternative save (FR-053)
- [ ] T047 Update folder photo count in Folders tab list after save

**Checkpoint**: All three user stories complete - all save contexts working (home, equipment, folder before/after)

---

## Phase 6: Per-Client "Needs Assigned" Folders (Priority: P4)

**Goal**: Automatically create and manage per-client "Needs Assigned" folders

**Independent Test**: Create a new client, verify "Needs Assigned" folder appears at top of main sites list with unique icon

### Implementation for Per-Client Folders

- [ ] T048 Create `NeedsAssignedProvider` implementation in `lib/providers/needs_assigned_provider.dart` per contract
- [ ] T049 Implement `createClientNeedsAssigned()` method in NeedsAssignedProvider
- [ ] T050 Update client creation workflow to call createClientNeedsAssigned after client creation
- [ ] T051 Update client sites list UI to display per-client "Needs Assigned" at top with NeedsAssignedBadge
- [ ] T052 Prevent deletion of per-client "Needs Assigned" folders in folder service
- [ ] T053 Prevent renaming of per-client "Needs Assigned" folders in folder service
- [ ] T054 Implement `loadClientNeedsAssigned()` method in NeedsAssignedProvider
- [ ] T055 Update existing clients to have "Needs Assigned" folders (migration/seed script)

**Checkpoint**: Per-client "Needs Assigned" folders working for organizational hierarchy

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories

- [ ] T056 [P] Update CLAUDE.md with new technologies: camera save services, equipment navigator, sequential naming patterns
- [ ] T057 [P] Add implementation notes to CLAUDE.md for camera save architecture and key decisions
- [ ] T058 Optimize thumbnail generation to run asynchronously (don't block save operations)
- [ ] T059 Add storage validation before all save operations (FR-050)
- [ ] T060 Implement storage error handling showing "Insufficient storage" message (FR-052)
- [ ] T061 Add database integrity check on app startup for corruption detection
- [ ] T062 Performance optimization: Use batch inserts for multi-photo saves
- [ ] T063 [P] Run quickstart.md validation scenarios to verify all workflows
- [ ] T064 Add user feedback messages for all save operations per FR-058, FR-059, FR-060
- [ ] T065 Verify equipment deletion/archival during navigation refreshes navigator (FR-054)
- [ ] T066 Test partial save scenarios (9 of 10 photos saved) and verify messaging
- [ ] T067 Test critical error rollback scenarios and verify session preservation
- [ ] T068 Verify 20-photo session limit Quick Save completes in under 15 seconds (SC-010)
- [ ] T069 Code cleanup and refactoring across all save services
- [ ] T070 Security review: Verify system clients cannot be deleted/edited by users

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately (database migration)
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Story 1 (Phase 3)**: Depends on Foundational - MVP priority
- **User Story 2 (Phase 4)**: Depends on Foundational and PhotoSaveService from US1
- **User Story 3 (Phase 5)**: Depends on Foundational and PhotoSaveService from US1
- **Per-Client Folders (Phase 6)**: Depends on Foundational - can run parallel with US2/US3
- **Polish (Phase 7)**: Depends on all desired user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational (Phase 2) - No dependencies on other stories
  - QuickSaveService is independent
  - EquipmentNavigatorProvider is independent
  - PhotoSaveService.saveToEquipment is needed
- **User Story 2 (P2)**: Depends on PhotoSaveService from US1, but can start in parallel if PhotoSaveService done first
- **User Story 3 (P3)**: Depends on PhotoSaveService from US1, extends with saveToFolder method

### Within Each User Story

**User Story 1 Order**:
1. Foundational models/utils (T005-T012) - parallel
2. QuickSaveService (T013) - depends on models
3. Camera page Quick Save UI (T014-T015) - depends on QuickSaveService
4. NeedsAssignedPage + navigation (T016-T018) - parallel with navigator
5. EquipmentNavigatorProvider + UI (T019-T025) - parallel with Quick Save UI
6. PhotoSaveService core (T026-T031) - depends on models, needed for Next button

**User Story 2 Order**:
1. PhotoSaveService.saveToEquipment must exist (from US1)
2. Camera page equipment context detection (T032)
3. AllPhotosTab integration (T033-T037) - sequential

**User Story 3 Order**:
1. PhotoSaveService.saveToFolder extension (T038)
2. Camera page folder context detection (T039)
3. FolderDetailScreen integration (T040-T045) - sequential
4. Error handling (T046-T047) - parallel

### Parallel Opportunities

**Within Phase 2 (Foundational)**:
- T005, T006, T007, T008, T009 can all run in parallel (different model files)
- T010, T011, T012 sequential (depend on models)

**Within Phase 3 (User Story 1)**:
- Quick Save path (T013-T018) can run parallel with Equipment Navigator path (T019-T025)
- Both paths need PhotoSaveService (T026-T031) for completion

**Across User Stories**:
- Once PhotoSaveService.saveToEquipment is done (T026), US2 can start
- Once PhotoSaveService foundation exists, US3 can extend in parallel with US2
- Phase 6 (Per-Client Folders) can run parallel with US2/US3

---

## Parallel Example: User Story 1

```bash
# Launch foundational models together (Phase 2):
Task T005: "Create SaveContext model in lib/models/save_context.dart"
Task T006: "Create SaveResult model in lib/models/save_result.dart"
Task T007: "Create QuickSaveItem model in lib/models/quick_save_item.dart"
Task T008: "Create EquipmentNavigationNode model in lib/models/equipment_navigation_node.dart"
Task T009: "Create SequentialNamer utility in lib/utils/sequential_namer.dart"

# After models done, split into two parallel paths:
Path A (Quick Save):
Task T013: "Create QuickSaveService in lib/services/quick_save_service.dart"
Task T014-T018: Camera Quick Save UI and NeedsAssignedPage

Path B (Equipment Navigator):
Task T019: "Create EquipmentNavigatorProvider in lib/providers/equipment_navigator_provider.dart"
Task T020-T025: Equipment navigator UI and Next button integration

# Both paths converge on:
Task T026-T031: PhotoSaveService implementation
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (database migration) - **~30 min**
2. Complete Phase 2: Foundational (models + utils) - **~2 hours**
3. Complete Phase 3: User Story 1 - **~8 hours**
   - Quick Save workflow: ~4 hours
   - Equipment Navigator workflow: ~4 hours
4. **STOP and VALIDATE**: Test User Story 1 independently per quickstart.md scenarios
5. Deploy/demo MVP

**Estimated Total for MVP**: ~10.5 hours

### Incremental Delivery

1. Setup + Foundational → Foundation ready (~2.5 hours)
2. Add User Story 1 → Test independently → Deploy/Demo (MVP!) (~8 hours)
3. Add User Story 2 → Test independently → Deploy/Demo (~2 hours)
4. Add User Story 3 → Test independently → Deploy/Demo (~3 hours)
5. Add Per-Client Folders → Test independently → Deploy/Demo (~3 hours)
6. Polish phase → Final validation (~3 hours)

**Estimated Total for Full Feature**: ~21.5 hours

### Parallel Team Strategy

With multiple developers (after Foundational phase):

1. Team completes Setup + Foundational together (~2.5 hours)
2. Once Foundational is done:
   - **Developer A**: User Story 1 Quick Save path (T013-T018, T026-T031)
   - **Developer B**: User Story 1 Equipment Navigator path (T019-T025)
   - **Developer C**: Per-Client Folders (Phase 6)
3. Merge User Story 1 paths together
4. Then in parallel:
   - **Developer A**: User Story 2 (T032-T037)
   - **Developer B**: User Story 3 (T038-T047)
5. Polish phase together

**Estimated Total with 3 developers**: ~12 hours elapsed time

---

## Task Estimates

### Phase 1 (Setup): ~30 minutes
- T001-T004: Database migration (30 min)

### Phase 2 (Foundational): ~2 hours
- T005-T009: Model creation (1 hour - parallel)
- T010-T012: Service extensions (1 hour - sequential)

### Phase 3 (User Story 1): ~8 hours
- T013-T018: Quick Save workflow (4 hours)
- T019-T025: Equipment Navigator workflow (4 hours)
- T026-T031: PhotoSaveService (included in above, shared)

### Phase 4 (User Story 2): ~2 hours
- T032-T037: Equipment direct save (2 hours)

### Phase 5 (User Story 3): ~3 hours
- T038-T047: Folder before/after save (3 hours)

### Phase 6 (Per-Client Folders): ~3 hours
- T048-T055: Per-client "Needs Assigned" (3 hours)

### Phase 7 (Polish): ~3 hours
- T056-T070: Documentation, optimization, validation (3 hours)

**Total Estimated Time**: ~21.5 hours (single developer, sequential)

---

## Notes

- [P] tasks = different files, no dependencies, can run in parallel
- [Story] label (US1, US2, US3) maps task to specific user story for traceability
- Each user story should be independently completable and testable
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
- Database migration must run before any development work
- PhotoSaveService is shared across all user stories - implement in US1 phase
- Tests not included as they weren't explicitly requested in specification
- Focus on delivering working MVP (User Story 1) first before adding US2/US3
- quickstart.md contains detailed implementation examples for reference

---

## Constitution Compliance

All tasks validated against constitution articles:

- ✅ **Article I (Field-First)**: Quick Save enables immediate storage, one-handed operation
- ✅ **Article II (Offline Autonomy)**: All save operations work offline using local SQLite
- ✅ **Article III (Data Integrity)**: Incremental save with rollback, session preservation
- ✅ **Article IV (Hierarchical Consistency)**: Special client record maintains hierarchy
- ✅ **Article V (Privacy & Security)**: Local-only operations, user attribution
- ✅ **Article VI (Performance)**: 15 seconds for 20 photos, ≤500ms navigation
- ✅ **Article VII (Intuitive Simplicity)**: Context-aware UI, clear confirmation messages
- ✅ **Article VIII (Modular Independence)**: Clean service separation, extends existing features
- ✅ **Article IX (Collaborative Transparency)**: Logging, user attribution, audit trail

---

## Success Criteria Mapping

Tasks map to success criteria from spec.md:

- **SC-001** (Quick Save <10s): T013-T015, T026-T028
- **SC-002** (Next button <30s): T019-T023
- **SC-003** (100% Quick Save appearance): T013-T018
- **SC-004** (100% equipment photos): T032-T037
- **SC-005** (100% folder categorization): T038-T047
- **SC-006** (95% equipment selection success): T019-T025
- **SC-007** (100% error handling): T028-T029, T046, T059-T060
- **SC-008** (100% per-client folders): T048-T055
- **SC-009** (Sequential naming): T009, T013
- **SC-010** (20 photos <15s): T058, T062, T068
- **SC-011** (90% understand destination): T031, T064

All success criteria covered by task list.
