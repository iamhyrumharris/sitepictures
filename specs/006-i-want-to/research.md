# Research: Camera Photo Save Functionality

**Feature**: 006-i-want-to | **Date**: 2025-10-13
**Purpose**: Research technical decisions and best practices for camera save implementation

## Technical Decisions

### Decision 1: Global "Needs Assigned" as Special Client Record

**Context**: Need to implement a global "Needs Assigned" folder that is not associated with any specific client, while maintaining consistency with existing client-site-equipment hierarchy.

**Decision**: Create a special client record with id="GLOBAL_NEEDS_ASSIGNED" and a system flag in the clients table.

**Rationale**:
- Reuses existing client-folder relationships and database schema (Clarification 1)
- Minimizes schema changes - only requires adding `is_system BOOLEAN` column to clients table
- Existing folder service, photo associations, and UI components work without modification
- Maintains hierarchical consistency (Constitution Article IV)
- Simplifies querying: "Needs Assigned" folders are just folders with specific client_id
- Natural isolation from user-created clients via system flag

**Alternatives Considered**:
- **New top-level table**: Would require parallel photo association logic, duplicate UI components, and complex migration
- **Orphaned photos table**: Breaks hierarchical consistency, requires special-case handling throughout codebase
- **No global folder**: Forces users to select client before Quick Save, adds friction (violates Constitution Article I: Field-First Architecture)

**Implementation Notes**:
- Database migration: Add `is_system INTEGER DEFAULT 0` to clients table
- Seed global client on database creation: `INSERT INTO clients (id, name, is_system, ...) VALUES ('GLOBAL_NEEDS_ASSIGNED', 'Needs Assigned', 1, ...)`
- Filter out system clients from user-facing client lists: `WHERE is_system = 0`
- Special case handling in client creation UI: prevent deletion/editing of system clients

---

### Decision 2: Incremental Save with Selective Rollback

**Context**: Need to save up to 20 photos reliably in field environments with potential storage/connectivity issues, while ensuring no data loss.

**Decision**: Implement incremental save (one-by-one) with rollback only on critical failures (Clarification 2).

**Rationale**:
- **Field resilience**: Maximizes data capture in intermittent connectivity/storage scenarios
- **Partial success handling**: If 7 of 10 photos save successfully, user keeps 7 and can retry remaining 3
- **Clear user feedback**: Shows progress during save, partial completion messages (FR-055b: "9 of 10 photos saved")
- **Critical error protection**: Database connection loss triggers rollback of current operation, preserves entire session (FR-055c)
- **Aligns with Constitution Article III**: Data Integrity - no successful saves lost, session preserved on failure

**Alternatives Considered**:
- **Atomic transaction**: All-or-nothing approach loses successfully saved photos on any failure, poor user experience in field
- **Best-effort with no rollback**: Critical errors (DB connection lost) could leave database in inconsistent state
- **Atomic with auto-retry**: Adds complexity, may retry indefinitely in persistent error conditions

**Implementation Pattern** (Dart/Flutter):
```dart
class PhotoSaveService {
  Future<SaveResult> savePhotosIncrementally({
    required List<TempPhoto> photos,
    required SaveContext context,
  }) async {
    final savedPhotos = <String>[];
    final failedPhotos = <String>[];

    try {
      for (final photo in photos) {
        try {
          // Save individual photo
          await _savePhotoTransaction(photo, context);
          savedPhotos.add(photo.id);
        } on NonCriticalError catch (e) {
          // File corruption, individual photo issue
          failedPhotos.add(photo.id);
          await _logger.logError(e, photo.id);
          continue; // Keep going
        }
      }

      return SaveResult.partial(
        successful: savedPhotos.length,
        failed: failedPhotos.length,
        savedIds: savedPhotos,
      );

    } on CriticalError catch (e) {
      // DB connection lost, folder deleted
      await _rollbackPhotos(savedPhotos);
      return SaveResult.criticalFailure(
        error: e,
        sessionPreserved: true,
      );
    }
  }
}
```

**Critical vs Non-Critical Errors**:
- **Critical** (trigger rollback): Database connection lost, target folder/equipment deleted, storage corruption
- **Non-Critical** (continue): Single photo file corruption, thumbnail generation failure, metadata write failure

---

### Decision 3: Sequential Numbering for Same-Date Disambiguation

**Context**: Multiple Quick Save operations on same date need unique, user-friendly names.

**Decision**: Use sequential numbering starting from (2): "Folder - 2025-10-13", "Folder - 2025-10-13 (2)", "Folder - 2025-10-13 (3)" (Clarification 5).

