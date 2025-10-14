# Quickstart: Context-Aware Camera and Expandable FABs

**Feature**: 005-i-want-to | **Date**: 2025-10-11
**Purpose**: Quick reference guide for implementing and testing context-aware UI components

## Table of Contents
1. [Adding Expandable FAB to Screen](#adding-expandable-fab-to-screen)
2. [Launching Camera with Context](#launching-camera-with-context)
3. [Testing Context-Aware Flows](#testing-context-aware-flows)
4. [Troubleshooting](#troubleshooting)

---

## Adding Expandable FAB to Screen

### Step 1: Import Dependencies

```dart
import 'package:flutter/material.dart';
import '../widgets/expandable_fab.dart';
import '../models/fab_menu_item.dart';
```

### Step 2: Add FAB to Scaffold

```dart
class YourScreen extends StatefulWidget {
  // ... existing code ...
}

class _YourScreenState extends State<YourScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Screen')),
      body: YourBodyWidget(),
      floatingActionButton: _buildFAB(), // Add this
    );
  }

  Widget _buildFAB() {
    // Check permissions
    final authState = context.watch<AuthState>();
    if (authState.currentUser?.role == UserRole.viewer) {
      return const SizedBox.shrink(); // No FAB for viewers
    }

    // Return expandable FAB with menu items
    return ExpandableFAB(
      heroTag: 'your_screen_fab_${widget.yourId}', // Must be unique!
      menuItems: _getFABMenuItems(),
    );
  }

  List<FABMenuItem> _getFABMenuItems() {
    // Define your menu items
    return [
      FABMenuItem(
        label: 'Action 1',
        icon: Icons.add,
        onTap: _handleAction1,
      ),
      FABMenuItem(
        label: 'Action 2',
        icon: Icons.edit,
        onTap: _handleAction2,
      ),
    ];
  }

  void _handleAction1() {
    // Your action logic
  }

  void _handleAction2() {
    // Your action logic
  }
}
```

### Step 3: Test FAB Behavior

1. Run app and navigate to your screen
2. Tap FAB → verify menu items appear
3. Tap outside FAB → verify menu collapses
4. Tap menu item → verify action executes and FAB collapses
5. Navigate away → verify FAB state resets

---

## Launching Camera with Context

### Home Context (Quick Capture)

```dart
void _openQuickCapture() {
  context.push('/camera-capture', extra: {
    'context': 'home',
  });
}
```

**Expected Result**: Camera shows modal with "Next" and "Quick Save" buttons

---

### Equipment All Photos Context

```dart
void _openEquipmentCapture() {
  context.push('/camera-capture', extra: {
    'context': 'equipment-all-photos',
    'equipmentId': widget.equipmentId,
  });
}
```

**Expected Result**: Camera shows "Save to Equipment" button (mock functionality)

---

### Equipment Before/After Context

```dart
void _captureBeforePhoto() {
  context.push('/camera-capture', extra: {
    'context': 'equipment-before',
    'folderId': widget.folderId,
    'beforeAfter': 'before',
  });
}

void _captureAfterPhoto() {
  context.push('/camera-capture', extra: {
    'context': 'equipment-after',
    'folderId': widget.folderId,
    'beforeAfter': 'after',
  });
}
```

**Expected Result**: Camera shows "Capture as Before" or "Capture as After" button (mock functionality)

---

### Invalid Context Handling

```dart
void _testInvalidContext() {
  context.push('/camera-capture', extra: {
    'context': 'invalid-context-type',
    // Missing required params
  });
}
```

**Expected Result**: Camera defaults to home context with "Next" and "Quick Save" buttons

---

## Testing Context-Aware Flows

### Manual Testing Checklist

#### Expandable FAB Tests

- [ ] **Client Page FAB**:
  - [ ] FAB displays for admin/technician roles
  - [ ] FAB hidden for viewer role
  - [ ] Tap FAB → 3 menu items appear (Main Site, SubSite, Equipment)
  - [ ] Tap "Add Main Site" → dialog appears, FAB collapses
  - [ ] Tap "Add SubSite" → dialog appears, FAB collapses
  - [ ] Tap "Add Equipment" → dialog appears, FAB collapses
  - [ ] Tap outside expanded FAB → FAB collapses
  - [ ] Navigate away during expansion → FAB state resets on return

- [ ] **Main Site Page FAB**:
  - [ ] FAB displays for admin/technician roles
  - [ ] Tap FAB → 2 menu items appear (SubSite, Equipment)
  - [ ] Each menu item opens correct dialog and collapses FAB
  - [ ] Tap outside → FAB collapses

- [ ] **SubSite Page FAB**:
  - [ ] Simple "+" FAB displays (no expansion)
  - [ ] Tap FAB → equipment creation dialog opens directly

#### Camera Context Tests

- [ ] **Home Context**:
  - [ ] Launch camera from home screen
  - [ ] Capture photos
  - [ ] Tap Done → modal with "Next" and "Quick Save"
  - [ ] Tap "Next" → existing behavior executes
  - [ ] Tap "Quick Save" → existing behavior executes

- [ ] **Equipment All Photos Context**:
  - [ ] Navigate to equipment All Photos tab
  - [ ] Tap camera FAB
  - [ ] Capture photos
  - [ ] Tap Done → "Save to Equipment" button appears
  - [ ] Tap "Save to Equipment" → SnackBar shows "coming soon", returns to equipment

- [ ] **Equipment Before Context**:
  - [ ] Navigate to equipment Folders tab
  - [ ] Open a folder
  - [ ] Tap "Capture Before" button
  - [ ] Capture photos
  - [ ] Tap Done → "Capture as Before" button appears
  - [ ] Tap button → SnackBar shows "coming soon", returns to folder

- [ ] **Equipment After Context**:
  - [ ] Navigate to equipment Folders tab
  - [ ] Open a folder
  - [ ] Tap "Capture After" button
  - [ ] Capture photos
  - [ ] Tap Done → "Capture as After" button appears
  - [ ] Tap button → SnackBar shows "coming soon", returns to folder

- [ ] **Invalid Context**:
  - [ ] Launch camera with missing params
  - [ ] Verify defaults to home context
  - [ ] Verify "Next" and "Quick Save" buttons appear

#### Performance Tests

- [ ] **FAB Expansion Animation**:
  - [ ] Expansion completes smoothly (< 300ms)
  - [ ] No frame drops during animation
  - [ ] Stagger effect visible on menu items

- [ ] **Camera Context Detection**:
  - [ ] Context detection is instant (no delay)
  - [ ] Correct buttons display immediately on Done tap

### Automated Testing

#### Widget Tests

```bash
# Run all widget tests
flutter test test/widget/

# Run specific widget tests
flutter test test/widget/expandable_fab_test.dart
flutter test test/widget/context_save_buttons_test.dart
```

#### Unit Tests

```bash
# Run all unit tests
flutter test test/unit/

# Run camera context tests
flutter test test/unit/models/camera_context_test.dart
```

#### Integration Tests

```bash
# Run camera context flow tests
flutter test integration_test/camera_context_flow_test.dart
```

---

## Troubleshooting

### FAB Issues

**Problem**: FAB doesn't expand when tapped

**Solutions**:
- Check hero tag is unique (no duplicates on screen)
- Verify menuItems list is not empty
- Check console for error messages
- Ensure StatefulWidget state is properly initialized

---

**Problem**: FAB expansion is janky/slow

**Solutions**:
- Check animation duration is 250ms (not too high)
- Use `RepaintBoundary` around FAB
- Test on physical device (simulator may be slow)
- Check for heavy operations in onTap callbacks

---

**Problem**: Menu items overflow screen

**Solutions**:
- Reduce number of menu items (max 3 recommended)
- Test on smallest supported screen (iPhone SE)
- Ensure menuItems list is not too long

---

### Camera Context Issues

**Problem**: Wrong buttons appear in camera

**Solutions**:
- Verify extra map keys are correct ('context', 'equipmentId', etc.)
- Check context string values match enum ('home', 'equipment-all-photos', etc.)
- Add debug print in CameraContext.fromMap() to inspect params
- Verify equipment/folder IDs are valid (non-null, non-empty)

---

**Problem**: Camera defaults to home context unexpectedly

**Solutions**:
- Check required params are provided (equipmentId for equipment context, folderId for before/after)
- Verify param types are correct (all strings)
- Check for null values in extra map
- Add logging to see what context is being created

---

**Problem**: Mock save buttons don't show SnackBar

**Solutions**:
- Verify ScaffoldMessenger.of(context) has access to Scaffold
- Check SnackBar isn't being dismissed immediately
- Ensure Navigator.pop() happens after SnackBar shows
- Increase SnackBar duration if needed

---

### Permission Issues

**Problem**: FAB appears for viewer role

**Solutions**:
- Check AuthState is properly provided in widget tree
- Verify role check logic: `currentUser?.role != UserRole.viewer`
- Ensure permission state updates trigger widget rebuild
- Check if watching AuthState: `context.watch<AuthState>()`

---

## Quick Reference

### FAB Menu Items by Screen

| Screen | Menu Items | Notes |
|--------|-----------|-------|
| Client | Main Site, SubSite, Equipment | 3-option expandable FAB |
| Main Site | SubSite, Equipment | 2-option expandable FAB |
| SubSite | (none) | Simple FAB, direct action |

### Camera Context Types

| Context | Extra Params | Save Buttons |
|---------|--------------|--------------|
| `home` | (none) | Modal: "Next", "Quick Save" |
| `equipment-all-photos` | equipmentId | Single: "Save to Equipment" |
| `equipment-before` | folderId, beforeAfter='before' | Single: "Capture as Before" |
| `equipment-after` | folderId, beforeAfter='after' | Single: "Capture as After" |

### Animation Targets

| Component | Target | Actual |
|-----------|--------|--------|
| FAB Expansion | < 300ms | 250ms + stagger |
| Context Detection | Instant | Synchronous (< 1ms) |
| Button Rendering | No delay | Synchronous build |

---

## Code Snippets

### Get Current Camera Context

```dart
final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;
final cameraContext = CameraContext.fromMap(extra ?? {});

print('Camera launched with context: ${cameraContext.type}');
```

### Customize FAB Colors

```dart
FABMenuItem(
  label: 'Add Main Site',
  icon: Icons.location_city,
  backgroundColor: Colors.blue,
  onTap: _showAddMainSiteDialog,
)
```

### Handle FAB Expansion Callback

```dart
ExpandableFAB(
  menuItems: _menuItems,
  onExpansionChanged: (expanded) {
    if (expanded) {
      print('FAB expanded');
    } else {
      print('FAB collapsed');
    }
  },
)
```

---

## Next Steps

After implementing context-aware UI:

1. **Run manual tests** using the checklist above
2. **Write automated tests** for your specific screens
3. **Monitor performance** using Flutter DevTools
4. **Gather user feedback** on button labeling and FAB usability
5. **Prepare for Phase 2** (actual save functionality implementation)

---

## Related Documentation

- [Feature Specification](./spec.md)
- [Implementation Plan](./plan.md)
- [Research Decisions](./research.md)
- [Data Model](./data-model.md)
- [Camera Context Contract](./contracts/camera-context.md)
- [FAB Expansion Contract](./contracts/fab-expansion.md)
