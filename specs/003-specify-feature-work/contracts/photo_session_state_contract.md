# Service & Provider Contracts: Camera Capture Page

**Feature**: Camera Capture Page
**Date**: 2025-10-07
**Type**: Service & State Management Contract Specification

## Overview
This document defines the contracts (inputs, outputs, behaviors) for services and state management (Provider) components. Each contract maps to functional requirements and serves as the specification for unit/integration tests (TDD approach).

---

## 1. CameraService

### Contract Specification

**Purpose**: Manages camera initialization, permissions, and photo capture.

**Dependencies**: `camera` package, `permission_handler` package

**Methods**:

#### `Future<bool> requestPermissions()`

**Contract**:
- **Inputs**: None
- **Outputs**: `bool` - true if camera permission granted, false otherwise
- **Behaviors**:
  1. Check current camera permission status
  2. If already granted, return true immediately
  3. If denied, request permission from user
  4. If permanently denied, return false (user must go to settings)
  5. Map to FR-021 (request permissions before accessing camera)
- **Test**: `test_camera_service_request_permissions_granted()`
- **Test**: `test_camera_service_request_permissions_denied()`
- **Test**: `test_camera_service_request_permissions_permanently_denied()`

**Error Handling**:
- Catches platform exceptions (iOS/Android permission dialogs)
- Returns false on any exception (graceful degradation)

---

#### `Future<void> initialize()`

**Contract**:
- **Inputs**: None
- **Outputs**: void (throws on error)
- **Behaviors**:
  1. Get list of available cameras
  2. Select first camera (typically rear camera)
  3. Create CameraController with ResolutionPreset.high, JPEG format
  4. Initialize controller
  5. Map to FR-001 (display camera preview - requires initialization)
- **Test**: `test_camera_service_initialize_success()`
- **Test**: `test_camera_service_initialize_no_cameras_available()`
- **Test**: `test_camera_service_initialize_controller_failure()`

**Error Handling**:
- Throws `CameraException` if no cameras available
- Throws `CameraException` if controller initialization fails
- Maps to FR-024 (handle camera failures gracefully)

---

#### `Future<XFile> takePicture()`

**Contract**:
- **Inputs**: None (uses internal controller)
- **Outputs**: `XFile` - captured photo file reference
- **Behaviors**:
  1. Verify camera controller is initialized
  2. Call controller.takePicture()
  3. Return XFile reference to captured photo
  4. Map to FR-005 (capture photo when button tapped)
- **Test**: `test_camera_service_take_picture_success()`
- **Test**: `test_camera_service_take_picture_controller_not_initialized()`
- **Test**: `test_camera_service_take_picture_capture_failure()`

**Error Handling**:
- Throws `StateError` if controller not initialized
- Throws `CameraException` if capture fails
- Maps to FR-024 (handle camera failures gracefully)

---

#### `Future<void> dispose()`

**Contract**:
- **Inputs**: None
- **Outputs**: void
- **Behaviors**:
  1. Dispose camera controller if initialized
  2. Release camera hardware resources
  3. Map to FR-029 (preserve session when backgrounded - requires camera disposal)
- **Test**: `test_camera_service_dispose_releases_resources()`

**Error Handling**:
- Silently handles disposal errors (best-effort cleanup)

---

#### `CameraController? get controller`

**Contract**:
- **Inputs**: None
- **Outputs**: `CameraController?` - current controller or null
- **Behaviors**:
  1. Return camera controller for CameraPreview widget
  2. Map to FR-001 (camera preview requires controller)
- **Test**: `test_camera_service_controller_null_before_init()`
- **Test**: `test_camera_service_controller_available_after_init()`

---

### Contract Test Summary

| Method | Contract Tests | Total |
|--------|----------------|-------|
| requestPermissions() | 3 tests (granted, denied, permanently denied) | 3 |
| initialize() | 3 tests (success, no cameras, failure) | 3 |
| takePicture() | 3 tests (success, not initialized, failure) | 3 |
| dispose() | 1 test (releases resources) | 1 |
| controller getter | 2 tests (null before/after init) | 2 |
| **TOTAL** | **12 unit tests** | **12** |

