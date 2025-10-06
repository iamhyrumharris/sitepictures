import 'package:flutter_test/flutter_test.dart';
import 'package:sitepictures/models/site.dart';

void main() {
  group('MainSite', () {
    test('creates main site with valid data', () {
      final site = MainSite(
        clientId: 'client-123',
        name: 'Factory North',
        address: '123 Industrial Way',
        latitude: 45.5,
        longitude: -122.6,
        createdBy: 'user-123',
      );

      expect(site.clientId, 'client-123');
      expect(site.name, 'Factory North');
      expect(site.address, '123 Industrial Way');
      expect(site.latitude, 45.5);
      expect(site.longitude, -122.6);
      expect(site.createdBy, 'user-123');
      expect(site.id, isNotEmpty);
      expect(site.isActive, true);
    });

    test('creates site without optional GPS coordinates', () {
      final site = MainSite(
        clientId: 'client-123',
        name: 'Factory North',
        createdBy: 'user-123',
      );

      expect(site.latitude, null);
      expect(site.longitude, null);
      expect(site.address, null);
    });

    test('isValid returns true for valid site', () {
      final site = MainSite(
        clientId: 'client-123',
        name: 'Factory North',
        createdBy: 'user-123',
      );

      expect(site.isValid(), true);
    });

    test('isValid returns false for empty name', () {
      final site = MainSite(
        clientId: 'client-123',
        name: '',
        createdBy: 'user-123',
      );

      expect(site.isValid(), false);
    });

    test('isValid returns false for name > 100 characters', () {
      final site = MainSite(
        clientId: 'client-123',
        name: 'A' * 101,
        createdBy: 'user-123',
      );

      expect(site.isValid(), false);
    });

    test('isValid returns false for empty clientId', () {
      final site = MainSite(
        clientId: '',
        name: 'Factory North',
        createdBy: 'user-123',
      );

      expect(site.isValid(), false);
    });

    test('isValid returns false for empty createdBy', () {
      final site = MainSite(
        clientId: 'client-123',
        name: 'Factory North',
        createdBy: '',
      );

      expect(site.isValid(), false);
    });

    test('isValid returns false for invalid latitude', () {
      final site1 = MainSite(
        clientId: 'client-123',
        name: 'Factory North',
        latitude: -91.0,
        createdBy: 'user-123',
      );
      final site2 = MainSite(
        clientId: 'client-123',
        name: 'Factory North',
        latitude: 91.0,
        createdBy: 'user-123',
      );

      expect(site1.isValid(), false);
      expect(site2.isValid(), false);
    });

    test('isValid returns false for invalid longitude', () {
      final site1 = MainSite(
        clientId: 'client-123',
        name: 'Factory North',
        longitude: -181.0,
        createdBy: 'user-123',
      );
      final site2 = MainSite(
        clientId: 'client-123',
        name: 'Factory North',
        longitude: 181.0,
        createdBy: 'user-123',
      );

      expect(site1.isValid(), false);
      expect(site2.isValid(), false);
    });

    test('isValid returns true for valid GPS coordinates', () {
      final site = MainSite(
        clientId: 'client-123',
        name: 'Factory North',
        latitude: -90.0,
        longitude: -180.0,
        createdBy: 'user-123',
      );

      expect(site.isValid(), true);
    });

    group('Serialization', () {
      test('toMap converts to database format', () {
        final site = MainSite(
          id: 'test-id',
          clientId: 'client-123',
          name: 'Factory North',
          address: '123 Industrial Way',
          latitude: 45.5,
          longitude: -122.6,
          createdBy: 'user-123',
        );

        final map = site.toMap();

        expect(map['id'], 'test-id');
        expect(map['client_id'], 'client-123');
        expect(map['name'], 'Factory North');
        expect(map['address'], '123 Industrial Way');
        expect(map['latitude'], 45.5);
        expect(map['longitude'], -122.6);
        expect(map['created_by'], 'user-123');
        expect(map['is_active'], 1);
      });

      test('fromMap creates site from database map', () {
        final map = {
          'id': 'test-id',
          'client_id': 'client-123',
          'name': 'Factory North',
          'address': '123 Industrial Way',
          'latitude': 45.5,
          'longitude': -122.6,
          'created_by': 'user-123',
          'created_at': '2025-01-01T00:00:00.000Z',
          'updated_at': '2025-01-01T00:00:00.000Z',
          'is_active': 1,
        };

        final site = MainSite.fromMap(map);

        expect(site.id, 'test-id');
        expect(site.clientId, 'client-123');
        expect(site.name, 'Factory North');
        expect(site.latitude, 45.5);
        expect(site.longitude, -122.6);
        expect(site.isActive, true);
      });

      test('fromMap handles null GPS coordinates', () {
        final map = {
          'id': 'test-id',
          'client_id': 'client-123',
          'name': 'Factory North',
          'address': null,
          'latitude': null,
          'longitude': null,
          'created_by': 'user-123',
          'created_at': '2025-01-01T00:00:00.000Z',
          'updated_at': '2025-01-01T00:00:00.000Z',
          'is_active': 1,
        };

        final site = MainSite.fromMap(map);

        expect(site.latitude, null);
        expect(site.longitude, null);
      });

      test('toJson converts to API format', () {
        final site = MainSite(
          id: 'test-id',
          clientId: 'client-123',
          name: 'Factory North',
          createdBy: 'user-123',
        );

        final json = site.toJson();

        expect(json['id'], 'test-id');
        expect(json['clientId'], 'client-123');
        expect(json['name'], 'Factory North');
        expect(json['isActive'], true);
      });

      test('fromJson creates site from API JSON', () {
        final json = {
          'id': 'test-id',
          'clientId': 'client-123',
          'name': 'Factory North',
          'address': '123 Industrial Way',
          'latitude': 45.5,
          'longitude': -122.6,
          'createdBy': 'user-123',
          'createdAt': '2025-01-01T00:00:00.000Z',
          'updatedAt': '2025-01-01T00:00:00.000Z',
          'isActive': true,
        };

        final site = MainSite.fromJson(json);

        expect(site.id, 'test-id');
        expect(site.clientId, 'client-123');
        expect(site.latitude, 45.5);
      });
    });

    test('copyWith creates new instance with updated fields', () {
      final original = MainSite(
        clientId: 'client-123',
        name: 'Old Name',
        createdBy: 'user-123',
      );

      final updated = original.copyWith(
        name: 'New Name',
        address: 'New Address',
        latitude: 45.5,
      );

      expect(updated.name, 'New Name');
      expect(updated.address, 'New Address');
      expect(updated.latitude, 45.5);
      expect(updated.clientId, original.clientId);
    });

    test('equality based on id', () {
      final site1 = MainSite(
        id: 'same-id',
        clientId: 'client-123',
        name: 'Site 1',
        createdBy: 'user-123',
      );
      final site2 = MainSite(
        id: 'same-id',
        clientId: 'client-456',
        name: 'Site 2',
        createdBy: 'user-123',
      );

      expect(site1 == site2, true);
    });
  });

  group('SubSite', () {
    test('creates sub site with valid data', () {
      final subSite = SubSite(
        mainSiteId: 'main-site-123',
        name: 'Assembly Line',
        description: 'Main assembly area',
        createdBy: 'user-123',
      );

      expect(subSite.mainSiteId, 'main-site-123');
      expect(subSite.name, 'Assembly Line');
      expect(subSite.description, 'Main assembly area');
      expect(subSite.createdBy, 'user-123');
      expect(subSite.id, isNotEmpty);
      expect(subSite.isActive, true);
    });

    test('isValid returns true for valid sub site', () {
      final subSite = SubSite(
        mainSiteId: 'main-site-123',
        name: 'Assembly Line',
        createdBy: 'user-123',
      );

      expect(subSite.isValid(), true);
    });

    test('isValid returns false for empty name', () {
      final subSite = SubSite(
        mainSiteId: 'main-site-123',
        name: '',
        createdBy: 'user-123',
      );

      expect(subSite.isValid(), false);
    });

    test('isValid returns false for name > 100 characters', () {
      final subSite = SubSite(
        mainSiteId: 'main-site-123',
        name: 'A' * 101,
        createdBy: 'user-123',
      );

      expect(subSite.isValid(), false);
    });

    test('isValid returns false for empty mainSiteId', () {
      final subSite = SubSite(
        mainSiteId: '',
        name: 'Assembly Line',
        createdBy: 'user-123',
      );

      expect(subSite.isValid(), false);
    });

    test('isValid returns false for empty createdBy', () {
      final subSite = SubSite(
        mainSiteId: 'main-site-123',
        name: 'Assembly Line',
        createdBy: '',
      );

      expect(subSite.isValid(), false);
    });

    group('Serialization', () {
      test('toMap converts to database format', () {
        final subSite = SubSite(
          id: 'test-id',
          mainSiteId: 'main-site-123',
          name: 'Assembly Line',
          description: 'Main assembly area',
          createdBy: 'user-123',
        );

        final map = subSite.toMap();

        expect(map['id'], 'test-id');
        expect(map['main_site_id'], 'main-site-123');
        expect(map['name'], 'Assembly Line');
        expect(map['description'], 'Main assembly area');
        expect(map['created_by'], 'user-123');
        expect(map['is_active'], 1);
      });

      test('fromMap creates sub site from database map', () {
        final map = {
          'id': 'test-id',
          'main_site_id': 'main-site-123',
          'name': 'Assembly Line',
          'description': 'Main assembly area',
          'created_by': 'user-123',
          'created_at': '2025-01-01T00:00:00.000Z',
          'updated_at': '2025-01-01T00:00:00.000Z',
          'is_active': 1,
        };

        final subSite = SubSite.fromMap(map);

        expect(subSite.id, 'test-id');
        expect(subSite.mainSiteId, 'main-site-123');
        expect(subSite.name, 'Assembly Line');
        expect(subSite.description, 'Main assembly area');
        expect(subSite.isActive, true);
      });

      test('toJson converts to API format', () {
        final subSite = SubSite(
          id: 'test-id',
          mainSiteId: 'main-site-123',
          name: 'Assembly Line',
          createdBy: 'user-123',
        );

        final json = subSite.toJson();

        expect(json['id'], 'test-id');
        expect(json['mainSiteId'], 'main-site-123');
        expect(json['name'], 'Assembly Line');
        expect(json['isActive'], true);
      });

      test('fromJson creates sub site from API JSON', () {
        final json = {
          'id': 'test-id',
          'mainSiteId': 'main-site-123',
          'name': 'Assembly Line',
          'description': 'Main assembly area',
          'createdBy': 'user-123',
          'createdAt': '2025-01-01T00:00:00.000Z',
          'updatedAt': '2025-01-01T00:00:00.000Z',
          'isActive': true,
        };

        final subSite = SubSite.fromJson(json);

        expect(subSite.id, 'test-id');
        expect(subSite.mainSiteId, 'main-site-123');
        expect(subSite.name, 'Assembly Line');
      });
    });

    test('copyWith creates new instance with updated fields', () {
      final original = SubSite(
        mainSiteId: 'main-site-123',
        name: 'Old Name',
        createdBy: 'user-123',
      );

      final updated = original.copyWith(
        name: 'New Name',
        description: 'New description',
      );

      expect(updated.name, 'New Name');
      expect(updated.description, 'New description');
      expect(updated.mainSiteId, original.mainSiteId);
    });

    test('equality based on id', () {
      final subSite1 = SubSite(
        id: 'same-id',
        mainSiteId: 'main-site-123',
        name: 'SubSite 1',
        createdBy: 'user-123',
      );
      final subSite2 = SubSite(
        id: 'same-id',
        mainSiteId: 'main-site-456',
        name: 'SubSite 2',
        createdBy: 'user-123',
      );

      expect(subSite1 == subSite2, true);
    });
  });
}
