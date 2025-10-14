# Implementation Plan: Camera Photo Save Functionality

**Branch**: `006-i-want-to` | **Date**: 2025-10-13 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/006-i-want-to/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/commands/plan.md` for the execution workflow.

## Summary

Implement comprehensive camera photo save functionality with three context-aware workflows: (1) Home camera with Quick Save to global "Needs Assigned" folder and Next button for equipment navigation, (2) Equipment Photos Tab for direct save to equipment's general photos, and (3) Folder Before/After tabs for categorized save. Technical approach uses special client record for global "Needs Assigned" (simple container, no per-client folders), incremental save with rollback on critical failure, and existing hierarchical navigation UI for equipment selection.

## Technical Context

**Language/Version**: Dart 3.8.1 / Flutter SDK 3.24+
**Primary Dependencies**: Flutter Framework, sqflite (SQLite), provider (state management), camera, go_router (navigation), uuid, intl
**Storage**: SQLite database (sqflite) for metadata and associations; local file system for photo files
**Testing**: Flutter widget tests, unit tests (Dart test package), integration tests
**Target Platform**: iOS 13+ and Android 8.0+ (mobile cross-platform)
**Project Type**: Mobile application (Flutter)
**Performance Goals**: Photo save ≤15s for 20 photos, navigation ≤500ms between screens, camera launch <2s
**Constraints**: Offline-first operation, battery efficient (≤5% drain/hour), incremental save with rollback, one-handed operation
**Scale/Scope**: Extends existing camera capture (features 003/005), adds 3 save contexts, single global "Needs Assigned" folder

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

### Article I: Field-First Architecture ✅ PASS
- **Quick photo capture**: Home page Quick Save enables immediate storage without navigation friction
- **One-handed operation**: All save contexts minimize taps (equipment/folder contexts are zero-tap saves)
- **Clear visual hierarchy**: "Needs Assigned" folders visually distinguished with unique icon + label
- **Offline-first**: All save operations work completely offline using local SQLite + file system

### Article II: Offline Autonomy ✅ PASS
- **Full offline operation**: No network connectivity required for any save workflow
- **Local storage**: SQLite for metadata, local file system for photos (Dependency 5 confirmed)
- **Sync later**: Photos saved locally, sync handled by existing infrastructure (out of scope)
- **No connectivity dependency**: Equipment navigator, Quick Save, and all contexts function offline

### Article III: Data Integrity Above All ✅ PASS
- **Incremental save with rollback**: Clarification confirms one-by-one save with rollback on critical failure (FR-055, FR-055a/b/c)
- **Session preservation**: FR-019, FR-052, FR-055c preserve photos in session on save failure, enable retry
- **Comprehensive logging**: FR-056 requires logging all save operations and errors for audit/debugging
- **No data loss**: Partial save keeps successfully saved photos (FR-055b), critical errors rollback and preserve entire session (FR-055c)

### Article IV: Hierarchical Consistency ✅ PASS
- **Respects client→site→equipment hierarchy**: Equipment navigator (FR-013) uses existing hierarchical navigation (Client → Main Site → SubSite → Equipment)
- **Global "Needs Assigned" as special client**: Clarification specifies special client record (id="GLOBAL_NEEDS_ASSIGNED") with system flag, maintaining hierarchy consistency as simple organizational container
- **Photo associations**: FR-049 maintains referential integrity between photos and associated entities (equipment, folders)

### Article V: Privacy and Security by Design ✅ PASS
- **GPS with consent**: Assumption 8 states geolocation services provide lat/long for metadata (existing consent flow assumed)
- **Local-only**: All save operations local to device, no telemetry or external calls
- **User attribution**: Assumption 7 confirms "captured_by" and "created_by" fields set from current user context
- **Company data isolation**: Equipment/folder associations enforce organizational boundaries

### Article VI: Performance Primacy ✅ PASS
- **Photo save performance**: SC-010 specifies 15 seconds for 20 photos (0.75s per photo average with I/O, thumbnails, DB writes)
- **Navigation**: SC-002 specifies 30 seconds for Next button workflow to select equipment; ≤500ms per screen aligns with constitution
- **Quick Save speed**: SC-001 specifies under 10 seconds for capture→Done→Quick Save workflow
- **Non-blocking save**: FR-057 requires visual feedback during save (loading indicator), implies async/background processing

### Article VII: Intuitive Simplicity ✅ PASS
- **Context-aware UI**: Camera context determines save options automatically (no user choice required for equipment/folder contexts)
- **Clear confirmation**: FR-058, FR-059, FR-060 require success/failure messages indicating destination and count
- **Visual distinction**: Per-client "Needs Assigned" uses unique icon + "Needs Assigned" label (Clarification 4) for instant recognition
- **Error recovery**: FR-052, FR-055c preserve session on failure and enable retry with actionable messaging

### Article VIII: Modular Independence ✅ PASS
- **Camera functionality independent**: Save logic extends existing camera (features 003/005) without modifying capture (Assumption 1)
- **Equipment navigator separable**: FR-013 reuses existing hierarchical navigation UI (Assumption 4, Dependency 4)
- **Photo storage service**: Dependency 5 specifies photo storage service handles moving temp→permanent storage
- **Folder service**: Dependency 6 specifies folder service creates folders in global "Needs Assigned" context

### Article IX: Collaborative Transparency ✅ PASS
- **User attribution**: Assumption 7 confirms "captured_by" metadata captured on save
- **Audit trail**: FR-056 requires logging all save operations and errors
- **Timestamp tracking**: Photo metadata includes timestamp (FR-047), folders have creation date (FR-025)
- **Referential integrity**: FR-049 maintains traceable associations between photos and entities

### Constitutional Violations: **NONE**

All nine constitutional articles satisfied. Feature aligns with field-first architecture, offline autonomy, data integrity, and performance primacy principles.

## Project Structure

### Documentation (this feature)

```
specs/006-i-want-to/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
├── checklists/
│   └── requirements.md  # Quality checklist from /speckit.specify
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)

