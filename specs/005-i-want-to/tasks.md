# Tasks: Context-Aware Camera and Expandable Navigation FABs

**Feature Branch**: `005-i-want-to`
**Input**: Design documents from `/specs/005-i-want-to/`
**Prerequisites**: plan.md ✅, spec.md ✅, research.md ✅, data-model.md ✅, contracts/ ✅

**Tests**: Not explicitly requested in feature specification - implementation tasks only

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`
- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3, US4)
- Include exact file paths in descriptions

## Path Conventions
- **Flutter Mobile Project**: `lib/` for source, `test/` for tests at repository root
- Paths follow Flutter standard structure as defined in plan.md

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Create base model files and reusable widgets needed across all user stories

- [X] T001 [P] [Setup] Create CameraContext model in `lib/models/camera_context.dart` with enum and factory methods per data-model.md
- [X] T002 [P] [Setup] Create FABMenuItem model in `lib/models/fab_menu_item.dart` with label, icon, onTap, backgroundColor properties
- [X] T003 [P] [Setup] Create SaveActionButton model in `lib/models/save_action_button.dart` with label, onTap, enabled, backgroundColor properties
- [X] T004 [Setup] Create ExpandableFAB widget in `lib/widgets/expandable_fab.dart` with animation controller, stagger logic, tap-outside-to-collapse per contracts/fab-expansion.md
- [X] T005 [Setup] Create ContextAwareSaveButtons widget in `lib/widgets/context_aware_save_buttons.dart` with switch statement for button rendering per contracts/camera-context.md

**Checkpoint**: Base models and reusable widgets created - ready for screen integration

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [X] T006 [Foundational] Update PhotoCaptureProvider in `lib/providers/photo_capture_provider.dart` to add cameraContext field and setCameraContext() method
- [X] T007 [Foundational] Update router.dart in `lib/router.dart` to support camera context passing via extra parameter in /camera-capture route

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - Context-Aware Camera Save Actions (Priority: P1) 🎯 MVP

**Goal**: Display context-appropriate save button labels when camera Done button is tapped based on launch context (home, equipment all photos, equipment before, equipment after)

**Independent Test**: Navigate to each context (home, equipment all photos tab, equipment folders tab with before/after designation), capture photos, tap Done, verify the save action labels and behaviors match the context

### Implementation for User Story 1

- [X] T008 [US1] Modify CameraCapturePage in `lib/screens/camera_capture_page.dart` to accept cameraContext parameter and pass to PhotoCaptureProvider
- [X] T009 [US1] Update CameraCapturePage Done button handler to render ContextAwareSaveButtons widget instead of hardcoded buttons
- [X] T010 [US1] Implement _handleNext() and _handleQuickSave() methods in CameraCapturePage for home context (preserve existing behavior)
- [X] T011 [US1] Implement _handleEquipmentSave() mock method in CameraCapturePage to show SnackBar "Equipment photo save coming soon!" and pop navigation
- [X] T012 [US1] Implement _handleBeforeSave() mock method in CameraCapturePage to show SnackBar "Before/After categorization coming soon!" and pop navigation
- [X] T013 [US1] Implement _handleAfterSave() mock method in CameraCapturePage to show SnackBar "Before/After categorization coming soon!" and pop navigation
- [X] T014 [US1] Update home screen (shell_scaffold.dart or home_screen.dart) camera FAB to pass context: 'home' in extra parameter
- [X] T015 [US1] Update equipment screen in `lib/screens/equipment/equipment_screen.dart` All Photos tab camera FAB to pass context: 'equipment-all-photos' and equipmentId in extra parameter
- [X] T016 [US1] Update equipment Folders tab "Capture Before" button to pass context: 'equipment-before', folderId, and beforeAfter: 'before' in extra parameter
- [X] T017 [US1] Update equipment Folders tab "Capture After" button to pass context: 'equipment-after', folderId, and beforeAfter: 'after' in extra parameter

**Checkpoint**: At this point, User Story 1 should be fully functional - camera displays correct button labels for all 4 contexts and mock handlers work

---

## Phase 4: User Story 2 - Client Page Expandable FAB (Priority: P2)

**Goal**: Client detail page displays expandable FAB with 3 options (Add Main Site, Add SubSite, Add Equipment) for admin/technician roles

**Independent Test**: Navigate to any client detail page, tap the FAB, verify it expands to show three labeled action buttons, tap each action to verify correct creation dialog appears

### Implementation for User Story 2

- [X] T018 [US2] Update client_detail_screen.dart in `lib/screens/clients/client_detail_screen.dart` to add _buildFAB() method with permission check (hide for viewer role)
- [X] T019 [US2] Implement _getFABMenuItems() in client_detail_screen.dart returning 3 FABMenuItem instances: "Add Main Site", "Add SubSite", "Add Equipment" with appropriate icons and callbacks
- [X] T020 [US2] Implement _showAddMainSiteDialog() in client_detail_screen.dart to display main site creation dialog with client context preserved
- [X] T021 [US2] Implement _showAddSubSiteDialog() in client_detail_screen.dart to display subsite creation dialog with client context preserved (with main site selection if needed)
- [X] T022 [US2] Implement _showAddEquipmentDialog() in client_detail_screen.dart to display equipment creation dialog with client context preserved (with site selection if needed)
- [X] T023 [US2] Replace existing FAB in client_detail_screen.dart Scaffold with _buildFAB() widget that uses ExpandableFAB with unique heroTag
- [X] T024 [US2] Add AuthState permission check to ensure FAB only displays for admin/technician roles

**Checkpoint**: Client page expandable FAB fully functional with 3 creation options and proper permission enforcement

---

## Phase 5: User Story 3 - Main Site Page Expandable FAB (Priority: P3)

**Goal**: Main site detail page displays expandable FAB with 2 options (Add SubSite, Add Equipment) for admin/technician roles

**Independent Test**: Navigate to any main site detail page, tap the FAB, verify it expands to show two labeled buttons (SubSite, Equipment), create items using each action

### Implementation for User Story 3

- [X] T025 [US3] Update main_site_screen.dart in `lib/screens/sites/main_site_screen.dart` to add _buildFAB() method with permission check (hide for viewer role)
- [X] T026 [US3] Implement _getFABMenuItems() in main_site_screen.dart returning 2 FABMenuItem instances: "Add SubSite" and "Add Equipment" with appropriate icons and callbacks
- [X] T027 [US3] Implement _showAddSubSiteDialog() in main_site_screen.dart to display subsite creation dialog with main site context preserved
- [X] T028 [US3] Implement _showAddEquipmentDialog() in main_site_screen.dart to display equipment creation dialog with main site context preserved
- [X] T029 [US3] Replace existing FAB in main_site_screen.dart Scaffold with _buildFAB() widget that uses ExpandableFAB with unique heroTag
- [X] T030 [US3] Add AuthState permission check to ensure FAB only displays for admin/technician roles

**Checkpoint**: Main site page expandable FAB fully functional with 2 creation options and proper permission enforcement

---

## Phase 6: User Story 4 - SubSite Page Simple FAB (Priority: P4)

**Goal**: SubSite detail page displays simple "+" FAB that directly opens equipment creation dialog for admin/technician roles

**Independent Test**: Navigate to any subsite page, tap the "+" FAB, verify it directly opens equipment creation dialog with subsite context preserved

### Implementation for User Story 4

- [X] T031 [US4] Update sub_site_screen.dart in `lib/screens/sites/sub_site_screen.dart` to add _buildFAB() method with permission check (hide for viewer role)
- [X] T032 [US4] Implement _showAddEquipmentDialog() in sub_site_screen.dart to display equipment creation dialog with subsite context preserved
- [X] T033 [US4] Verify existing simple FAB in sub_site_screen.dart Scaffold uses _buildFAB() method that returns FloatingActionButton (not ExpandableFAB)
- [X] T034 [US4] Add AuthState permission check to ensure FAB only displays for admin/technician roles
- [X] T035 [US4] Verify equipment created from subsite FAB is correctly associated with subsite in database

**Checkpoint**: SubSite page simple FAB fully functional - directly creates equipment with proper context association

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories and final validation

- [X] T036 [P] [Polish] Manual testing pass using quickstart.md checklist for all 4 user stories
- [X] T037 [P] [Polish] Performance validation: FAB expansion < 300ms (SC-005), camera context detection instant (SC-002)
- [X] T038 [P] [Polish] Verify all permission checks work correctly (viewer sees no FABs, admin/technician see FABs)
- [X] T039 [P] [Polish] Verify invalid camera context defaults to home gracefully (test with missing params)
- [X] T040 [P] [Polish] Code cleanup: Remove debug prints, add comments for complex animation logic
- [X] T041 [Polish] Update CLAUDE.md via `.specify/scripts/bash/update-agent-context.sh claude` with new widgets (ExpandableFAB, ContextAwareSaveButtons) and camera context pattern
- [X] T042 [Polish] Verify all mock save handlers show appropriate SnackBar messages and return to previous screen

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion (models needed for provider update) - BLOCKS all user stories
- **User Stories (Phase 3-6)**: All depend on Foundational phase completion
  - US1 can start after Foundational - establishes camera context pattern
  - US2, US3, US4 can proceed in parallel after Foundational (if staffed) OR sequentially in priority order
  - Each story is independent and can be tested separately
- **Polish (Phase 7)**: Depends on all desired user stories being complete

### User Story Dependencies

- **User Story 1 (P1) - Camera Context**: Can start after Foundational (Phase 2) - No dependencies on other stories
- **User Story 2 (P2) - Client FAB**: Can start after Foundational (Phase 2) - Independent of US1 (different screens)
- **User Story 3 (P3) - Main Site FAB**: Can start after Foundational (Phase 2) - Independent of US1, US2 (different screens)
- **User Story 4 (P4) - SubSite FAB**: Can start after Foundational (Phase 2) - Independent of all other stories (different screen, simple FAB)

### Within Each User Story

- **Phase 1 Setup**: T001, T002, T003 can run in parallel (different model files), then T004 and T005 sequentially (depend on models)
- **Phase 2 Foundational**: T006 and T007 can run in parallel (different files)
- **Phase 3 US1**:
  - T008, T009 must be sequential (same file modifications)
  - T010, T011, T012, T013 can run in parallel (different methods in same file but independent logic)
  - T014, T015, T016, T017 can run in parallel (different screen files)
- **Phase 4 US2**: All tasks sequential (same file modifications in client_detail_screen.dart)
- **Phase 5 US3**: All tasks sequential (same file modifications in main_site_screen.dart)
- **Phase 6 US4**: All tasks sequential (same file modifications in sub_site_screen.dart)
- **Phase 7 Polish**: T036, T037, T038, T039, T040 can run in parallel (different concerns), T041 and T042 depend on all previous tasks

### Parallel Opportunities

**Within Setup Phase**:
```bash
# Launch model creation in parallel:
Task: "Create CameraContext model in lib/models/camera_context.dart"
Task: "Create FABMenuItem model in lib/models/fab_menu_item.dart"
Task: "Create SaveActionButton model in lib/models/save_action_button.dart"
```

**Within Foundational Phase**:
```bash
# Launch provider and router updates in parallel:
Task: "Update PhotoCaptureProvider in lib/providers/photo_capture_provider.dart"
Task: "Update router.dart in lib/router.dart"
```

**Across User Stories (if team capacity allows)**:
```bash
# After Foundational phase completes, all user stories can start in parallel:
Task: "User Story 1 - Camera Context (T008-T017)"
Task: "User Story 2 - Client FAB (T018-T024)"
Task: "User Story 3 - Main Site FAB (T025-T030)"
Task: "User Story 4 - SubSite FAB (T031-T035)"
```

**Within Polish Phase**:
```bash
# Launch validation tasks in parallel:
Task: "Manual testing pass using quickstart.md"
Task: "Performance validation: FAB expansion and camera context"
Task: "Verify all permission checks work correctly"
Task: "Verify invalid camera context defaults to home gracefully"
Task: "Code cleanup: Remove debug prints, add comments"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only) - Recommended Approach

