# Data Model: Work Site Photo Capture Page

**Feature**: Camera Capture Page
**Date**: 2025-10-07
**Status**: Complete

## Overview
This document defines the data entities, relationships, validation rules, and state transitions for the photo capture feature. All models support offline-first operation and session preservation per constitutional requirements (Articles II & III).

---

## Entities

### 1. Photo

**Purpose**: Represents a single captured image within a photo session.

**Fields**:
| Field | Type | Required | Description | Validation |
|-------|------|----------|-------------|------------|
| `id` | String (UUID) | Yes | Unique identifier for the photo | Non-empty, valid UUID format |
| `filePath` | String | Yes | Absolute path to photo file in temp storage | Non-empty, file must exist |
| `captureTimestamp` | DateTime | Yes | When the photo was captured | Not null, not in future |
| `displayOrder` | int | Yes | Order in capture sequence (0-indexed) | >= 0, unique within session |
| `thumbnailData` | Uint8List? | No | Cached thumbnail bytes (100x100, JPEG 70%) | Optional for performance optimization |

**Relationships**:
- Belongs to one `PhotoSession` (many-to-one)

**Validation Rules**:
1. `id` must be valid UUID v4 format
2. `filePath` must point to existing file in temp directory
3. `captureTimestamp` cannot be in the future
4. `displayOrder` must be >= 0 and < 20 (session photo limit)
5. If `thumbnailData` is null, generate on first access (lazy loading)

**Serialization** (for session persistence FR-029/FR-030):
```dart
Map<String, dynamic> toJson() => {
  'id': id,
  'filePath': filePath,
  'captureTimestamp': captureTimestamp.toIso8601String(),
  'displayOrder': displayOrder,
  // thumbnailData NOT serialized (regenerate on restore)
};

factory Photo.fromJson(Map<String, dynamic> json) => Photo(
  id: json['id'],
  filePath: json['filePath'],
  captureTimestamp: DateTime.parse(json['captureTimestamp']),
  displayOrder: json['displayOrder'],
  thumbnailData: null, // Regenerate after restore
);
```

**Example**:
```dart
Photo(
  id: '550e8400-e29b-41d4-a716-446655440000',
  filePath: '/tmp/photos/photo_1696723200000.jpg',
  captureTimestamp: DateTime(2025, 10, 7, 14, 30, 0),
  displayOrder: 0,
  thumbnailData: Uint8List(...), // 100x100 JPEG thumbnail
)
```

---

### 2. PhotoSession

**Purpose**: Represents a collection of photos captured in a single camera session from open to completion/cancellation.

**Fields**:
| Field | Type | Required | Description | Validation |
|-------|------|----------|-------------|------------|
| `id` | String (UUID) | Yes | Unique identifier for the session | Non-empty, valid UUID format |
| `photos` | List<Photo> | Yes | Ordered list of captured photos | Length <= maxPhotos |
| `startTime` | DateTime | Yes | When the session was initiated | Not null, not in future |
| `status` | SessionStatus (enum) | Yes | Current session state | One of: inProgress, completed, cancelled |
| `maxPhotos` | int | Yes | Maximum photos allowed (constant) | Always 20 (FR-027) |

**Enums**:
```dart
enum SessionStatus {
  inProgress,  // Active capture session
  completed,   // User pressed Done + selected Next/Quick Save
  cancelled,   // User pressed Cancel and confirmed
}
```

**Relationships**:
- Has many `Photo` entities (one-to-many)

**Validation Rules**:
1. `photos.length` must be <= `maxPhotos` (20)
2. `photos` list must maintain insertion order (displayOrder sequential)
3. `startTime` cannot be in the future
4. `status` transitions must follow allowed state machine (see State Transitions)
5. Once `status` is `completed` or `cancelled`, session is immutable

**State Transitions**:
```
inProgress → completed   (User presses Done, selects Next/Quick Save)
inProgress → cancelled   (User presses Cancel, confirms discard)

Invalid transitions (throw exception):
completed → inProgress
completed → cancelled
cancelled → inProgress
cancelled → completed
```

