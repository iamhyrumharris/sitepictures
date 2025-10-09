import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Contract test for POST /auth/login endpoint
/// Tests authentication flow per api-contract.yaml specification
void main() {
  group('POST /auth/login', skip: 'API contract tests require backend server', () {
    const baseUrl = 'http://localhost:8080/v1';

    test('should return 200 with token and user on valid credentials', () async {
      // Arrange
      final requestBody = {
        'email': 'test@example.com',
        'password': 'password123',
      };

      // Act
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      // Assert
      expect(response.statusCode, equals(200));

      final responseData = jsonDecode(response.body);
      expect(responseData, containsPair('token', isA<String>()));
      expect(responseData['user'], isA<Map>());
      expect(responseData['user']['email'], equals('test@example.com'));
      expect(responseData['user']['role'], isIn(['ADMIN', 'TECHNICIAN', 'VIEWER']));
    });

    test('should return 401 on invalid credentials', () async {
      // Arrange
      final requestBody = {
        'email': 'invalid@example.com',
        'password': 'wrongpassword',
      };

      // Act
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      // Assert
      expect(response.statusCode, equals(401));
    });

    test('should validate required fields', () async {
      // Arrange - missing password
      final requestBody = {
        'email': 'test@example.com',
      };

      // Act
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      // Assert
      expect(response.statusCode, equals(400));
    });

    test('should validate email format', () async {
      // Arrange
      final requestBody = {
        'email': 'not-an-email',
        'password': 'password123',
      };

      // Act
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      // Assert
      expect(response.statusCode, equals(400));
    });
  });
}
