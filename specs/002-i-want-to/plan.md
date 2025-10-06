
# Implementation Plan: UI/UX Design for Site Pictures Application

**Branch**: `002-i-want-to` | **Date**: 2025-09-29 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/002-i-want-to/spec.md`

## Execution Flow (/plan command scope)
```
1. Load feature spec from Input path
   → If not found: ERROR "No feature spec at {path}"
2. Fill Technical Context (scan for NEEDS CLARIFICATION)
   → Detect Project Type from file system structure or context (web=frontend+backend, mobile=app+api)
   → Set Structure Decision based on project type
3. Fill the Constitution Check section based on the content of the constitution document.
4. Evaluate Constitution Check section below
   → If violations exist: Document in Complexity Tracking
   → If no justification possible: ERROR "Simplify approach first"
   → Update Progress Tracking: Initial Constitution Check
5. Execute Phase 0 → research.md
   → If NEEDS CLARIFICATION remain: ERROR "Resolve unknowns"
6. Execute Phase 1 → contracts, data-model.md, quickstart.md, agent-specific template file (e.g., `CLAUDE.md` for Claude Code, `.github/copilot-instructions.md` for GitHub Copilot, `GEMINI.md` for Gemini CLI, `QWEN.md` for Qwen Code or `AGENTS.md` for opencode).
7. Re-evaluate Constitution Check section
   → If new violations: Refactor design, return to Phase 1
   → Update Progress Tracking: Post-Design Constitution Check
