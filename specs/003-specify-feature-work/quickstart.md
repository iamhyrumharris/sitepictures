# Quickstart Validation: Camera Capture Page

**Feature**: Work Site Photo Capture Page
**Date**: 2025-10-07
**Purpose**: Manual validation steps derived from acceptance scenarios

## Overview
This quickstart guide provides step-by-step validation scenarios to verify the camera capture feature works correctly. Each scenario maps to acceptance criteria from the feature specification. Execute these scenarios after implementation is complete.

---

## Prerequisites

1. **Flutter environment**: Flutter SDK 3.24+ installed
2. **Device/emulator**: iOS 13+ or Android 8.0+ device with camera
3. **App running**: sitepictures app launched successfully
4. **Test data**: Clear any existing photo sessions

## Setup Steps

```bash
# 1. Ensure dependencies installed
flutter pub get

# 2. Run app on device (emulator cameras may not work properly)
flutter run

# 3. Navigate to camera capture page
# (Exact navigation depends on integration - may be from home screen or client detail)
```

---

## Validation Scenarios

### Scenario 1: Camera Page Loads with Full Preview (FR-001, FR-002, FR-003, FR-004)

**Acceptance Criteria**: Full-screen camera preview with Cancel (top-left), Done (top-right), and Capture button (bottom-center)

**Steps**:
1. Grant camera permission when prompted
2. Navigate to camera capture page
3. Observe page loads

**Expected Results**:
- ✅ Full-screen live camera preview visible
- ✅ Cancel/Back button visible in top-left corner
- ✅ Done button visible in top-right corner
- ✅ Large capture button visible at bottom-center
- ✅ Camera preview shows real-time feed (move device to verify)
- ✅ All UI elements render on top of camera preview (overlay pattern)

**Performance Validation**:
- Camera preview initializes in < 1 second
- UI navigation from previous screen completes in < 500ms

**Edge Case**: If camera permission denied, verify error message displays with instructions to enable in settings (jump to Scenario 10)

---

### Scenario 2: Capture Button Creates Thumbnail (FR-005, FR-007, FR-008)

**Acceptance Criteria**: Tapping capture button creates a photo and displays thumbnail in horizontal row

**Steps**:
1. Complete Scenario 1 (camera page loaded)
2. Tap the large capture button at bottom-center
3. Wait for capture to complete
4. Observe thumbnail row above capture button

**Expected Results**:
- ✅ Photo capture completes in < 2 seconds (constitutional requirement)
- ✅ Camera shutter sound/animation (platform-dependent)
- ✅ Thumbnail appears in horizontal scrollable row above capture button
- ✅ Thumbnail shows preview of captured photo
- ✅ Thumbnail has 'X' delete overlay in top-right corner
- ✅ displayOrder is 0 (first photo)

**Repeat Test**:
5. Tap capture button 2 more times
6. Verify 3 thumbnails total displayed left-to-right in capture order

---

### Scenario 3: Delete Thumbnail Removes Photo (FR-009, FR-010)

**Acceptance Criteria**: Tapping 'X' on thumbnail immediately removes it from session

**Steps**:
1. Complete Scenario 2 (3 photos captured)
2. Tap the 'X' button on the middle thumbnail (displayOrder 1)
3. Observe thumbnail row

**Expected Results**:
- ✅ Middle thumbnail disappears immediately (< 100ms)
- ✅ Remaining thumbnails shift left to close gap
- ✅ Only 2 thumbnails remain
- ✅ displayOrder reindexed (remaining photos now 0 and 1)

**Repeat Test**:
4. Delete another thumbnail
5. Verify only 1 thumbnail remains

---

### Scenario 4: Done Button Shows Modal Popup (FR-013, FR-014, FR-015)

**Acceptance Criteria**: Done button displays modal with "Next" and "Quick Save" options

**Steps**:
1. Capture at least 1 photo
2. Tap the Done button (top-right)
3. Observe modal popup