**Rationale**:
- **Simplicity**: Easy to understand and implement
- **No timezone complexity**: Avoids time format ambiguity (12hr vs 24hr, timezones)
- **Clear ordering**: Sequential numbers provide obvious chronological order
- **Low collision probability**: Rare for users to create >10 Quick Saves per day
- **Consistent with OS patterns**: Windows/Mac use similar "(2)", "(3)" suffixes for file naming

**Alternatives Considered**:
- **Timestamp suffix**: "Folder - 2025-10-13 14:23:15" - too verbose, timezone confusion
- **Short time**: "Folder - 2025-10-13 2:23pm" - 12hr format ambiguity, still verbose
- **No disambiguation**: Overwrite or merge - violates data integrity principle

**Implementation Pattern** (Dart):
```dart
class SequentialNamer {
  Future<String> getUniqueName({
    required String baseName,
    required String clientId,
  }) async {
    // baseName = "Folder - 2025-10-13"
    final existing = await _db.getFoldersByNamePrefix(
      clientId: clientId,
      prefix: baseName,
    );

    if (existing.isEmpty) return baseName;

    // Find highest number: "Folder - 2025-10-13 (5)" -> 5
    int maxNum = 1;
    final pattern = RegExp(r'\((\d+)\)$');
    for (final folder in existing) {
      final match = pattern.firstMatch(folder.name);
      if (match != null) {
        final num = int.parse(match.group(1)!);
        if (num > maxNum) maxNum = num;
      }
    }

    return '$baseName (${maxNum + 1})';
  }
}
```

---

### Decision 4: Equipment Navigator as Modal Bottom Sheet

**Context**: "Next" button from home camera needs equipment selection without losing camera context.

**Decision**: Implement equipment navigator as full-screen modal with hierarchical list navigation.

