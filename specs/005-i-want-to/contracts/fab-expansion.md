# Contract: Expandable FAB Interface

**Feature**: 005-i-want-to | **Version**: 1.0.0
**Purpose**: Define the interface for expandable FAB (Floating Action Button) widget

## Overview

This contract defines the reusable `ExpandableFAB` widget that displays a collapsed FAB button which expands to show multiple menu items when tapped. Used for context-aware creation actions on client, main site, and subsite screens.

## Widget Interface

### ExpandableFAB

**File**: `lib/widgets/expandable_fab.dart`

**Purpose**: Reusable expandable FAB with animation support

```dart
class ExpandableFAB extends StatefulWidget {
  /// Menu items to display when expanded
  final List<FABMenuItem> menuItems;

  /// Duration for expand/collapse animation
  final Duration animationDuration;

  /// Callback when FAB state changes
  final ValueChanged<bool>? onExpansionChanged;

  /// Hero tag for FAB (must be unique if multiple FABs on screen)
  final String? heroTag;

  /// Initial expansion state (default: false/collapsed)
  final bool initiallyExpanded;

  const ExpandableFAB({
    Key? key,
    required this.menuItems,
    this.animationDuration = const Duration(milliseconds: 250),
    this.onExpansionChanged,
    this.heroTag,
    this.initiallyExpanded = false,
  }) : super(key: key);
}
```

### FABMenuItem

**File**: `lib/models/fab_menu_item.dart`

**Purpose**: Configuration for individual menu item in expandable FAB

```dart
class FABMenuItem {
  /// Display label for menu item
  final String label;

  /// Icon to display
  final IconData icon;

  /// Callback when item is tapped
  final VoidCallback onTap;

  /// Background color (optional, defaults to theme color)
  final Color? backgroundColor;

  /// Hero tag for this specific item (optional)
  final String? heroTag;

  const FABMenuItem({
    required this.label,
    required this.icon,
    required this.onTap,
    this.backgroundColor,
    this.heroTag,
  });
}
```

---

## Behavior Contract

### Expansion Animation

**Requirements**:
1. FAB MUST expand when tapped
2. Animation MUST complete within 300ms (SC-005)
3. Menu items MUST appear with stagger effect
4. FAB MUST collapse when:
   - User taps outside the FAB area
   - User taps a menu item
   - User navigates away from screen

**Animation Sequence**:
```
Collapsed (0ms)
  ↓ User taps FAB
Expanding (0-250ms)
  - FAB rotates 45° (+ becomes ×)
  - Menu items slide in from FAB position
  - Items stagger by 50ms each
  ↓
Expanded (250ms)
  - All items visible
  - Scrim overlay active (tap outside to collapse)
```

### Collapse Animation

```
Expanded (0ms)
  ↓ User taps outside or menu item
Collapsing (0-250ms)
  - Menu items slide back to FAB position
  - Items stagger by 50ms each
  - FAB rotates back to 0° (× becomes +)
  ↓
Collapsed (250ms)
  - Only main FAB visible
  - Scrim overlay removed
```

### Tap Outside to Collapse

**Requirements**:
1. Transparent scrim MUST cover screen when expanded
2. Tapping scrim MUST trigger collapse animation
3. Scrim MUST NOT block FAB or menu items
4. Scrim MUST dismiss on any tap (no swipe gestures)

**Implementation**:
```dart
Widget build(BuildContext context) {
  return Stack(
    children: [
      // Scrim overlay (only visible when expanded)
      if (_isExpanded)
        GestureDetector(
          onTap: _collapse,
          child: Container(
            color: Colors.black.withOpacity(0.3),
          ),
        ),

      // FAB and menu items
      Positioned(
        right: 16,
        bottom: 16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Menu items (animated)
            ..._buildMenuItems(),

            // Main FAB
            _buildMainFAB(),
          ],
        ),
      ),
    ],
  );
}
```

---

## Usage Examples

### Client Page (3-Item Expandable FAB)

