# Research & Technical Decisions

**Feature**: UI/UX Design for Site Pictures Application
**Date**: 2025-09-29

## Framework Selection

### Decision: Flutter with Dart
**Rationale**:
- Cross-platform development from single codebase (iOS + Android)
- Native performance with compiled ARM code
- Rich widget library matching Material Design and iOS patterns
- Strong offline capabilities with local database support
- Active community and Google backing

**Alternatives Considered**:
- React Native: Good cross-platform but performance concerns for camera operations
- Native (Swift/Kotlin): Better platform integration but doubles development effort
- Ionic: Web-based approach inadequate for offline-first requirements

## State Management

### Decision: Provider Pattern
**Rationale**:
- Simple and intuitive for team adoption
- Official Flutter recommendation for most apps
- Minimal boilerplate compared to BLoC
- Sufficient for app complexity level

**Alternatives Considered**:
- Riverpod: More powerful but unnecessary complexity for current scope
- BLoC: Over-engineered for UI-focused feature set
- GetX: Too opinionated and potential maintenance concerns

## Local Storage

### Decision: SQLite via sqflite package
**Rationale**:
- Proven reliability for offline mobile apps
- ACID compliance ensures data integrity
- Efficient querying for hierarchical data
- Minimal storage overhead
- Built-in transaction support

**Alternatives Considered**:
- Hive: NoSQL approach doesn't fit hierarchical data well
- Shared Preferences: Insufficient for complex data structures
- ObjectBox: Less mature ecosystem in Flutter

## Photo Storage Strategy

### Decision: File System + SQLite Metadata
**Rationale**:
- Photos stored as files in app's document directory
- Metadata and references in SQLite
- Enables efficient thumbnail generation
- Supports background sync without database locks
- Allows direct file access for exports

**Implementation Details**:
- Original photos in `documents/photos/originals/`
- Thumbnails cached in `cache/thumbnails/`
- SQLite stores path, timestamp, GPS, equipment_id

## Sync Architecture

### Decision: Queue-based Background Sync
**Rationale**:
- Resilient to connectivity interruptions
- Non-blocking UI operations
- Retry logic with exponential backoff
- Preserves battery life

**Implementation Approach**:
- Local sync queue table in SQLite
- Background isolate for sync operations
- WorkManager for Android / BGTaskScheduler for iOS
- Conflict resolution via server timestamp comparison

## Navigation Pattern

### Decision: Navigator 2.0 with go_router
**Rationale**:
- Declarative routing matches hierarchical structure
- Deep linking support for future web version
- Type-safe route parameters
- Browser-like back button handling

**Alternatives Considered**:
- Navigator 1.0: Imperative approach harder to maintain
- Auto_route: Good but less community adoption
- Custom solution: Unnecessary complexity

## Camera Implementation

### Decision: camera package with custom overlay
**Rationale**:
- Official Flutter plugin with stable API
- Supports both platforms uniformly
- Allows custom UI overlays
- Direct access to image stream for processing

**Implementation Notes**:
- Custom carousel view using PageView widget
- Image compression before storage
- EXIF data extraction for GPS coordinates

## GPS/Location Services

### Decision: geolocator package
**Rationale**:
- Most mature location package for Flutter
- Handles permissions gracefully
- Background location support
- Battery-efficient location updates

**Configuration**:
- Request location only when camera active
- Accuracy: LocationAccuracy.high for photos
- Cache last known location for offline scenarios

## Authentication & Authorization

### Decision: JWT tokens with role claims
**Rationale**:
- Stateless authentication suitable for mobile
- Offline token validation possible
- Standard approach for REST APIs
- Role information embedded in token

**Implementation**:
- Secure storage via flutter_secure_storage
- Token refresh before expiration
- Role-based widget visibility

## UI Component Library

### Decision: Custom widgets extending Material Design
**Rationale**:
- Material Design familiar to users
- Platform-adaptive components (iOS feel on iOS)
- Consistent with "Ziatech" branding
- Customizable for industrial context

**Key Customizations**:
- Blue header (#4A90E2) across all screens
- Large touch targets for field use
- High contrast for outdoor visibility
- Custom breadcrumb widget for navigation

## Testing Strategy

### Decision: Widget tests + Integration tests
**Rationale**:
- Widget tests for component validation
- Integration tests for user flows
- No unit tests needed for UI-focused feature

**Test Coverage Goals**:
- Critical user paths: 100%
- Widget interaction: 80%
- Edge cases: 60%

## Performance Optimizations

### Decisions Made:
1. **Lazy Loading**: Load sites/equipment on demand
2. **Image Caching**: Three-tier cache (memory/disk/network)
3. **Database Indexing**: Indexes on frequently queried columns
4. **Pagination**: Load photos in batches of 20
5. **Thumbnail Generation**: Background isolate processing

## Security Considerations

### Decisions Made:
1. **Photo Encryption**: Optional AES encryption for sensitive sites
2. **Biometric Auth**: FaceID/TouchID for app access
3. **Certificate Pinning**: For API communication
4. **SQL Injection Prevention**: Parameterized queries only
5. **Data Scrubbing**: Remove EXIF data before external sharing

## Resolved Clarifications

All technical clarifications from the specification have been addressed:
- ✅ Empty state handling defined
- ✅ Offline sync strategy determined
- ✅ Photo-equipment association clarified
- ✅ Metadata requirements specified
- ✅ Role-based access implementation planned

## Dependencies Summary

```yaml
dependencies:
  flutter:
    sdk: flutter
  sqflite: ^2.3.0
  path_provider: ^2.1.1
  camera: ^0.10.5
  geolocator: ^10.1.0
  provider: ^6.1.1
  go_router: ^13.0.0
  http: ^1.1.0
  flutter_secure_storage: ^9.0.0
  image: ^4.1.3
  path: ^1.8.3
  intl: ^0.18.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  integration_test:
    sdk: flutter
  flutter_lints: ^3.0.0
```

## Next Steps
With all technical decisions made and clarifications resolved, the plan can proceed to Phase 1 for detailed design artifacts generation.