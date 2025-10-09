# Phase 0: Research Findings - Work Site Photo Capture Page

**Feature**: Camera Capture Page
**Date**: 2025-10-07
**Status**: Complete

## Research Overview
This document captures technology decisions, best practices, and implementation patterns for the photo capture feature. All decisions prioritize field-first architecture, offline autonomy, performance primacy, and intuitive simplicity per constitutional requirements.

---

## 1. Flutter Camera Plugin (camera package)

### Decision
Use the official `camera` package (latest stable version) for camera preview and image capture.

### Rationale
- **Official Flutter package**: Maintained by Flutter team, well-documented, stable API
- **Platform support**: Supports iOS 13+ and Android 8.0+ (meets target platform requirements)
- **Rich feature set**: Live preview, photo capture, camera control (zoom, flash, focus)
- **Performance**: Hardware-accelerated preview, efficient image capture pipeline
- **Permission integration**: Works seamlessly with permission_handler
- **Constitutional alignment**: Enables < 2s capture time (Article VI: Performance Primacy)

### Best Practices
1. **Initialization pattern**:
   ```dart
   // Initialize in initState, dispose in dispose
   Future<void> _initializeCamera() async {
     final cameras = await availableCameras();
     final firstCamera = cameras.first; // Rear camera typically first
     _controller = CameraController(
       firstCamera,
       ResolutionPreset.high, // Balance quality/performance
       enableAudio: false, // Photos only, no audio
       imageFormatGroup: ImageFormatGroup.jpeg, // JPEG format (FR-028)
     );
     await _controller.initialize();
   }
   ```

2. **Error handling**:
   - Wrap initialization in try-catch
   - Handle CameraException types: CameraAccessDenied, CameraNotAvailable
   - Display user-friendly error messages (FR-024)
   - Graceful fallback when camera unavailable

3. **Disposal pattern**:
   ```dart
   @override
   void dispose() {
     _controller?.dispose(); // Clean up resources
     super.dispose();
   }
   ```

4. **App lifecycle handling** (FR-029, FR-030):
   ```dart
   @override
   void didChangeAppLifecycleState(AppLifecycleState state) {
     if (state == AppLifecycleState.inactive) {
       _controller?.dispose(); // Release camera when backgrounded
     } else if (state == AppLifecycleState.resumed) {
       _initializeCamera(); // Reinitialize when resumed
       _restoreSessionState(); // Restore captured photos
     }
   }
   ```

5. **Capture optimization**:
   - Use `takePicture()` for XFile output (efficient path-based access)
   - Avoid blocking UI thread during capture
   - Set JPEG quality via ResolutionPreset.high (medium quality balance)

### Alternatives Considered
- **image_picker**: Simpler API but lacks live preview, doesn't meet FR-001 requirement
- **camera_camera**: Third-party package with built-in UI, but less customizable for field-first UX
- **Native platform channels**: Maximum control but requires dual iOS/Android implementation, violates simplicity principle

### References
- Official camera plugin: https://pub.dev/packages/camera
- Flutter camera best practices: https://docs.flutter.dev/cookbook/plugins/picture-using-camera

---

## 2. Image Compression & Thumbnails

### Decision
Use `flutter_image_compress` for thumbnail generation; camera package's built-in JPEG quality for captures.

### Rationale
- **Performance**: Generate small thumbnails (100x100) for ListView to maintain 60fps scrolling (FR-026)
- **Memory efficiency**: Reduce memory footprint with 20 photos in session
- **Quality balance**: Medium JPEG quality (~500KB per photo) balances storage and visual fidelity (FR-028 clarification)
- **Constitutional alignment**: Battery preservation (Article I), performance primacy (Article VI)

### Best Practices
1. **Thumbnail generation**:
   ```dart
   Future<Uint8List> generateThumbnail(String filePath) async {
     return await FlutterImageCompress.compressWithFile(
       filePath,
       minWidth: 100,
       minHeight: 100,
       quality: 70, // Lower quality for thumbnails
       format: CompressFormat.jpeg,
     );
   }
   ```

