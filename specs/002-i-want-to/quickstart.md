# Quickstart Guide

**Feature**: UI/UX Design for Site Pictures Application
**Purpose**: Validate the implementation meets all user stories

## Prerequisites

1. Flutter SDK 3.24+ installed
2. iOS Simulator or Android Emulator configured
3. VS Code or Android Studio with Flutter extensions
4. Test data seeded (see setup below)

## Setup

```bash
# Clone repository
git clone <repository-url>
cd sitepictures

# Install dependencies
flutter pub get

# Run database migrations
flutter run lib/scripts/setup_database.dart

# Seed test data
flutter run lib/scripts/seed_test_data.dart

# Launch app
flutter run
```

## Test Scenarios

### Scenario 1: Empty State (New Installation)
**Validates**: FR-001, Edge Case #1

1. Clear all app data
2. Launch the app fresh
3. **Expected**: Home screen shows "Add Your First Client" message
4. Tap "Add New Client" button
5. Enter client name "ACME Industrial"
6. **Expected**: Client created and appears in list

✅ Success: Empty state handled gracefully

### Scenario 2: Navigation Hierarchy
**Validates**: FR-004, FR-005, FR-006

1. From home screen, tap "ACME Industrial" client
2. **Expected**: Main sites list appears
3. Tap "Factory North" main site
4. **Expected**: See both "Assembly Line" subsite and "Generator A" equipment
5. Tap "Assembly Line" subsite
6. **Expected**: Only see equipment items, no further subsites
7. Navigate back using breadcrumb

✅ Success: Hierarchical navigation working

### Scenario 3: Breadcrumb Navigation
**Validates**: FR-014, FR-015, FR-016, FR-017

1. Navigate to: Client > Main Site > SubSite > Equipment
2. **Expected**: Breadcrumb shows full path
3. Create a long path that exceeds screen width
4. **Expected**: Breadcrumb scrolls horizontally
5. Tap "Main Site" in breadcrumb
6. **Expected**: Jump directly to Main Site screen
7. Navigate deeper
8. **Expected**: Breadcrumb updates dynamically

✅ Success: Breadcrumb navigation functional

### Scenario 4: Photo Capture & Carousel
**Validates**: FR-007, FR-008, FR-009, FR-010, FR-019

1. Navigate to any equipment
2. Tap floating camera button
3. **Expected**: Camera opens
4. Take 3 photos
5. **Expected**: Photos appear in carousel view
6. Swipe left/right
7. **Expected**: Navigate between photos
8. Tap "Quick Save" on second photo
9. **Expected**: Photo saved to equipment
10. Tap "Next" button
11. **Expected**: Advance to next photo

✅ Success: Camera and carousel working

### Scenario 5: Offline Photo Capture
**Validates**: FR-010a, FR-010b, Edge Case #2

1. Enable airplane mode
2. Navigate to equipment
3. Take 2 photos
4. **Expected**: Photos saved locally with GPS and timestamp
5. Check sync queue indicator
6. **Expected**: Shows "2 items pending sync"
7. Disable airplane mode
8. **Expected**: Automatic sync begins
9. Check sync status
10. **Expected**: Photos uploaded successfully

✅ Success: Offline mode functional

### Scenario 6: Recent Locations
**Validates**: FR-001, User Story #1

1. Visit 5 different locations in hierarchy
2. Return to home screen
3. **Expected**: "Recent" section shows last 5 locations as cards
4. Tap a recent location card
5. **Expected**: Navigate directly to that location
6. Visit 6 more locations
7. **Expected**: Only last 10 locations shown

✅ Success: Recent locations tracking

### Scenario 7: Role-Based Access
**Validates**: FR-018, User Roles

Test as Admin:
1. Login as admin@test.com
2. **Expected**: Can create, edit, delete all entities
3. **Expected**: Can manage user accounts

Test as Technician:
1. Login as tech@test.com
2. **Expected**: Can create sites and equipment
3. **Expected**: Can capture photos
4. **Expected**: Cannot delete clients or manage users

Test as Viewer:
1. Login as viewer@test.com
2. **Expected**: Can view all data
3. **Expected**: Cannot create or edit anything
4. **Expected**: Add buttons hidden

✅ Success: Role-based access enforced

### Scenario 8: Search Functionality
**Validates**: FR-012

1. Tap search icon in header
2. Type "Generator"
3. **Expected**: Results show all equipment matching "Generator"
4. Select a result
5. **Expected**: Navigate to that equipment
6. Clear search
7. Type client name
8. **Expected**: Client appears in results

✅ Success: Search functionality working

### Scenario 9: UI Consistency
**Validates**: FR-011, FR-012, FR-013

1. Navigate through all screens
2. **Expected**: Blue header (#4A90E2) on every screen
3. **Expected**: "Ziatech" app name always visible
4. **Expected**: Bottom navigation always accessible
5. Check Home, Map, Settings tabs
6. **Expected**: All tabs functional

✅ Success: UI consistency maintained

### Scenario 10: Performance Validation
**Validates**: Constitutional Performance Requirements

1. Launch app and time to home screen
2. **Expected**: < 2 seconds
3. Navigate between screens
4. **Expected**: < 500ms transition
5. Take photo from button tap to save
6. **Expected**: < 2 seconds
7. Search for equipment
8. **Expected**: < 1 second for results
9. Use app actively for 1 hour
10. **Expected**: < 5% battery drain

✅ Success: Performance within limits

## Automated Test Commands

```bash
# Run unit tests
flutter test

# Run widget tests
flutter test test/widget/

# Run integration tests
flutter test integration_test/

# Run specific scenario
flutter test integration_test/navigation_flow_test.dart

# Generate coverage report
flutter test --coverage
```

## Validation Checklist

- [ ] All 10 scenarios pass
- [ ] No crashes or errors in console
- [ ] Offline mode works reliably
- [ ] Photos never lost
- [ ] Navigation intuitive without training
- [ ] Performance meets targets
- [ ] Role permissions enforced
- [ ] Data persists between launches

## Known Limitations

1. Maximum 10MB per photo
2. Maximum 10 recent locations shown
3. GPS required for photo capture
4. Internet required for initial login

## Troubleshooting

### Issue: Photos not syncing
- Check internet connection
- Verify sync queue in Settings > Sync Status
- Check for sync errors in logs

### Issue: GPS not available
- Ensure location permissions granted
- Check device GPS is enabled
- May need to wait for GPS lock

### Issue: Cannot see clients
- Verify user role has view permissions
- Check client isActive flag
- Ensure proper authentication

## Support

For issues or questions about this quickstart:
- Check logs at Settings > Debug Logs
- Review implementation against spec.md
- Consult data-model.md for entity details