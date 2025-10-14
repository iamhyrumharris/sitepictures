# Data Model: Context-Aware Camera and Expandable FABs

**Feature**: 005-i-want-to | **Date**: 2025-10-11
**Purpose**: Define data structures and models for context-aware UI components

## Core Models

### 1. CameraContext

**Purpose**: Encapsulates camera launch context for determining save button display

**File**: `lib/models/camera_context.dart`

```dart
enum CameraContextType {
  home,                  // Launched from home screen
  equipmentAllPhotos,    // Launched from equipment "All Photos" tab
  equipmentBefore,       // Launched from folder "Capture Before" button
  equipmentAfter,        // Launched from folder "Capture After" button
}

class CameraContext {
  final CameraContextType type;
  final String? equipmentId;   // For equipment contexts
  final String? folderId;      // For before/after contexts
  final String? beforeAfter;   // 'before' or 'after' for folder contexts

  const CameraContext({
    required this.type,
    this.equipmentId,
    this.folderId,
    this.beforeAfter,
  });

  /// Factory: Create from navigation extra map
  factory CameraContext.fromMap(Map<String, dynamic> map) {
    final contextStr = map['context'] as String?;
    final equipmentId = map['equipmentId'] as String?;
    final folderId = map['folderId'] as String?;
    final beforeAfter = map['beforeAfter'] as String?;

    // Determine type based on context string
    if (contextStr == 'equipment-all-photos' && equipmentId != null) {
      return CameraContext(
        type: CameraContextType.equipmentAllPhotos,
        equipmentId: equipmentId,
      );
    } else if (contextStr == 'equipment-before' && folderId != null) {
      return CameraContext(
        type: CameraContextType.equipmentBefore,
        folderId: folderId,
        beforeAfter: 'before',
      );
    } else if (contextStr == 'equipment-after' && folderId != null) {
      return CameraContext(
        type: CameraContextType.equipmentAfter,
        folderId: folderId,
        beforeAfter: 'after',
      );
    }

    // Default to home context
    return const CameraContext(type: CameraContextType.home);
  }

  /// Convert to map for navigation
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    switch (type) {
      case CameraContextType.home:
        map['context'] = 'home';
        break;
      case CameraContextType.equipmentAllPhotos:
        map['context'] = 'equipment-all-photos';
        map['equipmentId'] = equipmentId;
        break;
      case CameraContextType.equipmentBefore:
        map['context'] = 'equipment-before';
        map['folderId'] = folderId;
        map['beforeAfter'] = 'before';
        break;
      case CameraContextType.equipmentAfter:
        map['context'] = 'equipment-after';
        map['folderId'] = folderId;
        map['beforeAfter'] = 'after';
        break;
    }

    return map;
  }

  /// Validation
  bool isValid() {
    switch (type) {
      case CameraContextType.home:
        return true;
      case CameraContextType.equipmentAllPhotos:
        return equipmentId != null && equipmentId!.isNotEmpty;
      case CameraContextType.equipmentBefore:
      case CameraContextType.equipmentAfter:
        return folderId != null && folderId!.isNotEmpty;
    }
  }
}
```

**Validation Rules**:
- Home context: Always valid (no params required)
- Equipment all photos: Requires valid equipmentId
- Equipment before/after: Requires valid folderId
- Invalid params → defaults to home context (FR-027)

**State Transitions**:
- User navigates from screen → Context created with params
- Context passed via go_router extra
- Camera page receives context → Validates → Defaults to home if invalid
- Context determines button rendering → No state mutation

---

### 2. FABMenuItem

**Purpose**: Represents a single menu item in expandable FAB

**File**: `lib/models/fab_menu_item.dart`

```dart
class FABMenuItem {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final String? heroTag;  // For unique FAB identification

  const FABMenuItem({
    required this.label,
    required this.icon,
    required this.onTap,
    this.backgroundColor,
    this.heroTag,
  });
}
```

**Usage Examples**:
```dart
// Client page (3 items)
final clientFABItems = [
  FABMenuItem(
    label: 'Add Main Site',
    icon: Icons.location_city,
    onTap: () => _showAddMainSiteDialog(),
  ),
  FABMenuItem(
    label: 'Add SubSite',
    icon: Icons.folder,
    onTap: () => _showAddSubSiteDialog(),
  ),
  FABMenuItem(
    label: 'Add Equipment',
    icon: Icons.precision_manufacturing,
    onTap: () => _showAddEquipmentDialog(),
  ),
];

// Main site page (2 items)
final mainSiteFABItems = [
  FABMenuItem(
    label: 'Add SubSite',
    icon: Icons.folder,
    onTap: () => _showAddSubSiteDialog(),
  ),
  FABMenuItem(
    label: 'Add Equipment',
    icon: Icons.precision_manufacturing,
    onTap: () => _showAddEquipmentDialog(),
  ),
];
```

