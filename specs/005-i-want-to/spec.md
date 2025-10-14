# Feature Specification: Context-Aware Camera and Expandable Navigation FABs

**Feature Branch**: `005-i-want-to`
**Created**: 2025-10-11
**Status**: Draft
**Input**: User description: "I want to update the camera page. Because I think there are different functions once you save photos. The main camera on the home page will open up the camera page and let you take pictures. Now I think that the difference is when you press the done button. When you are on the home page and go to the camera youll take pictures and when you press the done button it will display next or quick save(like it does already). Now if you are on the before and after tab on the equipment page then it will bring up the camera but this time it will say 'save before' or 'save after' I'd like better wording if you can think of some. Then on the main site page it will be a plus sign FAB and will extend into two buttons when clicked to show a subsite or equipment add button. When on the subsite page the FAB will just create an equipment. When you are on a client page it will show an plus FAB but then extend into 3 buttons main site, sub site, or equipment."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Context-Aware Camera Save Actions (Priority: P1)

Field technicians capture photos in different contexts throughout their workflow. When taking quick documentation from the home screen, they see familiar options. When capturing equipment-specific photos, they need clear labeling that indicates equipment context. When documenting before/after states in folders, they need clear indication of which category they're capturing for. This feature focuses on displaying context-appropriate button labels; the actual save functionality will be implemented in a future phase.

**Why this priority**: Establishes the UI foundation for context-aware workflows. Clear button labeling prevents user confusion even with mock implementations, and enables iterative development of save logic later.

**Independent Test**: Can be fully tested by navigating to each context (home, equipment all photos tab, equipment folders tab with before/after designation), capturing photos, and verifying the save action labels and behaviors match the context.

**Acceptance Scenarios**:

1. **Given** user is on home page, **When** they tap camera FAB and capture photos and tap Done, **Then** system displays modal with "Next" and "Quick Save" button labels (existing behavior preserved)
2. **Given** user is on equipment All Photos tab, **When** they tap camera FAB and capture photos and tap Done, **Then** system displays "Save to Equipment" button label (mock functionality)
3. **Given** user is on equipment Folders tab viewing a Before/After folder, **When** they tap "Capture Before" button and capture photos and tap Done, **Then** system displays "Capture as Before" button label (mock functionality)
4. **Given** user is on equipment Folders tab viewing a Before/After folder, **When** they tap "Capture After" button and capture photos and tap Done, **Then** system displays "Capture as After" button label (mock functionality)
5. **Given** user taps any new context-aware button (Save to Equipment, Capture as Before, Capture as After), **When** button is pressed, **Then** system shows temporary confirmation message and returns to previous screen (placeholder behavior for future implementation)
6. **Given** user taps "Next" or "Quick Save" from home context, **When** button is pressed, **Then** existing behavior is preserved unchanged

---

### User Story 2 - Client Page Expandable FAB (Priority: P2)

When viewing a client, users need to create organizational structures at any level (main sites for major locations, subsites for subdivisions, or equipment directly under the client). An expandable FAB provides quick access to all creation options without cluttering the interface.

**Why this priority**: Clients are the top level of hierarchy, and users need maximum flexibility to organize their work. This is the most complex FAB behavior and should be implemented early to inform simpler variations.

**Independent Test**: Navigate to any client detail page, tap the FAB, verify it expands to show three labeled action buttons (Main Site, SubSite, Equipment), tap each action to verify correct creation dialog appears.

**Acceptance Scenarios**:

1. **Given** user is viewing client detail page with admin/technician role, **When** they tap the "+" FAB, **Then** FAB expands to show three action buttons: "Add Main Site", "Add SubSite", and "Add Equipment"
2. **Given** expanded FAB is showing, **When** user taps "Add Main Site", **Then** main site creation dialog appears with client context preserved
3. **Given** expanded FAB is showing, **When** user taps "Add SubSite", **Then** subsite creation dialog appears with client context preserved
4. **Given** expanded FAB is showing, **When** user taps "Add Equipment", **Then** equipment creation dialog appears with client context preserved
5. **Given** expanded FAB is showing, **When** user taps outside the FAB area, **Then** FAB collapses back to single "+" button
6. **Given** user has viewer role, **When** viewing client detail page, **Then** no FAB is displayed

---

### User Story 3 - Main Site Page Expandable FAB (Priority: P3)

When managing a main site, users need to either create subsites (for subdividing the location) or add equipment directly. An expandable FAB with two clear options streamlines this common organizational task.

**Why this priority**: Main sites are frequently accessed for adding subsites and equipment. Reducing navigation friction here improves overall workflow efficiency.

**Independent Test**: Navigate to any main site detail page, tap the FAB, verify it expands to show two labeled buttons (SubSite, Equipment), create items using each action.

**Acceptance Scenarios**:

1. **Given** user is viewing main site page with admin/technician role, **When** they tap the "+" FAB, **Then** FAB expands to show two action buttons: "Add SubSite" and "Add Equipment"
2. **Given** expanded FAB is showing on main site page, **When** user taps "Add SubSite", **Then** subsite creation dialog appears with main site context preserved
3. **Given** expanded FAB is showing on main site page, **When** user taps "Add Equipment", **Then** equipment creation dialog appears with main site context preserved
4. **Given** expanded FAB is showing on main site page, **When** user taps outside the FAB area, **Then** FAB collapses back to single "+" button

---

### User Story 4 - SubSite Page Simple FAB (Priority: P4)

SubSites represent the lowest organizational level before equipment, so they only support adding equipment. A simple "+" FAB with single direct action provides the fastest path to equipment creation.

**Why this priority**: SubSites have only one creation action, making this the simplest FAB update. Existing behavior already works well, just needs to maintain consistency with permission model.

**Independent Test**: Navigate to any subsite page, tap the "+" FAB, verify it directly opens equipment creation dialog with subsite context preserved.

**Acceptance Scenarios**:

1. **Given** user is viewing subsite page with admin/technician role, **When** they tap the "+" FAB, **Then** equipment creation dialog opens directly (no expansion needed)
2. **Given** user creates equipment from subsite FAB, **When** equipment is saved, **Then** equipment is associated with that subsite and appears in the subsite's equipment list
3. **Given** user has viewer role, **When** viewing subsite page, **Then** no FAB is displayed

---

### Edge Cases

- What happens when camera is opened without proper context information? (System should default to home context behavior with Next/Quick Save options)
- How does system handle when user navigates away during FAB expansion? (FAB should collapse automatically when navigation occurs)
- What happens if user has permission to view but not create when FAB would normally appear? (FAB should be hidden entirely)
- How does system behave when user captures photos but folder is deleted before save? (System should show error and offer to save to equipment general photos instead)
- What happens when camera context indicates before/after but folder no longer exists? (System should show error message and return to equipment page without saving)
- How does FAB expansion behave on small screens where expanded buttons might overflow? (Buttons should stack vertically or use scrollable container if needed)
- What happens when user rapidly taps FAB during expansion animation? (System should debounce taps and prevent multiple expansions/collapses)

## Requirements *(mandatory)*

### Functional Requirements

**Camera Context Detection & Button Labeling:**

- **FR-001**: System MUST detect camera launch context (home, equipment-all-photos, equipment-before-after) and pass context to camera page
- **FR-002**: Camera page MUST display context-appropriate button labels when user taps Done button
- **FR-003**: When launched from home context, camera MUST display modal with "Next" and "Quick Save" button labels (existing behavior)
- **FR-004**: When launched from equipment All Photos tab, camera MUST display "Save to Equipment" button label
- **FR-005**: When launched from equipment folder with Before designation, camera MUST display "Capture as Before" button label
- **FR-006**: When launched from equipment folder with After designation, camera MUST display "Capture as After" button label
- **FR-007**: When user taps new context-aware buttons (Save to Equipment, Capture as Before, Capture as After), system MUST show placeholder confirmation message (e.g., "Feature coming soon") and return to previous screen
- **FR-008**: When user taps "Next" or "Quick Save" from home context, system MUST preserve existing functional behavior unchanged

**Expandable FAB - Client Page:**

- **FR-009**: Client detail page MUST display "+" FAB for users with admin or technician role
- **FR-010**: When user taps "+" FAB on client page, FAB MUST expand to show three action buttons: "Add Main Site", "Add SubSite", and "Add Equipment"
- **FR-011**: Expanded FAB buttons MUST be clearly labeled and distinguishable from each other
- **FR-012**: When user taps "Add Main Site" from expanded FAB, system MUST display main site creation dialog with client context preserved
- **FR-013**: When user taps "Add SubSite" from expanded FAB, system MUST display subsite creation dialog with client context preserved
- **FR-014**: When user taps "Add Equipment" from expanded FAB, system MUST display equipment creation dialog with client context preserved
- **FR-015**: Expanded FAB MUST collapse when user taps outside the FAB area
- **FR-016**: Expanded FAB MUST collapse when user navigates away from page

**Expandable FAB - Main Site Page:**

- **FR-017**: Main site detail page MUST display "+" FAB for users with admin or technician role
- **FR-018**: When user taps "+" FAB on main site page, FAB MUST expand to show two action buttons: "Add SubSite" and "Add Equipment"
- **FR-019**: When user taps "Add SubSite" from expanded FAB, system MUST display subsite creation dialog with main site context preserved
- **FR-020**: When user taps "Add Equipment" from expanded FAB, system MUST display equipment creation dialog with main site context preserved
- **FR-021**: Expanded FAB MUST collapse when user taps outside the FAB area or navigates away

**Simple FAB - SubSite Page:**