**Methods**:
```dart
class PhotoSession {
  // Add photo to session (FR-005, FR-007, FR-008)
  void addPhoto(Photo photo) {
    if (photos.length >= maxPhotos) {
      throw SessionPhotoLimitException('Cannot exceed $maxPhotos photos');
    }
    if (status != SessionStatus.inProgress) {
      throw InvalidSessionStateException('Cannot add photo to $status session');
    }
    photos.add(photo);
  }

  // Remove photo from session (FR-010)
  void removePhoto(String photoId) {
    if (status != SessionStatus.inProgress) {
      throw InvalidSessionStateException('Cannot remove photo from $status session');
    }
    photos.removeWhere((p) => p.id == photoId);
    _reindexDisplayOrder(); // Maintain sequential ordering
  }

  // Check if session is at photo limit (FR-027, FR-027a)
  bool get isAtLimit => photos.length >= maxPhotos;

  // Complete session (FR-013, FR-014, FR-015)
  void complete() {
    if (status != SessionStatus.inProgress) {
      throw InvalidSessionStateException('Can only complete inProgress session');
    }
    status = SessionStatus.completed;
  }

  // Cancel session (FR-018, FR-020)
  void cancel() {
    if (status != SessionStatus.inProgress) {
      throw InvalidSessionStateException('Can only cancel inProgress session');
    }
    status = SessionStatus.cancelled;
  }

  // Reindex photos after deletion to maintain sequential displayOrder
  void _reindexDisplayOrder() {
    for (int i = 0; i < photos.length; i++) {
      photos[i].displayOrder = i;
    }
  }
}
```

**Serialization** (for session preservation FR-029/FR-030):
```dart
Map<String, dynamic> toJson() => {
  'id': id,
  'photos': photos.map((p) => p.toJson()).toList(),
  'startTime': startTime.toIso8601String(),
  'status': status.name,
  'maxPhotos': maxPhotos,
};

factory PhotoSession.fromJson(Map<String, dynamic> json) => PhotoSession(
  id: json['id'],
  photos: (json['photos'] as List).map((p) => Photo.fromJson(p)).toList(),
  startTime: DateTime.parse(json['startTime']),
  status: SessionStatus.values.byName(json['status']),
  maxPhotos: json['maxPhotos'],
);
```

**Example**:
```dart
PhotoSession(
  id: '660e8400-e29b-41d4-a716-446655440001',
  photos: [
    Photo(id: '...1', filePath: '/tmp/photo_1.jpg', displayOrder: 0, ...),
    Photo(id: '...2', filePath: '/tmp/photo_2.jpg', displayOrder: 1, ...),
    Photo(id: '...3', filePath: '/tmp/photo_3.jpg', displayOrder: 2, ...),
  ],
  startTime: DateTime(2025, 10, 7, 14, 28, 0),
  status: SessionStatus.inProgress,
  maxPhotos: 20,
)
```

---

### 3. PhotoCaptureState (Provider State)

**Purpose**: Manages UI state for the camera capture page, wrapping PhotoSession with camera status and error handling.

**Fields**:
| Field | Type | Required | Description | Validation |
|-------|------|----------|-------------|------------|
| `session` | PhotoSession | Yes | Current photo capture session | Not null |
| `cameraStatus` | CameraStatus (enum) | Yes | Camera controller state | One of enum values |
| `errorMessage` | String? | No | User-facing error message | Null when no error |
| `isInitializing` | bool | Yes | Camera initialization in progress | Not null |

**Enums**:
```dart
enum CameraStatus {
  uninitialized,     // Camera controller not yet created
  initializing,      // Camera initialization in progress
  ready,             // Camera ready for preview and capture
  permissionDenied,  // User denied camera permission (FR-022)
  error,             // Camera hardware or initialization error (FR-024)
}
```

**Computed Properties**:
```dart
// Derived from session state
bool get canCapture => cameraStatus == CameraStatus.ready && !session.isAtLimit;
bool get hasPhotos => session.photos.isNotEmpty;
int get photoCount => session.photos.length;
bool get isAtLimit => session.isAtLimit;
```