---

## 2. PhotoStorageService

### Contract Specification

**Purpose**: Manages temporary file storage for photo sessions.

**Dependencies**: `path_provider` package

**Methods**:

#### `Future<Photo> saveTempPhoto(XFile xFile)`

**Contract**:
- **Inputs**: `XFile xFile` - captured photo from camera
- **Outputs**: `Photo` - Photo entity with filePath in temp directory
- **Behaviors**:
  1. Get temporary directory path (path_provider)
  2. Generate unique filename using timestamp
  3. Copy XFile to temp directory with new filename
  4. Create Photo entity with filePath, timestamp, displayOrder
  5. Generate thumbnail (100x100, 70% JPEG) and cache in Photo.thumbnailData
  6. Map to FR-011 (store photos temporarily until saved)
- **Test**: `test_photo_storage_service_save_temp_photo_success()`
- **Test**: `test_photo_storage_service_save_temp_photo_temp_dir_unavailable()`
- **Test**: `test_photo_storage_service_save_temp_photo_file_copy_failure()`

**Error Handling**:
- Throws `FileSystemException` if temp directory unavailable
- Throws `FileSystemException` if file copy fails
- Maps to edge case: "What happens if temporary storage location becomes unavailable?"

---

#### `Future<void> deleteTempPhoto(String photoId)`

**Contract**:
- **Inputs**: `String photoId` - Photo ID to delete
- **Outputs**: void
- **Behaviors**:
  1. Look up photo by ID in session
  2. Delete file at filePath
  3. Map to FR-010 (delete photo when X tapped)
- **Test**: `test_photo_storage_service_delete_temp_photo_success()`
- **Test**: `test_photo_storage_service_delete_temp_photo_file_not_found()`

**Error Handling**:
- Silently handles file not found (idempotent deletion)
- Logs error if deletion fails but doesn't throw

---

#### `Future<void> clearSessionPhotos(String sessionId)`

**Contract**:
- **Inputs**: `String sessionId` - Session ID to clear
- **Outputs**: void
- **Behaviors**:
  1. Get all photo file paths for session
  2. Delete all files in session
  3. Map to FR-020 (discard all photos when cancel confirmed)
- **Test**: `test_photo_storage_service_clear_session_photos_success()`
- **Test**: `test_photo_storage_service_clear_session_photos_partial_failure()`

