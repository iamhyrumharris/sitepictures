# FieldPhoto Pro Widget Documentation

## Core Widget Components

### PhotoCaptureWidget
**Purpose**: Handles camera integration and photo capture workflow
**Location**: `lib/widgets/photo_capture_widget.dart`
**Key Features**:
- One-handed operation support
- Quick capture mode (<2s requirement)
- GPS metadata extraction
- Automatic equipment assignment based on location

**Usage**:
```dart
PhotoCaptureWidget(
  onPhotoTaken: (Photo photo) => handlePhoto(photo),
  equipmentId: currentEquipment?.id,
  enableQuickCapture: true,
)
```

### HierarchyNavigationWidget
**Purpose**: Displays breadcrumb navigation for Client → Site → Equipment hierarchy
**Location**: `lib/widgets/hierarchy_navigation_widget.dart`
**Key Features**:
- Visual breadcrumb trail
- Tap-to-navigate functionality
- Current location indicator
- Performance optimized (<500ms transitions)

**Usage**:
```dart
HierarchyNavigationWidget(
  currentPath: navigationService.currentPath,
  onNavigate: (String nodeId) => navigateToNode(nodeId),
)
```

### EquipmentTimelineWidget
**Purpose**: Shows chronological photo history for equipment
**Location**: `lib/widgets/equipment_timeline_widget.dart`
**Key Features**:
- Revision grouping support
- Date-based organization
- Thumbnail previews
- Infinite scroll with pagination

**Usage**:
```dart
EquipmentTimelineWidget(
  equipmentId: equipment.id,
  revisions: equipment.revisions,
  onPhotoTap: (Photo photo) => viewPhoto(photo),
)
```

### SearchBarWidget
**Purpose**: Global search interface with filters
**Location**: `lib/widgets/search_bar_widget.dart`
**Key Features**:
- Full-text search (<1s response)
- Date range filtering
- GPS proximity search
- Equipment type filtering
- Real-time suggestions

**Usage**:
```dart
SearchBarWidget(
  onSearch: (String query, Map<String, dynamic> filters) => performSearch(query, filters),
  enableGPSFilter: true,
  enableDateFilter: true,
)
```

### SyncStatusWidget
**Purpose**: Displays sync queue status and progress
**Location**: `lib/widgets/sync_status_widget.dart`
**Key Features**:
- Pending items count
- Upload progress indicator
- Conflict notifications
- Battery-aware sync control

**Usage**:
```dart
SyncStatusWidget(
  syncService: syncService,
  showDetails: true,
  onConflict: (conflict) => resolveConflict(conflict),
)
```

### PhotoGridWidget
**Purpose**: Displays photo thumbnails in grid layout
**Location**: `lib/widgets/photo_grid_widget.dart`
**Key Features**:
- Lazy loading for performance
- Pinch-to-zoom support
- Selection mode for bulk operations
- Automatic layout adjustment

**Usage**:
```dart
PhotoGridWidget(
  photos: photoList,
  columns: 3,
  onPhotoTap: (Photo photo) => viewFullScreen(photo),
  enableSelection: true,
)
```

### GPSBoundaryMapWidget
**Purpose**: Visual representation of GPS boundaries
**Location**: `lib/widgets/gps_boundary_map_widget.dart`
**Key Features**:
- Circular boundary visualization
- Current location indicator
- Overlapping boundary display
- Priority-based coloring

**Usage**:
```dart
GPSBoundaryMapWidget(
  boundaries: activeBoundaries,
  currentLocation: currentGPSLocation,
  onBoundaryTap: (GPSBoundary boundary) => editBoundary(boundary),
)
```

### NeedsAssignmentWidget
**Purpose**: Shows photos requiring manual equipment assignment
**Location**: `lib/widgets/needs_assignment_widget.dart`
**Key Features**:
- Unassigned photo queue
- Quick assignment interface
- Bulk assignment support
- GPS hint display

**Usage**:
```dart
NeedsAssignmentWidget(
  unassignedPhotos: needsAssignmentPhotos,
  onAssign: (Photo photo, String equipmentId) => assignPhoto(photo, equipmentId),
)
```

## Custom Paint Widgets

### BatteryIndicatorPainter
**Purpose**: Custom battery level visualization
**Location**: `lib/widgets/painters/battery_indicator_painter.dart`
**Features**:
- Color coding based on level
- Warning states for low battery
- Animated charging indicator

### CircularProgressPainter
**Purpose**: Custom circular progress for sync operations
**Location**: `lib/widgets/painters/circular_progress_painter.dart`
**Features**:
- Smooth animations
- Percentage display
- Error state visualization

## Responsive Layouts

### AdaptiveScaffold
**Purpose**: Responsive layout for different screen sizes
**Location**: `lib/widgets/adaptive_scaffold.dart`
**Features**:
- Mobile/tablet layout switching
- Collapsible navigation drawer
- Floating action button positioning
- Landscape mode optimization

## Performance Considerations

### Widget Best Practices
1. **Use const constructors** where possible for better performance
2. **Implement AutomaticKeepAliveClientMixin** for expensive widgets in lists
3. **Use RepaintBoundary** for complex custom painters
4. **Leverage ValueListenableBuilder** for targeted rebuilds
5. **Implement proper dispose() methods** to prevent memory leaks

### State Management
- Uses Provider/Riverpod for global state
- Local state with StatefulWidget for UI-only state
- StreamBuilder for real-time updates
- FutureBuilder for async data loading

### Accessibility
All widgets include:
- Semantic labels for screen readers
- Proper focus management
- High contrast mode support
- Minimum touch target sizes (48x48dp)

## Testing

Each widget has corresponding test files in `test/widget_test/`:
- Unit tests for business logic
- Widget tests for UI behavior
- Golden tests for visual regression
- Performance tests for critical paths

## Theme Support

All widgets respect the app theme:
```dart
Theme.of(context).colorScheme.primary
Theme.of(context).textTheme.headlineMedium
```

Custom theme extensions for domain-specific styling:
```dart
Theme.of(context).extension<FieldPhotoTheme>()?.warningColor
```

## Internationalization

Widgets use localized strings:
```dart
AppLocalizations.of(context)!.takePhoto
```

Supported locales:
- English (en)
- Spanish (es)
- French (fr)
- German (de)

## Platform-Specific Widgets

### iOS
- Cupertino-style date pickers
- iOS-specific navigation transitions

### Android
- Material Design 3 components
- Android-specific permissions handling

### Desktop
- Keyboard shortcuts support
- Mouse hover states
- Context menus

## Widget Composition Examples

### Complex Screen Composition
```dart
class EquipmentDetailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      title: equipment.name,
      body: Column(
        children: [
          HierarchyNavigationWidget(...),
          Expanded(
            child: EquipmentTimelineWidget(...),
          ),
          PhotoCaptureWidget(...),
        ],
      ),
      floatingActionButton: SyncStatusWidget(...),
    );
  }
}
```

## Contributing

When creating new widgets:
1. Follow the single responsibility principle
2. Document public APIs with dartdoc comments
3. Include usage examples in documentation
4. Write comprehensive tests
5. Ensure constitutional compliance (performance, offline-first, etc.)