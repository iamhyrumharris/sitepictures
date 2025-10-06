import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Contract test for POST /clients endpoint
/// Tests client creation per api-contract.yaml specification
void main() {
  group('POST /clients', () {
    const baseUrl = 'http://localhost:8080/v1';
    const testToken = 'test-jwt-token'; // Mock token for testing

    test('should return 201 with created client', () async {
      // Arrange
      final requestBody = {
        'name': 'Test Client',
        'description': 'Test client description',
      };

      // Act
      final response = await http.post(
        Uri.parse('$baseUrl/clients'),
        headers: {
          'Authorization': 'Bearer $testToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      // Assert
      expect(response.statusCode, equals(201));

      final responseData = jsonDecode(response.body);
      expect(responseData['id'], isA<String>());
      expect(responseData['name'], equals('Test Client'));
      expect(responseData['description'], equals('Test client description'));
      expect(responseData['isActive'], equals(true));
      expect(responseData['createdAt'], isA<String>());
    });

    test('should create client with only required fields', () async {
      // Arrange
      final requestBody = {
        'name': 'Minimal Client',
      };

      // Act
      final response = await http.post(
        Uri.parse('$baseUrl/clients'),
        headers: {
          'Authorization': 'Bearer $testToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      // Assert
      expect(response.statusCode, equals(201));

      final responseData = jsonDecode(response.body);
      expect(responseData['name'], equals('Minimal Client'));
    });

    test('should return 400 when name is missing', () async {
      // Arrange
      final requestBody = {
        'description': 'Client without name',
      };

      // Act
      final response = await http.post(
        Uri.parse('$baseUrl/clients'),
        headers: {
          'Authorization': 'Bearer $testToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      // Assert
      expect(response.statusCode, equals(400));
    });

    test('should return 400 when name exceeds 100 chars', () async {
      // Arrange
      final requestBody = {
        'name': 'A' * 101, // 101 characters
      };

      // Act
      final response = await http.post(
        Uri.parse('$baseUrl/clients'),
        headers: {
          'Authorization': 'Bearer $testToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      // Assert
      expect(response.statusCode, equals(400));
    });

    test('should return 400 when description exceeds 500 chars', () async {
      // Arrange
      final requestBody = {
        'name': 'Test Client',
        'description': 'A' * 501, // 501 characters
      };

      // Act
      final response = await http.post(
        Uri.parse('$baseUrl/clients'),
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
        'name': 'Test Client',
      };

      // Act
      final response = await http.post(
        Uri.parse('$baseUrl/clients'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      // Assert
      expect(response.statusCode, equals(401));
    });
  });
}
