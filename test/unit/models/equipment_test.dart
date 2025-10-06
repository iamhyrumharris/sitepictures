import 'package:flutter_test/flutter_test.dart';
import 'package:sitepictures/models/equipment.dart';

void main() {
  group('Equipment', () {
    test('creates equipment for main site', () {
      final equipment = Equipment(
        mainSiteId: 'main-site-123',
        name: 'Generator A',
        serialNumber: 'SN-12345',
        manufacturer: 'ACME Corp',
        model: 'Gen-1000',
        createdBy: 'user-123',
      );

      expect(equipment.mainSiteId, 'main-site-123');
      expect(equipment.subSiteId, null);
      expect(equipment.name, 'Generator A');
      expect(equipment.serialNumber, 'SN-12345');
      expect(equipment.manufacturer, 'ACME Corp');
      expect(equipment.model, 'Gen-1000');
      expect(equipment.id, isNotEmpty);
      expect(equipment.isActive, true);
    });

    test('creates equipment for sub site', () {
      final equipment = Equipment(
        subSiteId: 'sub-site-123',
        name: 'Compressor B',
        createdBy: 'user-123',
      );

      expect(equipment.subSiteId, 'sub-site-123');
      expect(equipment.mainSiteId, null);
      expect(equipment.name, 'Compressor B');
    });

    test('throws assertion error when both mainSiteId and subSiteId are null', () {
      expect(
        () => Equipment(
          name: 'Invalid Equipment',
          createdBy: 'user-123',
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('throws assertion error when both mainSiteId and subSiteId are set',
        () {
      expect(
        () => Equipment(
          mainSiteId: 'main-site-123',
          subSiteId: 'sub-site-123',
          name: 'Invalid Equipment',
          createdBy: 'user-123',
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('isValid returns true for valid equipment', () {
      final equipment = Equipment(
        mainSiteId: 'main-site-123',
        name: 'Generator A',
        createdBy: 'user-123',
      );

      expect(equipment.isValid(), true);
    });

    test('isValid returns false for empty name', () {
      final equipment = Equipment(
        mainSiteId: 'main-site-123',
        name: '',
        createdBy: 'user-123',
      );

      expect(equipment.isValid(), false);
    });

    test('isValid returns false for name > 100 characters', () {
      final equipment = Equipment(
        mainSiteId: 'main-site-123',
        name: 'A' * 101,
        createdBy: 'user-123',
      );

      expect(equipment.isValid(), false);
    });

    test('isValid returns false for empty createdBy', () {
      final equipment = Equipment(
        mainSiteId: 'main-site-123',
        name: 'Generator A',
        createdBy: '',
      );

      expect(equipment.isValid(), false);
    });

    test('parentSiteId returns mainSiteId when present', () {
      final equipment = Equipment(
        mainSiteId: 'main-site-123',
        name: 'Generator A',
        createdBy: 'user-123',
      );

      expect(equipment.parentSiteId, 'main-site-123');
    });

    test('parentSiteId returns subSiteId when mainSiteId is null', () {
      final equipment = Equipment(
        subSiteId: 'sub-site-123',
        name: 'Compressor B',
        createdBy: 'user-123',
      );

      expect(equipment.parentSiteId, 'sub-site-123');
    });

    group('Serialization', () {
      test('toMap converts to database format', () {
        final equipment = Equipment(
          id: 'test-id',
          mainSiteId: 'main-site-123',
          name: 'Generator A',
          serialNumber: 'SN-12345',
          manufacturer: 'ACME Corp',
          model: 'Gen-1000',
          createdBy: 'user-123',
        );

        final map = equipment.toMap();

        expect(map['id'], 'test-id');
        expect(map['main_site_id'], 'main-site-123');
        expect(map['sub_site_id'], null);
        expect(map['name'], 'Generator A');
        expect(map['serial_number'], 'SN-12345');
        expect(map['manufacturer'], 'ACME Corp');
        expect(map['model'], 'Gen-1000');
        expect(map['created_by'], 'user-123');
        expect(map['is_active'], 1);
      });

      test('fromMap creates equipment from database map', () {
        final map = {
          'id': 'test-id',
          'main_site_id': 'main-site-123',
          'sub_site_id': null,
          'name': 'Generator A',
          'serial_number': 'SN-12345',
          'manufacturer': 'ACME Corp',
          'model': 'Gen-1000',
          'created_by': 'user-123',
          'created_at': '2025-01-01T00:00:00.000Z',
          'updated_at': '2025-01-01T00:00:00.000Z',
          'is_active': 1,
        };

        final equipment = Equipment.fromMap(map);

        expect(equipment.id, 'test-id');
        expect(equipment.mainSiteId, 'main-site-123');
        expect(equipment.subSiteId, null);
        expect(equipment.name, 'Generator A');
        expect(equipment.serialNumber, 'SN-12345');
        expect(equipment.isActive, true);
      });

      test('fromMap handles equipment with subSiteId', () {
        final map = {
          'id': 'test-id',
          'main_site_id': null,
          'sub_site_id': 'sub-site-123',
          'name': 'Compressor B',
          'serial_number': null,
          'manufacturer': null,
          'model': null,
          'created_by': 'user-123',
          'created_at': '2025-01-01T00:00:00.000Z',
          'updated_at': '2025-01-01T00:00:00.000Z',
          'is_active': 1,
        };

        final equipment = Equipment.fromMap(map);

        expect(equipment.mainSiteId, null);
        expect(equipment.subSiteId, 'sub-site-123');
        expect(equipment.serialNumber, null);
      });

      test('toJson converts to API format', () {
        final equipment = Equipment(
          id: 'test-id',
          mainSiteId: 'main-site-123',
          name: 'Generator A',
          createdBy: 'user-123',
        );

        final json = equipment.toJson();

        expect(json['id'], 'test-id');
        expect(json['mainSiteId'], 'main-site-123');
        expect(json['subSiteId'], null);
        expect(json['name'], 'Generator A');
        expect(json['isActive'], true);
      });

      test('fromJson creates equipment from API JSON', () {
        final json = {
          'id': 'test-id',
          'mainSiteId': 'main-site-123',
          'subSiteId': null,
          'name': 'Generator A',
          'serialNumber': 'SN-12345',
          'manufacturer': 'ACME Corp',
          'model': 'Gen-1000',
          'createdBy': 'user-123',
          'createdAt': '2025-01-01T00:00:00.000Z',
          'updatedAt': '2025-01-01T00:00:00.000Z',
          'isActive': true,
        };

        final equipment = Equipment.fromJson(json);

        expect(equipment.id, 'test-id');
        expect(equipment.mainSiteId, 'main-site-123');
        expect(equipment.name, 'Generator A');
      });
    });

    test('copyWith creates new instance with updated fields', () {
      final original = Equipment(
        mainSiteId: 'main-site-123',
        name: 'Old Name',
        serialNumber: 'OLD-123',
        createdBy: 'user-123',
      );

      final updated = original.copyWith(
        name: 'New Name',
        serialNumber: 'NEW-456',
        manufacturer: 'New Manufacturer',
      );

      expect(updated.name, 'New Name');
      expect(updated.serialNumber, 'NEW-456');
      expect(updated.manufacturer, 'New Manufacturer');
      expect(updated.mainSiteId, original.mainSiteId);
      expect(updated.id, original.id);
    });

    test('toString returns readable format', () {
      final equipment = Equipment(
        id: 'test-id',
        mainSiteId: 'main-site-123',
        name: 'Generator A',
        createdBy: 'user-123',
      );

      final str = equipment.toString();

      expect(str.contains('test-id'), true);
      expect(str.contains('Generator A'), true);
      expect(str.contains('main-site-123'), true);
    });

    test('equality based on id', () {
      final equipment1 = Equipment(
        id: 'same-id',
        mainSiteId: 'main-site-123',
        name: 'Equipment 1',
        createdBy: 'user-123',
      );
      final equipment2 = Equipment(
        id: 'same-id',
        subSiteId: 'sub-site-123',
        name: 'Equipment 2',
        createdBy: 'user-456',
      );

      expect(equipment1 == equipment2, true);
    });

    test('hashCode based on id', () {
      final equipment = Equipment(
        id: 'test-id',
        mainSiteId: 'main-site-123',
        name: 'Generator A',
        createdBy: 'user-123',
      );

      expect(equipment.hashCode, 'test-id'.hashCode);
    });
  });
}