**Expected Results**:
- ✅ Modal bottom sheet appears from bottom of screen
- ✅ Modal displays 2 buttons: "Next" and "Quick Save"
- ✅ Modal has white background with rounded top corners
- ✅ Buttons are full-width with appropriate spacing

**Button Actions** (placeholders per clarification):
4. Tap "Next" button
   - ✅ Modal closes (future: navigate to details screen)
5. Reopen modal, tap "Quick Save" button
   - ✅ Modal closes (future: save/upload photos)

---

### Scenario 5: Cancel with Photos Shows Confirmation (FR-018, FR-020)

**Acceptance Criteria**: Cancel button with unsaved photos shows confirmation dialog to prevent accidental loss

**Steps**:
1. Capture 3 photos
2. Tap the Cancel/Back button (top-left)
3. Observe confirmation dialog

**Expected Results**:
- ✅ Confirmation dialog appears
- ✅ Dialog message warns about losing unsaved photos
- ✅ Dialog has 2 buttons: "Cancel" (go back) and "Discard" (confirm)

**Confirm Discard**:
4. Tap "Discard" button
   - ✅ Dialog closes
   - ✅ Navigate back to previous screen
   - ✅ All 3 photos deleted from temp storage (verify with file explorer)

---

### Scenario 6: Cancel without Photos Exits Immediately (FR-019)

**Acceptance Criteria**: Cancel button with 0 photos exits without confirmation

**Steps**:
1. Open camera page (0 photos captured)
2. Tap the Cancel/Back button (top-left)

**Expected Results**:
- ✅ No confirmation dialog appears
- ✅ Navigate back to previous screen immediately

---

### Scenario 7: Horizontal Scrolling with Many Thumbnails (FR-026)

**Acceptance Criteria**: Thumbnail row scrolls smoothly with 10-20 photos

**Steps**:
1. Capture 15 photos (tap capture button 15 times)
2. Observe thumbnail row fills horizontal space
3. Swipe left on thumbnail row to scroll
4. Swipe right to scroll back

**Expected Results**:
- ✅ Thumbnail row displays first ~5-6 thumbnails (depends on device width)
- ✅ Horizontal scrolling works smoothly (60fps - use Flutter DevTools FPS counter)
- ✅ Thumbnails load quickly as they scroll into view (lazy loading)
- ✅ No visible lag or frame drops during scrolling

**Performance Validation**:
- Open Flutter DevTools → Performance tab
- Scroll thumbnail row back and forth
- Verify FPS stays above 55 (target: 60fps per FR-026)

---

### Scenario 8: 20 Photo Limit Enforcement (FR-027, FR-027a, FR-027b)

**Acceptance Criteria**: System prevents capturing more than 20 photos per session

**Steps**:
1. Capture 20 photos (tap capture button 20 times)
2. Observe capture button state
3. Attempt to tap capture button

**Expected Results**:
- ✅ After 20th photo, capture button becomes disabled (grayed out)
- ✅ Message displays below button: "Photo limit reached (20/20)" (or similar)
- ✅ Tapping disabled button has no effect (no 21st photo captured)
- ✅ Done button remains enabled (can complete session)

**Recovery Test**:
4. Delete 1 photo (tap 'X' on any thumbnail)
   - ✅ Capture button becomes enabled again
   - ✅ Limit message disappears or updates to "19/20"

---

### Scenario 9: Session Preservation on Backgrounding (FR-029, FR-030)

**Acceptance Criteria**: Photos persist when app is backgrounded (e.g., incoming call)

**Steps**:
1. Capture 5 photos
2. Press home button to background app (or simulate incoming call)
3. Wait 10 seconds
4. Return to app (tap app icon or resume)

**Expected Results**:
- ✅ Camera page reloads with camera preview
- ✅ All 5 photos still displayed in thumbnail row
- ✅ Correct order preserved (displayOrder 0-4)
- ✅ Can capture additional photos (session not reset)

**Technical Verification**:
- Check SharedPreferences for 'active_camera_session' key (developer tool)
- Verify session JSON contains 5 photo entries

