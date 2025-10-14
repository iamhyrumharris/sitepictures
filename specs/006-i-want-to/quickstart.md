# Quickstart Guide: Camera Photo Save Functionality

**Feature**: 006-i-want-to | **Date**: 2025-10-13
**Audience**: Developers implementing camera save workflows

## Overview

This feature adds save functionality to the existing camera capture system (features 003/005). Three context-aware workflows:
1. **Home Context**: Quick Save to global "Needs Assigned" or Next button for equipment selection
2. **Equipment Context**: Direct save to equipment's All Photos
3. **Folder Context**: Direct save to folder's Before or After section

## Prerequisites

- ✅ Feature 003 (camera capture) implemented
- ✅ Feature 005 (context-aware UI) implemented
- ✅ Feature 004 (folder management) implemented
- ✅ Dart 3.8.1+ and Flutter SDK 3.24+
- ✅ sqflite, provider, camera, uuid, intl dependencies

## Quick Start (5 Minutes)

### Step 1: Run Database Migration

Add migration 004 to `database_service.dart`:

```dart
Future<void> _migration004(Database db) async {
  // Add system flag to clients
  await db.execute('ALTER TABLE clients ADD COLUMN is_system INTEGER DEFAULT 0');

  // Create global "Needs Assigned" client
  await db.insert('clients', {
    'id': 'GLOBAL_NEEDS_ASSIGNED',
    'name': 'Needs Assigned',
    'is_system': 1,
    'created_by': 'SYSTEM',
    'created_at': DateTime.now().toIso8601String(),
    'updated_at': DateTime.now().toIso8601String(),
    'is_active': 1,
  });

  // Index for filtering
  await db.execute('CREATE INDEX idx_clients_system ON clients(is_system, is_active)');
}
```

Update `_onUpgrade` in `database_service.dart`:

```dart
Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
  if (oldVersion < 4) {
    await _migration004(db);
  }
}
```

Change database version from 3 to 4:

```dart
return await openDatabase(
  path,
  version: 4, // Changed from 3
  onCreate: _onCreate,
  onUpgrade: _onUpgrade,
);
```

### Step 2: Create New Models

Create `lib/models/quick_save_item.dart`:

```dart
enum QuickSaveType { singlePhoto, folder }

class QuickSaveItem {
  final QuickSaveType type;
  final String name;
  final List<String> photoIds;
  final String? folderId;
  final DateTime createdAt;

  QuickSaveItem({
    required this.type,
    required this.name,
    required this.photoIds,
    this.folderId,
    required this.createdAt,
  });
}
```

Create `lib/models/save_result.dart`:

```dart
class SaveResult {
  final bool success;
  final int successfulCount;
  final int failedCount;
  final List<String> savedIds;
  final String? error;
  final bool sessionPreserved;

  SaveResult({
    required this.success,
    required this.successfulCount,
    required this.failedCount,
    required this.savedIds,
    this.error,
    required this.sessionPreserved,
  });

  factory SaveResult.complete(List<String> savedIds) {
    return SaveResult(
      success: true,
      successfulCount: savedIds.length,
      failedCount: 0,
      savedIds: savedIds,
      sessionPreserved: false,
    );
  }

  factory SaveResult.partial({
    required int successful,
    required int failed,
    required List<String> savedIds,
  }) {
    return SaveResult(
      success: false,
      successfulCount: successful,
      failedCount: failed,
      savedIds: savedIds,
      sessionPreserved: false,
    );
  }
}
```

### Step 3: Implement Quick Save Service

Create `lib/services/quick_save_service.dart`:

```dart
import 'package:intl/intl.dart';
import '../models/photo_session.dart';
import '../models/save_result.dart';

class QuickSaveService {
  final DatabaseService _db;
  final PhotoStorageService _storage;

  QuickSaveService({
    required DatabaseService databaseService,
    required PhotoStorageService storageService,
  })  : _db = databaseService,
        _storage = storageService;

  Future<SaveResult> quickSave(List<TempPhoto> photos) async {
    // Generate base name with current date
    final now = DateTime.now();
    final dateStr = DateFormat('yyyy-MM-dd').format(now);
    final baseName = photos.length == 1
        ? 'Image - $dateStr'
        : 'Folder - $dateStr';

    // Get unique name with sequential numbering
    final uniqueName = await _generateUniqueName(baseName);

    // Save incrementally
    final savedIds = <String>[];
    for (final photo in photos) {
      try {
        await _savePhotoToGlobal(photo, uniqueName);
        savedIds.add(photo.id);
      } catch (e) {
        // Log error but continue
        print('Failed to save photo ${photo.id}: $e');
      }
    }

    return SaveResult.complete(savedIds);
  }

  Future<String> _generateUniqueName(String baseName) async {
    final existing = await _db.query(
      'photo_folders',
      where: 'name LIKE ?',
      whereArgs: ['$baseName%'],
    );

    if (existing.isEmpty) return baseName;

    // Find max number
    int maxNum = 1;
    final pattern = RegExp(r'\((\d+)\)$');
    for (final row in existing) {
      final name = row['name'] as String;
      final match = pattern.firstMatch(name);
      if (match != null) {
        final num = int.parse(match.group(1)!);
        if (num > maxNum) maxNum = num;
      }
    }

    return '$baseName (${maxNum + 1})';
  }

  Future<void> _savePhotoToGlobal(TempPhoto photo, String folderName) async {
    // Move from temp to permanent storage
    await _storage.moveToP ermanent(photo);

    // Insert into database
    await _db.insert('photos', {
      'id': photo.id,
      'equipment_id': 'GLOBAL_EQUIPMENT', // Placeholder
      'file_path': photo.permanentPath,
      'latitude': photo.latitude,
      'longitude': photo.longitude,
      'timestamp': photo.timestamp.toIso8601String(),
      'captured_by': photo.capturedBy,
      'file_size': photo.fileSize,
      'created_at': DateTime.now().toIso8601String(),
    });
  }
}
```