8. Plan Phase 2 → Describe task generation approach (DO NOT create tasks.md)
9. STOP - Ready for /tasks command
```

**IMPORTANT**: The /plan command STOPS at step 7. Phases 2-4 are executed by other commands:
- Phase 2: /tasks command creates tasks.md
- Phase 3-4: Implementation execution (manual or via tools)

## Summary
Implementing a hierarchical navigation UI for industrial site photo documentation, featuring client/site/equipment organization with offline-first photo capture, carousel viewing, and role-based access control. The solution uses Flutter/Dart for cross-platform mobile development with SQLite for local storage and automatic background synchronization.

## Technical Context
**Language/Version**: Dart 3.x / Flutter SDK 3.24+
**Primary Dependencies**: Flutter Framework, sqflite (SQLite), geolocator, camera, http, provider (state management)
**Storage**: SQLite via sqflite for local storage, file system for photo caching
**Testing**: Flutter test framework, integration_test package
**Target Platform**: iOS 13+ and Android 6.0+ (API 23+)
**Project Type**: mobile - Flutter cross-platform application
**Performance Goals**: < 2 seconds photo capture-to-save, < 500ms screen navigation, 60 fps UI rendering
**Constraints**: Offline-capable, < 5% battery drain per hour active use, < 100MB app size
**Scale/Scope**: ~15 screens, support for 1000+ photos per device, 100+ clients/sites

## Constitution Check
*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] **Field-First Architecture**: UI designed for one-handed operation, quick photo capture, minimal friction workflows
- [x] **Offline Autonomy**: Full offline functionality with SQLite storage and queued sync
- [x] **Data Integrity**: Photo metadata preservation, transaction-based operations, no data loss
- [x] **Hierarchical Consistency**: Client → Main Site → SubSite → Equipment structure enforced
- [x] **Privacy and Security**: Role-based access control, GPS with consent only, local storage
- [x] **Performance Primacy**: < 2s photo capture, < 500ms navigation, background sync
- [x] **Intuitive Simplicity**: Visual breadcrumb navigation, clear UI patterns, no training required
- [x] **Modular Independence**: Camera module, navigation module, sync module all separable
- [x] **Collaborative Transparency**: Role-based permissions (admin, technician, viewer) with clear attribution

**Result**: PASS - All constitutional principles satisfied

## Project Structure

### Documentation (this feature)
```
specs/[###-feature]/
├── plan.md              # This file (/plan command output)
├── research.md          # Phase 0 output (/plan command)
├── data-model.md        # Phase 1 output (/plan command)
├── quickstart.md        # Phase 1 output (/plan command)
├── contracts/           # Phase 1 output (/plan command)
└── tasks.md             # Phase 2 output (/tasks command - NOT created by /plan)
```

### Source Code (repository root)
<!--
  ACTION REQUIRED: Replace the placeholder tree below with the concrete layout
  for this feature. Delete unused options and expand the chosen structure with
  real paths (e.g., apps/admin, packages/something). The delivered plan must
  not include Option labels.
-->
```
# Flutter Mobile Application Structure
lib/
├── models/
│   ├── client.dart
│   ├── site.dart
│   ├── equipment.dart
│   ├── photo.dart
│   └── user.dart
├── screens/
│   ├── home/
│   │   ├── home_screen.dart
│   │   └── widgets/
│   ├── camera/
│   │   ├── camera_screen.dart
│   │   └── carousel_view.dart
│   ├── sites/
│   │   ├── main_site_screen.dart
│   │   └── sub_site_screen.dart
│   └── equipment/
│       └── equipment_screen.dart
├── services/
│   ├── database_service.dart
│   ├── sync_service.dart
│   ├── camera_service.dart
│   ├── gps_service.dart
│   └── auth_service.dart
├── widgets/
│   ├── breadcrumb_navigation.dart
│   ├── client_list_tile.dart
│   └── recent_location_card.dart
└── main.dart

test/
├── unit/
│   └── models/
├── widget/
│   └── screens/
└── integration/
    └── navigation_flow_test.dart
```

**Structure Decision**: Flutter mobile application with feature-based organization. Screens grouped by navigation hierarchy, shared widgets extracted, services layer for all external interactions (database, camera, GPS). This structure supports the offline-first architecture with clear separation of concerns.

## Phase 0: Outline & Research
1. **Extract unknowns from Technical Context** above:
   - For each NEEDS CLARIFICATION → research task
   - For each dependency → best practices task
   - For each integration → patterns task

2. **Generate and dispatch research agents**:
   ```
   For each unknown in Technical Context:
     Task: "Research {unknown} for {feature context}"
   For each technology choice:
     Task: "Find best practices for {tech} in {domain}"
   ```

3. **Consolidate findings** in `research.md` using format:
   - Decision: [what was chosen]
   - Rationale: [why chosen]
   - Alternatives considered: [what else evaluated]

**Output**: research.md with all NEEDS CLARIFICATION resolved

## Phase 1: Design & Contracts
*Prerequisites: research.md complete*

1. **Extract entities from feature spec** → `data-model.md`:
   - Entity name, fields, relationships
   - Validation rules from requirements
   - State transitions if applicable

2. **Generate API contracts** from functional requirements:
   - For each user action → endpoint
   - Use standard REST/GraphQL patterns
   - Output OpenAPI/GraphQL schema to `/contracts/`

3. **Generate contract tests** from contracts:
   - One test file per endpoint
   - Assert request/response schemas
   - Tests must fail (no implementation yet)

4. **Extract test scenarios** from user stories:
   - Each story → integration test scenario
   - Quickstart test = story validation steps

5. **Update agent file incrementally** (O(1) operation):
   - Run `.specify/scripts/bash/update-agent-context.sh claude`
     **IMPORTANT**: Execute it exactly as specified above. Do not add or remove any arguments.
   - If exists: Add only NEW tech from current plan
   - Preserve manual additions between markers
   - Update recent changes (keep last 3)
   - Keep under 150 lines for token efficiency
   - Output to repository root

**Output**: data-model.md, /contracts/*, failing tests, quickstart.md, agent-specific file

## Phase 2: Task Planning Approach
*This section describes what the /tasks command will do - DO NOT execute during /plan*

**Task Generation Strategy**:
- Load `.specify/templates/tasks-template.md` as base
- Generate tasks from Phase 1 design docs (contracts, data model, quickstart)
- Database setup and migration tasks first
- Each entity (8 total) → model creation task [P]
- Core services (5) → service implementation tasks
- UI screens (10) → screen implementation tasks [P]
- Navigation and state management tasks
- Integration test tasks from quickstart scenarios

**Task Categories**:
1. **Setup & Configuration** (3-4 tasks)
   - Flutter project initialization
   - Dependencies configuration
   - Database schema setup

2. **Data Layer** (8-10 tasks)
   - Model classes for each entity
   - Database repositories
   - Sync queue implementation

3. **Service Layer** (5-6 tasks)
   - Authentication service
   - Database service
   - Camera/GPS services
   - Sync service
   - Navigation service

4. **UI Implementation** (15-18 tasks)
   - Home screen with Recent/Clients sections
   - Client list and detail screens
   - Site hierarchy screens
   - Camera and carousel implementation
   - Breadcrumb navigation widget
   - Common widgets and themes

5. **Testing** (5-6 tasks)
   - Unit tests for models
   - Widget tests for screens
   - Integration tests for user flows
   - Performance validation

**Ordering Strategy**:
- Bottom-up: Data layer → Services → UI → Tests
- Dependency order within each layer
- Mark [P] for parallel execution where possible
- Critical path: Database → Models → Core Services → Home Screen

**Estimated Output**: 40-45 numbered, ordered tasks in tasks.md

**IMPORTANT**: This phase is executed by the /tasks command, NOT by /plan

## Phase 3+: Future Implementation
*These phases are beyond the scope of the /plan command*

**Phase 3**: Task execution (/tasks command creates tasks.md)  
**Phase 4**: Implementation (execute tasks.md following constitutional principles)  
**Phase 5**: Validation (run tests, execute quickstart.md, performance validation)

## Complexity Tracking
*Fill ONLY if Constitution Check has violations that must be justified*

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| [e.g., 4th project] | [current need] | [why 3 projects insufficient] |
| [e.g., Repository pattern] | [specific problem] | [why direct DB access insufficient] |


## Progress Tracking
*This checklist is updated during execution flow*

**Phase Status**:
- [x] Phase 0: Research complete (/plan command)
- [x] Phase 1: Design complete (/plan command)
- [x] Phase 2: Task planning complete (/plan command - describe approach only)
- [ ] Phase 3: Tasks generated (/tasks command)
- [ ] Phase 4: Implementation complete
- [ ] Phase 5: Validation passed

**Gate Status**:
- [x] Initial Constitution Check: PASS
- [x] Post-Design Constitution Check: PASS
- [x] All NEEDS CLARIFICATION resolved
- [x] Complexity deviations documented (none required)

**Artifacts Generated**:
- [x] research.md - Technical decisions and dependency analysis
- [x] data-model.md - Entity definitions and relationships
- [x] contracts/api-contract.yaml - OpenAPI specification
- [x] quickstart.md - Validation scenarios
- [x] CLAUDE.md updated - Agent context

---
*Based on Constitution v1.0.0 - See `.specify/memory/constitution.md`*
*Plan completed: 2025-09-29*
