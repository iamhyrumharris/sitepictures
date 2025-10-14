/// Provider Contract: EquipmentNavigatorProvider
///
/// Purpose: Manages equipment navigator state for "Next" button workflow
/// - Hierarchical navigation (Client → Site → Equipment)
/// - Lazy loading of child nodes
/// - Equipment selection state
/// - Navigation history/breadcrumbs

import 'package:flutter/foundation.dart';
import '../../../lib/models/equipment.dart';
import '../../../lib/models/equipment_navigation_node.dart';

abstract class EquipmentNavigatorProvider extends ChangeNotifier {
  /// Current navigation path (breadcrumb trail)
  List<EquipmentNavigationNode> get navigationPath;

  /// Current node's children
  List<EquipmentNavigationNode> get currentChildren;

  /// Currently selected equipment (null if none selected)
  Equipment? get selectedEquipment;

  /// Loading state
  bool get isLoading;

  /// Error message (if any)
  String? get errorMessage;

  /// Initialize navigator at root (clients list)
  ///
  /// Loads all active user clients (filters out system clients)
  /// Clears navigation path and selection
  /// Notifies listeners on completion
  Future<void> initialize();

  /// Navigate into a node (expand)
  ///
  /// [node]: Node to navigate into (client or site)
  ///
  /// Loads node's children lazily if not already loaded
  /// Adds node to navigation path
  /// Updates currentChildren to show node's children
  /// Notifies listeners on completion
  ///
  /// Throws:
  /// - StateError: If node is equipment (equipment has no children)
  Future<void> navigateInto(EquipmentNavigationNode node);

  /// Navigate back (pop breadcrumb)
  ///
  /// Removes last node from navigation path
  /// Updates currentChildren to show parent's children
  /// Clears selection if navigating back
  /// Notifies listeners on completion
  ///
  /// Throws:
  /// - StateError: If already at root
  void navigateBack();

  /// Select equipment
  ///
  /// [equipment]: Equipment to select
  ///
  /// Sets selectedEquipment
  /// Navigator can be dismissed after selection
  /// Notifies listeners
  void selectEquipment(Equipment equipment);

  /// Clear selection
  ///
  /// Sets selectedEquipment to null
  /// Used when user cancels navigation
  /// Notifies listeners
  void clearSelection();

  /// Reset navigator to initial state
  ///
  /// Clears navigation path, selection, and children
  /// Used when modal is closed
  void reset();
}

/// Example Usage:
///
/// ```dart
/// // In EquipmentNavigatorPage
/// class EquipmentNavigatorPage extends StatefulWidget {
///   @override
///   Widget build(BuildContext context) {
///     return Consumer<EquipmentNavigatorProvider>(
///       builder: (context, provider, child) {
///         return Scaffold(
///           appBar: AppBar(
///             title: Text('Select Equipment'),
///             leading: provider.navigationPath.isNotEmpty
///               ? IconButton(
///                   icon: Icon(Icons.arrow_back),
///                   onPressed: () => provider.navigateBack(),
///                 )
///               : null,
///           ),
///           body: ListView.builder(
///             itemCount: provider.currentChildren.length,
///             itemBuilder: (context, index) {
///               final node = provider.currentChildren[index];
///               return ListTile(
///                 leading: Icon(node.iconData),
///                 title: Text(node.name),
///                 trailing: node.isSelectable
///                   ? Icon(Icons.check_circle_outline)
///                   : Icon(Icons.chevron_right),
///                 onTap: () async {
///                   if (node.isSelectable) {
///                     // Equipment node - select and dismiss
///                     final equipment = await _loadEquipment(node.id);
///                     provider.selectEquipment(equipment);
///                     Navigator.of(context).pop(equipment);
///                   } else {
///                     // Client/site node - navigate in
///                     await provider.navigateInto(node);
///                   }
///                 },
///               );
///             },
///           ),
///         );
///       },
///     );
///   }
///
///   @override
///   void initState() {
///     super.initState();
///     Provider.of<EquipmentNavigatorProvider>(context, listen: false)
///       .initialize();
///   }
/// }
///
/// // In camera_capture_page "Next" button handler
/// final equipment = await Navigator.of(context).push<Equipment>(
///   MaterialPageRoute(
///     fullscreenDialog: true,
///     builder: (context) => EquipmentNavigatorPage(),
///   ),
/// );
///
/// if (equipment != null) {
///   final result = await _photoSaveService.saveToEquipment(
///     photos: provider.session.photos,
///     equipment: equipment,
///   );
/// }
/// ```