2. **ListView optimization**:
   - Use `Image.memory()` for thumbnails (cached in memory)
   - Lazy load thumbnails as ListView scrolls (only generate visible items)
   - Cache thumbnails in provider state (avoid regeneration)

3. **JPEG quality settings** (FR-028):
   - Camera capture: ResolutionPreset.high (~85% quality, ~500KB)
   - Thumbnails: 70% quality, 100x100px (~10KB)
   - Total session memory: ~20 photos × 500KB = 10MB (acceptable for modern devices)

### Alternatives Considered
- **image package**: Lower-level control but slower, synchronous operations block UI
- **Native platform compression**: Maximum control but requires dual implementation
- **No compression**: Simpler but violates performance/battery constitutional requirements (Article VI)

### References
- flutter_image_compress: https://pub.dev/packages/flutter_image_compress
- Image optimization guide: https://docs.flutter.dev/perf/rendering-performance

---

## 3. State Management (Provider vs Riverpod)

### Decision
Use `provider` package with ChangeNotifier for photo session state management.

### Rationale
- **Existing project standard**: CLAUDE.md shows provider already in use (consistency)
- **Simplicity**: ChangeNotifier pattern is intuitive, matches Article VII (Intuitive Simplicity)
- **Sufficient for scope**: Managing list of 20 photos doesn't require Riverpod's advanced features
- **Well-documented**: Extensive Flutter community knowledge base
- **Testable**: Easy to mock providers in unit/widget tests

### Best Practices
1. **Provider structure**:
   ```dart
   class PhotoCaptureProvider extends ChangeNotifier {
     final PhotoSession _session = PhotoSession();
     final CameraService _cameraService;
     final PhotoStorageService _storageService;

     List<Photo> get photos => _session.photos;
     bool get isAtLimit => _session.photos.length >= 20;
     SessionStatus get status => _session.status;

     Future<void> capturePhoto() async {
       if (isAtLimit) return; // Enforce FR-027
       final xFile = await _cameraService.takePicture();
       final photo = await _storageService.saveTempPhoto(xFile);
       _session.addPhoto(photo);
       notifyListeners();
     }

     void deletePhoto(String photoId) {
       _session.removePhoto(photoId);
       _storageService.deleteTempPhoto(photoId);
       notifyListeners();
     }
   }
   ```

2. **Consumer pattern**:
   ```dart
   Consumer<PhotoCaptureProvider>(
     builder: (context, provider, child) {
       return CaptureButton(
         onPressed: provider.isAtLimit ? null : provider.capturePhoto,
         isDisabled: provider.isAtLimit, // FR-027a
       );
     },
   )
   ```

3. **Session preservation** (FR-029, FR-030):
   - Store session state in provider
   - Serialize to SharedPreferences on app background
   - Restore on app resume

### Alternatives Considered
- **Riverpod**: More powerful (code generation, compile-time safety) but overkill for this scope; adds complexity
- **BLoC**: Event-driven pattern, more boilerplate for simple list management
- **GetX**: Not used in existing project, consistency violation
- **setState only**: Insufficient for cross-widget state sharing (thumbnails, buttons, overlays)

### References
- Provider package: https://pub.dev/packages/provider
- Flutter state management guide: https://docs.flutter.dev/data-and-backend/state-mgmt/simple

---

## 4. Permission Handling (permission_handler)

### Decision
Use `permission_handler` package with clear error messaging and permission request workflow.

### Rationale
- **Cross-platform**: Handles iOS/Android permission differences automatically
- **User control**: Allows checking permission status before requesting (less intrusive)
- **Settings deep link**: Can direct users to app settings when permission denied (FR-023)
- **Constitutional alignment**: Privacy by design (Article V), intuitive simplicity (Article VII)