```dart
// In client_detail_screen.dart
Widget _buildFAB() {
  final authState = context.watch<AuthState>();

  if (authState.currentUser?.role == UserRole.viewer) {
    return SizedBox.shrink(); // No FAB for viewers
  }

  return ExpandableFAB(
    heroTag: 'client_fab_${widget.clientId}',
    menuItems: [
      FABMenuItem(
        label: 'Add Main Site',
        icon: Icons.location_city,
        onTap: _showAddMainSiteDialog,
        backgroundColor: Colors.blue,
      ),
      FABMenuItem(
        label: 'Add SubSite',
        icon: Icons.folder,
        onTap: _showAddSubSiteDialog,
        backgroundColor: Colors.orange,
      ),
      FABMenuItem(
        label: 'Add Equipment',
        icon: Icons.precision_manufacturing,
        onTap: _showAddEquipmentDialog,
        backgroundColor: Colors.purple,
      ),
    ],
    onExpansionChanged: (expanded) {
      debugPrint('Client FAB expanded: $expanded');
    },
  );
}
```

### Main Site Page (2-Item Expandable FAB)

```dart
// In main_site_screen.dart
Widget _buildFAB() {
  final authState = context.watch<AuthState>();

  if (authState.currentUser?.role == UserRole.viewer) {
    return SizedBox.shrink();
  }

  return ExpandableFAB(
    heroTag: 'mainsite_fab_${widget.siteId}',
    menuItems: [
      FABMenuItem(
        label: 'Add SubSite',
        icon: Icons.folder,
        onTap: _showAddSubSiteDialog,
      ),
      FABMenuItem(
        label: 'Add Equipment',
        icon: Icons.precision_manufacturing,
        onTap: _showAddEquipmentDialog,
      ),
    ],
  );
}
```

### SubSite Page (Simple FAB - No Expansion)

```dart
// In sub_site_screen.dart
Widget _buildFAB() {
  final authState = context.watch<AuthState>();

  if (authState.currentUser?.role == UserRole.viewer) {
    return SizedBox.shrink();
  }

  // Simple FloatingActionButton (no ExpandableFAB)
  return FloatingActionButton(
    heroTag: 'subsite_fab_${widget.subSiteId}',
    onPressed: _showAddEquipmentDialog,
    child: const Icon(Icons.add),
    tooltip: 'Add Equipment',
  );
}
```

---

## Performance Requirements

### Animation Performance

**Target**: < 300ms expansion/collapse (SC-005)

**Implementation**:
```dart
class _ExpandableFABState extends State<ExpandableFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
  }

  void _expand() {
    _controller.forward();
    setState(() => _isExpanded = true);
    widget.onExpansionChanged?.call(true);
  }

  void _collapse() {
    _controller.reverse();
    setState(() => _isExpanded = false);
    widget.onExpansionChanged?.call(false);
  }
}
```

**Stagger Calculation**:
```dart
// Each menu item animates with 50ms stagger
List<Widget> _buildMenuItems() {
  return widget.menuItems.asMap().entries.map((entry) {
    final index = entry.key;
    final item = entry.value;
    final delay = index * 50; // 50ms stagger per item

    return AnimatedBuilder(
      animation: _expandAnimation,
      builder: (context, child) {
        final progress = (_expandAnimation.value * widget.menuItems.length) - index;
        final clampedProgress = progress.clamp(0.0, 1.0);

        return Transform.translate(
          offset: Offset(0, (1 - clampedProgress) * 60),
          child: Opacity(
            opacity: clampedProgress,
            child: _buildMenuItem(item),
          ),
        );
      },
    );
  }).toList().reversed.toList(); // Reverse so top item appears first
}
```

### Memory Efficiency

**Requirements**:
- Animation controller MUST be disposed in `dispose()`
- No memory leaks from listeners
- Scrim overlay only created when expanded

```dart
@override
void dispose() {
  _controller.dispose();
  super.dispose();
}
```

---

## Testing Contract

### Widget Tests Required

