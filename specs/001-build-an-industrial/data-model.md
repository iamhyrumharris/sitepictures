# Data Model: FieldPhoto Pro

## Core Entities

### Photo
Primary documentation unit for all captured images.
```dart
class Photo {
  String id;                    // UUID primary key
  String equipmentId;           // Foreign key to Equipment
  String? revisionId;           // Optional revision grouping
  String fileName;              // Local file system path
  String fileHash;              // SHA-256 for integrity verification
  double? latitude;             // GPS coordinate (nullable)
  double? longitude;            // GPS coordinate (nullable)
  DateTime capturedAt;          // Capture timestamp
  String? notes;                // User annotations
  String deviceId;              // Device identifier for attribution
  DateTime createdAt;           // Record creation timestamp
  DateTime updatedAt;           // Last modification timestamp
  bool isSynced;               // Sync status flag
}
```

**Validation Rules**:
- id: Must be valid UUID format
- fileName: Must be unique within device storage
- fileHash: Required for data integrity verification
- capturedAt: Cannot be future date
- deviceId: Required for attribution (from clarifications)

**State Transitions**:
- Created → Captured → Annotated → Synced
- Local-only → Sync-queued → Synced → Conflict-resolved

### Client
Top-level organization representing companies/facilities being serviced.
```dart
class Client {
  String id;                    // UUID primary key
  String companyId;             // Foreign key to Company
  String name;                  // Client display name
  String? description;          // Optional client details
  List<GPSBoundary> boundaries; // Geographic boundaries
  DateTime createdAt;           // Record creation timestamp
  DateTime updatedAt;           // Last modification timestamp
  bool isActive;               // Soft delete flag
}
```

**Validation Rules**:
- name: Required, 1-100 characters
- companyId: Must reference valid Company
- boundaries: Can have multiple non-overlapping boundaries

### Site
Location entity supporting Main Site → Sub Site hierarchy.
```dart
class Site {
  String id;                    // UUID primary key
  String clientId;              // Foreign key to Client
  String? parentSiteId;         // Self-reference for hierarchy (null = main site)
  String name;                  // Site display name
  String? address;              // Physical address
  double? centerLatitude;       // Site center GPS
  double? centerLongitude;      // Site center GPS
  double? boundaryRadius;       // Meters from center
  DateTime createdAt;           // Record creation timestamp
  DateTime updatedAt;           // Last modification timestamp
  bool isActive;               // Soft delete flag
}
```

**Validation Rules**:
- name: Required, 1-100 characters
- parentSiteId: Must reference valid Site within same Client
- Hierarchy depth: Maximum 2 levels (Main → Sub)

### Equipment
Specific machinery/panel being documented with photo timeline.
```dart
class Equipment {
  String id;                    // UUID primary key
  String siteId;                // Foreign key to Site
  String name;                  // Equipment display name
  String? equipmentType;        // Categorization (PLC, Panel, etc.)
  String? serialNumber;         // Manufacturer serial number
  String? model;                // Equipment model
  String? manufacturer;         // Equipment manufacturer
  List<String> tags;            // Searchable tags
  DateTime createdAt;           // Record creation timestamp
  DateTime updatedAt;           // Last modification timestamp
  bool isActive;               // Soft delete flag
}
```

**Validation Rules**:
- name: Required, 1-100 characters
- siteId: Must reference valid Site
- tags: Maximum 10 tags, each 1-30 characters

### Company
Root entity for team collaboration and data isolation.
```dart
class Company {
  String id;                    // UUID primary key
  String name;                  // Company display name
  Map<String, dynamic> settings; // JSON configuration
  DateTime createdAt;           // Record creation timestamp
  DateTime updatedAt;           // Last modification timestamp
  bool isActive;               // Soft delete flag
}
```

**Validation Rules**:
- name: Required, unique, 1-100 characters
- settings: Valid JSON object

### User (Device-Based)
Device identity for attribution without authentication (from clarifications).
```dart
class User {
  String id;                    // Device UUID
  String deviceName;            // Human-readable device name
  String? companyId;            // Optional company association
  Map<String, dynamic> preferences; // Sync and UI preferences
  DateTime firstSeen;           // First app usage
  DateTime lastSeen;            // Most recent activity
  bool isActive;               // Device status
}
```

**Validation Rules**:
- id: Device-generated UUID, immutable
- deviceName: User-editable, 1-50 characters
- No authentication required (from clarifications)

### Revision
Grouping mechanism for equipment photo timelines.
```dart
class Revision {
  String id;                    // UUID primary key
  String equipmentId;           // Foreign key to Equipment
  String name;                  // Revision display name (e.g., "2025-03-15 Upgrade")
  String? description;          // Optional revision notes
  DateTime createdAt;           // Revision timestamp
  String createdBy;             // Device ID of creator
  bool isActive;               // Soft delete flag
}
```

