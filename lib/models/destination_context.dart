enum DestinationType {
  needsAssigned('needs_assigned'),
  equipmentGeneral('equipment_general'),
  equipmentBefore('equipment_before'),
  equipmentAfter('equipment_after');

  const DestinationType(this.dbValue);

  final String dbValue;

  static DestinationType fromDb(String value) {
    return DestinationType.values.firstWhere(
      (type) => type.dbValue == value,
      orElse: () => DestinationType.needsAssigned,
    );
  }
}

class DestinationContext {
  final DestinationType type;
  final String clientId;
  final String? mainSiteId;
  final String? subSiteId;
  final String? equipmentId;
  final String? folderId;
  final String? label;

  const DestinationContext({
    required this.type,
    required this.clientId,
    this.mainSiteId,
    this.subSiteId,
    this.equipmentId,
    this.folderId,
    this.label,
  });

  DestinationContext copyWith({
    DestinationType? type,
    String? clientId,
    String? mainSiteId,
    String? subSiteId,
    String? equipmentId,
    String? folderId,
    String? label,
  }) {
    return DestinationContext(
      type: type ?? this.type,
      clientId: clientId ?? this.clientId,
      mainSiteId: mainSiteId ?? this.mainSiteId,
      subSiteId: subSiteId ?? this.subSiteId,
      equipmentId: equipmentId ?? this.equipmentId,
      folderId: folderId ?? this.folderId,
      label: label ?? this.label,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type.dbValue,
      'clientId': clientId,
      'mainSiteId': mainSiteId,
      'subSiteId': subSiteId,
      'equipmentId': equipmentId,
      'folderId': folderId,
      'label': label,
    };
  }

  factory DestinationContext.fromMap(Map<String, dynamic> map) {
    return DestinationContext(
      type: DestinationType.fromDb(map['type'] as String),
      clientId: map['clientId'] as String,
      mainSiteId: map['mainSiteId'] as String?,
      subSiteId: map['subSiteId'] as String?,
      equipmentId: map['equipmentId'] as String?,
      folderId: map['folderId'] as String?,
      label: map['label'] as String?,
    );
  }
}
