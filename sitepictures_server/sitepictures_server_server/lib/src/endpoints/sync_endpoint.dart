import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';

/// Sync endpoint for bidirectional synchronization with conflict resolution
class SyncEndpoint extends Endpoint {
  /// Get changes since last sync timestamp
  /// Returns all entities modified after the given timestamp
  Future<Map<String, dynamic>> getChangesSince(
    Session session,
    DateTime since,
  ) async {
    // Fetch all changed entities
    final companies = await Company.db.find(
      session,
      where: (t) => t.updatedAt > since,
    );

    final mainSites = await MainSite.db.find(
      session,
      where: (t) => t.updatedAt > since,
    );

    final subSites = await SubSite.db.find(
      session,
      where: (t) => t.updatedAt > since,
    );

    final equipment = await Equipment.db.find(
      session,
      where: (t) => t.updatedAt > since,
    );

    final photos = await Photo.db.find(
      session,
      where: (t) => t.createdAt > since,
      limit: 100, // Limit for performance
    );

    final folders = await PhotoFolder.db.find(
      session,
      where: (t) => t.createdAt > since,
    );

    return {
      'companies': companies.map((c) => c.toJson()).toList(),
      'mainSites': mainSites.map((s) => s.toJson()).toList(),
      'subSites': subSites.map((s) => s.toJson()).toList(),
      'equipment': equipment.map((e) => e.toJson()).toList(),
      'photos': photos.map((p) => p.toJson()).toList(),
      'folders': folders.map((f) => f.toJson()).toList(),
      'syncTimestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Push local changes to server
  /// Handles conflict resolution with last-write-wins strategy
  Future<Map<String, dynamic>> pushChanges(
    Session session,
    List<Map<String, dynamic>> changes,
  ) async {
    final results = <String, dynamic>{
      'success': <String>[],
      'conflicts': <Map<String, dynamic>>[],
      'errors': <Map<String, dynamic>>[],
    };

    for (final change in changes) {
      try {
        final entityType = change['entityType'] as String;
        final operation = change['operation'] as String; // create, update, delete
        final data = change['data'] as Map<String, dynamic>;

        switch (entityType) {
          case 'company':
            await _handleCompanyChange(session, operation, data, results);
            break;
          case 'mainSite':
            await _handleMainSiteChange(session, operation, data, results);
            break;
          case 'subSite':
            await _handleSubSiteChange(session, operation, data, results);
            break;
          case 'equipment':
            await _handleEquipmentChange(session, operation, data, results);
            break;
          case 'photo':
            await _handlePhotoChange(session, operation, data, results);
            break;
          case 'folder':
            await _handleFolderChange(session, operation, data, results);
            break;
          default:
            results['errors'].add({
              'entityType': entityType,
              'error': 'Unknown entity type',
            });
        }
      } catch (e) {
        results['errors'].add({
          'change': change,
          'error': e.toString(),
        });
      }
    }

    return results;
  }

  Future<void> _handleCompanyChange(
    Session session,
    String operation,
    Map<String, dynamic> data,
    Map<String, dynamic> results,
  ) async {
    final uuid = data['uuid'] as String;

    if (operation == 'create' || operation == 'update') {
      final existing = await Company.db.findFirstRow(
        session,
        where: (t) => t.uuid.equals(uuid),
      );

      if (existing != null) {
        // Check for conflicts (server version is newer)
        final serverUpdated = existing.updatedAt;
        final clientUpdated = DateTime.parse(data['updatedAt'] as String);

        if (serverUpdated.isAfter(clientUpdated)) {
          results['conflicts'].add({
            'entityType': 'company',
            'uuid': uuid,
            'serverVersion': existing.toJson(),
          });
          return;
        }

        // Update existing
        existing.name = data['name'] as String;
        existing.description = data['description'] as String?;
        existing.updatedAt = DateTime.now();
        await Company.db.updateRow(session, existing);
      } else {
        // Create new
        final company = Company.fromJson(data);
        await Company.db.insertRow(session, company);
      }

      results['success'].add('company:$uuid');
    }
  }

  Future<void> _handleMainSiteChange(
    Session session,
    String operation,
    Map<String, dynamic> data,
    Map<String, dynamic> results,
  ) async {
    final uuid = data['uuid'] as String;

    if (operation == 'create' || operation == 'update') {
      final existing = await MainSite.db.findFirstRow(
        session,
        where: (t) => t.uuid.equals(uuid),
      );

      if (existing != null) {
        final serverUpdated = existing.updatedAt;
        final clientUpdated = DateTime.parse(data['updatedAt'] as String);

        if (serverUpdated.isAfter(clientUpdated)) {
          results['conflicts'].add({
            'entityType': 'mainSite',
            'uuid': uuid,
            'serverVersion': existing.toJson(),
          });
          return;
        }

        existing.name = data['name'] as String;
        existing.address = data['address'] as String?;
        existing.latitude = data['latitude'] as double?;
        existing.longitude = data['longitude'] as double?;
        existing.updatedAt = DateTime.now();
        await MainSite.db.updateRow(session, existing);
      } else {
        final mainSite = MainSite.fromJson(data);
        await MainSite.db.insertRow(session, mainSite);
      }

      results['success'].add('mainSite:$uuid');
    }
  }

  Future<void> _handleSubSiteChange(
    Session session,
    String operation,
    Map<String, dynamic> data,
    Map<String, dynamic> results,
  ) async {
    final uuid = data['uuid'] as String;

    if (operation == 'create' || operation == 'update') {
      final existing = await SubSite.db.findFirstRow(
        session,
        where: (t) => t.uuid.equals(uuid),
      );

      if (existing != null) {
        existing.name = data['name'] as String;
        existing.description = data['description'] as String?;
        existing.updatedAt = DateTime.now();
        await SubSite.db.updateRow(session, existing);
      } else {
        final subSite = SubSite.fromJson(data);
        await SubSite.db.insertRow(session, subSite);
      }

      results['success'].add('subSite:$uuid');
    }
  }

  Future<void> _handleEquipmentChange(
    Session session,
    String operation,
    Map<String, dynamic> data,
    Map<String, dynamic> results,
  ) async {
    final uuid = data['uuid'] as String;

    if (operation == 'create' || operation == 'update') {
      final existing = await Equipment.db.findFirstRow(
        session,
        where: (t) => t.uuid.equals(uuid),
      );

      if (existing != null) {
        existing.name = data['name'] as String;
        existing.serialNumber = data['serialNumber'] as String?;
        existing.manufacturer = data['manufacturer'] as String?;
        existing.model = data['model'] as String?;
        existing.updatedAt = DateTime.now();
        await Equipment.db.updateRow(session, existing);
      } else {
        final equipment = Equipment.fromJson(data);
        await Equipment.db.insertRow(session, equipment);
      }

      results['success'].add('equipment:$uuid');
    }
  }

  Future<void> _handlePhotoChange(
    Session session,
    String operation,
    Map<String, dynamic> data,
    Map<String, dynamic> results,
  ) async {
    final uuid = data['uuid'] as String;

    if (operation == 'create') {
      final existing = await Photo.db.findFirstRow(
        session,
        where: (t) => t.uuid.equals(uuid),
      );

      if (existing == null) {
        final photo = Photo.fromJson(data);
        await Photo.db.insertRow(session, photo);
        results['success'].add('photo:$uuid');
      }
    }
  }

  Future<void> _handleFolderChange(
    Session session,
    String operation,
    Map<String, dynamic> data,
    Map<String, dynamic> results,
  ) async {
    final uuid = data['uuid'] as String;

    if (operation == 'create') {
      final existing = await PhotoFolder.db.findFirstRow(
        session,
        where: (t) => t.uuid.equals(uuid),
      );

      if (existing == null) {
        final folder = PhotoFolder.fromJson(data);
        await PhotoFolder.db.insertRow(session, folder);
        results['success'].add('folder:$uuid');
      }
    }
  }
}
