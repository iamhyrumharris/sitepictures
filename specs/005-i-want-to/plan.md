# Implementation Plan: Context-Aware Camera and Expandable Navigation FABs

**Branch**: `005-i-want-to` | **Date**: 2025-10-11 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/005-i-want-to/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/commands/plan.md` for the execution workflow.

## Summary

This feature implements context-aware button labeling on the camera capture screen and expandable FAB menus for streamlined organizational item creation. The camera page will display different save action buttons based on launch context (home, equipment all photos, equipment before/after folders), while FABs on client, main site, and subsite pages will expand to show contextually appropriate creation options. This phase focuses on UI implementation with mock functionality for new camera buttons; actual photo save logic will be implemented in a future phase.

## Technical Context

**Language/Version**: Dart 3.8.1 / Flutter SDK 3.24+
**Primary Dependencies**: Flutter Framework, provider (state management), go_router (navigation), camera, sqflite
**Storage**: SQLite database via sqflite (for organizational data); local file system for photos
**Testing**: Flutter widget tests, unit tests with mockito, integration tests
**Target Platform**: iOS 15+ and Android 8.0+ (mobile cross-platform)
**Project Type**: Mobile (Flutter cross-platform)
**Performance Goals**: FAB expansion < 300ms, camera context detection instant, UI responsiveness < 500ms
**Constraints**: Offline-capable (no network for core functionality), battery-efficient UI animations, one-handed operation support
**Scale/Scope**: 4 screen modifications (client, main site, subsite, camera), 2 new widget types (expandable FAB, context button renderer), existing camera provider enhancement

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

### Article I: Field-First Architecture ✅ PASS
- **Quick photo capture**: Context-aware buttons reduce decision time when saving photos
- **One-handed operation**: FAB expansion designed for thumb reach on mobile devices
- **Clear visual hierarchy**: Expandable FABs use material design patterns optimized for mobile
- **Minimal friction**: Reduces taps needed for common workflows (equipment photo saves, organizational item creation)

**Justification**: Feature directly enhances field worker efficiency by providing context-appropriate actions based on current workflow state.

### Article II: Offline Autonomy ✅ PASS
- **No network dependency**: All UI changes function entirely offline
- **Local state management**: Camera context and FAB expansion state managed locally via provider
- **SQLite integration**: Organizational item creation uses existing offline SQLite database

**Justification**: Feature adds no network dependencies; purely enhances offline-first UI flows.

### Article III: Data Integrity Above All ✅ PASS (with note)
- **No photo loss risk**: Mock save functionality shows placeholder messages without modifying data
- **Existing behavior preserved**: Home context "Next" and "Quick Save" buttons retain current functionality
- **Validation before action**: Context validation prevents invalid camera launches (defaults to home)

**Note**: Actual photo save logic (Phase 2) will require transaction-based operations and conflict resolution - deferred to future implementation.

### Article IV: Hierarchical Consistency ✅ PASS
- **Respects hierarchy**: FAB options match hierarchical level (Client: all 3 types, Main Site: 2 types, SubSite: equipment only)
- **Context preservation**: Creation dialogs maintain parent context (clientId, mainSiteId, subSiteId)
- **Camera context validation**: Before/after context requires valid folder hierarchy

**Justification**: Feature reinforces hierarchy by providing context-appropriate creation options at each level.

### Article V: Privacy and Security by Design ✅ PASS
- **No new data collection**: Feature adds no telemetry, analytics, or external data transmission
- **Existing permission model**: Leverages current admin/technician/viewer role enforcement
- **Context data local**: Camera launch context passed via navigation params, not persisted

**Justification**: Feature is purely UI enhancement with no security/privacy implications.

### Article VI: Performance Primacy ✅ PASS
- **FAB expansion**: Target < 300ms (success criteria SC-005)
- **Camera context detection**: Instant (success criteria SC-002: 100% accuracy)
- **Navigation responsiveness**: < 500ms (success criteria SC-004: < 5 seconds to dialog)
- **No blocking operations**: UI animations use Flutter's hardware-accelerated rendering

**Justification**: Performance targets align with constitutional thresholds; no heavy computations introduced.

### Article VII: Intuitive Simplicity ✅ PASS
- **Visual cues**: Expandable FABs use standard material design speed dial patterns
- **Clear labeling**: Context-aware buttons explicitly state action (e.g., "Capture as Before")
- **No training needed**: FAB tap-to-expand and context buttons are self-explanatory
- **Graceful degradation**: Viewer role hides FABs entirely; invalid context defaults to home behavior

**Justification**: Feature uses familiar UI patterns and clear action labeling requiring no documentation.

### Article VIII: Modular Independence ✅ PASS
- **Camera independence**: Context detection isolated to camera page; doesn't affect core capture functionality
- **FAB modularity**: Expandable FAB can be extracted as reusable widget
- **State isolation**: Camera context provider and FAB expansion state are separate concerns
- **Testable components**: Context rendering and FAB expansion logic independently testable

**Justification**: Feature components can be developed, tested, and maintained independently.

### Article IX: Collaborative Transparency ✅ PASS
- **No audit trail changes**: Feature doesn't modify data creation/edit workflows
- **Existing attribution**: Organizational items created through FABs use current user attribution system
- **No new collaboration features**: Pure UI enhancement without team collaboration aspects

**Justification**: Feature doesn't impact collaboration or audit trail functionality.

### Constitution Compliance Summary

**Overall Status**: ✅ **PASS** - All 9 constitutional articles satisfied

**Key Strengths**:
- Enhances field-first workflow efficiency (Article I)
- Maintains offline-first architecture (Article II)
- Uses modular, testable design (Article VIII)
- Preserves data integrity with mock functionality (Article III)

**Future Considerations**:
- Phase 2 (actual save logic) will require explicit Article III validation for transaction safety
- Performance monitoring needed during implementation to validate Article VI compliance

## Project Structure

### Documentation (this feature)

```
specs/005-i-want-to/
├── plan.md              # This file (/speckit.plan command output)
├── spec.md              # Feature specification (already created)
├── research.md          # Phase 0 output (to be generated)
├── data-model.md        # Phase 1 output (to be generated)
├── quickstart.md        # Phase 1 output (to be generated)
├── contracts/           # Phase 1 output (to be generated)
│   ├── camera-context.md
│   └── fab-expansion.md
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)