### Best Practices
1. **Permission request flow**:
   ```dart
   Future<bool> requestCameraPermission() async {
     final status = await Permission.camera.status;
     if (status.isGranted) return true;

     if (status.isDenied) {
       final result = await Permission.camera.request();
       return result.isGranted;
     }

     if (status.isPermanentlyDenied) {
       // Show dialog with "Open Settings" button (FR-023)
       _showPermissionSettingsDialog();
       return false;
     }

     return false;
   }
   ```

2. **Error messaging** (FR-022, FR-023):
   - Clear explanation: "Camera access required to capture photos"
   - Actionable steps: "Tap 'Open Settings' to enable camera permission"
   - Visual cues: Icon + text, prominent button
   - Graceful fallback: Don't block entire app, just camera feature

3. **iOS-specific**: Add NSCameraUsageDescription to Info.plist
4. **Android-specific**: Add CAMERA permission to AndroidManifest.xml

### Alternatives Considered
- **Manual permission checks**: Platform-specific code, more complex, error-prone
- **Embedded permission requests**: Less transparent, poor UX per Article VII

### References
- permission_handler: https://pub.dev/packages/permission_handler
- Flutter permissions guide: https://docs.flutter.dev/development/platform-integration/platform-channels

---

## 5. Temporary File Storage (path_provider)

### Decision
Use `path_provider`'s `getTemporaryDirectory()` for photo session storage with manual cleanup strategy.

### Rationale
- **OS-managed**: System cleans up temp directory when storage low (automatic backup)
- **Fast I/O**: Temp directory optimized for quick read/write
- **Session-scoped**: Appropriate for photos awaiting user decision (Next/Quick Save)
- **Constitutional alignment**: Offline autonomy (Article II), data integrity (Article III via session preservation)

### Best Practices
1. **Save pattern**:
   ```dart
   Future<Photo> saveTempPhoto(XFile xFile) async {
     final tempDir = await getTemporaryDirectory();
     final timestamp = DateTime.now().millisecondsSinceEpoch;
     final fileName = 'photo_$timestamp.jpg';
     final targetPath = '${tempDir.path}/$fileName';

     await xFile.saveTo(targetPath); // Move from camera to temp

     return Photo(
       id: Uuid().v4(),
       filePath: targetPath,
       captureTimestamp: DateTime.now(),
       displayOrder: _currentSessionPhotoCount++,
     );
   }
   ```

2. **Cleanup strategies**:
   - **On session complete**: Delete temp photos after Quick Save/Next (user completed flow)
   - **On session cancel**: Delete all temp photos immediately (user discarded, FR-020)
   - **On app restart**: Check for orphaned sessions older than 24 hours, clean up
   - **Never delete during active session**: Preserve on background (FR-029, FR-030)

3. **Session persistence** (FR-029, FR-030):
   ```dart
   // Save session metadata to SharedPreferences on app background
   Future<void> saveSessionState() async {
     final prefs = await SharedPreferences.getInstance();
     final sessionJson = jsonEncode({
       'photos': _session.photos.map((p) => p.toJson()).toList(),
       'timestamp': _session.startTime.toIso8601String(),
     });
     await prefs.setString('active_camera_session', sessionJson);
   }

   // Restore on app resume
   Future<void> restoreSessionState() async {
     final prefs = await SharedPreferences.getInstance();
     final sessionJson = prefs.getString('active_camera_session');
     if (sessionJson != null) {
       final data = jsonDecode(sessionJson);
       _session.restorePhotos(data['photos']);
       notifyListeners();
     }
   }
   ```

### Alternatives Considered
- **Application documents directory**: More permanent, requires manual cleanup, slower access
- **In-memory only**: Violates FR-029/FR-030 (session preservation on background)
- **SQLite immediately**: Premature, Quick Save/Next behavior not yet defined (deferred per clarification)

### References
- path_provider: https://pub.dev/packages/path_provider
- File handling guide: https://docs.flutter.dev/cookbook/persistence/reading-writing-files

