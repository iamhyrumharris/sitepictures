import 'package:flutter_test/flutter_test.dart';
import 'package:sitepictures/models/client.dart';

void main() {
  group('Client', () {
    test('creates client with valid data', () {
      final client = Client(
        name: 'ACME Industrial',
        description: 'Test client description',
        createdBy: 'user-123',
      );

      expect(client.name, 'ACME Industrial');
      expect(client.description, 'Test client description');
      expect(client.createdBy, 'user-123');
      expect(client.id, isNotEmpty);
      expect(client.isActive, true);
      expect(client.createdAt, isNotNull);
      expect(client.updatedAt, isNotNull);
    });

    test('generates UUID when id not provided', () {
      final client1 = Client(name: 'Client 1', createdBy: 'user-123');
      final client2 = Client(name: 'Client 2', createdBy: 'user-123');

      expect(client1.id, isNotEmpty);
      expect(client2.id, isNotEmpty);
      expect(client1.id, isNot(equals(client2.id)));
    });

    test('uses provided id when given', () {
      const testId = 'test-uuid-123';
      final client = Client(
        id: testId,
        name: 'Test Client',
        createdBy: 'user-123',
      );

      expect(client.id, testId);
    });

    test('isValid returns true for valid client', () {
      final client = Client(
        name: 'ACME Corp',
        description: 'A valid description',
        createdBy: 'user-123',
      );

      expect(client.isValid(), true);
    });

    test('isValid returns false for empty name', () {
      final client = Client(
        name: '',
        createdBy: 'user-123',
      );

      expect(client.isValid(), false);
    });

    test('isValid returns false for name > 100 characters', () {
      final client = Client(
        name: 'A' * 101,
        createdBy: 'user-123',
      );

      expect(client.isValid(), false);
    });

    test('isValid returns false for description > 500 characters', () {
      final client = Client(
        name: 'ACME Corp',
        description: 'A' * 501,
        createdBy: 'user-123',
      );

      expect(client.isValid(), false);
    });

    test('isValid returns false for empty createdBy', () {
      final client = Client(
        name: 'ACME Corp',
        createdBy: '',
      );

      expect(client.isValid(), false);
    });

    test('isValid returns false for invalid characters in name', () {
      final client1 = Client(
        name: 'ACME@Corp',
        createdBy: 'user-123',
      );
      final client2 = Client(
        name: 'ACME#Corp',
        createdBy: 'user-123',
      );

      expect(client1.isValid(), false);
      expect(client2.isValid(), false);
    });

    test('isValid returns true for name with alphanumeric and spaces', () {
      final client = Client(
        name: 'ACME Corp 123',
        createdBy: 'user-123',
      );

      expect(client.isValid(), true);
    });

    group('Serialization', () {
      test('toMap converts to database format', () {
        final client = Client(
          id: 'test-id',
          name: 'ACME Corp',
          description: 'Test description',
          createdBy: 'user-123',
          isActive: true,
        );

        final map = client.toMap();

        expect(map['id'], 'test-id');
        expect(map['name'], 'ACME Corp');
        expect(map['description'], 'Test description');
        expect(map['created_by'], 'user-123');
        expect(map['is_active'], 1);
        expect(map['created_at'], isNotNull);
        expect(map['updated_at'], isNotNull);
      });

      test('toMap converts isActive false to 0', () {
        final client = Client(
          name: 'ACME Corp',
          createdBy: 'user-123',
          isActive: false,
        );

        final map = client.toMap();
        expect(map['is_active'], 0);
      });

      test('fromMap creates client from database map', () {
        final map = {
          'id': 'test-id',
          'name': 'ACME Corp',
          'description': 'Test description',
          'created_by': 'user-123',
          'created_at': '2025-01-01T00:00:00.000Z',
          'updated_at': '2025-01-01T00:00:00.000Z',
          'is_active': 1,
        };

        final client = Client.fromMap(map);

        expect(client.id, 'test-id');
        expect(client.name, 'ACME Corp');
        expect(client.description, 'Test description');
        expect(client.createdBy, 'user-123');
        expect(client.isActive, true);
      });

      test('fromMap handles is_active = 0', () {
        final map = {
          'id': 'test-id',
          'name': 'ACME Corp',
          'description': null,
          'created_by': 'user-123',
          'created_at': '2025-01-01T00:00:00.000Z',
          'updated_at': '2025-01-01T00:00:00.000Z',
          'is_active': 0,
        };

        final client = Client.fromMap(map);
        expect(client.isActive, false);
      });

      test('toJson converts to API format', () {
        final client = Client(
          id: 'test-id',
          name: 'ACME Corp',
          description: 'Test description',
          createdBy: 'user-123',
        );

        final json = client.toJson();

        expect(json['id'], 'test-id');
        expect(json['name'], 'ACME Corp');
        expect(json['description'], 'Test description');
        expect(json['createdBy'], 'user-123');
        expect(json['isActive'], true);
        expect(json['createdAt'], isNotNull);
        expect(json['updatedAt'], isNotNull);
      });

      test('fromJson creates client from API JSON', () {
        final json = {
          'id': 'test-id',
          'name': 'ACME Corp',
          'description': 'Test description',
          'createdBy': 'user-123',
          'createdAt': '2025-01-01T00:00:00.000Z',
          'updatedAt': '2025-01-01T00:00:00.000Z',
          'isActive': true,
        };

        final client = Client.fromJson(json);

        expect(client.id, 'test-id');
        expect(client.name, 'ACME Corp');
        expect(client.description, 'Test description');
        expect(client.createdBy, 'user-123');
        expect(client.isActive, true);
      });

      test('fromJson defaults isActive to true when null', () {
        final json = {
          'id': 'test-id',
          'name': 'ACME Corp',
          'description': null,
          'createdBy': 'user-123',
          'createdAt': '2025-01-01T00:00:00.000Z',
          'updatedAt': '2025-01-01T00:00:00.000Z',
        };

        final client = Client.fromJson(json);
        expect(client.isActive, true);
      });
    });

    test('copyWith creates new instance with updated fields', () {
      final original = Client(
        id: 'test-id',
        name: 'Old Name',
        description: 'Old description',
        createdBy: 'user-123',
        isActive: true,
      );

      final updated = original.copyWith(
        name: 'New Name',
        description: 'New description',
        isActive: false,
      );

      expect(updated.id, original.id);
      expect(updated.name, 'New Name');
      expect(updated.description, 'New description');
      expect(updated.isActive, false);
      expect(updated.createdBy, original.createdBy);
      expect(updated.createdAt, original.createdAt);
      expect(updated.updatedAt.isAfter(original.updatedAt), true);
    });

    test('copyWith preserves original values when no updates', () {
      final original = Client(
        name: 'ACME Corp',
        description: 'Description',
        createdBy: 'user-123',
      );

      final copy = original.copyWith();

      expect(copy.name, original.name);
      expect(copy.description, original.description);
      expect(copy.isActive, original.isActive);
    });

    test('toString returns readable format', () {
      final client = Client(
        id: 'test-id',
        name: 'ACME Corp',
        createdBy: 'user-123',
        isActive: true,
      );

      final str = client.toString();

      expect(str.contains('test-id'), true);
      expect(str.contains('ACME Corp'), true);
      expect(str.contains('true'), true);
    });

    test('equality based on id', () {
      final client1 = Client(
        id: 'same-id',
        name: 'Client 1',
        createdBy: 'user-123',
      );
      final client2 = Client(
        id: 'same-id',
        name: 'Client 2',
        createdBy: 'user-456',
      );
      final client3 = Client(
        id: 'different-id',
        name: 'Client 1',
        createdBy: 'user-123',
      );

      expect(client1 == client2, true);
      expect(client1 == client3, false);
    });

    test('hashCode based on id', () {
      final client = Client(
        id: 'test-id',
        name: 'ACME Corp',
        createdBy: 'user-123',
      );

      expect(client.hashCode, 'test-id'.hashCode);
    });
  });
}
