
# Implementation Plan: Industrial Photo Management Application

**Branch**: `001-build-an-industrial` | **Date**: 2025-09-28 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/001-build-an-industrial/spec.md`

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
FieldPhoto Pro is an industrial photo management application that enables field technicians to capture, organize, and retrieve technical documentation photos efficiently. The solution uses Flutter/Dart for cross-platform development with offline-first architecture, local SQLite storage, GPS-based organization, and team collaboration features. Key focus is on sub-30 second workflows, zero data loss, and field worker efficiency.

## Technical Context
**Language/Version**: Flutter/Dart 3.x for cross-platform development
**Primary Dependencies**: Flutter SDK, SQLite (sqflite), geolocator, camera, http (for sync)
**Storage**: SQLite for local storage, PostgreSQL for server backend, local file system for photos
**Testing**: Flutter test framework, integration_test, mockito for unit testing
**Target Platform**: iOS 15+, Android API 23+, Windows/macOS desktop (secondary)
**Project Type**: Mobile + API - Flutter app with REST API backend
**Performance Goals**: <2s photo capture, <500ms navigation, <1s search, <5% battery/hour
**Constraints**: Offline-first, zero data loss, full resolution photos, device-based auth
**Scale/Scope**: Industrial teams (10-100 users), thousands of photos per user, multi-company support

## Constitution Check
*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

**Field-First Architecture**: ✅ PASS - Flutter mobile-first design with offline-first capabilities
**Offline Autonomy**: ✅ PASS - SQLite local storage with full feature parity offline
**Data Integrity**: ✅ PASS - Immutable photo storage, transaction-based operations, conflict resolution
**Hierarchical Consistency**: ✅ PASS - Client→Site→Equipment structure enforced across all features
**Privacy & Security**: ✅ PASS - Device-based auth, local data control, no telemetry
**Performance Primacy**: ✅ PASS - <2s capture, <500ms navigation targets defined
**Intuitive Simplicity**: ✅ PASS - One-handed operation, 30-second learnability requirements
**Modular Independence**: ✅ PASS - Camera, GPS, sync, search as separate modules
**Collaborative Transparency**: ✅ PASS - Device attribution, audit trails, version preservation

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
# [REMOVE IF UNUSED] Option 1: Single project (DEFAULT)
src/
├── models/
├── services/
├── cli/
└── lib/

tests/
├── contract/
├── integration/
└── unit/

# [REMOVE IF UNUSED] Option 2: Web application (when "frontend" + "backend" detected)
backend/
├── src/
│   ├── models/
│   ├── services/
│   └── api/
└── tests/

frontend/
├── src/
│   ├── components/
│   ├── pages/
│   └── services/
└── tests/

# Mobile + API Structure (Flutter + REST API)
api/
├── src/
│   ├── models/           # Data models matching mobile app
│   ├── services/         # Business logic for sync, auth, company management
│   ├── routes/           # REST API endpoints
│   └── database/         # PostgreSQL migrations and queries
└── tests/
    ├── integration/      # API integration tests
    └── unit/            # Service unit tests

app/
├── lib/
│   ├── models/          # Dart data models
│   ├── services/        # Camera, GPS, sync, storage services
│   ├── screens/         # UI screens and navigation
│   ├── widgets/         # Reusable UI components
│   └── utils/           # Helper functions and constants
└── test/
    ├── widget_test/     # Flutter widget tests
    ├── integration_test/ # End-to-end tests
    └── unit_test/       # Service unit tests
```

**Structure Decision**: Mobile + API structure selected to support Flutter cross-platform app with REST API backend for team collaboration and sync. The app/ directory contains the Flutter application with modular services, while api/ provides PostgreSQL-backed sync infrastructure.

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
- Flutter app tasks: Models → Services → Screens → Tests
- API backend tasks: Schema → Routes → Services → Tests
- Each entity → model creation task [P]
- Each API endpoint → contract test task [P]
- Each user story → integration test task
- Implementation tasks to make tests pass

**Ordering Strategy**:
- TDD order: Tests before implementation
- Dependency order: Database → Models → Services → API → UI
- Cross-platform considerations: Shared models first, platform-specific last
- Mark [P] for parallel execution (independent files)
- Priority: Core offline features → Sync features → Team features

**FieldPhoto Pro Specific Tasks**:
1. **Database Foundation**: SQLite schema, migrations, indexes
2. **Core Models**: Photo, Client, Site, Equipment entities in Dart
3. **Camera Service**: Photo capture with GPS and metadata
4. **Storage Service**: Local file management and SQLite operations
5. **Hierarchy Navigation**: Breadcrumb system and folder structure
6. **Search Engine**: Full-text search with performance optimization
7. **Sync Engine**: Background synchronization with conflict resolution
8. **API Backend**: PostgreSQL schema and REST endpoints
9. **GPS Boundaries**: Location detection and automatic assignment
10. **UI Screens**: Camera, navigation, search, settings interfaces
11. **Integration Tests**: All user stories from quickstart.md
12. **Performance Tests**: Constitutional compliance validation

**Estimated Output**: 35-40 numbered, ordered tasks in tasks.md

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

---
*Based on Constitution v2.1.1 - See `/memory/constitution.md`*
