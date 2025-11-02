class AnalyticsEventDefinition {
  final String name;
  final Set<String> requiredKeys;
  final Set<String> optionalKeys;

  const AnalyticsEventDefinition({
    required this.name,
    required this.requiredKeys,
    this.optionalKeys = const {},
  });
}

class AnalyticsEvents {
  static const galleryImportLogged = AnalyticsEventDefinition(
    name: 'gallery_import_logged',
    requiredKeys: {
      'batchId',
      'entryPoint',
      'destination',
      'permissionStatus',
      'selectedCount',
      'importedCount',
      'duplicateCount',
      'failedCount',
      'durationMs',
      'averageImportMs',
    },
    optionalKeys: {'deviceFreeSpaceBytes', 'errorCodes'},
  );

  static const permissionPromptLogged = AnalyticsEventDefinition(
    name: 'permission_prompt_logged',
    requiredKeys: {
      'entryPoint',
      'status',
      'timestamp',
    },
  );

  static const all = [
    galleryImportLogged,
    permissionPromptLogged,
  ];
}