**Methods** (Provider ChangeNotifier):
```dart
class PhotoCaptureProvider extends ChangeNotifier {
  PhotoCaptureState _state = PhotoCaptureState(
    session: PhotoSession.create(), // Factory for new session
    cameraStatus: CameraStatus.uninitialized,
    errorMessage: null,
    isInitializing: false,
  );

  // Initialize camera (FR-001, FR-021)
  Future<void> initializeCamera() async {
    _state.isInitializing = true;
    _state.cameraStatus = CameraStatus.initializing;
    notifyListeners();

    try {
      final hasPermission = await _cameraService.requestPermissions();
      if (!hasPermission) {
        _state.cameraStatus = CameraStatus.permissionDenied;
        _state.errorMessage = 'Camera permission required'; // FR-022
        notifyListeners();
        return;
      }

      await _cameraService.initialize();
      _state.cameraStatus = CameraStatus.ready;
      _state.errorMessage = null;
    } catch (e) {
      _state.cameraStatus = CameraStatus.error;
      _state.errorMessage = 'Camera initialization failed: ${e.message}'; // FR-024
    } finally {
      _state.isInitializing = false;
      notifyListeners();
    }
  }

  // Capture photo (FR-005, FR-007, FR-008)
  Future<void> capturePhoto() async {
    if (!canCapture) return; // Guard: camera ready + not at limit

    try {
      final xFile = await _cameraService.takePicture();
      final photo = await _photoStorageService.saveTempPhoto(xFile);
      _state.session.addPhoto(photo);
      notifyListeners();
    } catch (e) {
      _state.errorMessage = 'Photo capture failed: ${e.message}';
      notifyListeners();
    }
  }

  // Delete photo (FR-010)
  Future<void> deletePhoto(String photoId) async {
    _state.session.removePhoto(photoId);
    await _photoStorageService.deleteTempPhoto(photoId);
    notifyListeners();
  }

  // Complete session (FR-013, FR-014, FR-015)
  void completeSession() {
    _state.session.complete();
    notifyListeners();
  }

  // Cancel session (FR-018, FR-020)
  Future<void> cancelSession() async {
    _state.session.cancel();
    await _photoStorageService.clearSessionPhotos(_state.session.id);
    notifyListeners();
  }

  // Session preservation (FR-029, FR-030)
  Future<void> saveSessionState() async {
    await _sessionPersistence.save(_state.session);
  }

  Future<void> restoreSessionState() async {
    final session = await _sessionPersistence.restore();
    if (session != null) {
      _state.session = session;
      notifyListeners();
    }
  }
}
```

---

## Entity Relationships

```
PhotoCaptureState (Provider)
  ├── session: PhotoSession (1:1)
  │     ├── photos: List<Photo> (1:N)
  │     │     └── Photo (entity)
  │     └── status: SessionStatus (enum)
  ├── cameraStatus: CameraStatus (enum)
  └── errorMessage: String? (optional)
```

---

## Validation Summary

| Entity | Validation Rules | Error Handling |
|--------|------------------|----------------|
| Photo | UUID format, file exists, timestamp valid, displayOrder >= 0 | Throw ArgumentError on invalid construction |
| PhotoSession | Length <= 20, valid state transitions, photos ordered | Throw custom exceptions (SessionPhotoLimitException, InvalidSessionStateException) |
| PhotoCaptureState | Camera status valid, session not null | Set errorMessage, update cameraStatus, notify UI |

---

## State Machine Diagram

```
[Session Creation]
       |
       v
  inProgress ──────> completed
       |                (Done + Next/Quick Save)
       |
       └──────> cancelled
                (Cancel + Confirm)

[Terminal States: completed, cancelled]
- No further transitions allowed
- Session becomes immutable
```

---

## Performance Considerations

1. **Thumbnail caching**: Store `thumbnailData` in Photo entity to avoid regeneration during ListView scrolling (60fps target, FR-026)
2. **Lazy loading**: Generate thumbnails only when needed (first access or after restoration)
3. **Memory footprint**: 20 photos × (500KB original + 10KB thumbnail) = ~10.2MB (acceptable)
4. **Session persistence**: Use SharedPreferences for session metadata (fast serialization, < 50ms save/restore)
5. **File I/O**: Temp directory optimized for quick read/write (< 100ms per photo save)

---

## Constitutional Compliance

| Article | Compliance | Evidence |
|---------|------------|----------|
| Article II (Offline Autonomy) | ✅ | All data local (temp storage), no network dependency |
| Article III (Data Integrity) | ✅ | Session serialization (FR-029/FR-030), validation rules, immutable terminal states |
| Article VI (Performance Primacy) | ✅ | Cached thumbnails, lazy loading, fast serialization (< 50ms) |
| Article VIII (Modular Independence) | ✅ | Clear entity separation, testable models, serializable for persistence |

---

## Test Coverage Requirements

1. **Photo entity**:
   - Serialization/deserialization round-trip
   - Validation rules (invalid UUID, missing file, future timestamp)
   - Thumbnail lazy loading

2. **PhotoSession entity**:
   - Add photo (success, at limit, invalid state)
   - Remove photo (success, invalid state, reindexing)
   - State transitions (valid, invalid)
   - 20-photo limit enforcement

3. **PhotoCaptureState (Provider)**:
   - Camera initialization (success, permission denied, error)
   - Capture photo (success, at limit, camera not ready)
   - Delete photo (success, update UI)
   - Session completion/cancellation
   - Session persistence/restoration

---

**Data Model Status**: ✅ COMPLETE
**Entities Defined**: 3 (Photo, PhotoSession, PhotoCaptureState)
**Validation Rules**: 15+ rules across entities
**Ready for Contracts Phase**: YES
