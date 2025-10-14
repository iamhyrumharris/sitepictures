# Feature Specification: Camera Photo Save Functionality

**Feature Branch**: `006-i-want-to`
**Created**: 2025-10-13
**Status**: Draft
**Input**: User description: "I want to now add saving functionality to the camera. Currently you open the camera take pictures and click the done button and then it doesn't do anything. Now I want to create a way to save things. First: On the home page you open the camera and take a few pictures then you press done. It should prompt you with 'quick save' or 'next'. Quick Save will save the photos based on two factors, one if there is only one picture then it will save the photo with the image+date as the name in the 'Needs Assigned' folder. Two if there are more than 1 picture then it will save a folder in the needs assigned folder with Folder+date. Then you have 'next'. This is where you will essentially select a piece of equipment to save the folder/photo too. This will bring up a way to navigate to the equipment you desire. Second: When you select the camera on the photos tab in the equipment page then when you press done it will just save all photos to the photos tab. Third: When you select the camera on the before tab on the folder in the equipment then when you press done it will save all photos to that before section of the folder. And same with the after tab."

## Clarifications

### Session 2025-10-13
- Q: How should the global "Needs Assigned" folder be structured in the database? → A: Create a special client record (e.g., id="GLOBAL_NEEDS_ASSIGNED") with a system flag marking it as global, reusing existing client-folder relationships
- Q: When saving multiple photos, should the save operation be atomic (all-or-nothing) or incremental (save each photo independently)? → A: Incremental with rollback on critical failure: Save photos one-by-one; if one fails, keep previously saved photos but prompt user about partial completion
- Q: What is a realistic maximum save time for 20 photos that balances user experience with technical constraints? → A: 15 seconds for 20 photos
- Q: How should per-client "Needs Assigned" folders be visually distinguished from regular main sites? → A: Different icon + "Needs Assigned" label (always shows "Needs Assigned" as folder name regardless of client)
- Q: What disambiguation strategy should be used when multiple Quick Save operations occur on the same date? → A: Sequential numbering starting from (2) for duplicates (e.g., "Folder - 2025-10-13", "Folder - 2025-10-13 (2)", "Folder - 2025-10-13 (3)")

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Home Camera Quick Save and Equipment Assignment (Priority: P1)

A field technician arrives at a job site and needs to quickly capture photos without knowing yet which equipment they'll be assigned to. They open the camera from the home page, capture several photos, and tap Done. They see two options: "Quick Save" for immediate storage in an unorganized holding area, or "Next" to immediately assign the photos to specific equipment. If they choose Quick Save, the system automatically creates a dated folder in the global "Needs Assigned" area (or saves as a single image if only one photo). If they choose Next, they navigate through the familiar client/site/equipment hierarchy to select the destination equipment, and the photos are saved directly to that equipment's general photos collection.

**Why this priority**: This is the core MVP functionality that enables the most common workflow—capturing photos in the field when organization can happen later. The Quick Save option reduces friction for busy technicians, while Next enables immediate organization for those who know the target equipment.

