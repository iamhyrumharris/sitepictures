# Research: Context-Aware Camera and Expandable FABs

**Feature**: 005-i-want-to | **Date**: 2025-10-11
**Purpose**: Technical research and design decisions for context-aware UI implementation

## Research Areas

### 1. FAB Expansion Patterns

**Question**: Should we use Flutter's built-in SpeedDial pattern or custom expansion?

**Decision**: Use custom StatefulWidget with AnimationController for expandable FAB

**Rationale**:
- Flutter's `SpeedDial` pattern from material design provides standard expansion behavior
- However, we need custom control over:
  - Number of menu items (2 for main site, 3 for client)
  - Tap-outside-to-collapse behavior
  - Animation timing to meet <300ms requirement
  - Visual styling to match existing app design

**Implementation Approach**:
```dart
class ExpandableFAB extends StatefulWidget {
  final List<FABMenuItem> menuItems;
  final bool expanded;
  final VoidCallback onToggle;
  final Duration animationDuration;

  // Custom expansion logic with AnimationController
  // Stagger animations for menu items (cascade effect)
  // GestureDetector for tap-outside-to-collapse
}
```

**Alternatives Considered**:
- **SpeedDial package** (pub.dev): Rejected - adds dependency, limited customization
- **Pure AnimatedContainer**: Rejected - doesn't handle stagger animations well
- **Custom StatefulWidget**: ✅ Selected - full control, no dependencies, testable

**References**:
- Material Design Speed Dial: https://m2.material.io/components/buttons-floating-action-button#types-of-transitions
- Flutter Animation docs: https://docs.flutter.dev/ui/animations

---

### 2. Camera Context Passing

**Question**: How should context parameters be passed through go_router navigation?

**Decision**: Use `extra` parameter with typed Map for camera context

**Rationale**:
- go_router supports three ways to pass data:
  1. Path parameters: `/camera/:equipmentId` - good for required params
  2. Query parameters: `/camera?equipmentId=123` - good for optional params
  3. Extra data: `context.push('/camera', extra: {...})` - good for complex objects

- Camera context requires multiple optional params (folderId, beforeAfter, equipmentId)
- Using `extra` allows us to pass a typed map without polluting URL
- Current implementation already uses this pattern (line 199-204 in router.dart)

**Implementation Approach**:
```dart
// From equipment screen:
context.push('/camera-capture', extra: {
  'context': 'equipment-all-photos',
  'equipmentId': equipmentId,
});

// From folder screen:
context.push('/camera-capture', extra: {
  'context': 'equipment-before',
  'folderId': folderId,
  'beforeAfter': 'before',
});

// In CameraCapturePage:
final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;
final cameraContext = CameraContext.fromMap(extra ?? {});
```

**Alternatives Considered**:
- **Query parameters**: Rejected - URL becomes messy with optional params
- **Path parameters**: Rejected - doesn't support optional params well
- **Provider inheritance**: Rejected - context may not be available in provider tree
- **Extra map**: ✅ Selected - clean, type-safe, already in use

---

### 3. State Management for FAB Expansion

**Question**: Where should FAB expansion state live? Provider, StatefulWidget, or AnimationController?

**Decision**: Use StatefulWidget with local state for expansion

**Rationale**:
- FAB expansion is purely UI state with no business logic
- State doesn't need to persist across navigation
- State is specific to single screen instance
- Using provider would be overkill for simple boolean state

**Implementation Approach**:
```dart
class _ClientDetailScreenState extends State<ClientDetailScreen> {
  bool _fabExpanded = false;

  void _toggleFAB() {
    setState(() => _fabExpanded = !_fabExpanded);
  }

  Widget _buildFAB() {
    return ExpandableFAB(
      expanded: _fabExpanded,
      onToggle: _toggleFAB,
      menuItems: [
        FABMenuItem(label: 'Add Main Site', onTap: _showAddMainSiteDialog),
        FABMenuItem(label: 'Add SubSite', onTap: _showAddSubSiteDialog),
        FABMenuItem(label: 'Add Equipment', onTap: _showAddEquipmentDialog),
      ],
    );
  }
}
```

**Alternatives Considered**:
- **Provider**: Rejected - overkill for simple UI state, adds complexity
- **AnimationController only**: Rejected - needs state to track expanded/collapsed
- **StatefulWidget**: ✅ Selected - simple, scoped to screen, easy to test

---

### 4. Button Conditional Rendering

**Question**: How to cleanly render different save buttons based on camera context?

**Decision**: Create `ContextAwareSaveButtons` widget with builder pattern

**Rationale**:
- Camera context determines which buttons to show (4 scenarios)
- Conditional rendering logic should be isolated from camera page
- Widget should be testable independently
- Button callbacks need access to camera provider

**Implementation Approach**:
```dart
class ContextAwareSaveButtons extends StatelessWidget {
  final CameraContext context;
  final PhotoCaptureProvider provider;
  final Function(BuildContext) onNext;        // Home context
  final Function(BuildContext) onQuickSave;   // Home context

  Widget build(BuildContext context) {
    switch (context.type) {
      case CameraContextType.home:
        return _buildHomeButtons(); // Modal with Next + Quick Save

      case CameraContextType.equipmentAllPhotos:
        return _buildEquipmentButton(); // Single "Save to Equipment"

      case CameraContextType.equipmentBefore:
        return _buildBeforeButton(); // Single "Capture as Before"

      case CameraContextType.equipmentAfter:
        return _buildAfterButton(); // Single "Capture as After"
    }
  }
}
```

