# Contract: Camera Context Interface

**Feature**: 005-i-want-to | **Version**: 1.0.0
**Purpose**: Define the interface for passing camera launch context through navigation

## Overview

This contract defines how screens launch the camera with specific context information to determine save button behavior. The camera page uses this context to display appropriate save action buttons.

## Navigation Contract

### Launching Camera with Context

**Method**: go_router `context.push()` with `extra` parameter

**Route**: `/camera-capture`

**Extra Data Format**:
```dart
Map<String, dynamic> {
  'context': String,        // Required: 'home' | 'equipment-all-photos' | 'equipment-before' | 'equipment-after'
  'equipmentId'?: String,   // Required for equipment contexts
  'folderId'?: String,      // Required for before/after contexts
  'beforeAfter'?: String,   // Required for before/after contexts: 'before' | 'after'
}
```

### Context Types

#### 1. Home Context
**Use Case**: Launched from home screen quick capture

**Extra Data**:
```dart
{
  'context': 'home',
}
```

**Result**: Camera displays modal with "Next" and "Quick Save" buttons

---

#### 2. Equipment All Photos Context
**Use Case**: Launched from equipment "All Photos" tab

**Extra Data**:
```dart
{
  'context': 'equipment-all-photos',
  'equipmentId': 'uuid-string',
}
```

**Validation**:
- `equipmentId` must be non-null and non-empty
- If invalid → defaults to home context

**Result**: Camera displays "Save to Equipment" button (mock functionality)

---

#### 3. Equipment Before Context
**Use Case**: Launched from folder "Capture Before" button

**Extra Data**:
```dart
{
  'context': 'equipment-before',
  'folderId': 'uuid-string',
  'beforeAfter': 'before',
}
```

**Validation**:
- `folderId` must be non-null and non-empty
- `beforeAfter` must be 'before'
- If invalid → defaults to home context

**Result**: Camera displays "Capture as Before" button (mock functionality)

---

#### 4. Equipment After Context
**Use Case**: Launched from folder "Capture After" button

**Extra Data**:
```dart
{
  'context': 'equipment-after',
  'folderId': 'uuid-string',
  'beforeAfter': 'after',
}
```

**Validation**:
- `folderId` must be non-null and non-empty
- `beforeAfter` must be 'after'
- If invalid → defaults to home context

**Result**: Camera displays "Capture as After" button (mock functionality)

---

## Implementation Examples

### From Home Screen
```dart
// In home_screen.dart or shell_scaffold.dart
void _openQuickCapture() {
  context.push('/camera-capture', extra: {
    'context': 'home',
  });
}
```

### From Equipment All Photos Tab
```dart
// In equipment_screen.dart (All Photos tab)
void _openQuickCapture() {
  context.push('/camera-capture', extra: {
    'context': 'equipment-all-photos',
    'equipmentId': widget.equipmentId,
  });
}
```

### From Equipment Folder (Before/After)
```dart
// In folder_detail_screen.dart
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

---

## Camera Page Contract

### Receiving Context

**In CameraCapturePage**:
```dart
class CameraCapturePage extends StatefulWidget {
  final CameraContext cameraContext;

  const CameraCapturePage({
    Key? key,
    required this.cameraContext,
  }) : super(key: key);
}
```

**In Router**:
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
        cameraContext: cameraContext,
      ),
    );
  },
),
```

### Save Button Rendering

**Contract**: Camera page MUST render buttons based on context type

```dart
Widget _buildSaveButtons() {
  return ContextAwareSaveButtons(
    context: widget.cameraContext,
    provider: Provider.of<PhotoCaptureProvider>(context, listen: false),
    onNext: _handleNext,          // Home context only
    onQuickSave: _handleQuickSave, // Home context only
  );
}
```

---

## Error Handling

### Invalid Context Recovery

**Requirement**: Camera MUST handle invalid context gracefully by defaulting to home

**Implementation**:
```dart
factory CameraContext.fromMap(Map<String, dynamic> map) {
  // ... validation logic ...

  // If validation fails, default to home
  return const CameraContext(type: CameraContextType.home);
}
```

**Error Scenarios**:
1. `extra` is null → defaults to home
2. `context` key missing → defaults to home
3. Invalid context string → defaults to home
4. Required params missing (e.g., equipmentId for equipment context) → defaults to home
5. Invalid param types → defaults to home