**Independent Test**: Can be fully tested by opening camera from home page, capturing 1 photo (verify saves as "Image - [date]"), capturing 3 photos (verify saves as "Folder - [date]"), and using Next button to navigate to equipment (verify photos appear in equipment's All Photos tab).

**Acceptance Scenarios**:

1. **Given** user is on home page, **When** they tap camera FAB, capture 1 photo, tap Done, and tap "Quick Save", **Then** system saves photo as "Image - [date]" in global "Needs Assigned" folder and returns to home page
2. **Given** user is on home page, **When** they tap camera FAB, capture 3 photos, tap Done, and tap "Quick Save", **Then** system creates folder named "Folder - [date]" in global "Needs Assigned" folder containing all 3 photos and returns to home page
3. **Given** user is on home page, **When** they tap camera FAB, capture photos, tap Done, and tap "Next", **Then** system displays hierarchical navigation showing clients list
4. **Given** user is in equipment navigator from "Next" button, **When** they navigate to and select a specific equipment item, **Then** all captured photos are saved to that equipment's general photos collection and user returns to home page
5. **Given** user has Quick Saved photos to global "Needs Assigned", **When** they view the global "Needs Assigned" folder, **Then** they see all saved individual images and folders ordered by date (newest first)
6. **Given** user captures 1 photo and selects "Quick Save", **When** viewing the saved image in "Needs Assigned", **Then** image name follows format "Image - YYYY-MM-DD"
7. **Given** user captures 5 photos and selects "Quick Save", **When** viewing the saved folder in "Needs Assigned", **Then** folder name follows format "Folder - YYYY-MM-DD"

---

### User Story 2 - Equipment Photos Tab Direct Save (Priority: P2)

A technician is viewing a specific equipment item and wants to add photos to its documentation. They navigate to the equipment's "All Photos" tab and tap the camera button. After capturing several photos, they tap Done. The system immediately saves all photos to that equipment's general photos collection without requiring additional navigation or confirmation. The technician is returned to the equipment's All Photos tab where they can see the newly added photos at the top of the list.

**Why this priority**: This streamlines the workflow when the user already knows which equipment needs documentation. It eliminates unnecessary navigation steps and provides immediate visual confirmation of the saved photos.

**Independent Test**: Navigate to any equipment's All Photos tab, tap camera, capture 3 photos, tap Done, verify photos appear immediately in the equipment's All Photos tab in chronological order.

**Acceptance Scenarios**:

1. **Given** user is viewing equipment's "All Photos" tab, **When** they tap camera button, capture 4 photos, and tap Done, **Then** all 4 photos are saved to that equipment's photos and appear at the top of the All Photos list
2. **Given** user captures photos from equipment All Photos tab, **When** Done is tapped, **Then** no modal dialog appears—photos save immediately and user returns to All Photos tab
3. **Given** user captures photos from equipment All Photos tab, **When** photos are saved, **Then** photos have no folder association (they are standalone photos)
4. **Given** user is on equipment All Photos tab after saving photos, **When** they view the photo list, **Then** newly captured photos appear at the top ordered by capture timestamp (newest first)

---

### User Story 3 - Folder Before/After Categorized Save (Priority: P3)

A technician is documenting repair work using the folder's before/after structure. They open a folder and tap the "Before" tab, then tap the camera button to capture the current state before repairs. After capturing photos and tapping Done, the photos are automatically saved to that folder's "Before" section. Later, after completing repairs, they return to the same folder, switch to the "After" tab, capture photos, and tap Done. These photos are automatically saved to the folder's "After" section, keeping the before and after photos properly separated for comparison.

**Why this priority**: This enables structured documentation of work progression, which is critical for maintenance records, client reports, and warranty claims. The automatic categorization based on which tab launched the camera prevents user error in manual categorization.

**Independent Test**: Navigate to equipment folder, tap "Before" tab, capture 2 photos, verify they appear in Before section. Then tap "After" tab, capture 3 photos, verify they appear in After section and Before photos remain unchanged.

**Acceptance Scenarios**:

1. **Given** user is viewing folder's "Before" tab, **When** they tap camera button, capture 3 photos, and tap Done, **Then** all 3 photos are saved to that folder's "Before" section and user returns to folder's Before tab
2. **Given** user is viewing folder's "After" tab, **When** they tap camera button, capture 2 photos, and tap Done, **Then** all 2 photos are saved to that folder's "After" section and user returns to folder's After tab
3. **Given** user captures photos from folder Before tab, **When** Done is tapped, **Then** no modal dialog appears—photos save immediately to Before section
4. **Given** user captures photos from folder After tab, **When** Done is tapped, **Then** no modal dialog appears—photos save immediately to After section
5. **Given** folder has 5 Before photos and 3 After photos, **When** user views Before tab, **Then** they see only the 5 Before photos (After photos remain in After tab)
6. **Given** user saves photos to folder's Before section, **When** viewing the folder in Folders tab list, **Then** folder's photo count reflects the newly added Before photos

---

### Edge Cases

- What happens when user taps "Next" button but cancels out of equipment navigation without selecting anything? (Photos remain in session until user returns to camera or explicitly cancels)
- What happens when multiple Quick Saves occur on the same date? (System appends sequential numbers starting from (2): first save is "Folder - 2025-10-13", second is "Folder - 2025-10-13 (2)", third is "Folder - 2025-10-13 (3)", etc.)
- What happens when user has no clients created and tries to use "Next" button? (System shows empty state with message "No equipment available. Create clients and sites first.")
- What happens when device loses storage space during photo save? (System shows error "Insufficient storage" and retains photos in temporary session for retry)
- What happens when user navigates away from equipment navigator without completing selection? (Photos remain in camera session, user can return to Complete save or cancel)
- What happens when folder is deleted while user is capturing photos in its Before/After tab? (System detects deletion on save attempt, shows error, offers to save to equipment general photos instead)
- What happens when equipment is deleted/archived while user is in equipment navigator? (Navigator refreshes, shows equipment as unavailable, user must select different equipment)
- What happens to photos in global "Needs Assigned" when user wants to organize them later? (Photos/folders remain in "Needs Assigned" until user manually moves them to equipment via bulk selection tool—feature deferred to future implementation)
- What happens when user captures 20 photos (session limit) and selects Quick Save? (System saves all 20 photos into single dated folder in "Needs Assigned")
- What happens when saving 10 photos and photo #7 fails due to file corruption? (System saves photos 1-6 and 8-10 successfully, displays "9 of 10 photos saved", logs error for photo #7)
- What happens when database connection is lost during incremental save of 5 photos after 2 have saved? (Critical error triggers rollback of 2 saved photos, preserves entire session, prompts user to retry when connection restored)

## Requirements *(mandatory)*

### Functional Requirements

#### Camera Context Detection

- **FR-001**: System MUST detect camera launch context (home, equipment-all-photos, folder-before, folder-after) and store context metadata in camera session
- **FR-002**: Camera page MUST pass context information to save handler when Done button is tapped
- **FR-003**: System MUST validate context information before executing save operations

#### Home Context - Quick Save Behavior

- **FR-004**: When camera is launched from home page and Done is tapped, system MUST display modal with two options: "Quick Save" and "Next"
- **FR-005**: When user selects "Quick Save" with exactly 1 captured photo, system MUST save photo as standalone image in global "Needs Assigned" folder
- **FR-006**: Standalone image saved via Quick Save MUST be named using format "Image - YYYY-MM-DD" based on current date
- **FR-007**: When user selects "Quick Save" with 2 or more captured photos, system MUST create a folder in global "Needs Assigned" folder and save all photos into that folder
- **FR-008**: Folder created via Quick Save MUST be named using format "Folder - YYYY-MM-DD" based on current date
- **FR-009**: When multiple Quick Save operations occur on same date, system MUST append sequential numbering starting from (2) for duplicates (first occurrence has no suffix: "Folder - 2025-10-13", subsequent occurrences: "Folder - 2025-10-13 (2)", "Folder - 2025-10-13 (3)", etc.)
- **FR-009a**: Same sequential numbering strategy MUST apply to single-photo Quick Saves (e.g., "Image - 2025-10-13", "Image - 2025-10-13 (2)")
- **FR-010**: After Quick Save completes successfully, system MUST clear camera session and return user to home page
- **FR-011**: After Quick Save completes successfully, system MUST display confirmation message (e.g., "Saved to Needs Assigned")

#### Home Context - Next Button Behavior

- **FR-012**: When user selects "Next" button from home camera modal, system MUST display equipment navigator interface
- **FR-013**: Equipment navigator MUST use existing hierarchical navigation UI (Client → Main Site → SubSite → Equipment)
- **FR-014**: Equipment navigator MUST display all active clients at the top level
- **FR-015**: When user navigates into a client, system MUST display main sites and subsites belonging to that client
- **FR-016**: When user navigates into a site, system MUST display equipment items belonging to that site
- **FR-017**: Equipment navigator MUST clearly indicate which items are selectable (equipment) vs. navigable containers (clients, sites)
- **FR-018**: When user selects an equipment item in navigator, system MUST save all captured photos to that equipment's general photos collection (no folder association)
- **FR-019**: When user cancels out of equipment navigator without selection, system MUST return to camera page with session intact (photos preserved)
- **FR-020**: After equipment selection and save completes, system MUST clear camera session and return user to home page
- **FR-021**: After equipment selection and save completes, system MUST display confirmation message showing equipment name (e.g., "Saved to [Equipment Name]")

#### Global "Needs Assigned" Folder Structure

- **FR-022**: System MUST maintain a global "Needs Assigned" folder that is not associated with any client
- **FR-023**: Global "Needs Assigned" folder MUST be accessible from home page or main navigation
- **FR-024**: Global "Needs Assigned" folder MUST contain both individual images and folders created via Quick Save
- **FR-025**: Items in global "Needs Assigned" MUST be ordered by creation date (newest first)
- **FR-026**: System MUST persist Quick Save items in permanent storage (SQLite database with file system references)

#### Equipment All Photos Tab Context

- **FR-033**: When camera is launched from equipment's "All Photos" tab and Done is tapped, system MUST save all captured photos directly to that equipment's general photos collection
- **FR-034**: Photos saved from equipment All Photos tab context MUST NOT display modal dialog—save occurs immediately when Done is tapped
- **FR-035**: Photos saved from equipment All Photos tab context MUST have no folder association (standalone photos)
- **FR-036**: After save from equipment context completes, system MUST return user to equipment's All Photos tab
- **FR-037**: Newly saved photos MUST appear at the top of equipment's All Photos list ordered by timestamp (newest first)
- **FR-038**: After save from equipment context completes, system MUST display brief confirmation message (e.g., "3 photos saved")

#### Folder Before/After Tab Context

- **FR-039**: When camera is launched from folder's "Before" tab and Done is tapped, system MUST save all captured photos to that folder with "before" categorization
- **FR-040**: When camera is launched from folder's "After" tab and Done is tapped, system MUST save all captured photos to that folder with "after" categorization
- **FR-041**: Photos saved from folder Before/After context MUST NOT display modal dialog—save occurs immediately when Done is tapped
- **FR-042**: After save from folder context completes, system MUST return user to the folder tab from which camera was launched (Before or After)
- **FR-043**: Newly saved photos MUST appear in the appropriate tab (Before or After) at the top of the list
- **FR-044**: System MUST maintain separation between Before and After photos within the same folder
- **FR-045**: After save from folder context completes, system MUST display brief confirmation message indicating category (e.g., "2 photos saved to Before")

#### Photo Storage and Persistence

- **FR-046**: System MUST move photos from temporary session storage to permanent storage during save operation
- **FR-047**: System MUST store photo file paths, metadata (timestamp, location, captured_by), and associations (equipment, folder, before/after) in SQLite database
- **FR-048**: System MUST generate and store thumbnail images for each photo during save operation
- **FR-049**: System MUST maintain referential integrity between photos and their associated entities (equipment, folders)
- **FR-050**: System MUST validate storage availability before executing save operation

#### Error Handling and Validation

- **FR-051**: When equipment navigator is opened and no clients exist, system MUST display empty state message: "No equipment available. Create clients and sites first."
- **FR-052**: When storage space is insufficient for save operation, system MUST display error message "Insufficient storage" and preserve photos in session for retry
- **FR-053**: When target folder is deleted during capture session, system MUST detect deletion on save attempt and offer to save to equipment general photos instead
- **FR-054**: When target equipment is deleted/archived during navigation, system MUST refresh navigator and indicate equipment is unavailable
- **FR-055**: System MUST save photos incrementally (one-by-one) rather than as a single atomic transaction
- **FR-055a**: When a non-critical error occurs during incremental save (e.g., single photo file corruption), system MUST continue saving remaining photos
- **FR-055b**: When previously saved photos exist and remaining photos fail, system MUST keep successfully saved photos and display partial completion message (e.g., "3 of 5 photos saved")
- **FR-055c**: When a critical error occurs (e.g., database connection lost, folder deletion), system MUST rollback any photos saved in current operation and preserve entire session for retry
- **FR-056**: System MUST log all save operations and errors for debugging and audit purposes

#### User Feedback and Confirmation

- **FR-057**: System MUST provide visual feedback during save operations (loading indicator, progress bar for large photo sets)
- **FR-058**: System MUST display success confirmation messages after save operations complete
- **FR-059**: Confirmation messages MUST indicate destination and number of photos saved (e.g., "5 photos saved to Needs Assigned")
- **FR-060**: System MUST provide clear feedback when navigation or save is canceled by user

### Key Entities

- **Global Needs Assigned Folder**: A simple organizational container accessible from home page navigation that serves as a holding area for photos captured via Quick Save. Contains individual photos and folders with date-based names ("Image - YYYY-MM-DD" for single photos, "Folder - YYYY-MM-DD" for multiple photos). Items are ordered by creation date (newest first). Implemented using a special system client (id="GLOBAL_NEEDS_ASSIGNED") with a single equipment container for storage simplicity.

- **Camera Context**: Metadata attached to camera session indicating launch origin (home, equipment-all-photos, folder-before, folder-after), determines save behavior and UI options when Done is tapped.

- **Quick Save Item**: Photo or folder saved to global "Needs Assigned" via Quick Save button, named with date-based format ("Image - YYYY-MM-DD" for single photo, "Folder - YYYY-MM-DD" for multiple photos), persisted permanently until manually organized.

- **Equipment Navigator**: Hierarchical interface for browsing clients → main sites → subsites → equipment, used in "Next" button flow from home camera, reuses existing navigation UI patterns.

- **Photo Association**: Relationship between photo and its organizational context (equipment general photos, folder before/after section), stored in database as foreign keys and categorization flags.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can complete Quick Save workflow (capture photos → Done → Quick Save) in under 10 seconds from camera open to confirmation
- **SC-002**: Users can complete Next button workflow (capture photos → Done → Next → select equipment) in under 30 seconds for equipment in recently accessed list
- **SC-003**: 100% of photos saved via Quick Save appear in global "Needs Assigned" folder with correct date-based naming
- **SC-004**: 100% of photos saved via equipment All Photos tab context appear in that equipment's general photos collection
- **SC-005**: 100% of photos saved via folder Before/After context appear in correct category with proper separation maintained
- **SC-006**: 95% of users successfully complete equipment selection via Next button on first attempt without errors or confusion
- **SC-007**: System handles storage errors gracefully in 100% of cases (preserves photos, shows clear error message, enables retry)
- **SC-008**: Date-based naming disambiguation works correctly when multiple Quick Saves occur on same date (no name collisions)
- **SC-009**: Users can capture and save maximum session size (20 photos) via Quick Save in under 15 seconds save time (accounting for file I/O, database writes, and thumbnail generation)
- **SC-010**: 90% of users understand where their photos were saved based on confirmation messages alone (no need to hunt for photos)

## Assumptions

- **Assumption 1**: Existing camera capture functionality (20-photo limit, thumbnail preview, cancel/done buttons) remains unchanged; this feature only implements save behavior after Done is tapped
- **Assumption 2**: Current permission model (admin/technician can create, viewer cannot) applies consistently to all save operations
- **Assumption 3**: Global "Needs Assigned" folder is implemented as a special client record (id="GLOBAL_NEEDS_ASSIGNED") with a system flag, reusing existing client-folder data structures and relationships
- **Assumption 4**: Equipment navigator reuses existing navigation UI components and patterns—no new navigation design required
- **Assumption 5**: Date format for Quick Save naming uses ISO 8601 format (YYYY-MM-DD) for consistency and sortability
- **Assumption 6**: Photos saved to "Needs Assigned" folders remain there permanently until user manually moves them (bulk move/organize feature deferred to future implementation)
- **Assumption 7**: User authentication and current user context are available for setting "captured_by" and "created_by" fields
- **Assumption 8**: Geolocation services provide current latitude/longitude for photo metadata during save
- **Assumption 9**: Temporary photo storage from camera session uses existing session management from feature 003 (path_provider temporary directory)
- **Assumption 10**: Global "Needs Assigned" folder is created during database initialization and remains permanently available

## Dependencies

- **Dependency 1**: Existing camera capture functionality (feature 003 & 005) must support passing context parameters and returning photos for save
- **Dependency 2**: Database schema must support special client record for global "Needs Assigned" (requires adding system flag column to clients table and creating special client record during database initialization)
- **Dependency 3**: Existing hierarchical navigation UI must be componentized and reusable as equipment navigator
- **Dependency 4**: Photo storage service must support moving photos from temporary to permanent storage with metadata preservation
- **Dependency 5**: Folder service must support creating folders in global "Needs Assigned" context (no equipment association)
- **Dependency 6**: Database service must support creating junction table entries for folder_photos with before/after designation

## Out of Scope

- Bulk operations for organizing photos in "Needs Assigned" folders (moving multiple photos to equipment at once)
- Search or filter capabilities within equipment navigator
- Editing or renaming Quick Save items after creation
- Deleting individual photos from "Needs Assigned" folders
- Analytics or reporting on "Needs Assigned" folder usage
- Cloud sync for "Needs Assigned" folder contents
- Sharing or exporting photos directly from "Needs Assigned" folders
- Photo editing or annotation before/after save
- Changing photo associations after save (moving photo from one equipment to another)
- Custom naming for Quick Save items (always uses date-based format)
- Favorites or recent equipment list in equipment navigator (uses standard hierarchy only)
- Folder creation within equipment navigator (save only, no create)
- Multi-select for saving to multiple equipment items simultaneously
- Undo/redo for save operations
- Preview of save destination before confirming equipment selection
