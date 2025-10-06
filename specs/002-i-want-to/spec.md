# Feature Specification: UI/UX Design for Site Pictures Application

**Feature Branch**: `002-i-want-to`
**Created**: 2025-09-29
**Status**: Draft
**Input**: User description: "I want to focus on the ui ux elements. The home page will be like the ones I paste[Image #1][Image #2] The camera page will have a carousel with the pictures taken with a quick save button and a next button. The home page will consist of the clients, then there is a main site, subsite, and equipment page. The main site will be able to house subsites and equipments, the sub site will only house equipment."

## Execution Flow (main)
```
1. Parse user description from Input
   → Key UI/UX elements identified: home page, camera page, client hierarchy
2. Extract key concepts from description
   → Identified: clients, main sites, subsites, equipment, camera carousel
3. For each unclear aspect:
   → Marked navigation flows and user permissions
4. Fill User Scenarios & Testing section
   → Clear user flows for client selection and photo capture
5. Generate Functional Requirements
   → Each requirement is testable and UI-focused
6. Identify Key Entities
   → Client, MainSite, SubSite, Equipment, Photo
7. Run Review Checklist
   → WARN "Spec has uncertainties" - user roles and permissions need clarification
8. Return: SUCCESS (spec ready for planning)
```

---

## ⚡ Quick Guidelines
- ✅ Focus on WHAT users need and WHY
- ❌ Avoid HOW to implement (no tech stack, APIs, code structure)
- 👥 Written for business stakeholders, not developers

### Section Requirements
- **Mandatory sections**: Must be completed for every feature
- **Optional sections**: Include only when relevant to the feature
- When a section doesn't apply, remove it entirely (don't leave as "N/A")

---

## Clarifications

### Session 2025-09-29
- Q: When no clients exist in the system (brand new installation), what should the home page display? → A: Show empty state with "Add Your First Client" message
- Q: How should the system handle photo capture and storage when the device is offline? → A: Queue photos locally, auto-sync when online
- Q: Where should photos be associated when captured? → A: should be tied to equipment
- Q: What photo metadata should be captured with each image? → A: Timestamp and GPS location only
- Q: Who can access and manage client data in the system? → A: Role-based: admin, technician, viewer

### Session 2025-10-02
- Q: When device storage is full during photo capture, what should the app do? → A: Block capture and show "Storage Full" error requiring user to free space
- Q: Can users add equipment directly to both main sites AND subsites, or only to subsites? → A: Equipment can be added to both main sites and subsites
- Q: What is the maximum number of photos allowed per equipment item? → A: 100 photos per equipment

---

## User Scenarios & Testing *(mandatory)*

### Primary User Story
As a field technician visiting industrial sites, I need an intuitive mobile interface to navigate through a hierarchical structure of clients and their locations, capture photos of equipment, and quickly save them with proper categorization so that site documentation is organized and efficient.

### User Roles
- **Admin**: Full system access, can create/edit/delete all data, manage user accounts
- **Technician**: Can view all clients, create/edit sites and equipment, capture and manage photos
- **Viewer**: Read-only access to clients, sites, equipment, and photos

### Acceptance Scenarios
1. **Given** a user opens the app, **When** they view the home screen, **Then** they see a "Recent" section with their last visited locations and a "Clients" section with all available clients
2. **Given** a user is on the home page, **When** they tap a client, **Then** they are taken to the main sites list for that client
3. **Given** a user is viewing a main site, **When** they navigate to it, **Then** they can see both subsites and equipment at that location
4. **Given** a user is viewing a subsite, **When** they navigate to it, **Then** they can only see equipment (no nested subsites)
5. **Given** a user taps the camera button, **When** the camera page opens, **Then** they can take photos and see them in a carousel view
6. **Given** a user has taken photos, **When** viewing the carousel, **Then** they can use a quick save button to save current photo or a next button to navigate photos
7. **Given** a user navigates deeper into the hierarchy, **When** they look at the navigation area, **Then** they see a breadcrumb trail showing their current location with actual page titles (e.g., "ABC Corp > Warehouse A > Pump Room")
8. **Given** a user sees a long breadcrumb path, **When** the text exceeds screen width, **Then** the breadcrumb becomes horizontally scrollable
9. **Given** a user wants to navigate back, **When** they tap any segment in the breadcrumb trail, **Then** they are taken directly to that level in the hierarchy

