import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Contract test for POST /sync endpoint
/// Tests sync functionality per api-contract.yaml specification
void main() {
  group('POST /sync', skip: 'API contract tests require backend server', () {
    const baseUrl = 'http://localhost:8080/v1';
    const testToken = 'test-jwt-token'; // Mock token for testing

    test('should return 200 with sync confirmation', () async {
      // Arrange
      final requestBody = {
        'entities': [
          {
            'type': 'photo',
            'operation': 'create',
            'data': {
              'id': '123e4567-e89b-12d3-a456-426614174000',
              'equipmentId': '223e4567-e89b-12d3-a456-426614174000',
              'timestamp': DateTime.now().toIso8601String(),
            }
          }
        ],
        'lastSyncAt': DateTime.now().subtract(Duration(hours: 1)).toIso8601String(),
      };

      // Act
      final response = await http.post(
        Uri.parse('$baseUrl/sync'),
        headers: {
          'Authorization': 'Bearer $testToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      // Assert
      expect(response.statusCode, equals(200));

      final responseData = jsonDecode(response.body);
      expect(responseData['syncedAt'], isA<String>());
      expect(responseData['conflicts'], isA<List>());
    });

    test('should handle multiple entity types', () async {
      // Arrange
      final requestBody = {
        'entities': [
          {
            'type': 'client',
            'operation': 'create',
            'data': {'id': 'client-1', 'name': 'Test Client'}
          },
          {
            'type': 'mainSite',
            'operation': 'update',
            'data': {'id': 'site-1', 'name': 'Updated Site'}
          },
          {
            'type': 'equipment',
            'operation': 'delete',
            'data': {'id': 'equip-1'}
          }
        ],
        'lastSyncAt': DateTime.now().subtract(Duration(hours: 1)).toIso8601String(),
      };

      // Act
      final response = await http.post(
        Uri.parse('$baseUrl/sync'),
        headers: {
          'Authorization': 'Bearer $testToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      // Assert
      expect(response.statusCode, equals(200));
    });

    test('should return 400 when entities array is missing', () async {
      // Arrange
      final requestBody = {
        'lastSyncAt': DateTime.now().toIso8601String(),
      };

      // Act
      final response = await http.post(
        Uri.parse('$baseUrl/sync'),
        headers: {
          'Authorization': 'Bearer $testToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      // Assert
      expect(response.statusCode, equals(400));
    });

    test('should return 400 when lastSyncAt is missing', () async {
      // Arrange
      final requestBody = {
        'entities': [],
      };

      // Act
      final response = await http.post(
        Uri.parse('$baseUrl/sync'),
        headers: {
          'Authorization': 'Bearer $testToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      // Assert
      expect(response.statusCode, equals(400));
    });

    test('should validate entity type enum', () async {
      // Arrange - invalid entity type
      final requestBody = {
        'entities': [
          {
            'type': 'invalidType',
            'operation': 'create',
            'data': {}
          }
        ],
        'lastSyncAt': DateTime.now().toIso8601String(),
      };

      // Act
      final response = await http.post(
        Uri.parse('$baseUrl/sync'),
        headers: {
          'Authorization': 'Bearer $testToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      // Assert
      expect(response.statusCode, equals(400));
    });

    test('should validate operation enum', () async {
      // Arrange - invalid operation
      final requestBody = {
        'entities': [
          {
            'type': 'photo',
            'operation': 'invalidOperation',
            'data': {}
          }
        ],
        'lastSyncAt': DateTime.now().toIso8601String(),
      };

      // Act
      final response = await http.post(
        Uri.parse('$baseUrl/sync'),
        headers: {
          'Authorization': 'Bearer $testToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      // Assert
      expect(response.statusCode, equals(400));
    });

    test('should return 401 without authentication', () async {
      // Arrange
      final requestBody = {
        'entities': [],
        'lastSyncAt': DateTime.now().toIso8601String(),
      };

      // Act
      final response = await http.post(
        Uri.parse('$baseUrl/sync'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      // Assert
      expect(response.statusCode, equals(401));
    });

    test('should handle conflicts in response', () async {
      // Arrange
      final requestBody = {
        'entities': [
          {
            'type': 'client',
            'operation': 'update',
            'data': {
              'id': 'conflict-id',
              'name': 'Updated Name',
              'updatedAt': DateTime.now().subtract(Duration(hours: 2)).toIso8601String(),
            }
          }
        ],
        'lastSyncAt': DateTime.now().subtract(Duration(hours: 3)).toIso8601String(),
      };

      // Act
      final response = await http.post(
        Uri.parse('$baseUrl/sync'),
        headers: {
          'Authorization': 'Bearer $testToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      // Assert
      expect(response.statusCode, equals(200));

      final responseData = jsonDecode(response.body);
      expect(responseData['conflicts'], isA<List>());

      if (responseData['conflicts'].isNotEmpty) {
        final conflict = responseData['conflicts'][0];
        expect(conflict, containsPair('entityId', isA<String>()));
        expect(conflict, containsPair('type', isA<String>()));
        expect(conflict, containsPair('resolution', isA<String>()));
      }
    });
  });
}
