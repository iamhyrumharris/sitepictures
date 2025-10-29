# Implementation Plan: Photo Import From Device Library

**Branch**: `008-i-want-to` | **Date**: 2025-10-23 | **Spec**: [spec.md](./spec.md)  
**Input**: Feature specification from `/Users/hyrumharris/src/sitepictures/specs/008-i-want-to/spec.md`

## Summary

Deliver multi-entry “Import” workflows that pull images from the device photo library, reuse the Needs Assigned move flow for global destinations, and allow direct Before/After placement inside equipment records. The plan addresses permissions, multi-select import from home/All Photos/equipment tabs, contextual destination selection (including Before vs After choice), duplicate prevention, progress and error feedback, and analytics logging—while honoring offline operation, metadata preservation, and FieldPhoto Pro’s hierarchy rules.

## Technical Context

**Language/Version**: Dart 3.8.1 / Flutter 3.24+, Kotlin & Swift bridges for platform channels, Node.js 18+ (sync API)  
**Primary Dependencies**: Flutter, provider, go_router, sqflite, path_provider, permission_handler, workmanager, image, flutter_image_compress, http, photo_manager  
**Storage**: On-device SQLite (sqflite) for metadata, local filesystem for photo binaries, optional PostgreSQL via Sequelize in `/api` for server sync  
**Testing**: flutter_test, integration_test suites; Jest + Supertest for API parity (no new API planned)  
**Target Platform**: iOS 13+ and Android 8.0+ rugged field devices, offline-first usage  
**Project Type**: Cross-platform mobile application with optional self-hosted Node API  
**Performance Goals**: Imports of up to 20 photos finish in <30s (SC-002), UI remains ≥60fps, permission request feedback <1s, metadata capture 100% reliable  
**Constraints**: Article II offline autonomy (imports must succeed offline), Article III data integrity (no photo loss/metadata corruption), Article I ergonomics (Import reachable one-handed), Article V privacy (respect OS photo permissions)  
**Scale/Scope**: Dozens of technicians per org, thousands of photos per equipment record, import batches typically 1–20 images but must degrade gracefully for higher counts

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

### Article I – Field-First Architecture ✅ PASS
- Import buttons surface at home, All Photos, and equipment tabs with upload iconography, minimizing navigation for gloved or time-pressed techs.
- Flow mirrors familiar Needs Assigned move options, keeping muscle memory and one-handed interactions intact.

### Article II – Offline Autonomy ✅ PASS
- Imports read from device storage and persist into SQLite; no network dependency is introduced for selection or assignment.
- Destination movement uses existing offline Needs Assigned logic; sync remains asynchronous via Workmanager.

### Article III – Data Integrity Above All ✅ PASS
- Original photo binaries remain immutable; metadata preservation and duplicate warnings stop silent losses.
- Per-photo success feedback and retry options ensure technicians know if anything failed.

### Article IV – Hierarchical Consistency ✅ PASS
- Destination chooser enforces Client → Main Site → Sub Site → Equipment hierarchy; equipment Before/After assignment respects current context.
- Needs Assigned remains a legitimate staging area without bypassing hierarchy.

### Article V – Privacy & Security by Design ✅ PASS
- Permission prompts explain purpose; no new telemetry or external sharing is added.
- Analytics logging stays internal and avoids personal image data, aligning with isolation requirements.

### Article VI – Performance Primacy ✅ PASS
- Progress UI and background IO keep responsiveness within thresholds; plan targets <30s for 20-photo imports.
- UI thread remains free via async operations, preventing frame drops during import.

### Article VII – Intuitive Simplicity ✅ PASS
- Import labels and icons are self-explanatory; Before/After defaults to current tab to reduce choices.
- Error states include actionable instructions (enable permissions, select at least one photo).

### Article VIII – Modular Independence ✅ PASS
- A new import service encapsulates gallery integration; existing camera, Needs Assigned, and equipment modules remain decoupled.
- Providers expose import results without cross-module entanglement, enabling isolated testing.

### Article IX – Collaborative Transparency ✅ PASS
- Import logging captures entry point, counts, and outcomes for audit; destinations inherit existing attribution metadata.
- Before/After imports participate in the same version history used for compliance documentation.

### Post-Design Reaffirmation (2025-10-23)
- Review of data-model, contracts, and quickstart confirmed Articles I–IX remain fully satisfied; no mitigation actions required.

## Project Structure

### Documentation (this feature)

```
specs/008-i-want-to/
├── spec.md
├── plan.md              # This document
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output
└── tasks.md             # Phase 2 output (/speckit.tasks)
```

### Source Code (repository root)