---

## 6. ListView Performance Optimization

### Decision
Use `ListView.builder` with cached thumbnails and lazy loading for smooth 60fps scrolling.

### Rationale
- **Lazy rendering**: Only builds visible items, efficient with 20 photos
- **Memory efficient**: Doesn't load all 20 full images at once
- **Smooth scrolling**: Meets FR-026 (smooth scrolling) and Article VI (60fps target)
- **Simple API**: Matches Article VII (intuitive simplicity)

### Best Practices
1. **Builder pattern**:
   ```dart
   ListView.builder(
     scrollDirection: Axis.horizontal,
     itemCount: provider.photos.length,
     itemBuilder: (context, index) {
       return PhotoThumbnail(
         photo: provider.photos[index],
         onDelete: () => provider.deletePhoto(provider.photos[index].id),
       );
     },
   )
   ```

2. **Thumbnail caching**:
   - Generate thumbnails once on capture
   - Store Uint8List in Photo model (in-memory cache)
   - Use Image.memory() for instant display (no disk I/O during scroll)

3. **Delete overlay**:
   - Stack widget: thumbnail + positioned X button
   - IconButton with onPressed delete callback
   - Immediate removal from list (FR-010)

4. **Performance validation**:
   - Profile with Flutter DevTools (ensure 60fps with 20 photos)
   - Test on older devices (iOS 13, Android 8.0 minimum targets)

### Alternatives Considered
- **GridView**: Not needed (single horizontal row)
- **PageView**: Wrong pattern (not swipeable pages)
- **Custom scroll view**: Over-engineering for simple horizontal list

### References
- ListView.builder guide: https://api.flutter.dev/flutter/widgets/ListView/ListView.builder.html
- Scrolling performance: https://docs.flutter.dev/perf/rendering-performance

---

## 7. App Lifecycle & Session Preservation

### Decision
Implement `WidgetsBindingObserver` to detect app lifecycle changes and preserve session state during backgrounding.

### Rationale
- **Constitutional requirement**: Data integrity (Article III) demands no photo loss on background
- **User expectation**: Incoming calls shouldn't disrupt work (FR-029, FR-030)
- **Flutter pattern**: WidgetsBindingObserver is standard approach for lifecycle events

### Best Practices
1. **Observer setup**:
   ```dart
   class CameraCapturePageState extends State<CameraCapturePage>
       with WidgetsBindingObserver {

     @override
     void initState() {
       super.initState();
       WidgetsBinding.instance.addObserver(this);
       _initializeCamera();
     }

     @override
     void dispose() {
       WidgetsBinding.instance.removeObserver(this);
       _controller?.dispose();
       super.dispose();
     }

     @override
     void didChangeAppLifecycleState(AppLifecycleState state) {
       switch (state) {
         case AppLifecycleState.paused:
           _controller?.dispose(); // Release camera
           _saveSessionState(); // Persist photos
           break;
         case AppLifecycleState.resumed:
           _initializeCamera(); // Reinitialize camera
           _restoreSessionState(); // Restore photos
           break;
         default:
           break;
       }
     }
   }
   ```

2. **Session persistence**:
   - Save photo file paths to SharedPreferences (lightweight, fast)
   - Restore on resume before camera initialization completes
   - Validate file paths still exist (cleanup if missing)

3. **Camera resource management**:
   - Always dispose camera controller on pause (releases hardware)
   - Reinitialize on resume (may fail if permissions changed, handle gracefully)

### Alternatives Considered
- **No lifecycle handling**: Violates FR-029/FR-030, data loss on background
- **Continuous camera hold**: Battery drain, resource contention, violates Article VI
- **Database persistence**: Over-engineering for temporary session state

### References
- WidgetsBindingObserver: https://api.flutter.dev/flutter/widgets/WidgetsBindingObserver-class.html
- App lifecycle: https://docs.flutter.dev/development/ui/advanced/app-lifecycle

