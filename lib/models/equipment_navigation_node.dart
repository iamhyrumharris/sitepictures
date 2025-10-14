/// Node type enumeration for equipment navigator tree
enum NavigationNodeType {
  client,
  mainSite,
  subSite,
  equipment,
}

/// Represents a node in the hierarchical equipment navigator tree
class EquipmentNavigationNode {
  final String id;
  final String name;
  final NavigationNodeType type;
  final String? parentId;
  final bool isSelectable;
  List<EquipmentNavigationNode>? children;

  EquipmentNavigationNode({
    required this.id,
    required this.name,
    required this.type,
    this.parentId,
    required this.isSelectable,
    this.children,
  });

  /// Factory constructor for client node
  factory EquipmentNavigationNode.client({
    required String id,
    required String name,
  }) {
    return EquipmentNavigationNode(
      id: id,
      name: name,
      type: NavigationNodeType.client,
      isSelectable: false,
    );
  }

  /// Factory constructor for main site node
  factory EquipmentNavigationNode.mainSite({
    required String id,
    required String name,
    required String parentId,
  }) {
    return EquipmentNavigationNode(
      id: id,
      name: name,
      type: NavigationNodeType.mainSite,
      parentId: parentId,
      isSelectable: false,
    );
  }

  /// Factory constructor for sub site node
  factory EquipmentNavigationNode.subSite({
    required String id,
    required String name,
    required String parentId,
  }) {
    return EquipmentNavigationNode(
      id: id,
      name: name,
      type: NavigationNodeType.subSite,
      parentId: parentId,
      isSelectable: false,
    );
  }

  /// Factory constructor for equipment node (only selectable type)
  factory EquipmentNavigationNode.equipment({
    required String id,
    required String name,
    required String parentId,
  }) {
    return EquipmentNavigationNode(
      id: id,
      name: name,
      type: NavigationNodeType.equipment,
      parentId: parentId,
      isSelectable: true,
    );
  }

  /// Check if children have been loaded
  bool get hasLoadedChildren => children != null;

  /// Check if this node has children (needs to be expanded)
  bool get canHaveChildren => type != NavigationNodeType.equipment;

  @override
  String toString() {
    return 'EquipmentNavigationNode(id: $id, name: $name, type: $type, parentId: $parentId, isSelectable: $isSelectable, children: ${children?.length ?? 'not loaded'})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EquipmentNavigationNode &&
        other.id == id &&
        other.name == name &&
        other.type == type &&
        other.parentId == parentId &&
        other.isSelectable == isSelectable;
  }

  @override
  int get hashCode {
    return Object.hash(id, name, type, parentId, isSelectable);
  }
}