```
lib/
├── main.dart
├── models/
├── providers/
├── screens/
├── services/
├── utils/
└── widgets/

api/
├── src/
│   ├── controllers/
│   ├── middleware/
│   ├── models/
│   └── routes/
└── tests/

android/                # Flutter Android host (manifests, native integration)
ios/                    # Flutter iOS host (Info.plist, permissions)
integration_test/       # Flutter end-to-end suites
test/                   # Flutter unit/widget tests
```

**Structure Decision**: Feature work concentrates in `lib/` (screens, providers, services) with supporting permission manifest updates in `android/` and `ios/`. No backend contract changes are required, keeping `/api` untouched unless analytics logging schema demands an update.

## Complexity Tracking

*No constitutional violations—tracking table not required.*

## Phase 0: Research & Unknowns

Focus: Resolve outstanding technical choices before design artifacts.

- **R0.1 – Gallery Import Plugin Selection**: Compare `photo_manager`, `image_picker`, and `file_picker` for Flutter multi-select gallery imports with metadata access, background safety, and offline support. Deliver decision with rationale (permissions handling, iOS/Android parity, resize abilities).
- **R0.2 – Permission UX Best Practices**: Review current `permission_handler` usage to ensure OS-compliant flows (pre-permission rationale screens, denied → settings guidance) align with Articles I, II, V.
- **R0.3 – Duplicate Detection Strategy**: Investigate reliable client-side duplicate heuristics (hashing, file identifiers, timestamps) that work offline and respect performance goals; determine storage of fingerprints for comparison.
- **R0.4 – Large Batch Import Performance**: Gather guidance on streaming vs eager loading for >20 photos to keep memory usage manageable in Flutter, potentially leveraging isolates or incremental writes.

Deliverable: `/Users/hyrumharris/src/sitepictures/specs/008-i-want-to/research.md` capturing decisions, rationale, and alternatives for each item. All **NEEDS CLARIFICATION** markers must be resolved here.

## Phase 1: Design & Contracts

Prerequisite: Phase 0 research complete and documented.

1. **Data Model (`data-model.md`)**
   - Document updates to `Photo Asset`, `Import Batch`, and `Destination Context` entities (fields, relationships, metadata preservation).
   - Specify duplicate fingerprint storage, permission state tracking, and import status transitions.
2. **Contracts (`contracts/`)**
   - Define service-level contract for new `ImportService` (inputs, outputs, error cases).
   - Outline provider/interface contracts for UI flows (home import, All Photos import, equipment Before/After import).
   - If sync analytics require schema adjustments, draft payload contract (e.g., JSON event structure).
3. **Quickstart (`quickstart.md`)**
   - Summarize end-to-end workflow for developers (register plugin, permission rationale, invoking import modal, handling results).
   - Include test checklist for common scenarios (first-time permission, denied permission, duplicates).
4. **Agent Context Update**
   - After documenting designs, run `.specify/scripts/bash/update-agent-context.sh codex` and record new technologies or patterns added by this feature.
5. **Constitution Re-check**
   - Re-evaluate Articles I–IX with finalized designs; document any mitigations if risks emerge.

Artifacts generated in this phase will guide `/speckit.tasks`.

## Phase 2: Implementation Outline

High-level breakdown for future task planning (do not execute here):

1. **Permission & Platform Setup**
   - Update `Info.plist`, Android `AndroidManifest.xml`, and permission rationale copy in shared constants.
   - Integrate pre-permission education screen if research recommends.
2. **Import Service Layer**
   - Implement gallery plugin wrapper with multi-select, metadata extraction, and duplicate filtering.
   - Write import pipeline to stage files, persist metadata, and queue sync operations.
   - Ensure Before/After routing logic and Needs Assigned move invocation handle batch destinations.
3. **UI Integration**
   - Add Import actions to home, All Photos, equipment Before/After tabs with consistent iconography.
   - Build modal flows for destination selection, duplicate handling, progress feedback, and final confirmation.
4. **State Management & Logging**
   - Extend relevant providers to trigger refreshes post-import and log analytics to local queue.
   - Capture import batch records for audit (entry point, counts, success/failure per photo).
5. **Testing Strategy**
   - Unit: import service, duplicate detector, permission manager.
   - Widget: Import button availability per screen, modal flows, Before/After selection.
   - Integration: End-to-end offline import from each entry point, permission denial/retry loops.
6. **Performance & QA Validation**
   - Stress-test 50-photo imports to verify memory and duration targets.
   - Validate metadata integrity by cross-checking timestamps/filenames post-import.

## Validation & QA Readiness

- Phase 0 research must resolve plugin selection before any coding begins.
- Phase 1 artifacts act as contract for development, ensuring offline, hierarchy, and data integrity requirements remain enforceable.
- Prior to `/speckit.tasks`, confirm Constitution check still passes with finalized designs.
