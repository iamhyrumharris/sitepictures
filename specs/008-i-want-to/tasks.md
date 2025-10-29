# Tasks: Photo Import From Device Library

**Input**: Design documents from `/specs/008-i-want-to/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/, quickstart.md

**Tests**: Include only where explicitly required by specification or to ensure independent verification.

**Organization**: Tasks grouped by user story to ensure independent delivery and testing.

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Prepare toolchain and dependencies for import feature work.

- [X] T001 Add `photo_manager` and `wechat_assets_picker` dependencies in `pubspec.yaml`
- [X] T002 Run `flutter pub get` to install new dependencies from project root
- [ ] T003 Verify iOS and Android build targets compile after dependency additions (`ios/Runner.xcodeproj`, `android/app/build.gradle`)

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure required before user stories.

- [X] T004 Update photo-library usage strings in `ios/Runner/Info.plist` (Import rationale, limited access messaging)
- [X] T005 Update Android permissions in `android/app/src/main/AndroidManifest.xml` (READ_MEDIA_IMAGES / READ_EXTERNAL_STORAGE fallbacks)
- [X] T006 Extend SQLite schema: add `sourceAssetId`, `fingerprintSha1`, `importBatchId`, `importSource` columns plus new `import_batches` table in `lib/services/database_service.dart`
- [X] T007 Create migration script for duplicate registry table in `lib/services/database_service.dart`
- [X] T008 Implement data models for `ImportBatch` and duplicate registry entries in `lib/models/import_batch.dart` and `lib/models/duplicate_registry_entry.dart`
- [X] T009 Add analytics event definition `gallery_import_logged` to local telemetry schema `lib/models/analytics_events.dart`
- [X] T010 Integrate fingerprint utilities (SHA-1) in `lib/utils/hash_utils.dart`

---

## Phase 3: User Story 1 - Import photos into the shared library (Priority: P1) 🎯 MVP

**Goal**: Enable home and All Photos entry points to import multiple gallery photos and route them through existing Needs Assigned move options.

**Independent Test**: From home, import two photos, select destination via Needs Assigned move flow, confirm photos appear in chosen location without visiting equipment screens.

### Implementation

- [X] T011 [US1] Implement `ImportService` with gallery selection, duplicate detection, and batch recording in `lib/services/import_service.dart`
- [X] T012 [US1] Implement `ImportFlowProvider` to manage state for home/All Photos imports in `lib/providers/import_flow_provider.dart`
- [X] T013 [US1] Add Import button with upload icon to home AppBar and integrate provider in `lib/screens/home/home_screen.dart`
- [X] T014 [US1] Add Import action to All Photos page AppBar in `lib/screens/all_photos/all_photos_screen.dart`
- [X] T015 [US1] Build modal to reuse Needs Assigned move options for destination selection post-picker in `lib/widgets/import_destination_modal.dart`
- [X] T016 [US1] Wire progress indicator and completion summary for shared library import in `lib/widgets/import_progress_sheet.dart`
- [X] T017 [US1] Persist `ImportBatch` records and tie them to imported photos in `lib/services/import_repository.dart`
- [X] T018 [US1] Trigger Needs Assigned/All Photos provider refreshes after import completion in `lib/providers/needs_assigned_provider.dart` and `lib/providers/all_photos_provider.dart`
- [X] T019 [US1] Log analytics event `gallery_import_logged` on batch completion in `lib/services/analytics_logger.dart`

### Tests

- [X] T020 [US1] Create widget test covering home import button flow in `test/widgets/home_import_button_test.dart`
- [X] T021 [US1] Add integration test for shared library import flow in `integration_test/import_shared_library_test.dart`

---

## Phase 4: User Story 2 - Import to equipment before/after documentation (Priority: P2)

**Goal**: Allow equipment-level Before/After tabs to import photos with explicit Before/After placement.

**Independent Test**: From equipment Before tab, import photos, choose “Import to Before,” and confirm images appear only in Before gallery for that equipment.

### Implementation

- [X] T022 [US2] Extend `ImportFlowProvider` to support equipment context and Before/After selection in `lib/providers/import_flow_provider.dart`
- [X] T023 [US2] Add Import button to equipment Before tab UI in `lib/screens/equipment/equipment_before_tab.dart`
- [X] T024 [US2] Add Import button to equipment After tab UI in `lib/screens/equipment/equipment_after_tab.dart`
- [X] T025 [US2] Implement Before/After choice modal defaulting to current tab in `lib/widgets/before_after_choice_sheet.dart`
- [X] T026 [US2] Update import pipeline to associate folder/category metadata in `lib/services/import_service.dart`
- [X] T027 [US2] Refresh equipment photo providers after import to show new photos in `lib/providers/equipment_photos_provider.dart`

### Tests

- [X] T028 [US2] Add widget test for Before tab import action in `test/widgets/equipment_before_import_test.dart`
- [X] T029 [US2] Add widget test for After tab import action in `test/widgets/equipment_after_import_test.dart`

---

## Phase 5: User Story 3 - Manage photo permissions and feedback (Priority: P3)

**Goal**: Provide clear permission prompts, denial handling, and retry flow across all import entry points.

**Independent Test**: Deny permission, observe guidance, grant access via settings, and resume import without restarting app.

### Implementation

- [X] T030 [US3] Implement pre-permission educational sheet component in `lib/widgets/permission_education_sheet.dart`
- [X] T031 [US3] Integrate permission sheet before gallery request in `lib/providers/import_flow_provider.dart`
- [X] T032 [US3] Handle limited access state with manage selection shortcut in `lib/services/import_service.dart`
- [X] T033 [US3] Display denied-state guidance with open settings shortcut in `lib/widgets/permission_denied_dialog.dart`
- [X] T034 [US3] Persist permission audit events for analytics in `lib/services/analytics_logger.dart`
- [X] T035 [US3] Ensure flow resumes seamlessly after returning from settings in `lib/providers/import_flow_provider.dart`

### Tests

- [X] T036 [US3] Add integration test exercising denied→settings→resume flow in `integration_test/import_permission_recovery_test.dart`

---

## Phase 6: Polish & Cross-Cutting

**Purpose**: Final refinements applicable across stories.

- [X] T037 [P] Update documentation for import workflows in `docs/import_feature.md`
- [X] T038 [P] Optimize import batch processing performance profiling in `lib/services/import_service.dart`
- [X] T039 Conduct accessibility review for new modals and prompts in `lib/widgets/`
- [X] T040 Review analytics event batching and consent handling in `lib/services/analytics_logger.dart`
- [X] T041 Run end-to-end smoke test following quickstart checklist in `quickstart.md`

---

## Dependencies & Execution Order

- Phase 1 → Phase 2 → subsequent phases in order.
- User Story phases can proceed sequentially (P1 → P2 → P3). After foundational work, US2 & US3 can begin in parallel if US1 shared components are stable.
- Tests for each user story should execute after core implementation within the same phase but before moving to next story.

## Parallel Execution Examples

- Phase 1 tasks T001–T003 can run in parallel.
- During Phase 3, UI integrations (T013, T014) can proceed alongside provider/service work after T011 groundwork.
- Phase 4 widget tests (T028, T029) can run concurrently.
- Phase 6 documentation (T037) and analytics review (T040) are parallelizable.

## Implementation Strategy

- MVP is completion of Phase 3 (User Story 1) enabling gallery imports from home/All Photos with Needs Assigned routing.
- Subsequent phases extend functionality to equipment contexts and robust permission handling.
- Each user story delivers independently testable value, allowing incremental releases aligned with FieldPhoto Pro constitution.