### Step 4: Wire Up to Camera Page

Update `lib/screens/camera_capture_page.dart`:

```dart
// Add to _CameraCapturePageState
Future<void> _handleQuickSave(BuildContext context) async {
  final provider = Provider.of<PhotoCaptureProvider>(context, listen: false);
  final quickSaveService = QuickSaveService(
    databaseService: DatabaseService(),
    storageService: PhotoStorageService(),
  );

  // Close modal
  Navigator.of(context).pop();

  // Show loading
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => Center(child: CircularProgressIndicator()),
  );

  try {
    final result = await quickSaveService.quickSave(provider.session.photos);

    // Close loading
    Navigator.of(context).pop();

    if (result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Saved to Needs Assigned')),
      );
      provider.completeSession();
      Navigator.of(context).pop(); // Return to home
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${result.successfulCount} photos saved')),
      );
    }
  } catch (e) {
    Navigator.of(context).pop(); // Close loading
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Save failed: $e')),
    );
  }
}
```

### Step 5: Test Quick Save

Run the app and test:

1. ✅ Open camera from home page
2. ✅ Capture 1 photo → Done → Quick Save
3. ✅ Verify saved as "Image - YYYY-MM-DD"
4. ✅ Capture 3 photos → Done → Quick Save
5. ✅ Verify saved as "Folder - YYYY-MM-DD"
6. ✅ Quick Save again same day → verify "(2)" appended

## Implementation Workflows

### Workflow 1: Home Quick Save (Priority 1)

**User Journey**: Home → Camera → Capture → Done → Quick Save → Global "Needs Assigned"

**Implementation Steps**:

1. ✅ Database migration (Step 1 above)
2. ✅ Create QuickSaveService (Step 3 above)
3. ✅ Wire to camera page (Step 4 above)
4. ✅ Create NeedsAssignedPage to view saved items
5. ✅ Add navigation from home to NeedsAssignedPage

**Key Files**:
- `lib/services/quick_save_service.dart` (NEW)
- `lib/screens/needs_assigned_page.dart` (NEW)
- `lib/screens/camera_capture_page.dart` (EXTEND)
- `lib/services/database_service.dart` (EXTEND - migration)

**Testing**:
```bash
flutter test test/integration/home_quick_save_test.dart
```

---

### Workflow 2: Equipment Direct Save (Priority 2)

**User Journey**: Equipment → All Photos Tab → Camera → Capture → Done → Auto-save

**Implementation Steps**:

1. Create PhotoSaveService:

```dart
class PhotoSaveService {
  Future<SaveResult> saveToEquipment({
    required List<TempPhoto> photos,
    required Equipment equipment,
  }) async {
    final savedIds = <String>[];

    for (final photo in photos) {
      try {
        await _db.transaction((txn) async {
          // Move photo to permanent storage
          await _storage.moveToPermanent(photo);

          // Insert photo
          await txn.insert('photos', {
            'id': photo.id,
            'equipment_id': equipment.id,
            'file_path': photo.permanentPath,
            'latitude': photo.latitude,
            'longitude': photo.longitude,
            'timestamp': photo.timestamp.toIso8601String(),
            'captured_by': photo.capturedBy,
            'file_size': photo.fileSize,
            'created_at': DateTime.now().toIso8601String(),
          });
        });

        savedIds.add(photo.id);
      } catch (e) {
        // Log and continue
        print('Failed to save photo ${photo.id}: $e');
      }
    }

    return SaveResult.complete(savedIds);
  }
}
```

2. Update camera_capture_page.dart to handle equipment context:

```dart
Future<void> _handleDone(BuildContext context) async {
  final provider = Provider.of<PhotoCaptureProvider>(context, listen: false);

  // Check context type
  if (provider.cameraContext.type == SaveContextType.equipment) {
    // Direct save - no modal
    await _handleEquipmentSave(context);
  } else {
    // Show modal for home context
    await showModalBottomSheet(...);
  }
}

Future<void> _handleEquipmentSave(BuildContext context) async {
  final provider = Provider.of<PhotoCaptureProvider>(context, listen: false);
  final photoSaveService = PhotoSaveService(...);

  final result = await photoSaveService.saveToEquipment(
    photos: provider.session.photos,
    equipment: provider.cameraContext.equipment!,
  );

  if (result.success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${result.successfulCount} photos saved')),
    );
    provider.completeSession();
    Navigator.of(context).pop(); // Return to equipment page
  }
}
```

3. Update AllPhotosTab to pass equipment context when launching camera:

```dart
FloatingActionButton(
  onPressed: () async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CameraCapturePage(
          cameraContext: SaveContext.equipment(widget.equipmentId),
        ),
      ),
    );
    // Refresh photos list
    _loadPhotos();
  },
  child: Icon(Icons.camera_alt),
)
```

**Testing**:
```bash
flutter test test/integration/equipment_direct_save_test.dart
```

---

### Workflow 3: Folder Before/After Save (Priority 3)

**User Journey**: Equipment → Folder → Before Tab → Camera → Capture → Done → Auto-save to Before

**Implementation Steps**:

1. Extend PhotoSaveService with folder save:

```dart
Future<SaveResult> saveToFolder({
  required List<TempPhoto> photos,
  required PhotoFolder folder,
  required BeforeAfter category,
}) async {
  final savedIds = <String>[];

  for (final photo in photos) {
    try {
      await _db.transaction((txn) async {
        // Move photo to permanent storage
        await _storage.moveToPermanent(photo);

        // Insert photo
        await txn.insert('photos', {
          'id': photo.id,
          'equipment_id': folder.equipmentId,
          'file_path': photo.permanentPath,
          'latitude': photo.latitude,
          'longitude': photo.longitude,
          'timestamp': photo.timestamp.toIso8601String(),
          'captured_by': photo.capturedBy,
          'file_size': photo.fileSize,
          'created_at': DateTime.now().toIso8601String(),
        });

        // Create folder-photo association
        await txn.insert('folder_photos', {
          'folder_id': folder.id,
          'photo_id': photo.id,
          'before_after': category == BeforeAfter.before ? 'before' : 'after',
          'added_at': DateTime.now().toIso8601String(),
        });
      });

      savedIds.add(photo.id);
    } catch (e) {
      print('Failed to save photo ${photo.id}: $e');
    }
  }

  return SaveResult.complete(savedIds);
}
```

2. Update camera page to handle folder context:

```dart
Future<void> _handleDone(BuildContext context) async {
  final provider = Provider.of<PhotoCaptureProvider>(context, listen: false);

  switch (provider.cameraContext.type) {
    case SaveContextType.equipment:
      await _handleEquipmentSave(context);
      break;
    case SaveContextType.folderBefore:
    case SaveContextType.folderAfter:
      await _handleFolderSave(context);
      break;
    default:
      // Home context - show modal
      await showModalBottomSheet(...);
  }
}

Future<void> _handleFolderSave(BuildContext context) async {
  final provider = Provider.of<PhotoCaptureProvider>(context, listen: false);
  final photoSaveService = PhotoSaveService(...);

  final result = await photoSaveService.saveToFolder(
    photos: provider.session.photos,
    folder: provider.cameraContext.folder!,
    category: provider.cameraContext.beforeAfter!,
  );

  if (result.success) {
    final categoryStr = provider.cameraContext.beforeAfter == BeforeAfter.before
        ? 'Before'
        : 'After';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${result.successfulCount} photos saved to $categoryStr')),
    );
    provider.completeSession();
    Navigator.of(context).pop(); // Return to folder detail
  }
}
```

3. Update FolderDetailScreen to pass folder context:

```dart
// In Before tab
FloatingActionButton(
  onPressed: () async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CameraCapturePage(
          cameraContext: SaveContext.folderBefore(
            widget.folder.equipmentId,
            widget.folder.id,
          ),
        ),
      ),
    );
    _loadBeforePhotos();
  },
  child: Icon(Icons.camera_alt),
)

// In After tab
FloatingActionButton(
  onPressed: () async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CameraCapturePage(
          cameraContext: SaveContext.folderAfter(
            widget.folder.equipmentId,
            widget.folder.id,
          ),
        ),
      ),
    );
    _loadAfterPhotos();
  },
  child: Icon(Icons.camera_alt),
)
```

**Testing**:
```bash
flutter test test/integration/folder_before_after_save_test.dart
```

---