**Expansion/Collapse**:
```dart
testWidgets('FAB expands when tapped', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        floatingActionButton: ExpandableFAB(
          menuItems: [
            FABMenuItem(label: 'Item 1', icon: Icons.add, onTap: () {}),
            FABMenuItem(label: 'Item 2', icon: Icons.remove, onTap: () {}),
          ],
        ),
      ),
    ),
  );

  // Initially collapsed
  expect(find.text('Item 1'), findsNothing);

  // Tap to expand
  await tester.tap(find.byType(FloatingActionButton));
  await tester.pumpAndSettle(); // Wait for animation

  // Menu items visible
  expect(find.text('Item 1'), findsOneWidget);
  expect(find.text('Item 2'), findsOneWidget);
});

testWidgets('FAB collapses when tapping outside', (tester) async {
  // ... setup expanded FAB ...

  // Tap scrim overlay (outside FAB area)
  await tester.tapAt(Offset(50, 50)); // Top-left of screen
  await tester.pumpAndSettle();

  // Menu items hidden
  expect(find.text('Item 1'), findsNothing);
});

testWidgets('FAB collapses when menu item tapped', (tester) async {
  bool itemTapped = false;

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        floatingActionButton: ExpandableFAB(
          menuItems: [
            FABMenuItem(
              label: 'Item 1',
              icon: Icons.add,
              onTap: () => itemTapped = true,
            ),
          ],
        ),
      ),
    ),
  );

  // Expand FAB
  await tester.tap(find.byType(FloatingActionButton));
  await tester.pumpAndSettle();

  // Tap menu item
  await tester.tap(find.text('Item 1'));
  await tester.pumpAndSettle();

  // Item callback invoked
  expect(itemTapped, true);

  // FAB collapsed
  expect(find.text('Item 1'), findsNothing);
});
```

**Animation Performance**:
```dart
testWidgets('FAB expansion completes within 300ms', (tester) async {
  await tester.pumpWidget(/* ExpandableFAB */);

  final start = DateTime.now();

  await tester.tap(find.byType(FloatingActionButton));
  await tester.pumpAndSettle();

  final duration = DateTime.now().difference(start);

  expect(duration.inMilliseconds, lessThan(300));
});
```

### Unit Tests Required

**FABMenuItem validation**:
```dart
test('FABMenuItem requires non-empty label', () {
  expect(
    () => FABMenuItem(label: '', icon: Icons.add, onTap: () {}),
    throwsAssertionError,
  );
});
```

---

## Accessibility

### Screen Reader Support

**Requirements**:
1. Main FAB MUST have semantic label: "Expand menu" or "Collapse menu"
2. Menu items MUST have individual semantic labels
3. Expansion state MUST be announced to screen readers

**Implementation**:
```dart
Semantics(
  label: _isExpanded ? 'Collapse menu' : 'Expand menu',
  button: true,
  child: FloatingActionButton(
    onPressed: _isExpanded ? _collapse : _expand,
    child: AnimatedRotation(
      turns: _isExpanded ? 0.125 : 0, // 45° rotation
      duration: widget.animationDuration,
      child: Icon(Icons.add),
    ),
  ),
)
```

### Touch Target Size

**Requirements**:
- Main FAB: 56×56 dp (Material Design standard)
- Menu items: Minimum 48×48 dp touch target
- Spacing between items: Minimum 8 dp

---

## Error Handling

### Empty Menu Items

**Requirement**: MUST handle empty menu items list gracefully

**Implementation**:
```dart
@override
Widget build(BuildContext context) {
  // If no menu items, render simple FAB (no expansion)
  if (widget.menuItems.isEmpty) {
    return FloatingActionButton(
      heroTag: widget.heroTag,
      onPressed: () {
        debugPrint('Warning: ExpandableFAB has no menu items');
      },
      child: const Icon(Icons.add),
    );
  }

  // Normal expandable FAB logic
  return _buildExpandableFAB();
}
```

### Invalid Hero Tags

**Requirement**: Detect duplicate hero tags and warn developer

**Implementation**:
```dart
@override
void initState() {
  super.initState();

  if (widget.heroTag != null) {
    // Log warning if same hero tag used on screen
    debugPrint('ExpandableFAB hero tag: ${widget.heroTag}');
  }

  // ... rest of init
}
```

---

## Styling & Theming

### Default Styles

```dart
// Main FAB
FloatingActionButton(
  backgroundColor: Theme.of(context).colorScheme.primary,
  foregroundColor: Colors.white,
  elevation: 6.0,
  // ...
)

// Menu items
Container(
  decoration: BoxDecoration(
    color: item.backgroundColor ?? Theme.of(context).colorScheme.secondary,
    borderRadius: BorderRadius.circular(28),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.2),
        blurRadius: 4,
        offset: Offset(0, 2),
      ),
    ],
  ),
  // ...
)
```

### Customization

**Client page** can customize colors:
```dart
FABMenuItem(
  label: 'Add Main Site',
  icon: Icons.location_city,
  backgroundColor: Colors.blue,  // Custom color
  onTap: _showAddMainSiteDialog,
)
```

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2025-10-11 | Initial contract definition |

---

## Related Contracts

- [Camera Context Contract](./camera-context.md) - Camera launch interface
- [Data Model](../data-model.md) - FABMenuItem model definition