### Navigation Failure

**Scenario**: User pops camera before save completes

**Requirement**: No data loss, graceful cleanup

**Implementation**:
```dart
@override
void dispose() {
  // Clean up camera resources
  _provider?.disposeCamera();
  super.dispose();
}
```

---

## Performance Requirements

### Context Creation
- **Target**: Instant (< 1ms)
- **Method**: Synchronous map parsing in `fromMap()`
- **No I/O**: Pure in-memory operation

### Context Validation
- **Target**: Instant (< 1ms)
- **Method**: Simple null checks and string comparison
- **Complexity**: O(1)

### Button Rendering
- **Target**: No perceived delay
- **Method**: Synchronous switch statement in widget build
- **Complexity**: O(1)

---

## Testing Contract

### Unit Tests Required

**CameraContext.fromMap()**:
```dart
test('fromMap creates home context when extra is null', () {
  final context = CameraContext.fromMap({});
  expect(context.type, CameraContextType.home);
});

test('fromMap creates equipment context with valid params', () {
  final context = CameraContext.fromMap({
    'context': 'equipment-all-photos',
    'equipmentId': 'test-id',
  });
  expect(context.type, CameraContextType.equipmentAllPhotos);
  expect(context.equipmentId, 'test-id');
});

test('fromMap defaults to home when equipmentId missing', () {
  final context = CameraContext.fromMap({
    'context': 'equipment-all-photos',
    // Missing equipmentId
  });
  expect(context.type, CameraContextType.home);
});
```

### Widget Tests Required

**ContextAwareSaveButtons**:
```dart
testWidgets('shows modal with Next and Quick Save for home context', (tester) async {
  final context = CameraContext(type: CameraContextType.home);
  await tester.pumpWidget(/* ContextAwareSaveButtons with home context */);

  // Tap Done button
  await tester.tap(find.text('Done'));
  await tester.pump();

  // Verify modal appears with both buttons
  expect(find.text('Next'), findsOneWidget);
  expect(find.text('Quick Save'), findsOneWidget);
});

testWidgets('shows Save to Equipment button for equipment context', (tester) async {
  final context = CameraContext(
    type: CameraContextType.equipmentAllPhotos,
    equipmentId: 'test-id',
  );
  await tester.pumpWidget(/* ContextAwareSaveButtons with equipment context */);

  // Tap Done button
  await tester.tap(find.text('Done'));
  await tester.pump();

  // Verify single button appears
  expect(find.text('Save to Equipment'), findsOneWidget);
  expect(find.text('Next'), findsNothing);
  expect(find.text('Quick Save'), findsNothing);
});
```

### Integration Tests Required

**End-to-end context flow**:
```dart
testWidgets('equipment to camera preserves context', (tester) async {
  // Navigate to equipment screen
  // Tap camera FAB
  // Verify context passed correctly
  // Verify correct save button displayed
});
```

---

## Backward Compatibility

### Existing Behavior Preservation

**Home Context**:
- ✅ "Next" and "Quick Save" buttons retain existing functionality
- ✅ No changes to current home screen camera workflow

**Equipment Screen**:
- ✅ Existing simple FAB on "All Photos" tab launches camera with new context
- ✅ No breaking changes to existing camera launch points

### Migration Path

**Phase 1** (This Feature):
- Add context parameter support to camera page
- Existing launches without context → defaults to home (backward compatible)

**Phase 2** (Future):
- Implement actual save logic for new contexts
- Mock functionality replaced with real photo association

---

## Security & Privacy

### Context Data Sensitivity

**Equipment IDs**: Non-sensitive UUID strings, safe to pass in navigation

**Folder IDs**: Non-sensitive UUID strings, safe to pass in navigation

**No PII**: Context contains no personally identifiable information

### Validation Required

- ✅ Equipment ID existence validated before creating context
- ✅ Folder ID existence validated before creating context
- ✅ Invalid IDs gracefully handled (default to home)
- ✅ No database queries in context creation (performance)

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2025-10-11 | Initial contract definition |

---

## Related Contracts

- [FAB Expansion Contract](./fab-expansion.md) - Expandable FAB widget interface
- [Data Model](../data-model.md) - CameraContext model definition
