# Implementation Plan: Equipment Page Photo Management with Folders

**Branch**: `004-i-want-to` | **Date**: 2025-10-09 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/004-i-want-to/spec.md`

## Execution Flow (/plan command scope)
```
1. Load feature spec from Input path ✓
2. Fill Technical Context (scan for NEEDS CLARIFICATION) ✓
3. Fill Constitution Check section ✓
4. Evaluate Constitution Check → No violations ✓
5. Execute Phase 0 → research.md ✓
6. Execute Phase 1 → contracts, data-model.md, quickstart.md, CLAUDE.md ✓
7. Re-evaluate Constitution Check ✓
8. Plan Phase 2 → Describe task generation approach ✓
9. STOP - Ready for /tasks command ✓
```

## Summary

This feature enhances the equipment detail page with a tabbed interface for organizing photos. Users can view all photos chronologically or organize them into work-order-based folders with before/after sections. This supports field workers documenting maintenance activities with structured photo capture workflows.

**Primary Requirement**: Two-tab equipment page with "All Photos" (chronological, with folder indicators) and "Folders" (work-order folders containing before/after photo tabs).

**Technical Approach**: Extend existing Flutter photo management with new folder data model, tabbed UI using Material TabBarView, and folder-aware photo associations. Maintains offline-first architecture with SQLite storage.

## Technical Context

**Language/Version**: Dart 3.8.1 / Flutter SDK 3.24+
**Primary Dependencies**: sqflite (SQLite), provider (state management), camera, go_router, uuid
**Storage**: SQLite database with existing `photos` table, new `photo_folders` and `folder_photos` junction table
**Testing**: flutter_test, mockito, integration_test SDK
**Target Platform**: iOS/Android mobile (offline-capable field application)
**Project Type**: Mobile (single Flutter project with iOS/Android targets)
**Performance Goals**:
- Tab switching < 300ms
- Folder creation < 500ms
- Photo list rendering < 1s for 100 photos
- Maintain camera capture < 2s (constitutional requirement)

**Constraints**:
- Offline-first: All operations must work without network
- Battery efficient: No continuous polling or heavy background tasks
- One-handed operation where possible
- Preserve existing 100-photo-per-equipment limit

**Scale/Scope**:
- ~15 folders per equipment average
- Up to 100 total photos per equipment
- 4 new screens/widgets (tabs, folder view, folder detail, create dialog)
- 3 new database tables/modifications

**UI/UX Design Approach**: Common Material Design patterns with standard Flutter widgets - TabBar for top-level tabs, ListTile for folder entries, GridView for photos, AlertDialog for creation/deletion confirmations. Familiar iOS/Android native patterns for field workers.

## Constitution Check
*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

### Article I: Field-First Architecture ✓
- **Tab navigation**: Single tap to switch views, no drill-down required
- **Folder creation**: Simple work-order entry dialog with auto-date appending
- **Photo indicators**: Visual badges on All Photos tab show folder membership
- **One-handed capable**: Tabs at top, FAB in thumb zone, list scrolling

### Article II: Offline Autonomy ✓
- **All folder operations** (create, delete, organize) work offline
- **Before/after photo capture** uses existing offline camera service
- **SQLite storage** for folders and associations (no API dependency)
- **Sync deferred**: Folder metadata syncs when connectivity available

### Article III: Data Integrity Above All ✓
- **Folder deletion**: User choice dialog prevents accidental photo loss
- **Photo associations**: Junction table maintains referential integrity
- **Transaction-based**: Folder operations wrapped in SQLite transactions
- **Immutable photos**: Existing photo files never modified, only associations change

### Article IV: Hierarchical Consistency ✓
- **Equipment context maintained**: Folders belong to equipment level
- **Breadcrumb navigation**: Existing breadcrumb system unchanged
- **Search implications**: Photos remain searchable (folder metadata included)

### Article V: Privacy and Security by Design ✓
- **Local folder data**: Work order numbers stored locally only
- **No additional telemetry**: Folder usage not tracked
- **Existing photo privacy**: GPS/metadata handling unchanged

### Article VI: Performance Primacy ✓
- **Tab switching**: < 300ms (lazy load tab content)
- **Folder list**: Indexed SQLite queries, sorted by creation date DESC
- **Photo grid**: Existing thumbnail caching reused
- **No background tasks**: All operations user-initiated

### Article VII: Intuitive Simplicity ✓
- **Standard tab pattern**: Familiar Material Design tabs
- **Clear visual hierarchy**: Folder icon badges, empty states with guidance
- **Confirmation dialogs**: Plain language choices ("Delete photos" vs "Keep as standalone")
- **Consistent with existing UI**: Reuses existing photo grid, FAB patterns

### Article VIII: Modular Independence ✓
- **Folder module**: Separate provider (`FolderProvider`) from photo capture
- **Photo model extension**: Non-breaking addition of optional `folderId` field
- **UI separation**: New folder widgets don't modify camera/carousel screens
- **Testable components**: Folder service, provider, and widgets independently testable

### Article IX: Collaborative Transparency ✓
- **Folder creator tracking**: Created_by field links to user
- **Photo attribution**: Existing captured_by field preserved
- **Audit trail**: Folder creation timestamp, modification tracking

**Constitution Check Result**: ✅ PASS - No violations identified

## Project Structure

### Documentation (this feature)
```
specs/004-i-want-to/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output (API schemas if needed)
└── tasks.md             # Phase 2 output (/tasks command)
```

### Source Code (repository root)
```
lib/
├── models/
│   ├── photo.dart                    # MODIFIED: Add folderId, folderName fields
│   ├── photo_folder.dart             # NEW: Folder entity
│   └── photo_session.dart            # EXISTING: Unchanged
├── providers/
│   ├── folder_provider.dart          # NEW: Folder state management
│   └── app_state.dart                # MODIFIED: Add folder queries
├── screens/
│   ├── equipment/
│   │   ├── equipment_screen.dart     # MODIFIED: Replace body with TabBarView
│   │   ├── all_photos_tab.dart       # NEW: All photos with folder indicators
│   │   ├── folders_tab.dart          # NEW: Folder list view
│   │   └── folder_detail_screen.dart # NEW: Before/After tabs
│   └── camera_capture_page.dart      # MODIFIED: Accept optional folderId, beforeAfter params
├── widgets/
│   ├── folder_badge.dart             # NEW: Visual indicator for folder photos
│   ├── create_folder_dialog.dart     # NEW: Work order entry dialog
│   └── delete_folder_dialog.dart     # NEW: Confirmation with photo choice
├── services/
│   ├── database_service.dart         # MODIFIED: Add folder tables, queries
│   └── folder_service.dart           # NEW: Folder CRUD operations
└── router.dart                        # MODIFIED: Add /equipment/:id/folder/:folderId route

