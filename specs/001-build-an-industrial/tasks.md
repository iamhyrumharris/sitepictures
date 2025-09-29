# Tasks: Industrial Photo Management Application

**Input**: Design documents from `/specs/001-build-an-industrial/`
**Prerequisites**: plan.md (required), research.md, data-model.md, contracts/

## Execution Flow (main)
```
1. Load plan.md from feature directory
   → If not found: ERROR "No implementation plan found"
   → Extract: tech stack, libraries, structure
2. Load optional design documents:
   → data-model.md: Extract entities → model tasks
   → contracts/: Each file → contract test task
   → research.md: Extract decisions → setup tasks
3. Generate tasks by category:
   → Setup: project init, dependencies, linting
   → Tests: contract tests, integration tests
   → Core: models, services, CLI commands
   → Integration: DB, middleware, logging
   → Polish: unit tests, performance, docs
4. Apply task rules:
   → Different files = mark [P] for parallel
   → Same file = sequential (no [P])
   → Tests before implementation (TDD)
5. Number tasks sequentially (T001, T002...)
6. Generate dependency graph
7. Create parallel execution examples
8. Validate task completeness:
   → All contracts have tests?
   → All entities have models?
   → All endpoints implemented?
9. Return: SUCCESS (tasks ready for execution)
```

## Format: `[ID] [P?] Description`
- **[P]**: Can run in parallel (different files, no dependencies)
- Include exact file paths in descriptions

## Path Conventions
- **Mobile + API Structure**: `app/` for Flutter, `api/` for REST backend
- Paths shown below follow plan.md structure decision

## Phase 3.1: Setup
- [X] T001 Create project structure per implementation plan (app/ and api/ directories)
- [X] T002 Initialize Flutter project with dependencies in app/pubspec.yaml
- [X] T003 Initialize Node.js API project with package.json in api/
- [X] T004 [P] Configure Flutter linting and formatting in app/analysis_options.yaml
- [X] T005 [P] Configure ESLint and Prettier for API in api/.eslintrc.json
- [X] T006 [P] Setup PostgreSQL database schema and migrations in api/src/database/migrations/
- [X] T007 [P] Configure SQLite database structure in app/lib/services/database/schema.dart

## Phase 3.2: Tests First (TDD) ⚠️ MUST COMPLETE BEFORE 3.3
**CRITICAL: These tests MUST be written and MUST FAIL before ANY implementation**

### Contract Tests (API)
- [X] T008 [P] Contract test POST /sync/changes in api/tests/contract/test_sync_changes_post.js
- [X] T009 [P] Contract test GET /sync/changes/{since} in api/tests/contract/test_sync_changes_get.js
- [X] T010 [P] Contract test POST /photos in api/tests/contract/test_photos_post.js
- [X] T011 [P] Contract test GET /photos/{photoId} in api/tests/contract/test_photos_get.js
- [X] T012 [P] Contract test GET /companies/{companyId}/structure in api/tests/contract/test_company_structure.js
- [X] T013 [P] Contract test POST /boundaries in api/tests/contract/test_boundaries_post.js
- [X] T014 [P] Contract test GET /boundaries/detect/{lat}/{lng} in api/tests/contract/test_boundaries_detect.js

