# Implementation Plan: Work Site Photo Capture Page

**Branch**: `003-specify-feature-work` | **Date**: 2025-10-07 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/Users/hyrumharris/src/sitepictures/specs/003-specify-feature-work/spec.md`

## Execution Flow (/plan command scope)
```
1. Load feature spec from Input path
   → SUCCESS: Spec loaded with clarifications complete
2. Fill Technical Context (scan for NEEDS CLARIFICATION)
   → Project Type: Mobile (Flutter)
   → Structure Decision: Flutter mobile app with lib/ structure
3. Fill the Constitution Check section based on the constitution document.
4. Evaluate Constitution Check section below
   → All constitutional principles aligned
   → Update Progress Tracking: Initial Constitution Check PASS
5. Execute Phase 0 → research.md
   → Research Flutter camera best practices, state management, image compression
6. Execute Phase 1 → contracts, data-model.md, quickstart.md, CLAUDE.md
7. Re-evaluate Constitution Check section
   → Verify field-first, offline-first, performance primacy maintained
   → Update Progress Tracking: Post-Design Constitution Check
8. Plan Phase 2 → Describe task generation approach (DO NOT create tasks.md)
9. STOP - Ready for /tasks command
```

**IMPORTANT**: The /plan command STOPS at step 9. Phases 2-4 are executed by other commands:
- Phase 2: /tasks command creates tasks.md
- Phase 3-4: Implementation execution (manual or via tools)

## Summary
Implement a field-optimized photo capture page that allows technicians to quickly document work site conditions. The page provides full-screen camera preview, rapid photo capture (up to 20 images per session), thumbnail review with deletion, and session completion with placeholder Next/Quick Save buttons. Critical features include session preservation during app backgrounding, camera permission handling, and smooth performance with 10-20 images. Photos are stored as JPEG with medium quality in temporary local storage.

## Technical Context
**Language/Version**: Dart 3.x / Flutter SDK 3.24+
**Primary Dependencies**: camera (live preview & capture), path_provider (temp storage), permission_handler (runtime permissions), provider (state management), flutter_image_compress (optional thumbnail optimization)
**Storage**: Temporary local file system (path_provider's getTemporaryDirectory), future integration with SQLite for permanent storage
**Testing**: flutter_test (widget tests), integration_test (full flow tests), flutter_driver (performance validation)
**Target Platform**: iOS 13+ and Android 8.0+ (mobile devices with rear cameras)
**Project Type**: Mobile (Flutter) - single app with potential future API integration
**Performance Goals**: Photo capture < 2s from tap to save, thumbnail scroll 60fps, UI navigation < 500ms, camera preview initialization < 1s
**Constraints**: Offline-first (no network required), < 5% battery drain per hour active use, smooth with 20 photos @ JPEG medium quality (~500KB each), one-handed operation capability
**Scale/Scope**: Single feature screen (CameraCapturePage) with 3-4 supporting widgets, ~500-800 LOC, session state management for up to 20 photos

## Constitution Check
*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

### Article I: Field-First Architecture ✅
- **Quick photo capture**: < 2s capture time, large centered capture button for one-handed use
- **Offline-first**: All operations local, no network dependency
- **One-handed operation**: Capture button bottom-center, Cancel/Done accessible at top corners
- **Clear visual hierarchy**: Full-screen preview, prominent controls, thumbnail strip above capture
- **Battery preservation**: Efficient camera controller disposal, compressed images reduce I/O

### Article II: Offline Autonomy ✅
- **Fully offline**: Photos stored in temporary local storage via path_provider
- **No network required**: All capture, review, delete operations local
- **Local data access**: Photos remain accessible until explicitly saved/discarded
- **Future sync ready**: Temporary storage enables future upload queue integration

### Article III: Data Integrity Above All ✅
- **Session preservation**: Photos retained when app backgrounded (FR-029, FR-030)
- **Immutable originals**: Captured photos stored immediately, deletion explicit user action
- **No accidental loss**: Confirmation dialog when canceling with unsaved photos (FR-018)
- **Error recovery**: Camera failures handled gracefully with clear user messaging (FR-024)
- **Temporary backup**: Photos in temp storage survive app restart until session completion

### Article IV: Hierarchical Consistency ⚠️
- **Deferred integration**: Current scope is isolated capture page; future work connects to Client→Site→Equipment hierarchy
- **No current violation**: Photo capture screen doesn't navigate hierarchy yet
- **Future alignment**: Next button will route to details screen respecting hierarchy context

### Article V: Privacy and Security by Design ✅
- **Permission-based**: Explicit camera permission request with clear messaging (FR-021, FR-022, FR-023)
- **Local-only storage**: Photos remain on device until user-initiated save
- **No telemetry**: Pure local operations, no analytics in capture flow
- **GPS deferred**: Location metadata not included in initial scope (clarified as deferred)

### Article VI: Performance Primacy ✅
- **< 2s photo capture**: Aligned with constitution's photo capture threshold
- **< 500ms navigation**: UI transitions meet constitutional standard
- **60fps scrolling**: Thumbnail ListView optimized for smooth scrolling (FR-026)
- **< 5% battery/hour**: Efficient camera controller, image compression, proper disposal
- **Responsive under load**: Smooth performance validated with 10-20 images (FR-012)

### Article VII: Intuitive Simplicity ✅
- **No training required**: Standard camera UI patterns (shutter button, thumbnails, cancel/done)
- **Clear visual cues**: Large capture button, visible X delete overlays, labeled top buttons
- **Actionable errors**: Permission denial shows how to enable (FR-023)
- **Consistent patterns**: Follows Flutter Material Design conventions
- **Graceful degradation**: Clear messaging when camera unavailable or permission denied

### Article VIII: Modular Independence ✅
- **Standalone widget**: CameraCapturePage is self-contained StatefulWidget
- **Camera isolation**: Camera functionality independent of broader app (reusable)
- **Testable isolation**: Widget tests, integration tests, unit tests for state management
- **Decoupled from hierarchy**: Capture logic separate from Client/Site/Equipment models
- **Provider state**: Session state isolated in PhotoCaptureProvider

### Article IX: Collaborative Transparency 🔄
- **Future requirement**: Current scope is single-user capture session
- **No multi-user yet**: Photo attribution/audit trails deferred to permanent storage phase
- **Preparation**: Capture timestamp (FR-008 via entity) enables future audit trail
- **Alignment path**: When photos saved permanently, timestamp + user context enable traceability

**Constitutional Verdict**: ✅ PASS with deferred items
- Articles I, II, III, V, VI, VII, VIII: Full compliance
- Article IV: Deferred (hierarchy integration in future details screen)
- Article IX: Deferred (audit trails in future permanent storage)

## Project Structure

### Documentation (this feature)
```
specs/003-specify-feature-work/
├── plan.md              # This file (/plan command output)
├── research.md          # Phase 0 output (/plan command)
├── data-model.md        # Phase 1 output (/plan command)
├── quickstart.md        # Phase 1 output (/plan command)
├── contracts/           # Phase 1 output (/plan command)
│   ├── photo_capture_widget_contract.md
│   └── photo_session_state_contract.md
└── tasks.md             # Phase 2 output (/tasks command - NOT created by /plan)
```

### Source Code (repository root)
```
lib/
├── screens/
│   └── camera_capture_page.dart         # Main camera capture screen (NEW)
├── widgets/
│   ├── camera_preview_overlay.dart      # Top bar with Cancel/Done (NEW)
│   ├── photo_thumbnail_strip.dart       # Horizontal scrolling thumbnails (NEW)
│   └── capture_button.dart              # Large centered shutter button (NEW)
├── providers/
│   └── photo_capture_provider.dart      # Session state management (NEW)
├── models/
│   ├── photo.dart                       # Photo entity (EXISTING - may extend)
│   └── photo_session.dart               # Photo session model (NEW)
├── services/
│   ├── camera_service.dart              # Camera initialization & control (NEW)
│   └── photo_storage_service.dart       # Temporary file storage (NEW)
└── router.dart                          # Add camera capture route (MODIFY)