```
lib/
├── models/
│   └── camera_context.dart           # NEW: Camera context enum and utilities
├── providers/
│   └── photo_capture_provider.dart    # MODIFIED: Add context detection
├── widgets/
│   ├── expandable_fab.dart            # NEW: Reusable expandable FAB widget
│   ├── context_aware_save_buttons.dart # NEW: Camera save button renderer
│   └── fab_menu_item.dart             # NEW: Individual FAB expansion item
├── screens/
│   ├── camera_capture_page.dart       # MODIFIED: Context-aware button rendering
│   ├── clients/
│   │   └── client_detail_screen.dart  # MODIFIED: 3-option expandable FAB
│   ├── sites/
│   │   ├── main_site_screen.dart      # MODIFIED: 2-option expandable FAB
│   │   └── sub_site_screen.dart       # NO CHANGE: Keep simple FAB
│   └── equipment/
│       └── equipment_screen.dart      # MODIFIED: Pass context to camera
└── router.dart                         # MODIFIED: Pass camera context params

test/
├── widget/
│   ├── expandable_fab_test.dart       # NEW: Widget tests for FAB
│   ├── context_save_buttons_test.dart # NEW: Widget tests for camera buttons
│   └── screens/
│       └── camera_screen_test.dart    # MODIFIED: Add context tests
├── unit/
│   ├── providers/
│   │   └── photo_capture_provider_test.dart # MODIFIED: Context detection tests
│   └── models/
│       └── camera_context_test.dart   # NEW: Context model tests
└── integration/
    └── camera_context_flow_test.dart  # NEW: End-to-end context workflow test
```

**Structure Decision**: Flutter mobile project with standard lib/test organization. New widgets created for expandable FAB and context-aware button rendering. Existing screens modified to integrate new UI components. Camera context detection added to existing PhotoCaptureProvider. Tests follow Flutter conventions: widget tests for UI, unit tests for logic, integration tests for flows.

## Complexity Tracking

*No constitutional violations - this section is empty.*

## Phase 0: Research & Technical Decisions

**Status**: To be generated in `research.md`

**Research Tasks**:
1. **FAB Expansion Patterns**: Research Flutter material design speed dial vs custom expansion approaches
2. **Camera Context Passing**: Investigate optimal method for passing context through go_router navigation
3. **State Management for FAB**: Determine if provider, StatefulWidget, or AnimationController best for expansion state
4. **Button Conditional Rendering**: Research best practices for conditional UI based on context parameters
5. **Mock Functionality UX**: Design user-friendly placeholder messages that clearly indicate "coming soon" status

**Output**: `research.md` with decisions and rationale for each area

## Phase 1: Design Artifacts

**Status**: To be generated

### 1. Data Model (`data-model.md`)
- `CameraContext` enum (home, equipmentAllPhotos, equipmentBefore, equipmentAfter)
- `FabExpansionState` (collapsed, expanding, expanded)
- `SaveActionButton` model (label, onTap, enabled)
- Validation rules for context parameters

### 2. API Contracts (`contracts/`)
- **camera-context.md**: Camera launch interface (context params, validation, defaults)
- **fab-expansion.md**: Expandable FAB widget interface (menu items, callbacks, animations)

### 3. Quickstart Guide (`quickstart.md`)
- How to launch camera with specific context
- How to add expandable FAB to new screen
- How to customize FAB menu items
- Testing checklist for context-aware flows

### 4. Agent Context Update
- Run `.specify/scripts/bash/update-agent-context.sh claude`
- Add new widgets (ExpandableFAB, ContextAwareSaveButtons) to CLAUDE.md
- Document camera context pattern for future features

## Phase 2: Implementation Planning

**Status**: Deferred to `/speckit.tasks` command

Will generate `tasks.md` with:
- Phased implementation tasks (widgets → providers → screens → tests)
- Dependency ordering (base widgets before screen integration)
- Testing strategy (unit → widget → integration)
- Rollout plan (SubSite simple FAB → Main Site 2-option → Client 3-option → Camera context)

---

**Next Steps**:
1. Execute Phase 0 research
2. Generate Phase 1 design artifacts
3. Run `/speckit.tasks` to create implementation task breakdown
4. Begin development following constitutional guidelines
