import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Contract test for GET /clients endpoint
/// Tests client listing per api-contract.yaml specification
void main() {
  group('GET /clients', skip: 'API contract tests require backend server', () {
    const baseUrl = 'http://localhost:8080/v1';
    const testToken = 'test-jwt-token'; // Mock token for testing

    test('should return 200 with array of clients', () async {
      // Act
      final response = await http.get(
        Uri.parse('$baseUrl/clients'),
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
        final client = responseData[0];
        expect(client['id'], isA<String>());
        expect(client['name'], isA<String>());
        expect(client['isActive'], isA<bool>());
        expect(client['createdAt'], isA<String>());
      }
    });

    test('should filter by isActive query parameter', () async {
      // Act
      final response = await http.get(
        Uri.parse('$baseUrl/clients?isActive=true'),
        headers: {
          'Authorization': 'Bearer $testToken',
          'Content-Type': 'application/json',
        },
      );

      // Assert
      expect(response.statusCode, equals(200));

      final responseData = jsonDecode(response.body) as List;
      for (var client in responseData) {
        expect(client['isActive'], equals(true));
      }
    });

    test('should return 401 without authentication', () async {
      // Act
      final response = await http.get(
        Uri.parse('$baseUrl/clients'),
        headers: {'Content-Type': 'application/json'},
      );

      // Assert
      expect(response.statusCode, equals(401));
    });

    test('should validate client schema', () async {
      // Act
      final response = await http.get(
        Uri.parse('$baseUrl/clients'),
        headers: {
          'Authorization': 'Bearer $testToken',
          'Content-Type': 'application/json',
        },
      );

      // Assert
      expect(response.statusCode, equals(200));

      final responseData = jsonDecode(response.body);
      if (responseData.isNotEmpty) {
        final client = responseData[0];
        expect(client, containsPair('id', isA<String>()));
        expect(client, containsPair('name', isA<String>()));
        expect(client['name'].length, lessThanOrEqualTo(100));
        if (client['description'] != null) {
          expect(client['description'].length, lessThanOrEqualTo(500));
        }
      }
    });
  });
}