**Estimated Effort**: 5-8 hours for experienced Flutter developer

1. ✅ Complete Phase 1: Setup (T001-T005) - Create models and widgets - **~2 hours**
2. ✅ Complete Phase 2: Foundational (T006-T007) - Provider and router updates - **~1 hour**
3. ✅ Complete Phase 3: User Story 1 (T008-T017) - Camera context-aware buttons - **~2-3 hours**
4. **STOP and VALIDATE**: Test User Story 1 independently using quickstart.md checklist
   - Test home context → "Next" and "Quick Save" buttons
   - Test equipment all photos → "Save to Equipment" button + mock SnackBar
   - Test before/after contexts → "Capture as Before/After" buttons + mock SnackBar
5. Deploy/demo if ready (MVP demonstrates core feature value)

**Value Delivered**: Users see context-appropriate camera save buttons, understand what context they're capturing in, even though actual save logic is placeholder

---

### Incremental Delivery (All User Stories)

**Estimated Effort**: 10-15 hours for experienced Flutter developer

1. ✅ Complete Setup + Foundational (T001-T007) → Foundation ready - **~3 hours**
2. ✅ Add User Story 1 (T008-T017) → Test independently → Deploy/Demo (MVP!) - **~2-3 hours**
3. ✅ Add User Story 2 (T018-T024) → Test independently → Deploy/Demo - **~2-3 hours**
4. ✅ Add User Story 3 (T025-T030) → Test independently → Deploy/Demo - **~1-2 hours**
5. ✅ Add User Story 4 (T031-T035) → Test independently → Deploy/Demo - **~1 hour**
6. ✅ Polish & Validation (T036-T042) → Final testing and cleanup - **~1-2 hours**