### Edge Cases
- When no clients exist in the system, the home page displays an empty state with "Add Your First Client" message
- When offline, the system queues photos locally and automatically synchronizes when connection is restored
- When device storage is full, the camera blocks capture and displays "Storage Full - Free up space to continue" error message
- Equipment can be added to both main sites and subsites; UI should allow adding equipment from either level

## Requirements *(mandatory)*

### Functional Requirements
- **FR-001**: System MUST display a home page with "Recent" section showing recently accessed locations as cards with folder icons
- **FR-002**: System MUST display a "Clients" section below Recent with a list of all clients as tappable rows with right-pointing chevrons
- **FR-003**: System MUST provide an "Add New Client" button as the last item in the Clients list
- **FR-004**: System MUST implement a hierarchical navigation structure: Client → Main Site → SubSite/Equipment
- **FR-005**: Main sites MUST be able to contain both subsites and equipment items (equipment can be added directly to main sites)
- **FR-006**: Subsites MUST only be able to contain equipment items (no further nesting of subsites)
- **FR-007**: System MUST provide a floating camera button accessible from the main navigation
- **FR-008**: Camera page MUST display captured photos in a carousel/swipeable view
- **FR-009**: Camera page MUST provide a "Quick Save" button to immediately save the current photo
- **FR-010**: Camera page MUST provide a "Next" button to navigate through captured photos
- **FR-010a**: System MUST queue photos locally when offline and automatically sync when online connection is restored
- **FR-010b**: Each captured photo MUST include timestamp and GPS location metadata
- **FR-010c**: System MUST check available storage before photo capture and block capture with "Storage Full - Free up space to continue" error when insufficient space exists
- **FR-011**: System MUST maintain consistent blue header styling (hex color similar to #4A90E2) across all screens
- **FR-012**: System MUST display app name "Ziatech" in the header with search functionality
- **FR-013**: System MUST provide bottom navigation with at least: Home, Map, and Settings tabs
- **FR-014**: System MUST display a touchable breadcrumb navigation showing the current location in the hierarchy using actual page titles (e.g., "ABC Corp > Warehouse A > Pump Room > Generator #4")
- **FR-015**: Breadcrumb navigation MUST be horizontally scrollable when the path exceeds screen width
- **FR-016**: Each segment in the breadcrumb MUST be touchable and navigate directly to that level when tapped
- **FR-017**: Breadcrumb MUST update dynamically as users navigate through the hierarchy
- **FR-018**: System MUST implement role-based access control with three roles: admin (full access), technician (create/edit/view), and viewer (read-only)
- **FR-019**: Photos MUST be associated with specific equipment
- **FR-020**: System MUST enforce a maximum limit of 100 photos per equipment item
- **FR-021**: System MUST display a warning when equipment approaches photo limit (90+ photos) and block new captures at 100 photos with "Photo limit reached for this equipment" message

### Key Entities
- **Client**: Represents a customer organization, contains main sites, displayed with name in list view
- **MainSite**: Primary location for a client, can contain both subsites and equipment, has name and location attributes
- **SubSite**: Secondary location within a main site, can only contain equipment, has name and parent site reference
- **Equipment**: Individual asset or machinery, belongs to either main site or subsite, has identification details
- **Photo**: Captured image, tied to specific equipment, includes timestamp and GPS location, maximum 100 photos per equipment
- **RecentLocation**: Quick access reference to recently visited sites, displayed as cards on home screen
- **NavigationPath**: Represents the current location in the hierarchy, displayed as breadcrumb trail with touchable segments

---

## Review & Acceptance Checklist
*GATE: Automated checks run during main() execution*

### Content Quality
- [x] No implementation details (languages, frameworks, APIs)
- [x] Focused on user value and business needs
- [x] Written for non-technical stakeholders
- [x] All mandatory sections completed

### Requirement Completeness
- [x] No [NEEDS CLARIFICATION] markers remain
- [x] Requirements are testable and unambiguous
- [x] Success criteria are measurable
- [x] Scope is clearly bounded
- [x] Dependencies and assumptions identified

---

## Execution Status
*Updated by main() during processing*

- [x] User description parsed
- [x] Key concepts extracted
- [x] Ambiguities marked
- [x] User scenarios defined
- [x] Requirements generated
- [x] Entities identified
- [x] Review checklist passed

---