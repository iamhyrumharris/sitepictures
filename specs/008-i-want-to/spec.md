# Feature Specification: Photo Import From Device Library

**Feature Branch**: `008-i-want-to`  
**Created**: 2025-10-23  
**Status**: Draft  
**Input**: User description: "I want to add an import feature. This will import photos from the devices photos. I want a import button on the home page, before and after tabs on equipment folders, all photos page, and all photos tab in equipment on the app bar with an upload symbol. I want the user to be able to select multiple photos to import. There will need to be permissions added to access users photos. When you click on import on the home page and all photos page, then you select photos, then I want the same options as if you were moving the photos like you do in the needs assigned folder. And when you import photos in before/after tab in the equipment I want to give an option of Import to Before or Import to After."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Import photos into the shared library (Priority: P1)

Field technicians and admins can import multiple device photos from the home page or All Photos page, then assign them using the existing “Move” options used in the Needs Assigned flow.

**Why this priority**: This is the most common entry point for capturing new work documentation and connects directly to the current photo organization workflow.

**Independent Test**: From the home screen, trigger import, select at least two photos, and confirm they land in the intended destination without visiting any equipment-level screen.

**Acceptance Scenarios**:

1. **Given** a user on the home screen with photo permissions granted, **When** they tap Import, select multiple photos, and confirm a destination using the existing move options, **Then** the selected photos appear in the chosen location with confirmation feedback.
2. **Given** a user on the All Photos page who has never granted photo access, **When** they tap Import and approve the permission request, **Then** they can select photos and complete the move flow without leaving the All Photos page.
3. **Given** a user who previously denied access, **When** they tap Import and decline to change permissions, **Then** the system surfaces guidance on how to enable access and the import flow gracefully exits.

---

### User Story 2 - Import to equipment before/after documentation (Priority: P2)

Equipment owners can import photos directly while viewing an equipment record, choosing whether the images should populate the Before or After tab.

**Why this priority**: Capturing before/after evidence on site is critical for equipment records and drives compliance reporting.

**Independent Test**: From an equipment before/after tab, trigger import, select photos, choose “Import to Before,” and verify the photos display under Before without affecting other tabs.

**Acceptance Scenarios**:

1. **Given** a user on the Before tab for a piece of equipment, **When** they tap Import, choose “Import to Before,” and select photos, **Then** the photos display in the Before gallery with confirmation messaging.
2. **Given** a user on the After tab, **When** they tap Import, choose “Import to After,” and select photos, **Then** the photos appear in the After gallery and inherit the equipment context automatically.

---

### User Story 3 - Manage photo permissions and feedback (Priority: P3)

Users receive clear prompts when photo access is missing, revoked, or limited, and can retry imports after adjusting permissions without losing progress.

**Why this priority**: Without predictable permission handling, users cannot import photos at all; explicit messaging reduces support tickets.

**Independent Test**: Simulate denied permissions, attempt an import, follow the provided instructions to grant access, and verify the user can resume the import without restarting the app.

**Acceptance Scenarios**:

1. **Given** the app lacks photo permissions, **When** a user attempts to import, **Then** the system requests access with a contextual explanation and continues only after approval.
2. **Given** a user returns to the app after enabling access in device settings, **When** they relaunch the import flow, **Then** the action resumes without re-selecting the entry point and the app confirms access is restored.

### Edge Cases

- Permission remains denied: display actionable guidance and allow retry without crashing the view.
- Device photo library is empty or nothing is selected: disable confirmation and show “Select at least one photo” messaging.
- Photos already exist in the target location: confirm whether duplicates should be blocked or allowed and message the outcome.
- Import interrupted (app backgrounded, device sleep, low storage): provide recovery messaging and ensure partially imported photos are clearly reported.
- Slow or large imports: surface progress feedback to prevent duplicate submissions.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Provide an Import control on the home page, All Photos page, and the All Photos tab app bar, displayed with an upload icon next to the label.
- **FR-002**: Provide an Import control within the Before and After tabs of each equipment record, visible without additional navigation.
- **FR-003**: When a user taps any Import control, request device photo-library access if not already granted, including an explanation of why access is needed.
- **FR-004**: Support selecting multiple photos within the native picker and require at least one photo before enabling the confirmation action.
- **FR-005**: After selection from the home page or All Photos page, present the same destination options currently used in the Needs Assigned “Move” flow (e.g., choosing equipment, folder, or status) to finalize placement.
- **FR-006**: After selection from the equipment Before/After tabs, prompt users to choose “Import to Before” or “Import to After,” defaulting to the currently viewed tab.
- **FR-007**: Persist the originating context (e.g., equipment ID, folder) through the import flow so users do not need to reselect it unless they intentionally change the destination.
- **FR-008**: Display a progress indicator while photos import and confirm success once files appear in the destination; include messaging for any photo that fails to import.
- **FR-009**: Prevent duplicate imports within the same batch by warning the user when identical photos are selected more than once and allowing them to continue or deselect duplicates.
- **FR-010**: Preserve key photo metadata (timestamp, original filename) when storing imported photos so downstream workflows (sorting, audit trails) remain accurate.
- **FR-011**: When permissions remain denied, block the import action and show clear instructions for enabling access via device settings, plus a shortcut to retry.
- **FR-012**: Log each import attempt with context (entry point, number of photos, success/failure) for analytics and support review without exposing personal photo contents.

### Key Entities *(include if feature involves data)*

- **Photo Asset**: Represents an individual photo available within the app; includes source identifier, capture timestamp, associated equipment/folder, and import origin.
- **Import Batch**: Represents a single user action importing one or more photos; includes entry point (home, All Photos, Before/After), selected destination, permission status, and per-photo success state.
- **Destination Context**: Represents the target location where photos will reside after import; includes destination type (Needs Assigned, equipment Before, equipment After, other folders) and any linked asset identifiers.

## Assumptions

- The existing Needs Assigned “Move” workflow already supports selecting equipment, folders, or statuses; the import flow will reuse the same options without changes.
- Users are already authenticated and have permission to view and manage the equipment or folders they target during import.
- Imported photos are stored in the same repository and follow the same retention rules as photos captured in-app.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 90% of users who start an import from the home page or All Photos page can complete importing at least three photos and assigning a destination in under 120 seconds.
- **SC-002**: 95% of imported photos appear in the selected destination within 30 seconds of confirmation during pilot testing, as measured by analytics events.
- **SC-003**: 100% of import attempts with denied permissions display actionable guidance within the same session, verified through QA test cases.
- **SC-004**: At least 75% of surveyed pilot users rate the new import experience as “easy” or “very easy” after first use.