---

### 3. FABExpansionState (Internal to ExpandableFAB)

**Purpose**: Track FAB expansion animation state

**File**: `lib/widgets/expandable_fab.dart` (not a separate model file)

```dart
enum FABExpansionState {
  collapsed,   // FAB shows + icon only
  expanding,   // Animation in progress (expanding)
  expanded,    // Menu items visible
  collapsing,  // Animation in progress (collapsing)
}
```

**State Machine**:
```
collapsed → (tap FAB) → expanding → expanded
expanded → (tap outside/item) → collapsing → collapsed
expanded → (navigate away) → collapsed (immediate)
```

**Implementation Note**: This is internal state managed by ExpandableFAB widget's AnimationController, not exposed to parent widgets.

---

### 4. SaveActionButton

**Purpose**: Configuration for camera save action buttons

**File**: `lib/models/save_action_button.dart`

```dart
class SaveActionButton {
  final String label;
  final VoidCallback onTap;
  final bool enabled;
  final Color? backgroundColor;

  const SaveActionButton({
    required this.label,
    required this.onTap,
    this.enabled = true,
    this.backgroundColor,
  });
}
```

**Button Configurations by Context**:

```dart
// Home context (modal with 2 buttons)
final homeButtons = [
  SaveActionButton(
    label: 'Next',
    onTap: () => _handleNext(context),
    backgroundColor: Colors.blue,
  ),
  SaveActionButton(
    label: 'Quick Save',
    onTap: () => _handleQuickSave(context),
    backgroundColor: Colors.green,
  ),
];

// Equipment all photos context (single button)
final equipmentButton = SaveActionButton(
  label: 'Save to Equipment',
  onTap: () => _handleEquipmentSave(context),
  backgroundColor: Colors.blue,
);

// Equipment before context (single button)
final beforeButton = SaveActionButton(
  label: 'Capture as Before',
  onTap: () => _handleBeforeSave(context),
  backgroundColor: Colors.orange,
);

// Equipment after context (single button)
final afterButton = SaveActionButton(
  label: 'Capture as After',
  onTap: () => _handleAfterSave(context),
  backgroundColor: Colors.green,
);
```

---

## Relationships

```
CameraContext (1) ──determines──> SaveActionButton (1..2)
   ↓
   └─ type: CameraContextType
      ├─ home          → 2 buttons (Next, Quick Save)
      ├─ equipmentAll  → 1 button (Save to Equipment)
      ├─ equipBefore   → 1 button (Capture as Before)
      └─ equipAfter    → 1 button (Capture as After)

FABMenuItem (0..3) ──compose──> ExpandableFAB
   ↑
   └─ Number determined by screen:
      ├─ Client page    → 3 items
      ├─ Main site page → 2 items
      └─ SubSite page   → 0 items (simple FAB, no expansion)
```

---

## Validation Rules

### CameraContext Validation
1. **Home context**: No validation needed (always valid)
2. **Equipment all photos**:
   - equipmentId must be non-null and non-empty
   - If invalid → default to home context
3. **Equipment before/after**:
   - folderId must be non-null and non-empty
   - beforeAfter must be 'before' or 'after'
   - If invalid → default to home context

### FABMenuItem Validation
1. **Label**: Must be non-empty string
2. **Icon**: Must be valid IconData
3. **onTap**: Must be non-null callback
4. **heroTag**: If provided, must be unique across FABs on same screen

### SaveActionButton Validation
1. **Label**: Must be non-empty string
2. **onTap**: Must be non-null callback
3. **enabled**: Defaults to true if not specified

---

## Immutability & State Management

### Immutable Models
All models are **immutable** (const constructors where possible):
- `CameraContext`: Immutable, created once from navigation params
- `FABMenuItem`: Immutable, defined statically per screen
- `SaveActionButton`: Immutable, derived from camera context

### Mutable State
Only **UI state** is mutable (managed by StatefulWidget):
- FAB expansion state (bool in screen state)
- Animation controllers (in ExpandableFAB widget)