---

### Scenario 10: Permission Denied Shows Error (FR-021, FR-022, FR-023)

**Acceptance Criteria**: Clear error message when camera permission denied

**Setup**:
1. Deny camera permission in device settings (Settings > sitepictures > Camera > Deny)
2. Open camera capture page

**Steps**:
3. Observe page loads with permission denied

**Expected Results**:
- ✅ No camera preview displayed
- ✅ Error message appears: "Camera access required to capture photos" (or similar)
- ✅ Instructions shown: "Tap 'Open Settings' to enable camera permission"
- ✅ "Open Settings" button displayed
- ✅ Tapping button opens device settings app (iOS: Settings > sitepictures, Android: App Info)

**Recovery Test**:
4. Grant permission in settings
5. Return to app
6. Camera page should now display preview (auto-retry or manual refresh)

---

### Scenario 11: Camera Hardware Failure Handling (FR-024)

**Acceptance Criteria**: Graceful error handling when camera unavailable

**Setup** (requires physical testing or mock):
1. Disconnect camera (if possible) or force camera error via mock
2. Open camera capture page

**Expected Results**:
- ✅ User-friendly error message: "Camera is currently unavailable" (or similar)
- ✅ Suggestion to restart app or check hardware
- ✅ No crash or blank screen
- ✅ Cancel button still functional (can exit page)

---

## Performance Validation Checklist

Run these performance tests with Flutter DevTools:

| Metric | Target | Test Method | Pass/Fail |
|--------|--------|-------------|-----------|
| Photo capture latency | < 2s from tap to thumbnail | Stopwatch + manual timing | ☐ |
| Camera preview init | < 1s from page load to preview | Stopwatch + manual timing | ☐ |
| Thumbnail scroll FPS | 60fps (min 55fps) | DevTools Performance tab | ☐ |
| UI navigation | < 500ms from previous screen | DevTools Performance tab | ☐ |
| Memory usage (20 photos) | < 50MB increase | DevTools Memory tab | ☐ |
| Battery drain (10 min active use) | < 1% per minute | Device battery stats | ☐ |

---

## Edge Case Validation

Test these edge cases manually:

1. **Storage Full**:
   - Fill device storage to capacity
   - Attempt to capture photo
   - Expected: Error message "Storage full" or similar

2. **App Crash Recovery**:
   - Capture 5 photos
   - Force quit app (swipe up on iOS, force stop on Android)
   - Reopen app
   - Expected: Session may not restore (acceptable - crash scenario)

3. **Camera in Use by Another App**:
   - Open another camera app first
   - Return to sitepictures and open camera page
   - Expected: Error message "Camera in use" or auto-retry when available

4. **Screen Rotation** (if supported):
   - Capture photos in portrait mode
   - Rotate device to landscape
   - Expected: UI adapts or locks to portrait (depends on app constraints)

---

## Automated Test Verification

After manual quickstart validation, run automated tests:

```bash
# Run all unit tests
flutter test

# Run widget tests
flutter test test/widget/

# Run integration tests (on device)
flutter drive --driver=test_driver/integration_test.dart \
              --target=integration_test/camera_capture_flow_test.dart
```

**Expected**: All tests pass (26 widget tests + 47 unit tests + 4 integration tests = 77 total)

---

## Validation Sign-Off

**Tester Name**: _______________________
**Date**: _______________________
**Device(s) Tested**: _______________________ (iOS version or Android version)

**Scenarios Passed**: _____ / 11
**Performance Checks Passed**: _____ / 6
**Edge Cases Validated**: _____ / 4

**Overall Status**: ☐ PASS  ☐ FAIL (list failures):
_______________________________________________________________
_______________________________________________________________

**Notes/Issues**:
_______________________________________________________________
_______________________________________________________________

---

**Quickstart Status**: ✅ READY FOR VALIDATION
**Total Scenarios**: 11 acceptance tests + 6 performance tests + 4 edge cases
**Estimated Completion Time**: 30-45 minutes