**Value per Increment**:
- **Increment 1 (US1)**: Context-aware camera buttons improve photo workflow clarity
- **Increment 2 (US1+US2)**: Client page FAB streamlines organizational item creation
- **Increment 3 (US1+US2+US3)**: Main site page FAB improves common workflows
- **Increment 4 (All stories)**: Complete feature - all navigation levels have context-appropriate FABs

---

### Parallel Team Strategy

With 2-3 developers (after Foundational phase completes):

**Team Setup**:
1. All developers complete Setup + Foundational together (T001-T007) - **~3 hours**

**Parallel User Story Work**:
2. Once Foundational is done:
   - **Developer A**: User Story 1 (Camera context) - T008-T017 - **~2-3 hours**
   - **Developer B**: User Story 2 (Client FAB) - T018-T024 - **~2-3 hours**
   - **Developer C**: User Story 3 + 4 (Site FABs) - T025-T035 - **~2-3 hours**

**Integration**:
3. Stories complete independently, merge one at a time
4. Final polish and validation together (T036-T042) - **~1-2 hours**

**Total Time**: ~6-8 hours with 3 developers (vs ~10-15 hours with 1 developer)

---

## Testing Strategy

**Note**: Automated tests (unit, widget, integration) were NOT requested in the feature specification. Testing approach focuses on manual validation using quickstart.md.