```
lib/
├── models/
│   ├── camera_context.dart           # Existing (feature 005)
│   ├── photo.dart                     # Existing (feature 004)
│   ├── photo_folder.dart              # Existing (feature 004)
│   ├── folder_photo.dart              # Existing (feature 004)
│   ├── photo_session.dart             # Existing (feature 003)
│   ├── client.dart                    # Existing
│   ├── quick_save_item.dart           # NEW - Quick Save result entity
│   └── equipment_navigation_node.dart # NEW - Equipment navigator tree node
│
├── providers/
│   ├── photo_capture_provider.dart    # Existing (feature 003/005) - EXTEND
│   ├── folder_provider.dart           # Existing (feature 004)
│   ├── needs_assigned_provider.dart   # NEW - Global "Needs Assigned" management
│   └── equipment_navigator_provider.dart # NEW - Equipment selection state
│
├── services/
│   ├── camera_service.dart            # Existing (feature 003)
│   ├── photo_storage_service.dart     # Existing (feature 003) - EXTEND
│   ├── folder_service.dart            # Existing (feature 004) - EXTEND
│   ├── database_service.dart          # Existing - EXTEND (add system flag to clients)
│   ├── quick_save_service.dart        # NEW - Quick Save logic (single/multi photo)
│   └── photo_save_service.dart        # NEW - Context-aware save orchestration
│
├── screens/
│   ├── camera_capture_page.dart       # Existing (feature 003/005) - EXTEND
│   ├── equipment/
│   │   ├── equipment_detail_page.dart # Existing
│   │   ├── all_photos_tab.dart        # Existing
│   │   ├── folders_tab.dart           # Existing (feature 004)
│   │   └── folder_detail_screen.dart  # Existing (feature 004)
│   ├── equipment_navigator_page.dart  # NEW - Equipment selection for Next button
│   └── needs_assigned_page.dart       # NEW - Global "Needs Assigned" view
│
├── widgets/
│   ├── capture_button.dart            # Existing (feature 003)
│   ├── photo_thumbnail_strip.dart     # Existing (feature 003)
│   ├── camera_preview_overlay.dart    # Existing (feature 003)
│   ├── context_aware_save_buttons.dart # Existing (feature 005) - EXTEND
│   ├── equipment_navigator_tree.dart  # NEW - Hierarchical equipment selector
│   ├── needs_assigned_badge.dart      # NEW - Visual indicator for special folders
│   └── save_progress_indicator.dart   # NEW - Loading UI for multi-photo saves
│
└── utils/
    ├── date_formatter.dart            # Existing
    ├── sequential_namer.dart          # NEW - Naming with (2), (3) disambiguation
    └── save_result.dart               # NEW - Save operation result wrapper

tests/
├── unit/
│   ├── services/
│   │   ├── quick_save_service_test.dart
│   │   └── photo_save_service_test.dart
│   ├── providers/
│   │   └── needs_assigned_provider_test.dart
│   └── utils/
│       └── sequential_namer_test.dart
│
├── widget/
│   ├── equipment_navigator_tree_test.dart
│   └── save_progress_indicator_test.dart
│
└── integration/
    ├── home_quick_save_test.dart
    ├── equipment_direct_save_test.dart
    ├── folder_before_after_save_test.dart
    └── partial_save_recovery_test.dart
```

**Structure Decision**: Mobile application (Flutter) structure with feature-based organization. Existing camera capture infrastructure (features 003, 005) extended with save services and providers. Equipment navigator reuses existing hierarchical navigation patterns. "Needs Assigned" implemented as special client record in existing database schema. Tests organized by type (unit/widget/integration) with full coverage of save workflows and edge cases.

## Complexity Tracking

*No constitutional violations - section not required*