**Rationale**:
- **Context preservation**: Modal keeps camera session alive in background
- **Familiar pattern**: Reuses existing hierarchical navigation UI (Dependency 4)
- **Performance**: Lazy-loads equipment lists per navigation level (doesn't load entire tree upfront)
- **Back button handling**: Native back button dismisses modal and returns to camera (FR-019)
- **Aligns with Constitution Article VII**: Intuitive Simplicity - standard mobile navigation pattern

**UI Flow**:
1. User taps "Next" in home camera modal
2. Full-screen modal slides up showing clients list
3. User taps client → shows that client's main sites and subsites
4. User taps site → shows equipment at that site
5. User taps equipment → modal dismisses, save executes, returns to home

**Implementation Pattern** (Flutter):
```dart
Future<Equipment?> showEquipmentNavigator(BuildContext context) {
  return Navigator.of(context).push<Equipment>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (context) => EquipmentNavigatorPage(),
    ),
  );
}

// In camera page
final equipment = await showEquipmentNavigator(context);
if (equipment != null) {
  await _photoSaveService.saveToEquipment(
    photos: provider.session.photos,
    equipment: equipment,
  );
}
```

**Alternatives Considered**:
- **Bottom sheet**: Limited screen space for deep hierarchies (3-4 levels)
- **New screen with camera dismissal**: Loses camera context, poor UX if user cancels
- **Inline expansion**: Clutters modal UI, confusing navigation

---

### Decision 5: Visual Distinction via IconData + Label

**Context**: Per-client "Needs Assigned" folders must be visually distinguished from regular main sites.

**Decision**: Use unique IconData (inbox/tray icon) + always display "Needs Assigned" label (Clarification 4).

**Rationale**:
- **Dual recognition**: Icon for quick visual scanning, label for explicit confirmation
- **Accessibility**: Works for color-blind users, high contrast, screen readers
- **Consistency**: Same pattern for global and per-client "Needs Assigned" folders
- **One-handed operation**: Icon provides larger touch target than text-only badge
- **Aligns with Constitution Article VII**: Intuitive Simplicity - no training required

**Implementation** (Flutter):
```dart
class NeedsAssignedBadge extends StatelessWidget {
  final bool isGlobal;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.inbox, // or Icons.move_to_inbox
          color: Theme.of(context).colorScheme.secondary,
          size: 24,
        ),
        SizedBox(width: 8),
        Text(
          'Needs Assigned',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
      ],
    );
  }
}
```

**Alternatives Considered**:
- **Icon only**: Users must learn icon meaning, not immediately clear
- **Badge indicator**: Small text/color badges hard to see in bright sunlight (field environment)
- **Background color**: Accessibility issues, may conflict with theme colors

---

## Best Practices

### Flutter State Management with Provider

**Pattern**: Use ChangeNotifier providers for save workflow state, Service classes for business logic.

**Rationale**:
- Existing codebase uses Provider pattern (Technical Context)
- Separation of concerns: UI state (provider) vs business logic (service)
- Testability: Services can be unit tested without widget tree

**Example Structure**:
```dart
// Service: Pure business logic
class QuickSaveService {
  Future<SaveResult> quickSave(List<TempPhoto> photos) async {
    // Logic here
  }
}

// Provider: UI state + service coordination
class PhotoCaptureProvider extends ChangeNotifier {
  final QuickSaveService _quickSaveService;
  SaveState _saveState = SaveState.idle;

  Future<void> executeQuickSave() async {
    _saveState = SaveState.saving;
    notifyListeners();

    final result = await _quickSaveService.quickSave(session.photos);

    _saveState = result.success ? SaveState.success : SaveState.error;
    notifyListeners();
  }
}
```

### SQLite Transaction Patterns for Dart

**Pattern**: Use sqflite's transaction API for multi-statement operations with rollback support.

**Rationale**:
- Built-in rollback on exception (critical error handling)
- ACID guarantees for folder+photo creation
- Prevents partial database state

**Example**:
```dart
Future<void> savePhotoWithFolder({
  required Photo photo,
  required PhotoFolder folder,
  required BeforeAfter category,
}) async {
  await _db.transaction((txn) async {
    // Insert folder if new
    await txn.insert('photo_folders', folder.toMap());

    // Insert photo
    await txn.insert('photos', photo.toMap());

    // Create association
    await txn.insert('folder_photos', {
      'folder_id': folder.id,
      'photo_id': photo.id,
      'before_after': category.toDb(),
      'added_at': DateTime.now().toIso8601String(),
    });
  });
}
```

### Progress Indication for Long-Running Operations

**Pattern**: Use StreamController to emit progress events during incremental save.

**Rationale**:
- Real-time UI updates without blocking
- Aligns with Constitution Article VI (Performance Primacy) - FR-057 requires visual feedback
- User sees progress: "Saving photo 3 of 10..."

**Example**:
```dart
class PhotoSaveService {
  final _progressController = StreamController<SaveProgress>();
  Stream<SaveProgress> get progressStream => _progressController.stream;

  Future<SaveResult> savePhotosIncrementally(...) async {
    for (int i = 0; i < photos.length; i++) {
      _progressController.add(SaveProgress(
        current: i + 1,
        total: photos.length,
        currentPhotoId: photos[i].id,
      ));

      await _savePhotoTransaction(photos[i], context);
    }
  }
}

// In UI
StreamBuilder<SaveProgress>(
  stream: _photoSaveService.progressStream,
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      return Text('Saving ${snapshot.data!.current} of ${snapshot.data!.total}');
    }
    return SizedBox.shrink();
  },
)
```

### Error Logging and Debugging

**Pattern**: Use structured logging with log levels and contextual metadata.

**Rationale**:
- FR-056 requires logging all save operations and errors
- Field debugging: Logs help diagnose issues in environments without live debugging
- Compliance: Audit trail for data operations (Constitution Article IX)

**Example**:
```dart
class Logger {
  void logSaveOperation({
    required String userId,
    required SaveContext context,
    required int photoCount,
    required SaveResult result,
  }) {
    final logEntry = {
      'timestamp': DateTime.now().toIso8601String(),
      'user_id': userId,
      'context': context.toString(),
      'photo_count': photoCount,
      'success': result.success,
      'saved_count': result.successfulCount,
      'failed_count': result.failedCount,
      'error': result.error?.toString(),
    };

    // Write to local log file or database log table
    _writeLog(logEntry, level: result.success ? LogLevel.info : LogLevel.error);
  }
}
```

---

## Dependencies Research

### sqflite (SQLite for Flutter)

**Version**: 2.3.0+ (existing dependency)
**Purpose**: Database operations for photo/folder metadata and associations

**Key Features**:
- Transaction support with automatic rollback
- Batch operations for performance
- Migration management
- Works offline (local database file)

**Relevant APIs**:
- `db.transaction()` - ACID operations for photo+folder creation
- `db.batch()` - Bulk insert for multiple photos
- `db.query()` with JOINs - Fetch photos with folder info

### provider (State Management)

**Version**: 6.0.0+ (existing dependency)
**Purpose**: UI state management for save workflows

**Key Features**:
- ChangeNotifier for reactive updates
- Dependency injection
- Testing support

**Relevant Pattern**:
- `ChangeNotifierProvider` for PhotoCaptureProvider
- `Consumer` widgets for save progress UI

### uuid (Unique Identifiers)

**Version**: 3.0.0+ (existing dependency)
**Purpose**: Generate unique IDs for photos and folders

**Usage**: `const Uuid().v4()` for new entities

### intl (Internationalization)

**Version**: 0.18.0+ (existing dependency)
**Purpose**: Date formatting for Quick Save naming

**Usage**: `DateFormat('yyyy-MM-dd').format(DateTime.now())` for "Folder - 2025-10-13" format

---

## Integration Patterns

### Extending Existing Camera Capture Provider

**Context**: PhotoCaptureProvider (feature 003/005) handles camera session, needs save capabilities added.

**Pattern**: Add save methods to existing provider without breaking current functionality.

**Implementation**:
```dart
class PhotoCaptureProvider extends ChangeNotifier {
  // Existing fields
  PhotoSession session;
  CameraContext? cameraContext;

  // NEW: Inject save services via constructor
  final QuickSaveService _quickSaveService;
  final PhotoSaveService _photoSaveService;

  // NEW: Save method for home context
  Future<SaveResult> executeQuickSave() async {
    return await _quickSaveService.quickSave(session.photos);
  }

  // NEW: Save method for equipment context
  Future<SaveResult> saveToEquipment(Equipment equipment) async {
    return await _photoSaveService.saveToEquipment(
      photos: session.photos,
      equipment: equipment,
    );
  }

  // Existing methods remain unchanged
  Future<void> capturePhoto() async { /* ... */ }
  void deletePhoto(String id) { /* ... */ }
}
```

### Database Schema Extension

**Context**: Need to add system flag to clients table for global "Needs Assigned".

**Migration Pattern** (SQLite):
```dart
Future<void> _migration004(Database db) async {
  // Migration 004: Global "Needs Assigned" Support
  // Feature: 006-i-want-to
  // Date: 2025-10-13

  // Add system flag to clients table
  await db.execute('ALTER TABLE clients ADD COLUMN is_system INTEGER DEFAULT 0');

  // Create global "Needs Assigned" client
  await db.insert('clients', {
    'id': 'GLOBAL_NEEDS_ASSIGNED',
    'name': 'Needs Assigned',
    'description': 'Global holding area for unorganized photos',
    'is_system': 1,
    'created_by': 'SYSTEM',
    'created_at': DateTime.now().toIso8601String(),
    'updated_at': DateTime.now().toIso8601String(),
    'is_active': 1,
  });

  // Index for filtering out system clients
  await db.execute(
    'CREATE INDEX idx_clients_system ON clients(is_system, is_active)',
  );
}
```

---

## Performance Considerations

### Thumbnail Generation Strategy

**Context**: FR-048 requires thumbnail generation during save; 20 photos need thumbnails generated.

**Strategy**: Generate thumbnails asynchronously after photo save completes, don't block save operation.

**Rationale**:
- Save time priority: Primary photo save should complete quickly
- Background processing: Thumbnails can be generated during idle time
- Graceful degradation: If thumbnail fails, photo is still saved and viewable

**Implementation**:
```dart
Future<void> savePhotoWithBackgroundThumbnail(Photo photo) async {
  // Save photo immediately
  await _db.insert('photos', photo.toMap());

  // Queue thumbnail generation (non-blocking)
  _thumbnailQueue.add(photo.id);
  _processThumbnailQueue(); // Fire and forget
}

Future<void> _processThumbnailQueue() async {
  while (_thumbnailQueue.isNotEmpty) {
    final photoId = _thumbnailQueue.removeFirst();
    try {
      final thumbnail = await _generateThumbnail(photoId);
      await _db.update('photos',
        {'thumbnail_path': thumbnail},
        where: 'id = ?',
        whereArgs: [photoId],
      );
    } catch (e) {
      // Log but don't fail
      _logger.logWarning('Thumbnail generation failed for $photoId');
    }
  }
}
```

### Batch Insert Optimization

**Context**: Saving 20 photos requires 20 database inserts + associations.

**Strategy**: Use sqflite batch operations for multiple inserts in single transaction.

**Performance Gain**: ~10x faster than individual inserts for large batches.

**Implementation**:
```dart
Future<void> batchSavePhotos(List<Photo> photos, String folderId) async {
  await _db.transaction((txn) async {
    final batch = txn.batch();

    for (final photo in photos) {
      batch.insert('photos', photo.toMap());
      batch.insert('folder_photos', {
        'folder_id': folderId,
        'photo_id': photo.id,
        'before_after': 'before',
        'added_at': DateTime.now().toIso8601String(),
      });
    }

    await batch.commit(noResult: true); // Faster when results not needed
  });
}
```

---

## Testing Strategy

### Unit Tests (Services)

**Coverage**: QuickSaveService, PhotoSaveService, SequentialNamer

**Key Test Cases**:
- Single photo Quick Save creates correct name format
- Multi-photo Quick Save creates folder with correct name
- Sequential numbering handles existing folders correctly
- Incremental save continues after non-critical error
- Critical error triggers rollback of partial saves

**Example**:
```dart
test('QuickSaveService creates folder with sequential number on collision', () async {
  // Arrange
  await _createExistingFolder('Folder - 2025-10-13');
  await _createExistingFolder('Folder - 2025-10-13 (2)');

  // Act
  final result = await quickSaveService.quickSave(photos);

  // Assert
  expect(result.folderName, equals('Folder - 2025-10-13 (3)'));
});
```

### Widget Tests (UI Components)

**Coverage**: EquipmentNavigatorTree, SaveProgressIndicator, NeedsAssignedBadge

**Key Test Cases**:
- Equipment navigator displays hierarchical tree correctly
- Progress indicator updates during incremental save
- "Needs Assigned" badge renders with correct icon + label

### Integration Tests (End-to-End Workflows)

**Coverage**: Home Quick Save, Equipment Direct Save, Folder Before/After Save

**Key Test Cases**:
- Complete Quick Save workflow (capture → Done → Quick Save → verify in global Needs Assigned)
- Equipment save workflow (navigate to equipment → capture → Done → verify in All Photos)
- Partial save recovery (simulate error on photo #7 of 10, verify 9 photos saved)

**Example**:
```dart
testWidgets('Home Quick Save workflow end-to-end', (tester) async {
  // Pump app
  await tester.pumpWidget(MyApp());

  // Tap camera FAB on home page
  await tester.tap(find.byIcon(Icons.camera_alt));
  await tester.pumpAndSettle();

  // Capture 3 photos
  await tester.tap(find.byType(CaptureButton));
  await tester.pump(Duration(milliseconds: 500));
  await tester.tap(find.byType(CaptureButton));
  await tester.pump(Duration(milliseconds: 500));
  await tester.tap(find.byType(CaptureButton));
  await tester.pumpAndSettle();

  // Tap Done
  await tester.tap(find.text('Done'));
  await tester.pumpAndSettle();

  // Tap Quick Save
  await tester.tap(find.text('Quick Save'));
  await tester.pumpAndSettle();

  // Verify confirmation message
  expect(find.text('Saved to Needs Assigned'), findsOneWidget);

  // Navigate to global Needs Assigned and verify folder exists
  // ... navigation code ...

  final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
  expect(find.text('Folder - $today'), findsOneWidget);
});
```

---

## Risk Mitigation

### Risk 1: Equipment Navigator Performance with Large Hierarchies

**Risk**: Rendering 1000+ equipment items in navigator may cause UI lag.

**Mitigation**:
- Lazy loading: Only load children when parent node expanded
- Pagination: Show 50 equipment items per page with "Load More"
- Search/filter: Add search box for quick equipment lookup

**Monitoring**: Log navigation tree depth and item counts in production to detect performance issues.

### Risk 2: Storage Space Exhaustion During Save

**Risk**: Device runs out of storage mid-save, leaving partial data.

**Mitigation**:
- FR-050: Validate storage availability before save (check free space >= estimated photo size * 1.5)
- FR-052: Display "Insufficient storage" error, preserve session for retry
- Critical error handling: Rollback on storage write failure

**User Guidance**: Show storage warning if <100MB available before camera launch.

### Risk 3: Database Corruption from Improper Shutdown

**Risk**: App force-closed during save transaction could corrupt SQLite database.

**Mitigation**:
- SQLite WAL mode: Write-Ahead Logging provides atomic commits
- Transaction boundaries: All multi-statement operations use transactions
- Database integrity check: Run `PRAGMA integrity_check` on app startup

**Recovery**: If corruption detected, restore from last known good backup (Constitution Article III: Data Integrity).

---

## Conclusion

All technical decisions researched and documented. Key patterns:
1. Special client record for global "Needs Assigned" (reuse existing schema)
2. Incremental save with selective rollback (field resilience)
3. Sequential numbering for disambiguation (simplicity)
4. Modal navigator for equipment selection (context preservation)
5. Icon + label for visual distinction (accessibility)

Ready to proceed to Phase 1: Data Model and Contracts generation.