### Manual Testing Checklist (Task T036)

**Use quickstart.md for detailed test scenarios**:

**Camera Context Tests**:
- [ ] Home context displays "Next" and "Quick Save" modal
- [ ] Equipment all photos displays "Save to Equipment" button
- [ ] Equipment before displays "Capture as Before" button
- [ ] Equipment after displays "Capture as After" button
- [ ] Invalid context defaults to home gracefully
- [ ] Mock buttons show appropriate SnackBar and return to previous screen

**Expandable FAB Tests**:
- [ ] Client page FAB expands to 3 items (Main Site, SubSite, Equipment)
- [ ] Main site page FAB expands to 2 items (SubSite, Equipment)
- [ ] SubSite page has simple FAB (no expansion)
- [ ] Tap outside expanded FAB collapses it
- [ ] Tap menu item executes action and collapses FAB
- [ ] FAB hidden for viewer role on all pages

**Performance Tests** (Task T037):
- [ ] FAB expansion completes in < 300ms (use stopwatch or DevTools)
- [ ] Camera context detection is instant (no perceived delay)
- [ ] No frame drops during FAB expansion animation

**Permission Tests** (Task T038):
- [ ] Viewer role sees no FABs on any page
- [ ] Admin role sees all FABs and can create items
- [ ] Technician role sees all FABs and can create items