test/
├── unit/
│   ├── models/
│   │   └── photo_folder_test.dart
│   ├── services/
│   │   └── folder_service_test.dart
│   └── providers/
│       └── folder_provider_test.dart
├── widget/
│   ├── all_photos_tab_test.dart
│   ├── folders_tab_test.dart
│   └── folder_detail_screen_test.dart
└── integration/
    └── folder_workflow_test.dart
```

**Structure Decision**: Single Flutter mobile project following existing lib/ organization. Equipment screen enhanced with tabbed interface, new folder-specific screens added under equipment/ directory. Database service extended for folder tables, maintaining existing photo table structure with optional foreign key.

## Phase 0: Outline & Research

### Research Tasks

1. **Flutter TabBar best practices for state preservation**
   - Decision: Use `AutomaticKeepAliveClientMixin` for tab state retention
   - Rationale: Prevents rebuild/reload when switching tabs, meets FR-002
   - Alternatives: `PageStorageKey` (doesn't preserve full state), `IndexedStack` (higher memory)

2. **SQLite junction table patterns for many-to-many with metadata**
   - Decision: Use `folder_photos` junction table with `before_after` enum field
   - Rationale: Photos can exist standalone or in folders, before/after is photo-folder relationship property
   - Alternatives: Separate before/after tables (violates normalization), embedded lists (no referential integrity)

3. **Material Design folder/organization visual indicators**
   - Decision: Small folder icon badge on top-right of photo thumbnails (All Photos tab)
   - Rationale: Common iOS/Android pattern, non-intrusive, immediately recognizable
   - Alternatives: Border color (ambiguous), text label (clutters UI), separate section (breaks chronology)

4. **Offline-first folder deletion with photo orphaning strategies**
   - Decision: Two-action confirmation dialog with immediate local execution, sync queue item
   - Rationale: Aligns with Article III (user choice), offline autonomy, constitutional Article II
   - Alternatives: Soft delete (complicates queries), automatic cascade (violates data integrity)

5. **Work order input validation patterns**
   - Decision: Free-text input with basic sanitization (no special validation)
   - Rationale: Field workers may have varied work order formats, over-validation creates friction
   - Alternatives: Regex validation (too restrictive), predefined list (requires API/sync)

**Output**: `research.md` (detailed findings below)

## Phase 1: Design & Contracts

### Data Model

**New Entities**:

1. **PhotoFolder**
   - `id` (TEXT PRIMARY KEY)
   - `equipment_id` (TEXT, FK to equipment)
   - `name` (TEXT) - Format: "{work_order} - {YYYY-MM-DD}"
   - `work_order` (TEXT) - User-entered portion
   - `created_at` (TEXT ISO8601)
   - `created_by` (TEXT, FK to users)
   - `is_deleted` (INTEGER 0/1) - Soft delete for sync
   - Indexes: `equipment_id`, `created_at DESC`

2. **FolderPhoto** (junction table)
   - `folder_id` (TEXT, FK to photo_folders)
   - `photo_id` (TEXT, FK to photos)
   - `before_after` (TEXT) - "before" or "after"
   - `added_at` (TEXT ISO8601)
   - Primary key: (folder_id, photo_id)
   - Indexes: `folder_id`, `photo_id`

**Modified Entities**:

3. **Photo** (existing, extended)
   - Add virtual field: `folder_id` (derived from junction table query, not stored)
   - Add virtual field: `folder_name` (derived, for display in All Photos tab)
   - No schema migration required - associations stored in junction table

### API Contracts

*Note: This is an offline-first feature. API contracts for future sync only.*

**Folder Sync Endpoints** (future):
```
POST /api/folders
  Request: { equipmentId, workOrder, createdAt, createdBy }
  Response: { id, ... } (server-assigned ID conflicts resolved)