### Integration Tests (App)
- [X] T015 [P] Integration test offline photo capture (Sarah's scenario) in app/test/integration_test/offline_capture_test.dart
- [X] T016 [P] Integration test hierarchical organization (Mike's scenario) in app/test/integration_test/hierarchy_organization_test.dart
- [X] T017 [P] Integration test sync conflict resolution (Jennifer's scenario) in app/test/integration_test/sync_conflict_test.dart
- [X] T018 [P] Integration test GPS boundary detection in app/test/integration_test/gps_boundary_test.dart
- [X] T019 [P] Integration test search performance (<1s requirement) in app/test/integration_test/search_performance_test.dart

## Phase 3.3: Core Implementation (ONLY after tests are failing)

### Data Models (App - Flutter/Dart)
- [X] T020 [P] Photo model with validation in app/lib/models/photo.dart
- [X] T021 [P] Client model with GPS boundaries in app/lib/models/client.dart
- [X] T022 [P] Site model with hierarchy support in app/lib/models/site.dart
- [X] T023 [P] Equipment model with tags in app/lib/models/equipment.dart
- [X] T024 [P] Company model with settings in app/lib/models/company.dart
- [X] T025 [P] User (device-based) model in app/lib/models/user.dart
- [X] T026 [P] Revision model for grouping in app/lib/models/revision.dart
- [X] T027 [P] GPSBoundary model with priority in app/lib/models/gps_boundary.dart
- [X] T028 [P] SyncPackage model for offline sync in app/lib/models/sync_package.dart

### Data Models (API - Node.js)
- [X] T029 [P] Photo model in api/src/models/photo.js
- [X] T030 [P] Client model in api/src/models/client.js
- [X] T031 [P] Site model in api/src/models/site.js
- [X] T032 [P] Equipment model in api/src/models/equipment.js
- [X] T033 [P] Company model in api/src/models/company.js
- [X] T034 [P] GPSBoundary model in api/src/models/gps_boundary.js
- [X] T035 [P] SyncPackage model in api/src/models/sync_package.js

### Core Services (App)
- [X] T036 [P] Camera service with metadata extraction in app/lib/services/camera_service.dart
- [X] T037 [P] Storage service for SQLite operations in app/lib/services/storage_service.dart
- [X] T038 [P] GPS service with location tracking in app/lib/services/gps_service.dart
- [X] T039 [P] Sync service for background sync in app/lib/services/sync_service.dart
- [X] T040 [P] Search service with FTS5 indexing in app/lib/services/search_service.dart
- [X] T041 [P] Navigation service for hierarchy in app/lib/services/navigation_service.dart
- [X] T042 [P] File service for photo storage in app/lib/services/file_service.dart

### API Endpoints Implementation
- [X] T043 POST /sync/changes endpoint in api/src/routes/sync.js
- [X] T044 GET /sync/changes/{since} endpoint in api/src/routes/sync.js (same file)
- [X] T045 POST /photos endpoint for upload in api/src/routes/photos.js
- [X] T046 GET /photos/{photoId} endpoint in api/src/routes/photos.js (same file)
- [X] T047 GET /companies/{companyId}/structure in api/src/routes/companies.js
- [X] T048 POST /boundaries endpoint in api/src/routes/boundaries.js
- [X] T049 GET /boundaries/detect/{lat}/{lng} in api/src/routes/boundaries.js (same file)

### UI Screens (App)
- [X] T050 [P] Camera screen with quick capture in app/lib/screens/camera_screen.dart
- [X] T051 [P] Navigation screen with breadcrumbs in app/lib/screens/navigation_screen.dart
- [X] T052 [P] Equipment detail screen with timeline in app/lib/screens/equipment_detail_screen.dart
- [X] T053 [P] Search screen with filters in app/lib/screens/search_screen.dart
- [X] T054 [P] Settings screen with sync controls in app/lib/screens/settings_screen.dart
- [X] T055 [P] Photo gallery screen with thumbnails in app/lib/screens/gallery_screen.dart
- [X] T056 [P] Needs Assignment folder screen in app/lib/screens/needs_assignment_screen.dart

## Phase 3.4: Integration

### Database Integration
- [X] T057 SQLite database initialization and migrations in app/lib/services/database/database_helper.dart
- [X] T058 PostgreSQL connection and pooling in api/src/database/connection.js
- [X] T059 Database seeding for development in api/src/database/seeds/
- [X] T060 Transaction support for data integrity in app/lib/services/database/transaction_manager.dart

### Middleware and Security
- [X] T061 Device-based authentication middleware in api/src/middleware/auth.js
- [X] T062 Request validation middleware in api/src/middleware/validation.js
- [X] T063 Error handling middleware in api/src/middleware/error_handler.js
- [X] T064 File upload middleware with size limits in api/src/middleware/upload.js
- [X] T065 CORS and security headers in api/src/middleware/security.js

### Background Processing
- [X] T066 Background sync queue implementation in app/lib/services/background/sync_queue.dart
- [X] T067 Conflict resolution logic (merge-all) in api/src/services/conflict_resolver.js
- [X] T068 Photo hash verification service in app/lib/services/integrity/hash_service.dart
- [X] T069 GPS boundary detection algorithm in app/lib/services/location/boundary_detector.dart

## Phase 3.5: Polish

### Performance Tests
- [X] T070 [P] Photo capture speed test (<2s) in app/test/performance/photo_capture_speed_test.dart
- [X] T071 [P] Navigation speed test (<500ms) in app/test/performance/navigation_speed_test.dart
- [X] T072 [P] Search performance test (<1s) in app/test/performance/search_speed_test.dart
- [X] T073 [P] Battery usage test (<5%/hour) in app/test/performance/battery_usage_test.dart
- [X] T074 [P] Sync performance test (>99.5% success) in app/test/performance/sync_reliability_test.dart

### Unit Tests
- [X] T075 [P] Unit tests for Photo model validation in app/test/unit_test/models/photo_test.dart
- [X] T076 [P] Unit tests for hierarchy navigation in app/test/unit_test/services/navigation_test.dart
- [X] T077 [P] Unit tests for GPS boundary calculations in app/test/unit_test/services/boundary_test.dart
- [X] T078 [P] Unit tests for sync package queue in app/test/unit_test/services/sync_queue_test.dart
- [X] T079 [P] Unit tests for conflict resolution in api/tests/unit/conflict_resolver.test.js

### Documentation and Cleanup
- [X] T080 [P] API documentation generation in api/docs/openapi.yaml
- [X] T081 [P] Flutter widget documentation in app/lib/widgets/README.md
- [X] T082 Remove code duplication across services
- [X] T083 Optimize database indexes for performance
- [X] T084 Run complete quickstart validation from quickstart.md

## Dependencies
- Setup tasks (T001-T007) must complete first
- All test tasks (T008-T019) before any implementation (T020-T069)
- Data models (T020-T035) before services that use them
- Core services (T036-T042) before UI screens
- API endpoints (T043-T049) require models (T029-T035)
- Database integration (T057-T060) before background processing
- All implementation before performance tests (T070-T074)
- Performance tests before final polish (T080-T084)

## Parallel Execution Examples

### Initial Test Writing (All can run simultaneously)
```
# Launch T008-T019 together (all test files are independent):
Task: "Contract test POST /sync/changes in api/tests/contract/test_sync_changes_post.js"
Task: "Contract test GET /sync/changes/{since} in api/tests/contract/test_sync_changes_get.js"
Task: "Contract test POST /photos in api/tests/contract/test_photos_post.js"
Task: "Contract test GET /photos/{photoId} in api/tests/contract/test_photos_get.js"
Task: "Integration test offline photo capture in app/test/integration_test/offline_capture_test.dart"
Task: "Integration test hierarchical organization in app/test/integration_test/hierarchy_organization_test.dart"
Task: "Integration test sync conflict resolution in app/test/integration_test/sync_conflict_test.dart"
```

### Model Creation (All independent files)
```
# Launch T020-T028 together for Flutter models:
Task: "Photo model with validation in app/lib/models/photo.dart"
Task: "Client model with GPS boundaries in app/lib/models/client.dart"
Task: "Site model with hierarchy support in app/lib/models/site.dart"
Task: "Equipment model with tags in app/lib/models/equipment.dart"
```

### Service Implementation (All independent)
```
# Launch T036-T042 together for core services:
Task: "Camera service with metadata extraction in app/lib/services/camera_service.dart"
Task: "Storage service for SQLite operations in app/lib/services/storage_service.dart"
Task: "GPS service with location tracking in app/lib/services/gps_service.dart"
Task: "Sync service for background sync in app/lib/services/sync_service.dart"
```

## Notes
- [P] tasks = different files, no shared dependencies
- Sequential tasks (T043-T044, T045-T046, T048-T049) modify same file
- Verify all tests fail before implementing features
- Commit after each completed task
- Follow constitutional principles throughout

## Validation Checklist
*GATE: All must pass before execution*

- [x] All API endpoints from contracts have tests (T008-T014)
- [x] All entities from data-model have model tasks (T020-T035)
- [x] All user stories have integration tests (T015-T019)
- [x] All tests come before implementation (Phase 3.2 before 3.3)
- [x] Parallel tasks are truly independent (different files)
- [x] Each task specifies exact file path
- [x] No [P] task modifies same file as another [P] task
- [x] Performance requirements have validation tests (T070-T074)
- [x] All quickstart scenarios covered (T015-T019 match quickstart.md)

## Estimated Completion
- Total Tasks: 84
- Parallel Execution Opportunities: ~60% of tasks
- Sequential Requirements: API endpoint pairs, database operations
- Critical Path: Setup → Tests → Models → Services → Integration → Polish

This task list ensures complete implementation of FieldPhoto Pro with constitutional compliance, TDD methodology, and efficient parallel execution where possible.