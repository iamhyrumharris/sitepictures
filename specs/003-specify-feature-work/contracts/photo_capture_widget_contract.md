# Widget Contract: Camera Capture Page

**Feature**: Camera Capture Page
**Date**: 2025-10-07
**Type**: Widget Contract Specification

## Overview
This document defines the contracts (inputs, outputs, behaviors) for all widgets in the camera capture feature. Each contract maps to functional requirements and serves as the specification for contract tests (TDD approach).

---

## 1. CameraCapturePage (Main Screen)

### Contract Specification

**Widget Type**: StatefulWidget (full-screen page)

**Inputs**:
| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `contextId` | String? | No | null | Future use: Client/Site/Equipment context for photo association |

**Outputs** (Navigation Results):
| Result | Type | Condition | Description |
|--------|------|-----------|-------------|
| `photos` | List<Photo> | Done + Next/Quick Save pressed | Completed photo list for further processing |
| `cancelled` | bool | Cancel + Confirm pressed | Session was cancelled, no photos returned |

**Behaviors** (from Functional Requirements):

1. **FR-001: Full-screen camera preview**
   - **Given**: Camera permissions granted
   - **When**: Page loads
   - **Then**: Display CameraPreview widget filling entire screen
   - **Test**: `test_camera_capture_page_displays_full_screen_preview()`

2. **FR-002: Cancel button (top-left)**
   - **Given**: Page is loaded
   - **When**: User observes UI
   - **Then**: Cancel/Back button visible in top-left corner
   - **Test**: `test_camera_capture_page_has_cancel_button_top_left()`

3. **FR-003: Done button (top-right)**
   - **Given**: Page is loaded
   - **When**: User observes UI
   - **Then**: Done button visible in top-right corner
   - **Test**: `test_camera_capture_page_has_done_button_top_right()`

4. **FR-004: Capture button (bottom-center)**
   - **Given**: Page is loaded
   - **When**: User observes UI
   - **Then**: Large capture button visible at bottom-center
   - **Test**: `test_camera_capture_page_has_capture_button_bottom_center()`

5. **FR-006: Camera preview behind overlays**
   - **Given**: UI elements rendered
   - **When**: User observes stack order
   - **Then**: Camera preview is bottom layer, buttons are overlays
   - **Test**: `test_camera_preview_renders_behind_overlays()`

6. **FR-018: Confirmation dialog on cancel with photos**
   - **Given**: User has captured at least 1 photo
   - **When**: User taps Cancel button
   - **Then**: Confirmation dialog appears with warning message
   - **Test**: `test_cancel_with_photos_shows_confirmation_dialog()`

7. **FR-019: No confirmation on cancel without photos**
   - **Given**: User has captured 0 photos
   - **When**: User taps Cancel button
   - **Then**: Navigate back immediately without dialog
   - **Test**: `test_cancel_without_photos_exits_immediately()`

8. **FR-022/FR-023: Permission denied error**
   - **Given**: Camera permission is denied
   - **When**: Page attempts to load
   - **Then**: Display error message with instructions to enable permission
   - **Test**: `test_permission_denied_shows_error_message()`

### Widget Tree Structure

```
CameraCapturePage
  └── Stack
        ├── CameraPreview (bottom layer, full-screen)
        ├── CameraPreviewOverlay (top layer)
        │     ├── Cancel button (top-left)
        │     └── Done button (top-right)
        └── Column (bottom alignment)
              ├── PhotoThumbnailStrip (horizontal ListView)
              └── CaptureButton (large, centered)
```

### State Dependencies

- Consumes: `PhotoCaptureProvider` (for photo list, camera status, error messages)
- Lifecycle: Implements `WidgetsBindingObserver` for app backgrounding (FR-029, FR-030)

---

## 2. CameraPreviewOverlay (Top Bar Widget)

### Contract Specification

**Widget Type**: StatelessWidget

**Inputs**:
| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `onCancel` | VoidCallback | Yes | - | Callback when Cancel button pressed |
| `onDone` | VoidCallback | Yes | - | Callback when Done button pressed |
| `hasPhotos` | bool | Yes | - | Whether session has any photos (for cancel confirmation logic) |

**Outputs**: None (callbacks handle actions)

**Behaviors**:

1. **Cancel button positioning**
   - **Given**: Widget rendered
   - **When**: User observes UI
   - **Then**: IconButton with back arrow icon in top-left corner
   - **Test**: `test_overlay_cancel_button_positioned_top_left()`

2. **Done button positioning**
   - **Given**: Widget rendered
   - **When**: User observes UI
   - **Then**: TextButton with "Done" label in top-right corner
   - **Test**: `test_overlay_done_button_positioned_top_right()`

3. **Cancel button tap**
   - **Given**: Widget rendered with onCancel callback
   - **When**: User taps Cancel button
   - **Then**: onCancel callback invoked
   - **Test**: `test_overlay_cancel_button_triggers_callback()`

4. **Done button tap**
   - **Given**: Widget rendered with onDone callback
   - **When**: User taps Done button
   - **Then**: onDone callback invoked
   - **Test**: `test_overlay_done_button_triggers_callback()`

### Visual Specifications

- **Background**: Semi-transparent gradient (top 80px, black to transparent)
- **Cancel button**: IconButton, Icons.arrow_back, white color, size 24px
- **Done button**: TextButton, "Done" text, white color, bold font
- **Padding**: 16px horizontal, 48px vertical (safe area consideration)

---

## 3. PhotoThumbnailStrip (Horizontal Scrolling Thumbnails)

### Contract Specification

**Widget Type**: StatelessWidget

**Inputs**:
| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `photos` | List<Photo> | Yes | - | List of captured photos to display |
| `onDeletePhoto` | void Function(String photoId) | Yes | - | Callback when X button tapped on thumbnail |

**Outputs**: None (callbacks handle actions)

**Behaviors** (from Functional Requirements):

1. **FR-007: Display thumbnails in horizontal row**
   - **Given**: photos list has 3 items
   - **When**: Widget renders
   - **Then**: 3 thumbnails displayed in horizontal ListView
   - **Test**: `test_thumbnail_strip_displays_all_photos()`

2. **FR-008: Thumbnails in capture order**
   - **Given**: photos list ordered by displayOrder [0, 1, 2]
   - **When**: Widget renders
   - **Then**: Thumbnails appear left-to-right in displayOrder sequence
   - **Test**: `test_thumbnail_strip_maintains_capture_order()`

3. **FR-009: X overlay on each thumbnail**
   - **Given**: Thumbnail rendered
   - **When**: User observes thumbnail
   - **Then**: X icon button visible on top-right corner of thumbnail
   - **Test**: `test_thumbnail_has_delete_overlay()`

4. **FR-010: Delete thumbnail on X tap**
   - **Given**: Thumbnail with X button
   - **When**: User taps X button
   - **Then**: onDeletePhoto callback invoked with photo.id
   - **Test**: `test_thumbnail_delete_triggers_callback()`

5. **FR-026: Smooth horizontal scrolling**
   - **Given**: 15 thumbnails rendered
   - **When**: User scrolls horizontally
   - **Then**: ListView scrolls smoothly (60fps target)
   - **Test**: `test_thumbnail_strip_scrolls_smoothly()` (performance test)

### Visual Specifications

- **Thumbnail size**: 80x80 px (square)
- **Spacing**: 8px between thumbnails
- **X button**: Positioned top-right corner, 24x24 px, red background, white icon
- **Border**: 2px white border around thumbnail
- **Empty state**: Show empty container if photos list is empty

---

## 4. CaptureButton (Large Shutter Button)

### Contract Specification

**Widget Type**: StatelessWidget

**Inputs**:
| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `onPressed` | VoidCallback? | Yes | - | Callback when button pressed (null = disabled) |
| `isDisabled` | bool | Yes | - | Whether button is disabled (at 20 photo limit) |

**Outputs**: None (callback handles action)

**Behaviors** (from Functional Requirements):

1. **FR-005: Capture photo on tap**
   - **Given**: Button enabled (isDisabled = false)
   - **When**: User taps button
   - **Then**: onPressed callback invoked
   - **Test**: `test_capture_button_triggers_callback_when_enabled()`

2. **FR-027a: Disabled when at limit**
   - **Given**: isDisabled = true (20 photos captured)
   - **When**: User observes button
   - **Then**: Button appears disabled (grayed out, no tap response)
   - **Test**: `test_capture_button_disabled_at_photo_limit()`