**Alternatives Considered**:
- **Inline conditionals**: Rejected - clutters camera page code
- **Strategy pattern with classes**: Rejected - overkill for simple UI logic
- **Builder widget**: ✅ Selected - clean separation, easily testable

---

### 5. Mock Functionality UX

**Question**: How to communicate "feature coming soon" without confusing users?

**Decision**: Use SnackBar with informative message + return to previous screen

**Rationale**:
- Users need clear feedback that button was tapped
- Must avoid appearing like a bug or error
- Should hint at future functionality
- Consistent with existing app UX patterns

**Implementation Approach**:
```dart
void _handleEquipmentSave(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text(
        'Equipment photo save coming soon!\n'
        'Photos captured in this session will be available in the gallery.',
      ),
      duration: Duration(seconds: 3),
      backgroundColor: Colors.blue, // Info color, not error
    ),
  );

  Navigator.of(context).pop(); // Return to previous screen
}
```

**Message Strategy**:
- **"Save to Equipment"**: "Equipment photo save coming soon!"
- **"Capture as Before"**: "Before/After categorization coming soon!"
- **"Capture as After"**: "Before/After categorization coming soon!"

**Alternatives Considered**:
- **Dialog popup**: Rejected - too intrusive for placeholder
- **Toast/SnackBar**: ✅ Selected - non-blocking, informative
- **Silent return**: Rejected - users wouldn't know if tap registered
- **Disabled buttons**: Rejected - defeats purpose of showing context

---

## Technical Decisions Summary

| Decision Area | Choice | Key Benefit |
|--------------|--------|-------------|
| FAB Expansion | Custom StatefulWidget + AnimationController | Full control, <300ms animations, no dependencies |
| Context Passing | go_router `extra` parameter with typed Map | Clean URLs, type-safe, supports optional params |
| FAB State | Local StatefulWidget state | Simple, scoped, no persistence needed |
| Button Rendering | Dedicated widget with switch/case | Clean separation, testable, maintainable |
| Mock UX | SnackBar + navigation return | Clear feedback, non-blocking, informative |

## Performance Considerations

### FAB Expansion Animation
- **Target**: <300ms (SC-005)
- **Approach**:
  - Use `AnimationController` with `Duration(milliseconds: 250)`
  - Stagger item animations by 50ms each
  - Use `Curves.easeOut` for natural deceleration
  - Total animation: 250ms + (50ms × items) = 250-350ms

### Camera Context Detection
- **Target**: Instant (SC-002)
- **Approach**:
  - Parse context from `extra` map in `initState()`
  - No async operations
  - Default to home context if invalid
  - O(1) enum comparison

### Button Rendering
- **Target**: No perceived delay
- **Approach**:
  - Synchronous widget build
  - Pre-computed button configurations
  - No layout recalculation between contexts

## Testing Strategy

### Widget Tests
- **ExpandableFAB**:
  - Tap to expand shows menu items
  - Tap outside collapses menu
  - Animation completes in <300ms
  - Correct number of items rendered

- **ContextAwareSaveButtons**:
  - Home context shows modal with 2 buttons
  - Equipment context shows single button
  - Before/After contexts show appropriate labels
  - Mock handlers show SnackBar and pop

### Unit Tests
- **CameraContext**:
  - fromMap() handles all valid combinations
  - fromMap() defaults to home on invalid input
  - Enum comparison works correctly

- **PhotoCaptureProvider**:
  - Context detection from navigation params
  - Button configurations for each context
  - Mock save handlers don't modify data

### Integration Tests
- End-to-end flow: Equipment → Camera → Save → Return
- End-to-end flow: Client → FAB expand → Create item
- Context validation: Invalid params → home context
- Permission checks: Viewer role → no FAB

## Implementation Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|-----------|
| FAB animation janky on low-end devices | High (Article VI) | Use `RepaintBoundary`, test on min-spec device |
| Context params lost during navigation | High (Article III) | Add validation in camera page, default to home |
| Mock functionality confuses users | Medium (Article VII) | Clear SnackBar messages, consistent UX |
| FAB menu overflow on small screens | Medium (Article I) | Test on smallest supported screen (iPhone SE), stack vertically if needed |
| Expansion state persists incorrectly | Low | Always collapse on navigation away, test thoroughly |

## Dependencies & Prerequisites

**No new external dependencies required** - feature uses existing packages:
- ✅ `flutter` - AnimationController, StatefulWidget
- ✅ `provider` - PhotoCaptureProvider (existing)
- ✅ `go_router` - Navigation with extra params (existing)

**Code prerequisites**:
- ✅ Existing `PhotoCaptureProvider` must support context parameter
- ✅ Existing camera routes must accept `extra` data
- ✅ Existing permission system (AuthState) for FAB visibility

## Next Steps (Phase 1)

1. Create `data-model.md` with:
   - `CameraContext` enum and factory
   - `FABMenuItem` model
   - `SaveActionButton` model

2. Create contracts:
   - `camera-context.md`: Interface for context passing
   - `fab-expansion.md`: ExpandableFAB widget contract

3. Create `quickstart.md` with:
   - How to add expandable FAB to screen
   - How to launch camera with context
   - Testing checklist

4. Update agent context:
   - Add ExpandableFAB widget to CLAUDE.md
   - Document camera context pattern
