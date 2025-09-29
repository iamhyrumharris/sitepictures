# FieldPhoto Pro Quickstart Guide

## Development Environment Setup

### Prerequisites
- Flutter 3.x SDK
- Dart 3.x
- Android Studio / Xcode for mobile development
- Node.js 18+ for API backend
- PostgreSQL 14+ for team features
- Docker (optional, for self-hosting)

### Initial Setup
```bash
# Clone repository
git clone https://github.com/company/fieldphoto-pro.git
cd fieldphoto-pro

# Install Flutter dependencies
cd app
flutter pub get

# Install API dependencies
cd ../api
npm install

# Setup database
createdb fieldphoto_dev
npm run migrate

# Run tests to verify setup
cd ../app
flutter test
cd ../api
npm test
```

## Core User Stories Validation

### Story 1: Offline Photo Capture (Sarah's Scenario)
**Test Steps**:
1. Launch FieldPhoto Pro app
2. Disable device network connectivity
3. Navigate to "Quick Capture" mode
4. Take photo of industrial equipment
5. Add GPS coordinates (simulated: 42.3601, -71.0589)
6. Add annotation: "Control panel before modification"
7. Verify photo appears in "Needs Assignment" folder
8. Check SQLite database contains photo record
9. Verify file saved to local storage with correct hash

**Expected Results**:
- Photo capture completes in <2 seconds
- No network errors displayed
- Photo visible in local gallery
- GPS coordinates stored in metadata
- Annotation saved with timestamp and device ID

**Test Command**:
```bash
flutter test test/integration_test/offline_capture_test.dart
```

### Story 2: Hierarchical Organization (Mike's Equipment History)
**Test Steps**:
1. Create test hierarchy: "ACME Corp" → "Plant A" → "Control Room" → "PLC Panel 1"
2. Add 5 photos with different timestamps spanning 2 years
3. Create revision folders: "2023-Installation", "2024-Upgrade", "2025-Maintenance"
4. Assign photos to appropriate revisions
5. Navigate to equipment detail view
6. Verify chronological ordering
7. Test timeline visualization

**Expected Results**:
- All photos display in chronological order
- Revision folders show correct photo counts
- Navigation breadcrumbs show: ACME Corp > Plant A > Control Room > PLC Panel 1
- Timeline shows evolution over 2-year period
- Search by equipment name returns all related photos

**Test Command**:
```bash
flutter test test/integration_test/hierarchy_organization_test.dart
```

### Story 3: Sync and Conflict Resolution (Jennifer's Offline Work)
**Test Steps**:
1. Device A: Add 3 photos to "Pump Station 1" while offline
2. Device B: Add 2 photos to same equipment while offline
3. Device A: Add notes to Equipment: "Maintenance required"
4. Device B: Add notes to Equipment: "Inspection complete"
5. Both devices come online simultaneously
6. Trigger sync process
7. Verify conflict resolution (merge both versions)
8. Check all 5 photos visible on both devices
9. Verify both equipment notes preserved

**Expected Results**:
- All photos from both devices successfully synced
- Equipment shows merged notes: "Maintenance required; Inspection complete"
- No data loss during conflict resolution
- Clear attribution showing which device added what
- Sync completes with >99.5% success rate

**Test Command**:
```bash
flutter test test/integration_test/sync_conflict_test.dart
```

### Story 4: GPS Boundary Detection
**Test Steps**:
1. Create GPS boundary for "Factory Site A" (center: 42.3601, -71.0589, radius: 500m)
2. Simulate photo capture at coordinates within boundary (42.3605, -71.0590)
3. Verify automatic assignment to Factory Site A
4. Simulate photo capture outside boundary (42.3650, -71.0600)
5. Verify photo goes to "Needs Assignment"
6. Test overlapping boundaries with priority resolution

**Expected Results**:
- Photos within boundary automatically assigned to correct client/site
- Photos outside boundaries require manual assignment
- Overlapping boundaries resolved by priority order
- GPS accuracy maintained within constitutional requirements (>99%)

**Test Command**:
```bash
flutter test test/integration_test/gps_boundary_test.dart
```

### Story 5: Search Performance (10-Second Retrieval)
**Test Steps**:
1. Create test dataset: 1000 photos across 50 equipment items
2. Add varied annotations and GPS coordinates
3. Test search scenarios:
   - By client name: "ACME"
   - By date range: "2024-01-01 to 2024-12-31"
   - By annotation content: "maintenance"
   - By equipment type: "PLC"
   - By GPS proximity: within 1km of coordinates
4. Measure search response times
5. Verify result accuracy and completeness