test/
├── widget/
│   ├── screens/
│   │   └── camera_capture_page_test.dart      # Widget tests for main screen (NEW)
│   └── widgets/
│       ├── camera_preview_overlay_test.dart   # Widget tests for overlay (NEW)
│       ├── photo_thumbnail_strip_test.dart    # Widget tests for thumbnails (NEW)
│       └── capture_button_test.dart           # Widget tests for button (NEW)
├── unit/
│   ├── providers/
│   │   └── photo_capture_provider_test.dart   # State management tests (NEW)
│   ├── services/
│   │   ├── camera_service_test.dart           # Camera service tests (NEW)
│   │   └── photo_storage_service_test.dart    # Storage service tests (NEW)
│   └── models/
│       └── photo_session_test.dart            # Photo session model tests (NEW)
└── integration_test/
    └── camera_capture_flow_test.dart          # End-to-end capture flow (NEW)

integration_test/
└── camera_capture_flow_test.dart              # Full user journey test (NEW)
```

**Structure Decision**: Flutter mobile app with existing `lib/` structure. This feature adds a new screen under `lib/screens/`, supporting widgets under `lib/widgets/`, state management under `lib/providers/`, services under `lib/services/`, and models under `lib/models/`. Tests follow existing structure: widget tests, unit tests, and integration tests. The architecture maintains modular independence (Article VIII) with clear separation of concerns: UI (screens/widgets), state (providers), business logic (services), and data (models).

## Phase 0: Outline & Research
1. **Extract unknowns from Technical Context** above:
   - ✅ No NEEDS CLARIFICATION remaining (all resolved in /clarify phase)
   - Research tasks:
     - Flutter camera plugin best practices (initialization, disposal, error handling)
     - Image compression techniques for thumbnail generation (flutter_image_compress vs manual)
     - State management patterns for photo session (Provider vs Riverpod)
     - Permission handling UX patterns (permission_handler best practices)
     - Temporary file storage and cleanup strategies (path_provider patterns)
     - Performance optimization for ListView with image thumbnails
     - App lifecycle handling for camera controller (backgrounding, resuming)

2. **Generate and dispatch research agents**:
   ```
   Task 1: "Research Flutter camera plugin initialization, disposal, and error handling best practices"
   Task 2: "Find performance-optimized image thumbnail generation patterns for Flutter ListView"
   Task 3: "Research Provider vs Riverpod state management for photo session (list of XFile objects, max 20 items)"
   Task 4: "Find permission_handler best practices for camera permissions in Flutter with clear error messaging"
   Task 5: "Research path_provider temporary storage patterns and cleanup strategies for photo sessions"
   Task 6: "Find Flutter app lifecycle patterns for preserving camera state during backgrounding"
   Task 7: "Research JPEG compression quality settings in Flutter for medium quality (balance size/quality)"
   ```

3. **Consolidate findings** in `research.md` using format:
   - Decision: [what was chosen]
   - Rationale: [why chosen]
   - Alternatives considered: [what else evaluated]

**Output**: research.md with all technology decisions documented

## Phase 1: Design & Contracts
*Prerequisites: research.md complete*

1. **Extract entities from feature spec** → `data-model.md`:
   - **Photo**: Represents single captured image
     - Fields: id (String), filePath (String), captureTimestamp (DateTime), displayOrder (int)
     - Validation: filePath must exist, captureTimestamp not null, displayOrder >= 0
     - Relationships: belongs to PhotoSession
   - **PhotoSession**: Represents collection of photos in single capture session
     - Fields: id (String), photos (List<Photo>), startTime (DateTime), status (SessionStatus enum: inProgress/completed/cancelled), maxPhotos (int = 20)
     - Validation: photos.length <= maxPhotos, startTime not null, status not null
     - State transitions: inProgress → completed (Done pressed) OR inProgress → cancelled (Cancel confirmed)
   - State management entities:
     - **PhotoCaptureState**: Provider state holding current PhotoSession, camera controller status, error messages

2. **Generate API contracts** from functional requirements:
   - No traditional REST API (local Flutter app), but define widget contracts:
     - **CameraCapturePage contract**: Inputs (navigation params for future context), Outputs (completed photo list or cancellation)
     - **PhotoCaptureProvider contract**: Methods (capturePhoto, deletePhoto, completeSession, cancelSession), State (photos, isAtLimit, sessionStatus)
     - **CameraService contract**: Methods (initialize, dispose, takePicture, requestPermissions), Events (onPermissionDenied, onCameraError)
     - **PhotoStorageService contract**: Methods (saveTempPhoto, deleteTempPhoto, clearSessionPhotos), Returns (file paths)
   - Output contract specs to `/contracts/photo_capture_widget_contract.md` and `/contracts/photo_session_state_contract.md`

3. **Generate contract tests** from contracts:
   - Widget contract tests (test/widget/):
     - test_camera_capture_page_renders_preview.dart (FR-001)
     - test_camera_capture_page_cancel_button.dart (FR-002)
     - test_camera_capture_page_done_button.dart (FR-003)
     - test_capture_button_takesphoto.dart (FR-005)
   - Provider contract tests (test/unit/providers/):
     - test_photo_capture_provider_add_photo.dart
     - test_photo_capture_provider_delete_photo.dart
     - test_photo_capture_provider_20_photo_limit.dart
   - Service contract tests (test/unit/services/):
     - test_camera_service_initialize.dart
     - test_camera_service_permissions.dart
     - test_photo_storage_service_save_temp.dart
   - Tests must fail initially (no implementation yet)

4. **Extract test scenarios** from user stories:
   - Acceptance Scenario 1 → integration test: "Camera page loads with preview and controls"
   - Acceptance Scenario 2 → integration test: "Capture button creates thumbnail"
   - Acceptance Scenario 3 → integration test: "Delete thumbnail removes photo"
   - Acceptance Scenario 4 → integration test: "Done button shows modal popup"
   - Acceptance Scenario 7 → integration test: "Cancel with photos shows confirmation"
   - Acceptance Scenario 10 → integration test: "No permissions shows error message"
   - Create quickstart.md with these test scenarios as validation steps

5. **Update agent file incrementally** (O(1) operation):
   - Run `.specify/scripts/bash/update-agent-context.sh claude`
   - Add NEW tech from current plan:
     - Flutter camera plugin
     - path_provider
     - permission_handler
     - Provider state management
     - flutter_image_compress (if chosen)
   - Preserve manual additions between `<!-- MANUAL ADDITIONS START -->` and `<!-- MANUAL ADDITIONS END -->`
   - Update recent changes (keep last 3 features)
   - Keep CLAUDE.md under 150 lines for token efficiency
   - Output to `/Users/hyrumharris/src/sitepictures/CLAUDE.md`

**Output**: data-model.md, /contracts/*, failing tests (8-10 contract tests), quickstart.md, CLAUDE.md updated

## Phase 2: Task Planning Approach
*This section describes what the /tasks command will do - DO NOT execute during /plan*

**Task Generation Strategy**:
- Load `.specify/templates/tasks-template.md` as base
- Generate tasks from Phase 1 design docs (contracts, data model, quickstart)
- **Contract test tasks** (must be first, TDD approach):
  - [P] Widget contract tests (4 files) - can run in parallel
  - [P] Provider contract tests (3 files) - can run in parallel
  - [P] Service contract tests (3 files) - can run in parallel
- **Model creation tasks**:
  - [P] Create Photo model (extends existing if present)
  - [P] Create PhotoSession model
- **Service implementation tasks** (dependencies on models):
  - Create CameraService (depends on Photo model)
  - Create PhotoStorageService (depends on Photo model)
- **Provider implementation tasks** (depends on models + services):
  - Create PhotoCaptureProvider (depends on PhotoSession, CameraService, PhotoStorageService)
- **Widget implementation tasks** (depends on provider):
  - Create CaptureButton widget
  - Create PhotoThumbnailStrip widget
  - Create CameraPreviewOverlay widget
- **Screen implementation tasks** (depends on all widgets + provider):
  - Create CameraCapturePage (assembles all components)
- **Integration tasks**:
  - Add camera capture route to router.dart
  - Add navigation to camera page from home/client screen
- **Integration test tasks** (depends on full implementation):
  - Create camera_capture_flow_test.dart (end-to-end scenarios)
- **Validation tasks**:
  - Run all tests (contract, unit, widget, integration)
  - Execute quickstart.md validation
  - Performance validation (thumbnail scroll, capture latency)

**Ordering Strategy**:
- TDD order: All contract tests first (fail initially), then implementation to make them pass
- Dependency order: Models → Services → Providers → Widgets → Screens → Integration
- Mark [P] for parallel execution:
  - All contract test creation can be parallel
  - Model creation can be parallel (Photo and PhotoSession independent)
  - Service creation can be parallel (after models complete)
  - Widget creation can be parallel (after provider complete)
- Sequential dependencies clearly marked in task list

**Estimated Output**: 30-35 numbered, ordered tasks in tasks.md
- 10 contract test tasks
- 2 model tasks
- 2 service tasks
- 1 provider task
- 3 widget tasks
- 1 screen task
- 2 integration tasks
- 1 integration test task
- 3 validation tasks
- 5-10 refinement/polish tasks (error handling, edge cases, performance tuning)

**IMPORTANT**: This phase is executed by the /tasks command, NOT by /plan

## Phase 3+: Future Implementation
*These phases are beyond the scope of the /plan command*

**Phase 3**: Task execution (/tasks command creates tasks.md)
**Phase 4**: Implementation (execute tasks.md following constitutional principles)
- Follow TDD: Write failing tests first, implement to make them pass
- Maintain constitutional compliance: Field-first UX, offline-first, performance validation, modular independence
- Code review checkpoints: After models, after services, after widgets, after screen, before integration
**Phase 5**: Validation (run tests, execute quickstart.md, performance validation)
- All contract tests pass
- All widget tests pass
- All integration tests pass
- Quickstart scenarios execute successfully
- Performance validation: Capture < 2s, scroll 60fps, navigation < 500ms
- Constitutional compliance re-check: Field usability, battery impact, one-handed operation

## Complexity Tracking
*Fill ONLY if Constitution Check has violations that must be justified*

**No violations requiring justification.** All constitutional principles are aligned:
- Deferred items (Article IV hierarchy integration, Article IX audit trails) are explicitly scoped as future work and do not violate current implementation.
- Current implementation maintains constitutional compliance within its bounded scope.

## Progress Tracking
*This checklist is updated during execution flow*

**Phase Status**:
- [x] Phase 0: Research complete (/plan command)
- [x] Phase 1: Design complete (/plan command)
- [x] Phase 2: Task planning complete (/plan command - describe approach only)
- [x] Phase 3: Tasks generated (/tasks command)
- [ ] Phase 4: Implementation complete
- [ ] Phase 5: Validation passed

**Gate Status**:
- [x] Initial Constitution Check: PASS
- [x] Post-Design Constitution Check: PASS
- [x] All NEEDS CLARIFICATION resolved (completed in /clarify phase)
- [x] Complexity deviations documented (none required)

**Artifacts Generated**:
- [x] research.md (8 research decisions documented)
- [x] data-model.md (3 entities: Photo, PhotoSession, PhotoCaptureState)
- [x] contracts/photo_capture_widget_contract.md (5 widgets, 26 contract tests)
- [x] contracts/photo_session_state_contract.md (3 components, 51 contract tests)
- [x] quickstart.md (11 acceptance scenarios + 6 performance tests + 4 edge cases)
- [x] CLAUDE.md updated (new dependencies added)
- [x] tasks.md (110 tasks: 86 tests + 14 implementation + 10 polish/validation)

---
*Based on Constitution v1.0.0 - See `.specify/memory/constitution.md`*