DELETE /api/folders/:id
  Request: { deletePhotos: boolean }
  Response: 204

GET /api/equipment/:id/folders
  Response: [ { id, name, workOrder, createdAt, photoCount, ... } ]
```

**Contract Tests**: Deferred to sync implementation phase (not blocking this feature)

### Quickstart Test Scenarios

1. **Create and view folder**
   - Navigate to equipment page → Folders tab
   - Tap "Create Folder", enter "WO-789", confirm
   - Verify folder "WO-789 - 2025-10-09" appears at top of list

2. **Capture before photos**
   - Open folder → Before tab → Tap FAB
   - Capture 3 photos
   - Verify photos appear in Before tab only

3. **Capture after photos**
   - Switch to After tab → Tap FAB
   - Capture 2 photos
   - Verify photos appear in After tab, Before unchanged

4. **View all photos with indicators**
   - Navigate to All Photos tab
   - Verify all 5 folder photos show folder badge icon
   - Verify chronological ordering maintained

5. **Delete folder keeping photos**
   - Folders tab → Long-press folder → Delete
   - Choose "Keep photos as standalone"
   - All Photos tab → Verify 5 photos still present, no badges

**Output**: `quickstart.md`, `data-model.md`

### Agent Context Update

Execute update script:
```bash
.specify/scripts/bash/update-agent-context.sh claude
```

This will append to `CLAUDE.md`:
- New technologies: (none - using existing stack)
- Project structure: New folder screens under lib/screens/equipment/
- Recent changes: "004-i-want-to: Added folder organization with before/after tabs"

**Output**: Updated `CLAUDE.md` at repository root

## Phase 2: Task Planning Approach
*This section describes what the /tasks command will do - DO NOT execute during /plan*

**Task Generation Strategy**:

1. **Database tasks** (from data-model.md):
   - Create photo_folders table migration
   - Create folder_photos junction table migration
   - Add folder-related indexes
   - Update database_service.dart with folder queries

2. **Model tasks**:
   - Create PhotoFolder model class
   - Add toMap/fromMap for folder serialization
   - Extend Photo model with virtual folder fields (non-breaking)

3. **Service layer tasks**:
   - Create FolderService with CRUD operations
   - Implement folder deletion with photo orphaning logic
   - Add folder queries to AppState provider

4. **Provider tasks**:
   - Create FolderProvider with ChangeNotifier
   - Implement folder state management (create, delete, list)
   - Handle before/after photo associations

5. **UI tasks** (following TDD: tests before implementation):
   - Widget test: CreateFolderDialog
   - Widget test: DeleteFolderDialog
   - Implement CreateFolderDialog widget
   - Implement DeleteFolderDialog widget
   - Widget test: AllPhotosTab with folder badges
   - Widget test: FoldersTab list
   - Widget test: FolderDetailScreen with before/after tabs
   - Implement AllPhotosTab
   - Implement FoldersTab
   - Implement FolderDetailScreen
   - Implement FolderBadge widget
   - Modify EquipmentScreen to use TabBarView

6. **Integration tasks**:
   - Update router with folder routes
   - Connect camera_capture_page to accept folderId param
   - Integration test: End-to-end folder workflow (quickstart scenarios)

**Ordering Strategy**:
- Database migrations first (foundation)
- Models next (data layer) [P]
- Services (business logic) [P after models]
- Providers (state management) [P after services]
- Widget tests + implementations (UI layer, can parallelize individual widgets)
- Photo deletion UI (T025-T028, covers FR-021 requirements)
- Integration tests last (full stack)

**Estimated Output**: ~36 numbered tasks in tasks.md (updated post-generation to add deletion UI)

**IMPORTANT**: This phase is executed by the /tasks command, NOT by /plan

## Phase 3+: Future Implementation
*These phases are beyond the scope of the /plan command*

**Phase 3**: Task execution (/tasks command creates tasks.md)
**Phase 4**: Implementation (execute tasks.md following TDD approach)
**Phase 5**: Validation (run tests, execute quickstart.md, performance validation against Article VI thresholds)

## Complexity Tracking
*No constitutional violations - table remains empty*

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| - | - | - |

## Progress Tracking

**Phase Status**:
- [x] Phase 0: Research complete (/plan command)
- [x] Phase 1: Design complete (/plan command)
- [x] Phase 2: Task planning approach documented (/plan command)
- [x] Phase 3: Tasks generated (/tasks command) - **36 tasks created**
- [x] Post-generation refinement: Added T025-T028 for photo deletion UI (FR-021 coverage)
- [ ] Phase 4: Implementation in progress (execute tasks T001-T036)
- [ ] Phase 5: Validation passed

**Gate Status**:
- [x] Initial Constitution Check: PASS (no violations)
- [x] Post-Design Constitution Check: PASS (re-validated against research.md and data-model.md)
- [x] All NEEDS CLARIFICATION resolved (FR-009 deferred, FR-017 specified)
- [x] Complexity deviations documented (none - no violations)
- [x] FR-022 numbering corrected in spec.md

**Artifacts Generated**:
- [x] research.md - 5 research areas with decisions documented
- [x] data-model.md - 3 entities, 2 tables, migration scripts, query patterns
- [x] quickstart.md - 10 manual test scenarios with validation queries
- [x] CLAUDE.md - Updated with new technologies and project structure
- [x] tasks.md - 36 implementation tasks with dependencies and parallel execution strategy
- [x] spec.md - 24 functional requirements (FR-001 to FR-024), deferred features documented

**Ready for implementation** - Begin with T001 (database migrations)

---
*Based on Constitution v1.0.0 - See `.specify/memory/constitution.md`*