3. **FR-027b: Show limit message**
   - **Given**: isDisabled = true
   - **When**: Widget renders
   - **Then**: "Photo limit reached (20/20)" message displayed below button
   - **Test**: `test_capture_button_shows_limit_message_when_disabled()`

4. **Enabled state visual**
   - **Given**: isDisabled = false
   - **When**: User observes button
   - **Then**: Button has normal appearance (white circle, drop shadow)
   - **Test**: `test_capture_button_enabled_appearance()`

### Visual Specifications

- **Size**: 72px diameter (large, easy to tap)
- **Shape**: Circle
- **Color**: White with subtle gray border
- **Shadow**: Elevation 4 (Material drop shadow)
- **Disabled color**: Gray (#CCCCCC)
- **Positioning**: Bottom-center, 24px margin from bottom edge
- **Limit message**: Below button, 12sp font, red color

---

## 5. Modal Popup (Done Button Action)

### Contract Specification

**Widget Type**: StatelessWidget (showModalBottomSheet content)

**Inputs**: None (modal context)

**Outputs** (Navigation actions):
| Result | Type | Condition | Description |
|--------|------|-----------|-------------|
| `'next'` | String | Next button tapped | Navigate to details screen (placeholder) |
| `'quick_save'` | String | Quick Save button tapped | Save photos (placeholder) |

**Behaviors** (from Functional Requirements):

1. **FR-013: Modal appears on Done tap**
   - **Given**: User tapped Done button
   - **When**: Modal renders
   - **Then**: Bottom sheet appears with 2 buttons
   - **Test**: `test_done_modal_appears_with_two_buttons()`

2. **FR-014: Next button present**
   - **Given**: Modal rendered
   - **When**: User observes modal
   - **Then**: "Next" button visible
   - **Test**: `test_done_modal_has_next_button()`

3. **FR-015: Quick Save button present**
   - **Given**: Modal rendered
   - **When**: User observes modal
   - **Then**: "Quick Save" button visible
   - **Test**: `test_done_modal_has_quick_save_button()`

4. **FR-016: Next button navigation (placeholder)**
   - **Given**: Modal rendered
   - **When**: User taps Next button
   - **Then**: Return 'next' result (future: navigate to details screen)
   - **Test**: `test_next_button_returns_next_result()`

5. **FR-017: Quick Save button action (placeholder)**
   - **Given**: Modal rendered
   - **When**: User taps Quick Save button
   - **Then**: Return 'quick_save' result (future: save photos)
   - **Test**: `test_quick_save_button_returns_quick_save_result()`

### Visual Specifications

- **Modal height**: 200px (fixed)
- **Background**: White with rounded top corners (16px radius)
- **Button layout**: Vertical stack, 16px spacing
- **Button style**: Material ElevatedButton, full width (minus 32px horizontal padding)
- **Next button color**: Blue (primary color)
- **Quick Save button color**: Green (success color)

---

## Contract Test Coverage Summary

| Widget | Contract Tests | Total |
|--------|----------------|-------|
| CameraCapturePage | 8 tests (FR-001, FR-002, FR-003, FR-004, FR-006, FR-018, FR-019, FR-022/023) | 8 |
| CameraPreviewOverlay | 4 tests (positioning + callbacks) | 4 |
| PhotoThumbnailStrip | 5 tests (FR-007, FR-008, FR-009, FR-010, FR-026) | 5 |
| CaptureButton | 4 tests (FR-005, FR-027a, FR-027b, enabled state) | 4 |
| Modal Popup | 5 tests (FR-013, FR-014, FR-015, FR-016, FR-017) | 5 |
| **TOTAL** | **26 widget contract tests** | **26** |

---

## Test Execution Order (TDD)

1. Write all contract tests first (they will fail - no implementation yet)
2. Implement widgets one by one to make tests pass:
   - CaptureButton (simplest, no dependencies)
   - PhotoThumbnailStrip (depends on Photo model)
   - CameraPreviewOverlay (simple, callback-based)
   - Modal Popup (simple, showModalBottomSheet)
   - CameraCapturePage (assembles all widgets + provider)

---

**Widget Contract Status**: ✅ COMPLETE
**Total Contracts Defined**: 5 widgets
**Total Test Specifications**: 26 contract tests
**Ready for Test Implementation**: YES
