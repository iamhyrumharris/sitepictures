# Tasks: All Photos Gallery

**Input**: Design documents from `/specs/007-i-want-to/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, contracts/

**Tests**: Include targeted tests where they materially guard functionality. Broader suites can be added during implementation if quality gates demand it.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`
- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Finalize supporting design artifacts required for downstream implementation.

- [X] T001 Capture research decisions R0.1–R0.5 in specs/007-i-want-to/research.md
- [X] T002 Document updated data relationships for global photo feed in specs/007-i-want-to/data-model.md
- [X] T003 [P] Author quickstart validation plan covering success criteria in specs/007-i-want-to/quickstart.md

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core data access changes that underpin all user stories.

**⚠️ CRITICAL**: No user story work can begin until this phase is complete.

- [X] T004 Implement migration v6 with descending timestamp index and bump database version in lib/services/database_service.dart
- [X] T005 Extend photo aggregation query and helper methods in lib/services/database_service.dart to return equipment/site metadata
- [X] T006 Expose getAllPhotos API from AppState with location summary mapping in lib/providers/app_state.dart
- [X] T007 Add read-write fields for equipment/location metadata to Photo model in lib/models/photo.dart

**Checkpoint**: Foundation ready—global photo data available for UI layers.

---

## Phase 3: User Story 1 - Review latest equipment photos (Priority: P1) 🎯 MVP

**Goal**: Provide a global gallery combining all authorized photos ordered newest-to-oldest with contextual metadata.

**Independent Test**: Launch the All Photos screen directly, confirm newest-first ordering, metadata rendering, incremental loading, and PhotoViewer navigation without relying on navigation changes.

### Implementation for User Story 1

- [X] T008 [US1] Implement AllPhotosProvider with pagination state and cache controls in lib/providers/all_photos_provider.dart
- [X] T009 [US1] Register AllPhotosProvider via ChangeNotifierProxyProvider in lib/main.dart
- [X] T010 [US1] Build AllPhotosScreen with RefreshIndicator, lazy grid, and edge-state handling in lib/screens/all_photos/all_photos_screen.dart
- [X] T011 [P] [US1] Extract reusable photo_grid_tile widget with metadata slots in lib/widgets/photo_grid_tile.dart
- [X] T012 [US1] Refactor lib/screens/equipment/all_photos_tab.dart to reuse PhotoGridTile and accept enriched metadata
- [X] T013 [US1] Notify AllPhotosProvider on deletions from PhotoViewer in lib/screens/photo_viewer_screen.dart
- [X] T014 [US1] Invalidate AllPhotosProvider cache after successful saves in lib/services/photo_save_service.dart
- [X] T015 [P] [US1] Add AllPhotosProvider unit coverage in test/unit/providers/all_photos_provider_test.dart
- [X] T016 [P] [US1] Create AllPhotosScreen widget tests for loading/empty/populated states in test/widget/screens/all_photos_screen_test.dart
- [X] T017 [US1] Author integration_test/all_photos_gallery_test.dart validating newest-first ordering and PhotoViewer launch

**Checkpoint**: All Photos gallery works independently when routed directly.

---

## Phase 4: User Story 2 - Access all photos from navigation (Priority: P2)

**Goal**: Surface the All Photos gallery from primary navigation, replacing the map entry point while preserving layout consistency.

**Independent Test**: From the authenticated shell, tap the All Photos tab, verify it opens the gallery, and ensure nav bar state remains consistent across screen transitions.

### Implementation for User Story 2

- [X] T018 [US2] Replace map button with All Photos label/icon in lib/widgets/bottom_nav.dart
- [X] T019 [US2] Update ShellScaffold index handling for All Photos tab in lib/screens/shell_scaffold.dart
- [X] T020 [US2] Register /all-photos route and remove map placeholder in lib/router.dart
- [X] T021 [P] [US2] Add widget regression test for BottomNav labels in test/widget/widgets/bottom_nav_test.dart
- [X] T022 [US2] Extend integration_test/navigation_all_photos_test.dart to cover bottom-nav tap-to-gallery flow

**Checkpoint**: Users access the global gallery via navigation bar with consistent highlighting.

---

## Phase 5: Polish & Cross-Cutting Concerns

**Purpose**: Hardening work and optional backend parity.

- [X] T023 [P] Update specs/007-i-want-to/quickstart.md with final validation results after implementation
- [X] T024 Execute flutter test and integration_test suites documenting outcomes in specs/007-i-want-to/quickstart.md
- [X] T025 Implement optional GET /v1/photos endpoint with pagination in api/src/routes/photos.js (create only if backend parity required)
- [X] T026 [P] Add PostgreSQL timestamp index migration and Sequelize model update for optional parity in api/src/database/migrations/002_add_photo_timestamp_index.sql and api/src/models/photo.js
- [X] T027 [P] Add jest + supertest coverage for optional photos feed in api/tests/integration/photos_feed.test.js

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)** → prerequisite documentation available  
- **Phase 2 (Foundational)** → depends on Phase 1 completion  
- **Phase 3 (US1)** → depends on Phase 2 completion  
- **Phase 4 (US2)** → depends on Phase 3 completion for shared screen readiness  
- **Phase 5 (Polish)** → depends on targeted user stories completion; optional backend parity can start once database/query foundation is stable

### User Story Dependencies

- **US1** has no upstream story dependencies once foundational data layer is ready.
- **US2** depends on US1 assets (screen/provider) to avoid rework and ensure navigation attaches to finalized gallery.

### Within-Story Ordering Highlights

- US1: Complete provider registration (T008–T009) before UI work (T010). Shared widget extraction (T011) can proceed once provider state shape is known. Tests (T015–T017) should execute after corresponding implementations.
- US2: Navigation code updates (T018–T020) precede tests (T021–T022) to ensure assertions target final behavior.

---

## Parallel Execution Examples

### Within User Story 1

```bash
# Run provider and widget tests concurrently once implementations land:
flutter test test/unit/providers/all_photos_provider_test.dart test/widget/screens/all_photos_screen_test.dart

# Build shared UI components in parallel with provider logic:
# T011 can proceed while T008 is finalized, assuming data contract documented.
```

### Cross-Team Opportunities

- One developer focuses on provider + data invalidation (T008–T014) while another handles UI + tests (T010–T017).
- Optional backend parity (T025–T027) can be owned by backend specialist after foundational schema work completes.

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Finish Phases 1–2 to unlock data access.
2. Deliver Phase 3 (US1) end-to-end and run targeted tests.  
3. Demo the All Photos gallery accessible via direct route for early feedback.

### Incremental Delivery

1. Roll out US1 as MVP.  
2. Layer US2 navigation enhancements once gallery is validated.  
3. Apply polish tasks and optional backend parity as capacity allows.

### Continuous Quality

- Execute `flutter test` and integration suites after each phase.  
- Update quickstart.md with observed timings to confirm success criteria SC-001–SC-004.  
- Keep optional API tasks gated; only execute if stakeholders confirm backend exposure requirement.