- **FR-022**: SubSite detail page MUST display "+" FAB for users with admin or technician role
- **FR-023**: When user taps "+" FAB on subsite page, system MUST directly open equipment creation dialog (no expansion)
- **FR-024**: Equipment created from subsite FAB MUST be associated with that subsite
- **FR-025**: SubSite page FAB behavior MUST remain consistent with existing single-action pattern

**Permissions & Context Validation:**

- **FR-026**: System MUST hide all FABs when user has viewer role
- **FR-027**: System MUST validate context before launching camera and provide default (home) context if invalid
- **FR-028**: System MUST validate folder existence before displaying before/after save actions
- **FR-029**: System MUST handle folder deletion during capture by offering alternative save location (equipment general photos)

### Key Entities

- **Camera Context**: Represents the launch origin of camera (home, equipment-all-photos, equipment-folder-before, equipment-folder-after)
- **Save Action Button**: UI button displayed after photo capture, with label determined by camera context (Next, Quick Save, Save to Equipment, Capture as Before, Capture as After)
- **FAB Expansion State**: UI state indicating whether FAB is collapsed (single button) or expanded (multiple action buttons visible)
- **Navigation Context**: Hierarchical location context (client, main site, subsite, equipment) used to populate creation dialogs

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 90% of users correctly identify which context they're capturing in based on save button labels (e.g., "Save to Equipment" indicates equipment context, "Capture as Before" indicates before-state documentation)
- **SC-002**: Camera context detection accuracy of 100% (camera always displays correct button labels for launch context)
- **SC-003**: Users understand button labels are context-aware even with placeholder functionality (measured by user feedback or testing)
- **SC-004**: Users create new organizational items (sites, subsites, equipment) from expandable FABs in under 5 seconds from FAB tap to creation dialog appearance
- **SC-005**: FAB expansion animations complete within 300ms to maintain perception of instant response
- **SC-006**: 95% of users understand which creation options are available at each navigation level based on FAB expansion choices
- **SC-007**: Zero confusion about camera context based on post-capture button labeling during user testing
- **SC-008**: Context-aware button labels display consistently across all equipment navigation paths (All Photos tab, Folders tab, Before/After designations)

## Assumptions

- **Assumption 1**: Existing camera capture functionality (20-photo limit, thumbnail preview, cancel/done buttons) remains unchanged; only button labels differ by context
- **Assumption 2**: Current permission model (admin/technician can create, viewer cannot) applies consistently to all new FAB behaviors
- **Assumption 3**: Mock save functionality for new buttons is acceptable for this phase (actual photo association logic deferred to future implementation)
- **Assumption 4**: "Next" and "Quick Save" actions in home context preserve existing behavior unchanged (this feature only adds new button labels for other contexts)
- **Assumption 5**: FAB expansion uses standard material design patterns for speed dial or expandable FABs
- **Assumption 6**: Creating subsite directly from client page should prompt user to select which main site it belongs to (context validation needed)
- **Assumption 7**: Creating equipment directly from client page should prompt user to select main site or subsite association (context validation needed)
- **Assumption 8**: Users prefer concise action labels like "Capture as Before" over verbose alternatives like "Save these photos as Before photos to this folder"
- **Assumption 9**: SubSite pages maintain simple FAB because they only support one action (add equipment); no expansion needed for single action
- **Assumption 10**: Screen sizes are sufficient to display expanded FAB buttons without overflow (mobile-first design assumes modern smartphone dimensions)

## Dependencies

- **Dependency 1**: Existing camera capture functionality must support passing context parameters (folderId, beforeAfter, equipmentId) from launch location
- **Dependency 2**: Navigation routing system must support passing context data when launching camera from different screens
- **Dependency 3**: Camera page must support conditional rendering of save buttons based on context parameters
- **Dependency 4**: Permission system must be consistently enforced across all FAB display logic
- **Dependency 5**: Main site and subsite creation workflows must support optional parent context (creating from client level vs. from site level)

## Out of Scope

- **Actual save functionality for new context-aware buttons** (Save to Equipment, Capture as Before, Capture as After) - This phase only implements button label display; actual photo association logic will be implemented in future phase
- Full implementation of equipment-specific photo workflows and folder-based photo categorization
- Changing the 20-photo capture limit or core camera UI (preview, thumbnails, capture button)
- Modifying the Cancel button behavior or confirmation dialogs beyond placeholder messages
- Adding new organizational hierarchy levels beyond client > main site > subsite > equipment
- Implementing keyboard shortcuts or gesture-based FAB interactions
- Changing the "Quick Save" or "Next" behavior in home context (existing behavior preserved)
- Modifying equipment folder structure or before/after categorization system
- Adding batch operations or multi-select for organizational item creation
- Implementing search or filtering within FAB action selections
- Adding tooltips, help text, or onboarding tutorials for new FAB behaviors
- Customizing FAB colors, icons, or animation styles beyond default material design patterns
- Backend photo storage logic for context-specific saves (deferred to future implementation)