### Future Testing (Optional)

If tests are added later, follow test structure from plan.md:
- **Widget tests**: `test/widget/expandable_fab_test.dart`, `test/widget/context_save_buttons_test.dart`
- **Unit tests**: `test/unit/models/camera_context_test.dart`, `test/unit/providers/photo_capture_provider_test.dart`
- **Integration tests**: `test/integration/camera_context_flow_test.dart`

---

## Constitutional Compliance

All tasks align with constitutional articles:

- ✅ **Article I (Field-First)**: Context-aware buttons reduce decision time, FAB expansion supports one-handed operation
- ✅ **Article II (Offline Autonomy)**: All UI changes function entirely offline, no network dependencies added
- ✅ **Article III (Data Integrity)**: Mock functionality shows placeholders without modifying data, preserves existing behavior
- ✅ **Article IV (Hierarchical Consistency)**: FAB options match hierarchical level (Client: 3 types, Main Site: 2 types, SubSite: 1 type)
- ✅ **Article V (Privacy & Security)**: No new data collection, respects existing permission model
- ✅ **Article VI (Performance)**: FAB expansion < 300ms, camera context detection instant, no blocking operations
- ✅ **Article VII (Intuitive Simplicity)**: Standard material design patterns, clear action labels, no training needed
- ✅ **Article VIII (Modular Independence)**: Camera context isolated, FAB widgets reusable, independently testable
- ✅ **Article IX (Collaborative Transparency)**: No audit trail changes, uses existing user attribution

---

## Notes

- **[P] tasks** = different files, no dependencies, can run in parallel
- **[Story] label** maps task to specific user story (US1, US2, US3, US4) for traceability
- **Each user story is independently testable** per acceptance scenarios in spec.md
- **Mock functionality**: New camera buttons show placeholder messages (Phase 2 will implement actual save logic)
- **Existing behavior preserved**: Home context "Next" and "Quick Save" retain current functionality
- **FAB expansion uses custom widget** (not external package) for full control and customization
- **Camera context defaults to home** if invalid params provided (graceful degradation)
- **Permission model enforced**: FABs hidden for viewer role across all screens
- **Commit after each task or logical group** for easier code review and rollback if needed
- **Stop at any checkpoint** to validate story independently before proceeding

---

## Success Criteria Mapping

Tasks directly support these success criteria from spec.md:

- **SC-001**: 90% of users correctly identify context based on save button labels → US1 tasks (T008-T017)
- **SC-002**: 100% camera context detection accuracy → Foundational (T006-T007) + US1 (T008-T017)
- **SC-003**: Users understand button labels are context-aware → US1 tasks (T008-T017) with mock SnackBars
- **SC-004**: Create items in < 5 seconds from FAB tap → US2, US3, US4 tasks (T018-T035)
- **SC-005**: FAB expansion < 300ms → Setup (T004) + Performance validation (T037)
- **SC-006**: 95% understand creation options at each level → US2, US3, US4 tasks (T018-T035)
- **SC-007**: Zero confusion about camera context → US1 tasks (T008-T017) + Manual testing (T036)
- **SC-008**: Context-aware labels consistent across equipment paths → US1 tasks (T015-T017)

---

## Task Summary

- **Total Tasks**: 42 tasks across 7 phases
- **MVP Tasks (Setup + Foundational + US1)**: 17 tasks (T001-T017)
- **Full Feature Tasks**: 42 tasks (all phases)
- **Parallel Opportunities**:
  - Setup: 3 tasks can run in parallel (T001-T003)
  - Foundational: 2 tasks can run in parallel (T006-T007)
  - User Stories: All 4 stories can run in parallel after Foundational
  - Polish: 5 tasks can run in parallel (T036-T040)
- **Estimated Total Effort**: 10-15 hours (single developer, all stories)
- **Estimated MVP Effort**: 5-8 hours (single developer, US1 only)

---

**Generated by**: `/speckit.tasks` command
**Date**: 2025-10-12
**Ready for**: `/speckit.implement` command to begin execution
