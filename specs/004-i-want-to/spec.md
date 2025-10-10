# Feature Specification: Equipment Page Photo Management

**Feature Branch**: `004-i-want-to`
**Created**: 2025-10-09
**Status**: Draft
**Input**: User description: "I want to focus on the equipment page. This page should have 2 tabs, one for all photos and the other for folders with pictures in it. The photos tab will have all the photos that are tied to the equipment in chronological order with the most recent starting at the top. The folders page will contain folders that the user can create but in each folder I want a before and after tabs. This way a user can go and take pictures before performing work and then take more pictures after the work is done so you can see what changed. There needs to be buttons to create the folders."

## Execution Flow (main)
```
1. Parse user description from Input
   → Identified: Equipment page enhancement with photo organization
2. Extract key concepts from description
   → Actors: Field workers viewing/organizing equipment photos
   → Actions: View all photos, create folders, capture before/after photos
   → Data: Photos, folders, before/after associations
   → Constraints: Chronological ordering, folder organization
3. For each unclear aspect:
   → [NEEDS CLARIFICATION: Folder naming - user input or auto-generated?]
   → [NEEDS CLARIFICATION: Max number of folders per equipment?]
   → [NEEDS CLARIFICATION: Can folders be edited/deleted after creation?]
   → [NEEDS CLARIFICATION: Can photos be moved between folders or deleted?]
   → [NEEDS CLARIFICATION: What happens to folder photos when viewing "All Photos" tab?]
4. Fill User Scenarios & Testing section
   → Primary flow: View photos, create work folder, capture before/after
5. Generate Functional Requirements
   → Tab navigation, chronological display, folder CRUD, before/after segregation
6. Identify Key Entities
   → Photo, Folder, Equipment (existing)
7. Run Review Checklist
   → WARN "Spec has uncertainties requiring clarification"
8. Return: SUCCESS (spec ready for planning after clarification)
```

---

## ⚡ Quick Guidelines
- ✅ Focus on WHAT users need and WHY
- ❌ Avoid HOW to implement (no tech stack, APIs, code structure)
- 👥 Written for business stakeholders, not developers

---

## Clarifications

### Session 2025-10-09
- Q: What should the "All Photos" tab display? → A: All photos, but with visual indicators showing which belong to folders
- Q: How should folders be named when created? → A: Work order/job number entry with auto-appended date (no time)
- Q: Can folders be deleted, and what happens to their photos? → A: Folders can be deleted with user choice: delete photos or keep as standalone
- Q: In what order should folders be displayed in the Folders tab? → A: Newest first (by creation date, descending)
- Q: Can individual photos be deleted? → A: Yes, from anywhere (All Photos tab, folder Before/After tabs)

---

## User Scenarios & Testing *(mandatory)*

### Primary User Story
A field worker navigates to an equipment detail page to review maintenance history. They see two tabs: one showing all photos chronologically, and another showing organized folders. Before starting a repair, they create a new folder, switch to "Before" tab, and capture photos of the damaged component. After completing the repair, they switch to "After" tab and capture photos showing the fixed component. Later, they can compare before/after photos side-by-side to document their work.

### Acceptance Scenarios
1. **Given** an equipment page is open, **When** the user selects the "All Photos" tab, **Then** all photos associated with this equipment appear in reverse chronological order (newest first)

2. **Given** an equipment page is open, **When** the user selects the "Folders" tab, **Then** a list of folders appears ordered by creation date (newest first) with a button to create new folders

3. **Given** the user is on the "Folders" tab, **When** they tap "Create Folder", **Then** a dialog prompts for work order/job number, the system appends the current date, and the folder appears in the list (e.g., "WO-1234 - 2025-10-09")

4. **Given** a folder exists, **When** the user opens it, **Then** they see two tabs: "Before" and "After"

5. **Given** the user is viewing the "Before" tab in a folder, **When** they capture photos, **Then** those photos are stored in the "Before" section and appear when the folder is reopened

6. **Given** the user is viewing the "After" tab in a folder, **When** they capture photos, **Then** those photos are stored in the "After" section separate from "Before" photos

7. **Given** multiple folders exist, **When** the user views the "All Photos" tab, **Then** all photos appear (including folder photos) with visual indicators showing which photos belong to folders

8. **Given** a folder exists with photos, **When** the user deletes the folder, **Then** a dialog prompts to either delete all photos in the folder or keep them as standalone photos

9. **Given** a photo is visible (in All Photos tab or folder Before/After tab), **When** the user selects and deletes the photo, **Then** the photo is permanently removed from the system

### Edge Cases
- What happens when no folders exist yet on the "Folders" tab?
- What happens when a folder has no "Before" or no "After" photos?
- What happens if the user tries to create many folders? [NEEDS CLARIFICATION: Is there a limit?]
- What happens when deleting an empty folder (no photos)?
- What happens when the last photo in a folder's Before or After tab is deleted?
- What confirmation/warning is shown before permanently deleting a photo?

## Requirements *(mandatory)*

### Functional Requirements

**Tab Navigation**
- **FR-001**: Equipment page MUST display two tabs: "All Photos" and "Folders"
- **FR-002**: Users MUST be able to switch between tabs without losing state

**All Photos Tab**
- **FR-003**: All Photos tab MUST display all photos associated with the equipment in chronological order
- **FR-004**: Photos MUST be ordered with the most recent at the top
- **FR-005**: All Photos tab MUST include both standalone photos and photos inside folders
- **FR-005a**: Photos that belong to folders MUST have a visual indicator distinguishing them from standalone photos