### Workflow 4: Equipment Navigator (Next Button)

**User Journey**: Home → Camera → Capture → Done → Next → Navigate hierarchy → Select equipment → Save

**Implementation Steps**:

1. Create EquipmentNavigatorProvider
2. Create EquipmentNavigatorPage with hierarchical tree
3. Wire Next button to open navigator modal
4. On equipment selection, save photos via PhotoSaveService.saveToEquipment

See `contracts/equipment_navigator_provider.dart` for detailed contract.

**Testing**:
```bash
flutter test test/integration/equipment_navigator_test.dart
```

---

## Common Patterns

### Pattern 1: Incremental Save with Progress

```dart
final _progressController = StreamController<SaveProgress>();

Future<SaveResult> saveIncrementally(List<TempPhoto> photos) async {
  for (int i = 0; i < photos.length; i++) {
    _progressController.add(SaveProgress(
      current: i + 1,
      total: photos.length,
      currentPhotoId: photos[i].id,
    ));

    await _savePhoto(photos[i]);
  }

  return SaveResult.complete(photos.map((p) => p.id).toList());
}

// In UI
StreamBuilder<SaveProgress>(
  stream: _photoSaveService.progressStream,
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      return LinearProgressIndicator(
        value: snapshot.data!.percentage / 100,
      );
    }
    return SizedBox.shrink();
  },
)
```

### Pattern 2: Storage Validation Before Save

```dart
Future<bool> _validateStorage(List<TempPhoto> photos) async {
  final totalSize = photos.fold<int>(0, (sum, p) => sum + p.fileSize);
  final requiredSpace = (totalSize * 1.5).toInt() + (100 * 1024 * 1024); // 1.5x + 100MB

  final freeSpace = await _getFreeSpace();
  return freeSpace >= requiredSpace;
}
```

### Pattern 3: Error Recovery with Retry

```dart
Future<SaveResult> saveWithRetry(List<TempPhoto> photos, {int maxRetries = 3}) async {
  for (int attempt = 0; attempt < maxRetries; attempt++) {
    try {
      return await _save(photos);
    } on CriticalError catch (e) {
      if (attempt == maxRetries - 1) rethrow;
      await Future.delayed(Duration(seconds: 2));
    }
  }
  throw StateError('Save failed after $maxRetries attempts');
}
```

---

## Testing Checklist

### Unit Tests
- [ ] QuickSaveService.quickSave (single photo)
- [ ] QuickSaveService.quickSave (multiple photos)
- [ ] Sequential naming with collisions
- [ ] PhotoSaveService.saveToEquipment
- [ ] PhotoSaveService.saveToFolder (before)
- [ ] PhotoSaveService.saveToFolder (after)
- [ ] Storage validation logic

### Widget Tests
- [ ] Save progress indicator
- [ ] Equipment navigator tree
- [ ] Needs Assigned badge

### Integration Tests
- [ ] Home Quick Save end-to-end
- [ ] Equipment direct save end-to-end
- [ ] Folder before/after save end-to-end
- [ ] Partial save recovery (error on photo #7 of 10)
- [ ] Critical error rollback

---

## Troubleshooting

### Issue: "Database version mismatch"
**Solution**: Uninstall app and reinstall to run migrations from scratch.

### Issue: "Photos not appearing in Needs Assigned"
**Solution**: Check that GLOBAL_NEEDS_ASSIGNED client exists in database:
```sql
SELECT * FROM clients WHERE id = 'GLOBAL_NEEDS_ASSIGNED';
```

### Issue: "Sequential numbering not working"
**Solution**: Verify regex pattern matches existing folder names. Check LIKE query in _generateUniqueName.

### Issue: "Save hangs on large photo sets"
**Solution**: Ensure thumbnail generation is async and doesn't block save. Check for deadlocks in database transactions.

---

## Performance Tips

1. **Use batch inserts** for multiple photos (10x faster)
2. **Generate thumbnails asynchronously** (don't block save)
3. **Lazy load equipment navigator** (only load children when expanded)
4. **Index frequently queried columns** (equipment_id, folder_id, is_system)
5. **Use transactions** for multi-statement operations (prevents partial saves)

---

## Next Steps

After completing Phase 1 implementation:

1. Run `/speckit.tasks` to generate detailed task breakdown
2. Implement in priority order: Home Quick Save → Equipment Save → Folder Save → Navigator
3. Test each workflow before moving to next
4. Update CLAUDE.md with new technologies and patterns

---

## Resources

- Spec: `specs/006-i-want-to/spec.md`
- Plan: `specs/006-i-want-to/plan.md`
- Research: `specs/006-i-want-to/research.md`
- Data Model: `specs/006-i-want-to/data-model.md`
- Contracts: `specs/006-i-want-to/contracts/`
- Constitution: `.specify/memory/constitution.md`