**Error Handling**:
- Best-effort deletion (logs errors but doesn't throw)
- Ensures all files attempted even if some fail

---

### Contract Test Summary

| Method | Contract Tests | Total |
|--------|----------------|-------|
| saveTempPhoto() | 3 tests (success, dir unavailable, copy failure) | 3 |
| deleteTempPhoto() | 2 tests (success, file not found) | 2 |
| clearSessionPhotos() | 2 tests (success, partial failure) | 2 |
| **TOTAL** | **7 unit tests** | **7** |

---

## 3. PhotoCaptureProvider (ChangeNotifier)

### Contract Specification

**Purpose**: Manages photo capture session state and coordinates camera/storage services.

**Dependencies**: `CameraService`, `PhotoStorageService`, `PhotoSession` model

**State Properties**:

#### `PhotoSession get session`

**Contract**:
- **Outputs**: Current photo session
- **Behaviors**: Returns active session with photos list
- **Test**: `test_provider_session_initialized_on_creation()`

---

#### `bool get canCapture`

**Contract**:
- **Outputs**: true if can capture photo, false otherwise
- **Behaviors**:
  1. Check camera status is ready
  2. Check session is not at 20 photo limit
  3. Return true only if both conditions met
  4. Map to FR-027 (enforce 20 photo limit)
- **Test**: `test_provider_can_capture_when_camera_ready_and_not_at_limit()`
- **Test**: `test_provider_cannot_capture_when_at_limit()`
- **Test**: `test_provider_cannot_capture_when_camera_not_ready()`

---

#### `bool get hasPhotos`

**Contract**:
- **Outputs**: true if session has any photos
- **Behaviors**: Check session.photos.length > 0
- **Test**: `test_provider_has_photos_true_when_photos_exist()`
- **Test**: `test_provider_has_photos_false_when_no_photos()`

---

#### `int get photoCount`

**Contract**:
- **Outputs**: Number of photos in session
- **Behaviors**: Return session.photos.length
- **Test**: `test_provider_photo_count_matches_session_photos_length()`

---

#### `bool get isAtLimit`

**Contract**:
- **Outputs**: true if session has 20 photos
- **Behaviors**: Check session.photos.length >= 20
- **Test**: `test_provider_is_at_limit_true_at_20_photos()`
- **Test**: `test_provider_is_at_limit_false_below_20_photos()`

---

#### `CameraStatus get cameraStatus`

**Contract**:
- **Outputs**: Current camera status enum
- **Behaviors**: Return current camera state (uninitialized, ready, error, etc.)
- **Test**: `test_provider_camera_status_uninitialized_initially()`
- **Test**: `test_provider_camera_status_ready_after_init()`

---

#### `String? get errorMessage`

**Contract**:
- **Outputs**: User-facing error message or null
- **Behaviors**: Return error message when camera fails, permission denied, etc.
- **Test**: `test_provider_error_message_null_when_no_error()`
- **Test**: `test_provider_error_message_set_on_permission_denied()`

---

### State Methods:

#### `Future<void> initializeCamera()`

**Contract**:
- **Inputs**: None
- **Outputs**: void (updates state)
- **Behaviors**:
  1. Set cameraStatus to initializing
  2. Request camera permissions via CameraService
  3. If denied, set cameraStatus to permissionDenied, set errorMessage
  4. If granted, call CameraService.initialize()
  5. If success, set cameraStatus to ready
  6. If failure, set cameraStatus to error, set errorMessage
  7. Notify listeners after each state change
  8. Map to FR-001, FR-021, FR-022
- **Test**: `test_provider_initialize_camera_success()`
- **Test**: `test_provider_initialize_camera_permission_denied()`
- **Test**: `test_provider_initialize_camera_initialization_failure()`

---

#### `Future<void> capturePhoto()`

**Contract**:
- **Inputs**: None
- **Outputs**: void (updates session state)
- **Behaviors**:
  1. Verify canCapture is true (guard)
  2. Call CameraService.takePicture()
  3. Call PhotoStorageService.saveTempPhoto(xFile)
  4. Add Photo to session via session.addPhoto()
  5. Notify listeners
  6. Map to FR-005, FR-007, FR-008
- **Test**: `test_provider_capture_photo_success()`
- **Test**: `test_provider_capture_photo_blocked_when_at_limit()`
- **Test**: `test_provider_capture_photo_blocked_when_camera_not_ready()`
- **Test**: `test_provider_capture_photo_notifies_listeners()`

---

#### `Future<void> deletePhoto(String photoId)`

**Contract**:
- **Inputs**: `String photoId` - Photo ID to delete
- **Outputs**: void (updates session state)
- **Behaviors**:
  1. Call session.removePhoto(photoId)
  2. Call PhotoStorageService.deleteTempPhoto(photoId)
  3. Notify listeners
  4. Map to FR-010
- **Test**: `test_provider_delete_photo_success()`
- **Test**: `test_provider_delete_photo_notifies_listeners()`

---

#### `void completeSession()`

**Contract**:
- **Inputs**: None
- **Outputs**: void (updates session state)
- **Behaviors**:
  1. Call session.complete()
  2. Notify listeners
  3. Map to FR-013 (Done button pressed)
- **Test**: `test_provider_complete_session_success()`
- **Test**: `test_provider_complete_session_notifies_listeners()`

---

#### `Future<void> cancelSession()`

**Contract**:
- **Inputs**: None
- **Outputs**: void (updates session state, clears photos)
- **Behaviors**:
  1. Call session.cancel()
  2. Call PhotoStorageService.clearSessionPhotos(session.id)
  3. Notify listeners
  4. Map to FR-020
- **Test**: `test_provider_cancel_session_success()`
- **Test**: `test_provider_cancel_session_clears_temp_photos()`
- **Test**: `test_provider_cancel_session_notifies_listeners()`

---

#### `Future<void> saveSessionState()`

**Contract**:
- **Inputs**: None
- **Outputs**: void (persists to SharedPreferences)
- **Behaviors**:
  1. Serialize session to JSON
  2. Save to SharedPreferences with key 'active_camera_session'
  3. Map to FR-029 (preserve session when backgrounded)
- **Test**: `test_provider_save_session_state_persists_to_storage()`

---

#### `Future<void> restoreSessionState()`

**Contract**:
- **Inputs**: None
- **Outputs**: void (restores from SharedPreferences)
- **Behaviors**:
  1. Load from SharedPreferences with key 'active_camera_session'
  2. If exists, deserialize JSON to PhotoSession
  3. Restore session state
  4. Notify listeners
  5. Map to FR-030 (restore session when app resumed)
- **Test**: `test_provider_restore_session_state_loads_from_storage()`
- **Test**: `test_provider_restore_session_state_no_saved_session()`

---

### Contract Test Summary

| Component | Contract Tests | Total |
|-----------|----------------|-------|
| State Properties | 11 tests (getters, computed properties) | 11 |
| initializeCamera() | 3 tests (success, permission denied, failure) | 3 |
| capturePhoto() | 4 tests (success, blocked at limit, blocked not ready, notifies) | 4 |
| deletePhoto() | 2 tests (success, notifies) | 2 |
| completeSession() | 2 tests (success, notifies) | 2 |
| cancelSession() | 3 tests (success, clears photos, notifies) | 3 |
| saveSessionState() | 1 test (persists) | 1 |
| restoreSessionState() | 2 tests (loads, no saved session) | 2 |
| **TOTAL** | **28 unit tests** | **28** |

---

## Contract Integration Tests

These tests verify service + provider integration (not pure unit tests):

1. **End-to-end capture flow**:
   - Test: `test_integration_capture_photo_flow()`
   - Behaviors:
     1. Initialize provider
     2. Initialize camera (via provider)
     3. Capture photo (via provider)
     4. Verify photo added to session
     5. Verify file saved to temp storage

2. **Session preservation flow**:
   - Test: `test_integration_session_preservation_flow()`
   - Behaviors:
     1. Capture 3 photos
     2. Save session state
     3. Simulate app restart (new provider instance)
     4. Restore session state
     5. Verify 3 photos restored with correct file paths

3. **Cancel session flow**:
   - Test: `test_integration_cancel_session_flow()`
   - Behaviors:
     1. Capture 5 photos
     2. Cancel session
     3. Verify all 5 temp files deleted
     4. Verify session status is cancelled

4. **Photo limit enforcement**:
   - Test: `test_integration_20_photo_limit_enforcement()`
   - Behaviors:
     1. Capture 20 photos
     2. Verify canCapture is false
     3. Attempt to capture 21st photo
     4. Verify capture blocked, session still has 20 photos

**Integration Test Total**: 4 tests

---

## Total Contract Test Coverage

| Component | Unit Tests | Integration Tests | Total |
|-----------|------------|-------------------|-------|
| CameraService | 12 | - | 12 |
| PhotoStorageService | 7 | - | 7 |
| PhotoCaptureProvider | 28 | 4 | 32 |
| **GRAND TOTAL** | **47** | **4** | **51** |

---

## Test Execution Order (TDD)

1. Write all contract tests first (they will fail - no implementation yet)
2. Implement services and provider one by one to make tests pass:
   - **Phase 1**: PhotoStorageService (no dependencies)
   - **Phase 2**: CameraService (depends on camera package only)
   - **Phase 3**: PhotoCaptureProvider (depends on both services + PhotoSession model)
   - **Phase 4**: Integration tests (verify end-to-end flows)

---

**Service & Provider Contract Status**: ✅ COMPLETE
**Total Contracts Defined**: 3 components (CameraService, PhotoStorageService, PhotoCaptureProvider)
**Total Test Specifications**: 51 tests (47 unit + 4 integration)
**Ready for Test Implementation**: YES
