# Quickstart: Equipment Page Photo Management with Folders

**Feature**: 004-i-want-to
**Date**: 2025-10-09
**Purpose**: Manual validation scenarios for folder-based photo organization

## Prerequisites

- Flutter app installed on iOS/Android device or simulator
- User logged in with Admin or Technician role (not Viewer)
- At least one equipment item created (e.g., "Pump #3" under Client → Main Site → Sub Site)
- Camera permissions granted

## Test Scenarios

### Scenario 1: Create Folder and View in List

**Objective**: Verify folder creation with work order + date naming (FR-008, FR-008a, FR-008b, FR-011)

**Steps**:
1. Navigate to Home → Select Client → Main Site → Sub Site → Equipment
2. Tap "Folders" tab (should be empty initially)
3. Tap "Create Folder" button (FAB or in-tab button)
4. Enter work order: `WO-789`
5. Tap "Create" button

**Expected Results**:
- ✅ Dialog closes immediately
- ✅ Folder appears in list with name: `WO-789 - 2025-10-09` (today's date)
- ✅ Folder appears at TOP of list (newest first)
- ✅ Folder shows "0 photos" count or similar indicator

**Edge Cases**:
- Empty input: Create button should be disabled
- Very long work order (60+ chars): Should be truncated to 50 characters
- Special characters: Should be sanitized (only alphanumeric + -, _, #, / allowed)

**Validation Queries** (via database inspector):
```sql
SELECT * FROM photo_folders WHERE equipment_id = '<equipment-id>' ORDER BY created_at DESC;
-- Verify: name format, work_order field, created_at timestamp
```

---

### Scenario 2: Capture Before Photos

**Objective**: Verify photo capture in Before tab (FR-014, FR-016)

**Prerequisites**: Folder created from Scenario 1

**Steps**:
1. Folders tab → Tap on `WO-789 - 2025-10-09` folder
2. Verify "Before" and "After" tabs visible (FR-012)
3. Before tab should be active by default
4. Tap FAB (camera button)
5. Capture 3 photos in succession
6. Return to folder detail screen

**Expected Results**:
- ✅ 3 photos appear in Before tab only
- ✅ Photos ordered newest first (most recent at top)
- ✅ After tab shows "0 photos" or empty state
- ✅ Switching to After tab shows empty state message

**Edge Cases**:
- Camera permissions denied: Show error dialog with instructions
- Low storage space: Show warning before capture
- App backgrounded during capture: Session should resume on foreground

**Validation Queries**:
```sql
SELECT p.*, fp.before_after
FROM photos p
JOIN folder_photos fp ON p.id = fp.photo_id
WHERE fp.folder_id = '<folder-id>' AND fp.before_after = 'before';
-- Verify: 3 photos, before_after = 'before'
```

---

### Scenario 3: Capture After Photos

**Objective**: Verify after photo capture and separation from before photos (FR-015, FR-016)

**Prerequisites**: Scenario 2 completed (folder with 3 before photos)

**Steps**:
1. Folder detail screen → Tap "After" tab
2. Verify empty state (no photos yet)
3. Tap FAB (camera button)
4. Capture 2 photos
5. Return to folder detail screen

**Expected Results**:
- ✅ 2 photos appear in After tab
- ✅ Before tab still shows 3 photos (unchanged)
- ✅ Switching between tabs preserves state (no reload flash)
- ✅ Each tab shows correct photo count

**Visual Indicators**:
- Tab labels should show counts: "Before (3)" / "After (2)"

**Validation Queries**:
```sql
SELECT before_after, COUNT(*) as count
FROM folder_photos
WHERE folder_id = '<folder-id>'
GROUP BY before_after;
-- Verify: before = 3, after = 2
```

---

### Scenario 4: View All Photos with Folder Indicators

**Objective**: Verify All Photos tab shows folder photos with visual badges (FR-005, FR-005a)

**Prerequisites**: Scenario 3 completed (folder with 5 total photos)

**Steps**:
1. Navigate back to Equipment screen
2. Tap "All Photos" tab
3. Scroll through photo grid

**Expected Results**:
- ✅ All 5 folder photos visible in grid
- ✅ Each folder photo has small folder icon badge (top-right corner)
- ✅ Photos ordered chronologically (newest first, regardless of before/after)
- ✅ Tapping badge or long-pressing photo shows folder name in context menu/tooltip

**Visual Verification**:
- Folder badge: Small dark overlay with folder icon (distinct from sync badge)
- Badge color: Contrasts with photo thumbnail
- Badge position: Top-right corner, doesn't obscure photo content

**Edge Case**: Capture new standalone photo (not in folder)
- Navigate to Equipment → All Photos tab → FAB
- Capture 1 photo outside folder context
- Verify: New photo appears at top (newest), NO folder badge

**Validation Queries**:
```sql
SELECT
  p.id,
  p.timestamp,
  fp.folder_id,
  pf.name AS folder_name
FROM photos p
LEFT JOIN folder_photos fp ON p.id = fp.photo_id
LEFT JOIN photo_folders pf ON fp.folder_id = pf.id
WHERE p.equipment_id = '<equipment-id>'
ORDER BY p.timestamp DESC;
-- Verify: 5 photos with folder_name, 1 photo with null folder_name
```

---

### Scenario 5: Delete Folder (Keep Photos)

**Objective**: Verify folder deletion with photo orphaning (FR-010, FR-010a, FR-010b)

**Prerequisites**: Scenario 4 completed (folder with 5 photos + 1 standalone)

**Steps**:
1. Equipment screen → Folders tab
2. Long-press on `WO-789 - 2025-10-09` folder
3. Tap "Delete" option in context menu
4. Dialog appears with two options:
   - "Delete all photos in folder"
   - "Keep photos as standalone"
5. Select "Keep photos as standalone"
6. Confirm

**Expected Results**:
- ✅ Folder removed from Folders tab list
- ✅ All Photos tab still shows 6 photos (5 former folder photos + 1 standalone)
- ✅ Former folder photos NO LONGER have folder badge
- ✅ All 6 photos retain original timestamps (chronological order unchanged)

**Dialog Validation**:
- Dialog title: "Delete Folder?"
- Clear description: "Choose what happens to the 5 photos in this folder:"
- Button labels: Plain language (not "OK/Cancel")

**Validation Queries**:
```sql
SELECT COUNT(*) FROM photo_folders WHERE id = '<folder-id>';
-- Verify: 0 (or is_deleted = 1 if using soft delete)

SELECT COUNT(*) FROM folder_photos WHERE folder_id = '<folder-id>';
-- Verify: 0 (junction table entries removed)

SELECT COUNT(*) FROM photos WHERE equipment_id = '<equipment-id>';
-- Verify: 6 (photos still exist)
```

---

### Scenario 6: Delete Folder (Delete Photos)

**Objective**: Verify folder deletion with photo cascade (FR-010c)

**Prerequisites**: Create new folder with 2 photos

**Steps**:
1. Folders tab → Create folder `TEST-DELETE`
2. Open folder → Before tab → Capture 2 photos
3. Return to Folders tab
4. Long-press `TEST-DELETE - 2025-10-09` folder
5. Tap "Delete"
6. Select "Delete all photos in folder"
7. Confirm

**Expected Results**:
- ✅ Folder removed from list
- ✅ All Photos tab photo count reduced by 2
- ✅ Before photos NO LONGER appear anywhere in app
- ✅ Photo files deleted from device storage (verify via file manager)

**Data Integrity Check**:
- Photos table: Entries removed
- folder_photos table: Junction entries removed
- photo_folders table: Folder entry removed (or soft deleted)

**Validation Queries**:
```sql
SELECT COUNT(*) FROM photos WHERE id IN ('<photo-id-1>', '<photo-id-2>');
-- Verify: 0 (photos deleted)

SELECT COUNT(*) FROM folder_photos WHERE folder_id = '<folder-id>';
-- Verify: 0 (junction entries removed)
```

---

### Scenario 7: Delete Individual Photo from Folder

**Objective**: Verify individual photo deletion from Before/After tab (FR-021, FR-021a, FR-021c)

**Prerequisites**: Folder with 3 before photos and 2 after photos

**Steps**:
1. Folders tab → Open folder
2. Before tab (3 photos) → Long-press middle photo
3. Tap "Delete" option
4. Confirmation dialog appears: "Delete this photo?"
5. Confirm deletion
6. Switch to After tab
7. Long-press one photo → Delete → Confirm

**Expected Results**:
- ✅ Before tab now shows 2 photos
- ✅ After tab now shows 1 photo
- ✅ Deleted photos removed from All Photos tab
- ✅ Folder still appears in Folders tab
- ✅ Folder badge count updates: "Before (2)" / "After (1)"

**Edge Case**: Delete last photo in Before tab
- Before tab shows empty state: "No before photos yet"
- After tab still functional
- Folder remains in list (empty folders allowed)

**Validation Queries**:
```sql
SELECT before_after, COUNT(*) as count
FROM folder_photos
WHERE folder_id = '<folder-id>'
GROUP BY before_after;
-- Verify: before = 2, after = 1
```

---

### Scenario 8: Tab State Persistence

**Objective**: Verify tab switching preserves state without reload (FR-002, Performance Article VI)

**Prerequisites**: Folder with photos, All Photos tab has photos

**Steps**:
1. Equipment screen → All Photos tab
2. Scroll down to photo #10 (or last photo)
3. Tap Folders tab
4. Scroll down folders list
5. Tap All Photos tab again

**Expected Results**:
- ✅ All Photos tab scroll position maintained (still at photo #10)
- ✅ No loading spinner or flash
- ✅ Tab switch completes in < 300ms (visual smoothness)

**Performance Measurement**:
- Use Flutter DevTools timeline to measure tab switch duration
- Target: < 300ms from tap to fully rendered content

---

### Scenario 9: Empty States

**Objective**: Verify empty state messages guide user actions (FR-023, FR-024, FR-025)

**Prerequisites**: Equipment with no photos, no folders

**Steps**:
1. Navigate to Equipment screen
2. Verify All Photos tab shows:
   - Icon: Camera icon
   - Text: "No Photos Yet"
   - Subtext: "Tap the camera button to capture photos"
3. Tap Folders tab
4. Verify empty state shows:
   - Icon: Folder icon
   - Text: "No Folders Yet"
   - Subtext: "Tap 'Create Folder' to organize photos"
5. Create folder, open it
6. Verify Before tab empty state:
   - Text: "No before photos"
   - Action: "Tap camera to capture"
7. Verify After tab empty state:
   - Text: "No after photos"
   - Action: "Tap camera to capture"

**Expected Results**:
- ✅ All empty states use clear, actionable language
- ✅ Icons visually indicate what's missing
- ✅ Subtexts explain next steps
- ✅ No technical jargon or error codes

---

### Scenario 10: Offline Operation

**Objective**: Verify all folder operations work without network (Article II: Offline Autonomy)

**Prerequisites**: Device in airplane mode or network disabled

**Steps**:
1. Enable airplane mode
2. Execute Scenarios 1-7 (create folder, capture photos, delete folder, etc.)
3. Verify all operations complete successfully
4. Re-enable network
5. Verify sync queue contains folder operations

**Expected Results**:
- ✅ All folder operations execute immediately (no network errors)
- ✅ Photos captured and stored locally
- ✅ UI remains responsive (no spinners waiting for network)
- ✅ Sync indicator shows pending changes
- ✅ When online, changes sync to server (verify in server logs)

**Sync Queue Validation**:
```sql
SELECT * FROM sync_queue WHERE entity_type IN ('folder', 'folder_photo');
-- Verify: Pending items exist, status = 'pending'
```

---

## Performance Benchmarks

**Target Metrics** (Article VI: Performance Primacy):

| Operation | Target | Measurement Method |
|-----------|--------|-------------------|
| Tab switching | < 300ms | Flutter DevTools timeline |
| Folder creation | < 500ms | Stopwatch (tap Create → folder appears) |
| Photo grid render (100 photos) | < 1s | DevTools timeline (initial load) |
| Folder list query | < 10ms | Database profiling |
| All Photos JOIN query | < 15ms | Database profiling |

**How to Measure**:
1. Enable Flutter DevTools performance overlay: `flutter run --profile`
2. Record timeline during scenario execution
3. Look for frame drops (> 16ms frame time indicates jank)
4. SQL query timing: Add logging to `database_service.dart`

---

## Validation Checklist

After completing all scenarios, verify:

- [ ] All 25 functional requirements (FR-001 to FR-025) manually tested
- [ ] Constitution Article I-IX principles upheld (field-first, offline, data integrity, etc.)
- [ ] All edge cases handled gracefully (empty states, errors, permissions)
- [ ] Performance targets met (< 300ms tab switch, etc.)
- [ ] Database integrity maintained (foreign keys, cascades, constraints)
- [ ] No data loss occurred in any scenario
- [ ] UI follows Material Design patterns (common iOS/Android conventions)
- [ ] Accessibility: VoiceOver/TalkBack can navigate folder screens

---

## Known Limitations (Deferred Features)

- Folder renaming: Not implemented (FR-009 deferred)
- Photo reordering within Before/After tabs: Default chronological only
- Folder limits: No enforcement yet (edge case deferred)
- Bulk photo operations: Delete/move multiple photos at once
- Folder search/filter: Future enhancement
- Export folder as ZIP: Future enhancement

---

## Troubleshooting

**Issue**: Folder not appearing after creation
- **Check**: Database migration ran successfully (inspect photo_folders table)
- **Check**: App state updated (try hot reload or restart app)

**Issue**: Photos appear in both Before and After tabs
- **Check**: Database constraint violated (should be prevented by schema)
- **Action**: Run validation query to find duplicate junction entries

**Issue**: Tab switching causes reload flash
- **Check**: `AutomaticKeepAliveClientMixin` implemented on tab widgets
- **Check**: `super.build(context)` called in build method

**Issue**: Folder badge not visible on All Photos tab
- **Check**: LEFT JOIN query returning folder_id correctly
- **Check**: Badge widget rendered in photo tile Stack

---

**Status**: Quickstart scenarios defined and ready for manual testing after implementation.
