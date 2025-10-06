import 'package:flutter_test/flutter_test.dart';
import 'package:sitepictures/models/client.dart';

void main() {
  group('Client Creation Tests', () {
    test('Create client with valid data', () {
      final client = Client(
        name: 'Test Client',
        description: 'Test Description',
        createdBy: 'test-user-001',
      );

      expect(client.name, 'Test Client');
      expect(client.description, 'Test Description');
      expect(client.createdBy, 'test-user-001');
      expect(client.isActive, true);
    });

    test('Create client with system user', () {
      final client = Client(
        name: 'Test Client',
        description: null,
        createdBy: 'system',
      );

      expect(client.name, 'Test Client');
      expect(client.description, null);
      expect(client.createdBy, 'system');
    });

    test('Client toMap creates correct database format', () {
      final client = Client(
        name: 'Test Client',
        description: 'Test Description',
        createdBy: 'test-user-001',
      );

      final map = client.toMap();

      expect(map['name'], 'Test Client');
      expect(map['description'], 'Test Description');
      expect(map['created_by'], 'test-user-001');
      expect(map['is_active'], 1);
      expect(map['id'], isNotNull);
      expect(map['created_at'], isNotNull);
      expect(map['updated_at'], isNotNull);
    });

    test('Client toJson creates correct API format', () {
      final client = Client(
        name: 'Test Client',
        description: 'Test Description',
        createdBy: 'test-user-001',
      );

      final json = client.toJson();

      expect(json['name'], 'Test Client');
      expect(json['description'], 'Test Description');
      expect(json['createdBy'], 'test-user-001');
      expect(json['isActive'], true);
    });
  });
}