**Expected Results**:
- All searches complete in <1 second
- Results show full hierarchical context
- Search indexes perform efficiently with 1000+ records
- Multiple search paths return consistent results

**Test Command**:
```bash
flutter test test/integration_test/search_performance_test.dart
```

## Performance Validation

### Photo Capture Speed Test
```bash
# Test constitutional requirement: <2 seconds from launch to save
flutter test test/performance/photo_capture_speed_test.dart
```
**Target**: <2 seconds from app launch to photo saved with metadata

### Navigation Speed Test
```bash
# Test constitutional requirement: <500ms between screens
flutter test test/performance/navigation_speed_test.dart
```
**Target**: <500ms for all screen transitions

### Battery Usage Test
```bash
# Test constitutional requirement: <5% battery per hour
flutter test test/performance/battery_usage_test.dart
```
**Target**: <5% battery drain during 1 hour of active use

### Storage Management Test
```bash
# Test clarified requirement: Block capture when storage full
flutter test test/integration_test/storage_management_test.dart
```
**Target**: Graceful handling of storage constraints with user prompts

## Constitutional Compliance Verification

### Field-First Architecture Checklist
- [ ] One-handed operation for all critical functions
- [ ] Quick photo capture workflow (<2 seconds)
- [ ] Clear visual hierarchy optimized for mobile
- [ ] Minimal friction workflows tested in field conditions

### Offline Autonomy Checklist
- [ ] All features work without internet connectivity
- [ ] Local SQLite database stores all critical data
- [ ] Sync occurs automatically when connectivity restored
- [ ] No feature degradation in offline mode

### Data Integrity Checklist
- [ ] Photos stored immutably with hash verification
- [ ] All operations use SQLite transactions
- [ ] Comprehensive error logging and recovery
- [ ] Zero data loss during sync conflicts (merge all versions)

### Performance Primacy Checklist
- [ ] Photo capture: <2 seconds (measured)
- [ ] Navigation: <500ms (measured)
- [ ] Search: <1 second (measured)
- [ ] Battery: <5% per hour (measured)
- [ ] Sync: Background processing without UI blocking

### Security & Privacy Checklist
- [ ] Device-based authentication (no user accounts)
- [ ] Local GPS coordinate storage with user consent
- [ ] Company data isolation enforced
- [ ] No telemetry or analytics without opt-in

## API Testing

### Sync API Validation
```bash
cd api
npm run test:integration
```

### Photo Upload Testing
```bash
# Test full-resolution photo upload
curl -X POST http://localhost:3000/v1/photos \
  -H "X-Device-ID: test-device-uuid" \
  -F "file=@test-photo.jpg" \
  -F "metadata={\"equipmentId\":\"test-equipment-id\"}"
```

### Conflict Resolution Testing
```bash
# Simulate concurrent updates
npm run test:conflicts
```

## Production Deployment

### Self-Hosted Docker Setup
```bash
# Build and deploy complete stack
docker-compose up -d

# Verify health checks
curl http://localhost:3000/health
curl http://localhost:5432 # PostgreSQL
```

### Configuration Validation
```bash
# Verify environment variables
npm run config:validate

# Test database migrations
npm run migrate:test

# Validate SSL certificates
npm run ssl:check
```

## Troubleshooting

### Common Issues
1. **Flutter build fails**: Run `flutter clean && flutter pub get`
2. **SQLite permissions**: Check app storage permissions on device
3. **GPS not working**: Verify location permissions granted
4. **Sync failures**: Check network connectivity and API endpoints
5. **Photo quality issues**: Verify camera permissions and storage space

### Debug Mode
```bash
# Enable debug logging
flutter run --debug --verbose

# Check SQLite database state
flutter run --dart-define=DEBUG_DB=true

# Monitor sync operations
flutter run --dart-define=DEBUG_SYNC=true
```

### Performance Monitoring
```bash
# Profile photo capture performance
flutter run --profile test/performance/capture_profile.dart

# Monitor memory usage during large photo operations
flutter run --observatory-port=8080
```

## Success Criteria Verification

The quickstart is successful when:
- [ ] All integration tests pass
- [ ] Performance targets met (<2s capture, <500ms navigation, <1s search)
- [ ] Constitutional compliance verified through automated tests
- [ ] Field worker scenarios execute without friction
- [ ] Offline-first functionality confirmed through network simulation
- [ ] Data integrity maintained through simulated failures
- [ ] Team collaboration works across multiple simulated devices

This quickstart validates that FieldPhoto Pro meets all constitutional principles and user requirements before proceeding to full implementation.