**Validation Rules**:
- name: Required, 1-100 characters
- equipmentId: Must reference valid Equipment
- createdBy: Must reference valid User

### GPSBoundary
Geographic boundaries for automatic photo organization.
```dart
class GPSBoundary {
  String id;                    // UUID primary key
  String? clientId;             // Optional Client association
  String? siteId;               // Optional Site association
  String name;                  // Boundary display name
  double centerLatitude;        // Boundary center GPS
  double centerLongitude;       // Boundary center GPS
  double radiusMeters;          // Circular boundary radius
  int priority;                 // Overlap resolution order
  DateTime createdAt;           // Record creation timestamp
  DateTime updatedAt;           // Last modification timestamp
  bool isActive;               // Soft delete flag
}
```

**Validation Rules**:
- centerLatitude: Valid GPS coordinate (-90 to 90)
- centerLongitude: Valid GPS coordinate (-180 to 180)
- radiusMeters: Positive number, maximum 10000 meters
- priority: Higher number = higher priority for overlaps

### SyncPackage
Offline changes awaiting synchronization.
```dart
class SyncPackage {
  String id;                    // UUID primary key
  String entityType;            // Type of entity being synced
  String entityId;              // ID of entity being synced
  String operation;             // CREATE, UPDATE, DELETE
  Map<String, dynamic> data;    // Entity data snapshot
  DateTime timestamp;           // Operation timestamp
  String deviceId;              // Originating device
  String status;                // PENDING, SYNCING, SYNCED, FAILED
  int retryCount;              // Failed sync retry counter
  DateTime? lastAttempt;        // Last sync attempt timestamp
}
```

**Validation Rules**:
- operation: Must be CREATE, UPDATE, or DELETE
- status: Must be PENDING, SYNCING, SYNCED, or FAILED
- retryCount: Non-negative integer, maximum 10

## Relationships

### Hierarchical Structure
```
Company (1) → (N) Client (1) → (N) Site (1) → (N) Equipment (1) → (N) Photo
                                ↑
                           Site (parent/child)
```

### Support Entities
```
Equipment (1) → (N) Revision (1) → (N) Photo
Client/Site (1) → (N) GPSBoundary
User (1) → (N) SyncPackage
```

## SQLite Schema Considerations

### Indexes for Performance
```sql
-- Photo search performance
CREATE INDEX idx_photo_equipment_captured ON photos(equipment_id, captured_at DESC);
CREATE INDEX idx_photo_device_timestamp ON photos(device_id, created_at DESC);
CREATE INDEX idx_photo_gps_location ON photos(latitude, longitude) WHERE latitude IS NOT NULL;

-- Hierarchy navigation
CREATE INDEX idx_site_parent ON sites(parent_site_id, name);
CREATE INDEX idx_equipment_site ON equipment(site_id, name);

-- Sync operations
CREATE INDEX idx_sync_status ON sync_packages(status, timestamp);
CREATE INDEX idx_sync_device ON sync_packages(device_id, status);
```

### Constraints
```sql
-- Referential integrity
FOREIGN KEY constraints on all relationships
UNIQUE constraints on name fields within parent scope
CHECK constraints for GPS coordinate ranges
CHECK constraints for enum-like fields (status, operation)
```

### Full-Text Search
```sql
-- Global search capability
CREATE VIRTUAL TABLE search_index USING fts5(
  entity_type,
  entity_id,
  content,
  tokenize='porter'
);
```

## Data Lifecycle

### Photo Capture Flow
1. Photo captured with metadata → Local SQLite insert
2. File saved to local storage → File hash generated
3. GPS boundaries checked → Auto-assignment to Equipment
4. SyncPackage created → Queued for upload when online

### Conflict Resolution (Merge Strategy)
Based on clarification: "Merge both versions (keep all data)"
1. Conflicting updates detected during sync
2. All versions preserved in local storage
3. UI presents merged view with attribution
4. No automatic data loss - user sees all contributions

### Data Retention
Based on clarification: "Indefinitely (never auto-delete)"
- No automatic deletion of photos or metadata
- Manual deletion requires explicit user action
- Sync system preserves all historical versions
- Local storage management through user-initiated cleanup

## Validation Summary

All entities support constitutional requirements:
- **Data Integrity**: Immutable photos, transaction-based operations, hash verification
- **Offline Autonomy**: Complete local schema with sync packages
- **Hierarchical Consistency**: Four-level structure enforced through foreign keys
- **Performance**: Optimized indexes for <1s search requirement
- **Collaborative Transparency**: Device attribution and audit timestamps
- **Field-First**: Minimal validation overhead for quick capture workflows