---

## 8. JPEG Compression Quality

### Decision
Use `ResolutionPreset.high` for camera captures (approx. 85% quality, ~500KB per photo).

### Rationale
- **Clarification alignment**: FR-028 specifies "medium quality compression (balanced file size and image quality)"
- **Field usability**: High enough quality for documentation, low enough for fast capture/storage
- **Performance**: 20 photos × 500KB = 10MB total, easily fits in memory and temp storage
- **Constitutional**: Battery preservation (Article I), performance primacy (Article VI)

### Best Practices
1. **Camera configuration**:
   ```dart
   _controller = CameraController(
     firstCamera,
     ResolutionPreset.high, // ~1920x1080, 85% JPEG quality
     enableAudio: false,
     imageFormatGroup: ImageFormatGroup.jpeg, // Explicit JPEG (FR-028)
   );
   ```

2. **Quality trade-offs**:
   - ResolutionPreset.high: Balance quality/size (~500KB)
   - ResolutionPreset.max: Best quality but 2-3MB per photo (slower capture, excessive storage)
   - ResolutionPreset.medium: Lower quality (~200KB) but potential clarity loss for documentation

3. **Validation**:
   - Test captures on representative equipment (readable text, clear details)
   - Verify file sizes stay within 400-600KB range
   - Ensure capture latency < 2s (Article VI threshold)

### Alternatives Considered
- **ResolutionPreset.max**: Highest quality but violates performance/battery requirements
- **ResolutionPreset.medium**: Smaller files but may compromise documentation clarity
- **Custom compression**: More control but adds complexity, violates Article VII

### References
- CameraController ResolutionPreset: https://pub.dev/documentation/camera/latest/camera/ResolutionPreset.html
- JPEG quality guide: https://en.wikipedia.org/wiki/JPEG#JPEG_compression

---

## Summary of Decisions

| Component | Technology | Key Rationale |
|-----------|------------|---------------|
| Camera | camera package | Official Flutter plugin, hardware-accelerated, meets < 2s capture requirement |
| Thumbnails | flutter_image_compress | 60fps scrolling via small thumbnails (100x100, 70% quality) |
| State Management | provider (ChangeNotifier) | Existing project standard, sufficient for 20-photo list management |
| Permissions | permission_handler | Cross-platform, settings deep link, clear error messaging |
| Storage | path_provider (temp directory) | OS-managed cleanup, fast I/O, session-scoped lifecycle |
| Scrolling | ListView.builder | Lazy loading, 60fps performance, simple API |
| Lifecycle | WidgetsBindingObserver | Standard Flutter pattern for session preservation on background |
| JPEG Quality | ResolutionPreset.high | Balanced 85% quality (~500KB), meets medium quality requirement |

## Constitutional Compliance

All research decisions align with constitutional principles:
- **Article I (Field-First)**: < 2s capture, one-handed operation, battery-efficient compression
- **Article II (Offline Autonomy)**: All local operations, no network dependency
- **Article III (Data Integrity)**: Session preservation, temp storage, no photo loss on background
- **Article V (Privacy)**: Permission-based, local-only storage, no telemetry
- **Article VI (Performance Primacy)**: < 2s capture, 60fps scrolling, < 500ms navigation
- **Article VII (Intuitive Simplicity)**: Standard camera UI, clear errors, actionable messages
- **Article VIII (Modular Independence)**: Camera service isolated, testable components

## Next Steps (Phase 1)

With research complete, proceed to Phase 1:
1. Create `data-model.md` (Photo, PhotoSession entities)
2. Generate widget contracts in `/contracts/`
3. Write failing contract tests
4. Extract quickstart scenarios from acceptance tests
5. Update CLAUDE.md with new dependencies

---
**Research Status**: ✅ COMPLETE
**Ready for Phase 1**: YES
**Outstanding Questions**: NONE (all clarified in /clarify phase)
