import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Contract test for GET /clients/{id}/sites endpoint
/// Tests main site listing per api-contract.yaml specification
void main() {
  group('GET /clients/{id}/sites', skip: 'API contract tests require backend server', () {
    const baseUrl = 'http://localhost:8080/v1';
    const testToken = 'test-jwt-token'; // Mock token for testing
    const testClientId = '123e4567-e89b-12d3-a456-426614174000'; // Mock UUID

    test('should return 200 with array of main sites', () async {
      // Act
      final response = await http.get(
        Uri.parse('$baseUrl/clients/$testClientId/sites'),
        headers: {
          'Authorization': 'Bearer $testToken',
          'Content-Type': 'application/json',
        },
      );

      // Assert
      expect(response.statusCode, equals(200));

      final responseData = jsonDecode(response.body);
      expect(responseData, isA<List>());

      if (responseData.isNotEmpty) {
        final site = responseData[0];
        expect(site['id'], isA<String>());
        expect(site['clientId'], equals(testClientId));
        expect(site['name'], isA<String>());
        expect(site['isActive'], isA<bool>());
      }
    });

    test('should validate site schema with GPS coordinates', () async {
      // Act
      final response = await http.get(
        Uri.parse('$baseUrl/clients/$testClientId/sites'),
        headers: {
          'Authorization': 'Bearer $testToken',
          'Content-Type': 'application/json',
        },
      );

      // Assert
      expect(response.statusCode, equals(200));

      final responseData = jsonDecode(response.body);
      if (responseData.isNotEmpty) {
        final site = responseData[0];

        if (site['latitude'] != null) {
          expect(site['latitude'], isA<num>());
          expect(site['latitude'], greaterThanOrEqualTo(-90));
          expect(site['latitude'], lessThanOrEqualTo(90));
        }

        if (site['longitude'] != null) {
          expect(site['longitude'], isA<num>());
          expect(site['longitude'], greaterThanOrEqualTo(-180));
          expect(site['longitude'], lessThanOrEqualTo(180));
        }
      }
    });

    test('should return 401 without authentication', () async {
      // Act
      final response = await http.get(
        Uri.parse('$baseUrl/clients/$testClientId/sites'),
        headers: {'Content-Type': 'application/json'},
      );

      // Assert
      expect(response.statusCode, equals(401));
    });

    test('should return 404 for non-existent client', () async {
      // Act
      final response = await http.get(
        Uri.parse('$baseUrl/clients/00000000-0000-0000-0000-000000000000/sites'),
        headers: {
          'Authorization': 'Bearer $testToken',
          'Content-Type': 'application/json',
        },
      );

      // Assert
      expect(response.statusCode, equals(404));
    });

    test('should validate name length constraints', () async {
      // Act
      final response = await http.get(
        Uri.parse('$baseUrl/clients/$testClientId/sites'),
        headers: {
          'Authorization': 'Bearer $testToken',
          'Content-Type': 'application/json',
        },
      );

      // Assert
      expect(response.statusCode, equals(200));

      final responseData = jsonDecode(response.body);
      if (responseData.isNotEmpty) {
        final site = responseData[0];
        expect(site['name'].length, lessThanOrEqualTo(100));
      }
    });
  });
}
