# ✅ What Automatically Syncs

## Currently Auto-Queuing for Sync

### 1. ✅ **Clients (Companies)**
**When:** You create a new client in home screen
**Location:** `lib/screens/home/home_screen.dart:429-434`
**Example:**
```dart
// Create client "Acme Corp"
await db.insert('clients', client.toMap());

// ✅ Automatically queued for sync
await syncState.queueForSync(
  entityType: 'client',
  entityId: client.id,
  operation: 'create',
  payload: client.toMap(),
);
```
**Result:** Client creation queued immediately. Sync button shows badge "1"

---

### 2. ✅ **Photos**
**When:** You take photos and save them
**Location:** `lib/services/photo_save_service.dart:430-438, 493-500`
**Example:**
```dart
// Save photo to equipment
await db.insert('photos', photoData);

// ✅ Automatically queued for sync
await _syncState.queueForSync(
  entityType: 'photo',
  operation: 'create',
  payload: photoData,
);
```
**Result:** Every photo queued for sync with server. Photos upload to Serverpod storage.

---

## Not Yet Auto-Queuing (Manual Implementation Needed)

### ⚠️ **Sites (Main Sites & Sub Sites)**
**Current State:** Created directly via database inserts
**What's Needed:** Add sync queue calls after site creation
**Where to Add:** Site creation screens/services

**How it should work:**
```dart
// Create main site
await db.insert('main_sites', site.toMap());

// ❌ Missing: Queue for sync
await syncState.queueForSync(
  entityType: 'mainSite',
  entityId: site.id,
  operation: 'create',
  payload: site.toMap(),
);
```

---

### ⚠️ **Equipment**
**Current State:** Created directly via database inserts
**What's Needed:** Add sync queue calls after equipment creation
**Where to Add:** Equipment creation screens/services

**How it should work:**
```dart
// Create equipment
await db.insert('equipment', equipment.toMap());

// ❌ Missing: Queue for sync
await syncState.queueForSync(
  entityType: 'equipment',
  entityId: equipment.id,
  operation: 'create',
  payload: equipment.toMap(),
);
```

---

### ⚠️ **Folders**
**Current State:** Created via folder service
**What's Needed:** Add sync queue calls in folder service
**Where to Add:** `lib/services/folder_service.dart`

---

### ⚠️ **Updates & Deletes**
**Current State:** Update/delete operations don't queue for sync
**What's Needed:** Add sync queue calls after all update/delete operations

**Pattern for Updates:**
```dart
await db.update('clients', data, where: 'id = ?', whereArgs: [id]);

await syncState.queueForSync(
  entityType: 'client',
  entityId: id,
  operation: 'update',  // ← Note: 'update' not 'create'
  payload: data,
);
```

**Pattern for Deletes:**
```dart
await db.delete('clients', where: 'id = ?', whereArgs: [id]);

await syncState.queueForSync(
  entityType: 'client',
  entityId: id,
  operation: 'delete',  // ← Note: 'delete'
  payload: {'id': id},
);
```

---

## Test Scenario

### ✅ What Works Now:

**Test 1: Create Client**
1. Open app
2. Create new client "Test Company"
3. ✅ Sync button shows badge "1"
4. Tap sync button
5. ✅ Badge disappears
6. ✅ Check Serverpod database: company exists!

**Test 2: Take Photos**
1. Navigate to equipment
2. Take 3 photos
3. Save them
4. ✅ Sync button shows badge "3"
5. Tap sync
6. ✅ Photos upload to Serverpod storage
7. ✅ Files appear in `sitepictures_server_server/files/photos/`

---

### ⚠️ What Doesn't Work Yet:

**Test 3: Create Site** (Not auto-queuing)
1. Create new main site
2. ❌ Sync button stays at "0"
3. Site saved locally but NOT queued
4. Sync won't upload it

**Test 4: Create Equipment** (Not auto-queuing)
1. Create new equipment
2. ❌ Sync button stays at "0"
3. Equipment saved locally but NOT queued
4. Sync won't upload it

**Test 5: Edit Client** (Not auto-queuing)
1. Edit existing client name
2. ❌ Sync button stays at "0"
3. Change saved locally but NOT queued
4. Server won't know about the update

---

## Summary

### ✅ Currently Syncing Automatically:
- **Clients** - Create operations
- **Photos** - Create operations

### ⚠️ Needs Implementation:
- **Sites** - All operations (create/update/delete)
- **Equipment** - All operations (create/update/delete)
- **Folders** - All operations (create/update/delete)
- **All Entities** - Update operations
- **All Entities** - Delete operations

---

## Quick Implementation Guide

To add sync queueing to any operation:

### Step 1: Import SyncState
```dart
import '../../providers/sync_state.dart';
```

### Step 2: Get SyncState Instance
```dart
final syncState = context.read<SyncState>();
// or inject via constructor for services
```

### Step 3: Queue After Database Operation
```dart
// After db.insert, db.update, or db.delete
await syncState.queueForSync(
  entityType: 'client',  // or 'mainSite', 'equipment', 'photo', etc.
  entityId: item.id,
  operation: 'create',    // or 'update', 'delete'
  payload: item.toMap(),
);
```

### Step 4: Test
1. Perform the operation
2. Check sync button badge increases
3. Tap sync
4. Verify data appears on server

---

## Architecture

```
┌────────────────────────────────────────┐
│  User Action (Create/Update/Delete)   │
└──────────────┬─────────────────────────┘
               ↓
┌────────────────────────────────────────┐
│  Save to Local SQLite                  │
│  • db.insert() / update() / delete()   │
└──────────────┬─────────────────────────┘
               ↓
┌────────────────────────────────────────┐
│  Queue for Sync                        │
│  • syncState.queueForSync()            │
│  • Adds to sync_queue table            │
└──────────────┬─────────────────────────┘
               ↓
┌────────────────────────────────────────┐
│  Sync Button Updates                   │
│  • Badge shows pending count           │
│  • ☁️ [5] ← 5 items waiting            │
└──────────────┬─────────────────────────┘
               ↓
┌────────────────────────────────────────┐
│  User Taps Sync (or auto sync)        │
└──────────────┬─────────────────────────┘
               ↓
┌────────────────────────────────────────┐
│  ServerpodSyncService.performSync()    │
│  • Pulls server changes                │
│  • Pushes queued changes               │
│  • Resolves conflicts                  │
└──────────────┬─────────────────────────┘
               ↓
┌────────────────────────────────────────┐
│  Data Synced! ✅                        │
│  • Local & server match                │
│  • Badge disappears                    │
└────────────────────────────────────────┘
```

---

## Current Status: **Partially Complete** (40%)

✅ Infrastructure: 100% (sync service, UI, server endpoints)
✅ Auto-queue: 40% (clients + photos only)
⚠️ Remaining: 60% (sites, equipment, folders, updates, deletes)

**Ready to use for:** Client and photo operations
**Needs work for:** Everything else

---

## Next Steps

1. **Find all CRUD operations** in codebase
2. **Add queueForSync calls** after each database operation
3. **Test each entity type** to verify sync works
4. **Add update/delete sync** for all entities
5. **Complete coverage** to 100%

Then full bidirectional sync will work for all data! 🚀
