import '../services/database_service.dart';

/// Utility for generating unique names with sequential numbering
/// Handles "(2)", "(3)" disambiguation for same-date names
class SequentialNamer {
  final DatabaseService _db;

  SequentialNamer({required DatabaseService databaseService})
      : _db = databaseService;

  /// Generate a unique name by checking existing folders and appending sequential numbers
  ///
  /// Example:
  /// - "2025-10-13 14-30" (first occurrence)
  /// - "2025-10-13 14-30 (2)" (second occurrence)
  /// - "2025-10-13 14-30 (3)" (third occurrence)
  Future<String> getUniqueFolderName({
    required String baseName,
    required String equipmentId,
  }) async {
    final db = await _db.database;

    // Query existing folders with similar names
    final existing = await db.query(
      'photo_folders',
      columns: ['name'],
      where: 'equipment_id = ? AND name LIKE ? AND is_deleted = 0',
      whereArgs: [equipmentId, '$baseName%'],
    );

    // If no matches, base name is unique
    if (existing.isEmpty) {
      return baseName;
    }

    // Extract names and find highest sequential number
    final existingNames = existing.map((row) => row['name'] as String).toList();

    // Check if base name exists without number
    bool baseExists = existingNames.contains(baseName);

    // Pattern to match sequential numbers: " (2)", " (3)", etc.
    final pattern = RegExp(r'\((\d+)\)$');
    int maxNum = 0;

    if (baseExists) {
      maxNum = 1; // Base name counts as (1)
    }

    // Find highest number in existing names
    for (final name in existingNames) {
      final match = pattern.firstMatch(name);
      if (match != null) {
        final num = int.parse(match.group(1)!);
        if (num > maxNum) {
          maxNum = num;
        }
      }
    }

    // If no sequential numbers found but base exists, next is (2)
    if (maxNum == 0 && baseExists) {
      return '$baseName (2)';
    }

    // If sequential numbers exist, increment highest
    if (maxNum > 0) {
      return '$baseName (${maxNum + 1})';
    }

    // Otherwise base name is unique
    return baseName;
  }

  /// Generate a unique name for a photo (single photo Quick Save)
  ///
  /// Example: "Image - 2025-10-13", "Image - 2025-10-13 (2)", etc.
  Future<String> getUniquePhotoName({
    required String baseName,
    required String equipmentId,
  }) async {
    // Use same logic as folders since photos can also have collisions
    return await getUniqueFolderName(
      baseName: baseName,
      equipmentId: equipmentId,
    );
  }
}