### No Persistence
All models are **ephemeral** (not persisted to database):
- Camera context: Lives only during navigation
- FAB state: Resets on screen navigation
- Save buttons: Derived on-demand from context

---

## Error Handling

### Invalid Context Recovery
```dart
// In CameraCapturePage
final context = CameraContext.fromMap(extra ?? {});
if (!context.isValid()) {
  // Log warning but don't fail
  debugPrint('Warning: Invalid camera context, defaulting to home');
  final defaultContext = CameraContext(type: CameraContextType.home);
}
```

### Missing Navigation Params
```dart
// In go_router route builder
builder: (context, state) {
  final extra = state.extra as Map<String, dynamic>?;

  // Handle null extra gracefully
  return ChangeNotifierProvider(
    create: (_) => PhotoCaptureProvider(),
    child: CameraCapturePage(
      context: CameraContext.fromMap(extra ?? {}), // Defaults to home
    ),
  );
}
```

### FAB Menu Item Errors
```dart
// In ExpandableFAB widget
void _handleItemTap(FABMenuItem item) {
  try {
    item.onTap();
    setState(() => _isExpanded = false); // Collapse after tap
  } catch (e) {
    debugPrint('Error in FAB menu item tap: $e');
    // Don't crash - just log and collapse FAB
    setState(() => _isExpanded = false);
  }
}
```

---

## Testing Considerations

### Unit Tests
- **CameraContext.fromMap()**: Test all 4 context types + invalid inputs
- **CameraContext.isValid()**: Test validation logic for each type
- **FABMenuItem**: Test immutability and equality

### Widget Tests
- **ContextAwareSaveButtons**: Test button rendering for each context type
- **ExpandableFAB**: Test expansion/collapse with different item counts

### Integration Tests
- **Context flow**: Equipment → Camera (verify context preserved)
- **Invalid context**: Pass bad params → verify defaults to home
- **FAB workflow**: Tap expand → tap item → verify dialog + collapse

---

## Migration Notes

### Existing Code Changes Required

**PhotoCaptureProvider** (lib/providers/photo_capture_provider.dart):
```dart
class PhotoCaptureProvider extends ChangeNotifier {
  // ADD: Camera context field
  CameraContext? _cameraContext;

  // ADD: Setter for context (called from CameraCapturePage)
  void setCameraContext(CameraContext context) {
    _cameraContext = context;
    notifyListeners();
  }

  // ADD: Getter for save button config
  List<SaveActionButton> getSaveButtons(BuildContext context) {
    // Return buttons based on _cameraContext.type
  }
}
```

**Router** (lib/router.dart):
```dart
GoRoute(
  path: '/camera-capture',
  name: 'cameraCapture',
  builder: (context, state) {
    final extra = state.extra as Map<String, dynamic>?;
    final cameraContext = CameraContext.fromMap(extra ?? {});

    return ChangeNotifierProvider(
      create: (_) => PhotoCaptureProvider(),
      child: CameraCapturePage(
        cameraContext: cameraContext,  // PASS context to page
      ),
    );
  },
),
```

### No Database Changes
- No new tables or columns required
- All data structures are in-memory only
- Organizational item creation uses existing database schema

---

## Performance Characteristics

### Memory
- `CameraContext`: ~100 bytes (4 enums + 3 nullable strings)
- `FABMenuItem`: ~50 bytes per item × 3 max = 150 bytes
- `SaveActionButton`: ~40 bytes × 2 max = 80 bytes
- **Total per screen**: < 500 bytes (negligible)

### Computation
- Context creation: O(1) - simple map lookup
- Button configuration: O(1) - switch statement
- FAB expansion: O(n) where n = menu items (max 3)
- **All operations**: Constant time for practical purposes

### No I/O Operations
- No file system access
- No database queries (context determines UI only)
- No network calls
- **Pure in-memory state management**

---

## Next Steps

1. Implement model files:
   - `lib/models/camera_context.dart`
   - `lib/models/fab_menu_item.dart`
   - `lib/models/save_action_button.dart`

2. Write unit tests:
   - `test/unit/models/camera_context_test.dart`
   - Validate all factories, validation logic, edge cases

3. Create widget implementations using these models:
   - `lib/widgets/expandable_fab.dart`
   - `lib/widgets/context_aware_save_buttons.dart`