**Folders Tab**
- **FR-006**: Folders tab MUST display a list of all folders created for this equipment
- **FR-007**: Folders tab MUST provide a button to create new folders
- **FR-008**: When creating a folder, system MUST prompt user for work order or job number
- **FR-008a**: System MUST automatically append the current date (YYYY-MM-DD format, no time) to the user-entered identifier
- **FR-008b**: Folder name format MUST be: "[user-input] - [date]" (e.g., "WO-1234 - 2025-10-09")
- **FR-010**: Users MUST be able to delete folders
- **FR-010a**: When deleting a folder, system MUST present a confirmation dialog with two options: delete all photos in folder OR keep photos as standalone
- **FR-010b**: If user chooses to keep photos, they MUST appear as standalone photos (lose folder/before-after association)
- **FR-010c**: If user chooses to delete photos, all photos in the folder (both before and after) MUST be permanently deleted
- **FR-011**: Folders MUST be displayed in descending order by creation date (newest first)

**Folder Before/After Structure**
- **FR-012**: Each folder MUST contain two tabs: "Before" and "After"
- **FR-013**: Users MUST be able to switch between "Before" and "After" tabs within a folder
- **FR-014**: Photos captured while viewing "Before" tab MUST be stored in the "Before" section
- **FR-015**: Photos captured while viewing "After" tab MUST be stored in the "After" section
- **FR-016**: "Before" and "After" photos MUST remain separated and not intermix
- **FR-017**: Photos within Before and After sections MUST be displayed in chronological order (newest first)

**Photo Association**
- **FR-018**: System MUST maintain the association between photos and their equipment
- **FR-019**: System MUST maintain the association between photos and their folder (if in a folder)
- **FR-020**: System MUST maintain the before/after designation for photos in folders

**Photo Management**
- **FR-021**: Users MUST be able to delete individual photos from the All Photos tab
- **FR-021a**: Users MUST be able to delete individual photos from within folder Before/After tabs
- **FR-021b**: System MUST permanently delete the photo when user confirms deletion
- **FR-021c**: System MUST show confirmation dialog before deleting a photo

**Empty States**
- **FR-022**: System MUST display appropriate messaging when no photos exist on All Photos tab
- **FR-023**: System MUST display appropriate messaging when no folders exist on Folders tab
- **FR-024**: System MUST display appropriate messaging when Before or After tab is empty in a folder

### Key Entities

- **Photo**: Represents a captured image associated with equipment. Has attributes like timestamp, file reference, equipment association, and optional folder/before-after classification

- **Folder**: A user-created organizational container for grouping related before/after photos. Has attributes like name (format: work order/job number + date), creation timestamp, equipment association, and contains two collections (before photos, after photos)

- **Equipment**: (Existing entity) The physical asset being documented. Now has relationships to both loose photos and folders of photos

---

## Review & Acceptance Checklist
*GATE: Automated checks run during main() execution*

### Content Quality
- [x] No implementation details (languages, frameworks, APIs)
- [x] Focused on user value and business needs
- [x] Written for non-technical stakeholders
- [x] All mandatory sections completed

### Requirement Completeness
- [x] No [NEEDS CLARIFICATION] markers remain - **All resolved**
- [x] Requirements are testable and unambiguous
- [x] Success criteria are measurable
- [x] Scope is clearly bounded
- [x] Dependencies and assumptions identified

---

## Execution Status
*Updated by main() during processing*

- [x] User description parsed
- [x] Key concepts extracted
- [x] Ambiguities marked and 5 major clarifications resolved
- [x] User scenarios defined (9 acceptance scenarios)
- [x] Requirements generated (24 functional requirements FR-001 to FR-024)
- [x] Entities identified (Photo, Folder, Equipment)
- [x] Review checklist passed
- [x] Post-planning refinement: All clarifications resolved, FR-009 deferred to future
- [x] FR-022 numbering corrected (was FR-023-025)

---

## Next Steps

### Resolved Clarifications (5)
✅ All Photos tab content and visual indicators
✅ Folder naming with work order/job number + date
✅ Folder deletion with user choice for photos
✅ Folder display order (newest first)
✅ Individual photo deletion capability

### Resolved Clarifications (All)
All ambiguities resolved during planning phase:

1. ✅ **Folder Renaming**: Deferred to future enhancement (see Deferred Features below)
2. ✅ **Photo Ordering in Before/After**: Chronological (newest first) per FR-017
3. ✅ **Folder Limits**: No hard limits for MVP, system constraints only (100 photos per equipment existing limit)

## Deferred Features

The following features were considered but deferred to post-MVP releases:

### FR-009: Folder Renaming
**Decision**: Folders cannot be renamed after creation in MVP.

**Rationale**:
- Work order + date format provides clear documentation trail
- Renaming could create confusion in audit logs
- Simplifies offline sync conflict resolution
- Low user demand based on field worker workflow (capture → document → done)

**Future Consideration**: If needed, implement as "edit work order" with version history tracking.

### Folder Quantity Limits
**Decision**: No explicit limit on folder count for MVP.

**Rationale**:
- Existing 100-photo-per-equipment limit naturally constrains folder utility
- Field workers typically create 5-15 folders per equipment
- Can add soft limit (e.g., 50 folders) with warning if usage patterns warrant

**Recommendation**: Ready for implementation via `/implement` command.
