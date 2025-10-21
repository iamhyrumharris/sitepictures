# Feature Specification: All Photos Gallery

**Feature Branch**: `007-i-want-to`  
**Created**: 2025-10-18  
**Status**: Draft  
**Input**: User description: "I want to create an all-photos feature that will show all pictures from all equipment. Sort by newest to oldest. The button to show this page will replace the map button on the navigation bar."

## Clarifications

### Session 2025-10-18

- Q: How should users access the map feature after the navigation button is replaced? → A: Map temporarily removed; no user access until future update.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Review latest equipment photos (Priority: P1)

An operations manager wants to confirm the most recent condition updates across all equipment from a single location.

**Why this priority**: Delivers the core value of the feature by surfacing fresh visual data without requiring equipment-by-equipment navigation.

**Independent Test**: Can be validated by opening the All Photos view and confirming that the latest uploads across equipment appear with contextual details and can be browsed without leaving the page.

**Acceptance Scenarios**:

1. **Given** photos exist for multiple equipment items with recent timestamps, **When** the user opens the All Photos view, **Then** the gallery shows photos from all equipment combined and ordered from newest to oldest.
2. **Given** a photo includes equipment metadata, **When** it appears in the All Photos view, **Then** the user sees the equipment name or identifier and capture timestamp alongside the image.

---

### User Story 2 - Access all photos from navigation (Priority: P2)

A field technician wants quick access to all recent photos while on site.

**Why this priority**: Replaces the map button with All Photos to provide high-visibility entry to the new gallery without expanding the navigation bar.

**Independent Test**: Can be tested by using the app navigation bar, selecting the All Photos button, and confirming it opens the aggregated gallery consistently across supported platforms.

**Acceptance Scenarios**:

1. **Given** the standard navigation bar is visible, **When** the user taps or clicks the All Photos button, **Then** the app navigates directly to the All Photos view.
2. **Given** the navigation bar renders on different device sizes, **When** the All Photos button is shown, **Then** it maintains consistent labeling and placement where the Map button previously appeared.

### Edge Cases

- No photos exist for any equipment: the All Photos view communicates the empty state and offers guidance (e.g., "No photos yet") without errors.
- A photo lacks a capture timestamp: default to the upload timestamp and maintain sort order.
- A user lacks permission for certain equipment: restricted photos do not appear, and visible entries remain correctly sorted.
- Network delays or large photo volume: the gallery indicates a loading state and prevents duplicate fetches while additional batches load.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The primary navigation bar MUST present an `All Photos` button in the position previously occupied by the `Map` button across all supported interfaces.
- **FR-002**: Selecting the `All Photos` button MUST open a gallery that aggregates every photo the user is authorized to view from all equipment records.
- **FR-003**: The gallery MUST order photos from newest to oldest using the capture timestamp when available, otherwise the upload timestamp.
- **FR-004**: Each photo entry in the gallery MUST display the photo, equipment name or identifier, capture or upload timestamp, and any available location summary.
- **FR-005**: The gallery MUST support browsing beyond the initial set of photos through incremental loading that preserves the newest-to-oldest order without reloading the entire page.
- **FR-006**: The application MUST remove the `Map` option from the navigation bar and ensure remaining navigation items retain their relative order.

### Key Entities

- **Photo**: Represents an image associated with a piece of equipment; key attributes include capture timestamp, upload timestamp, equipment reference, location description, and access permissions.
- **Equipment**: Represents an asset that can have multiple photos; key attributes include equipment identifier, descriptive name, location, and associated photos.

## Assumptions

- Existing photo records contain at least one timestamp and an equipment association suitable for sorting and display.
- Users currently permitted to see equipment-specific photos automatically have access to the All Photos view without additional permission changes.
- The map feature may remain inaccessible until a future initiative reintroduces it, and its relocation is outside this scope.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: During usability testing, at least 95% of target users locate and open the All Photos view from the navigation bar within 5 seconds.
- **SC-002**: Under standard connectivity (e.g., Wi-Fi or LTE), the All Photos view displays the first batch of images within 2 seconds for 90% of attempts during QA testing with a representative dataset.
- **SC-003**: In QA audit samples, 100% of examined photo lists maintain newest-to-oldest ordering using available timestamps.
- **SC-004**: Post-launch feedback shows at least 80% of active users agree that the All Photos view makes it easier to monitor equipment updates compared to prior workflows.
