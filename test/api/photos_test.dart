import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Contract test for POST /equipment/{id}/photos endpoint
/// Tests photo upload per api-contract.yaml specification
void main() {
  group('POST /equipment/{id}/photos', skip: 'API contract tests require backend server', () {
    const baseUrl = 'http://localhost:8080/v1';
    const testToken = 'test-jwt-token'; // Mock token for testing
    const testEquipmentId = '123e4567-e89b-12d3-a456-426614174000'; // Mock UUID

    test('should return 201 with uploaded photo metadata', () async {
      // Arrange
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/equipment/$testEquipmentId/photos'),
      );
      request.headers['Authorization'] = 'Bearer $testToken';
      request.fields['latitude'] = '40.7128';
      request.fields['longitude'] = '-74.0060';
      request.fields['timestamp'] = DateTime.now().toIso8601String();

      // Mock photo file
      request.files.add(
        http.MultipartFile.fromString(
          'photo',
          'fake-image-data',
          filename: 'test.jpg',
        ),
      );

      // Act
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      // Assert
      expect(response.statusCode, equals(201));

      final responseData = jsonDecode(response.body);
      expect(responseData['id'], isA<String>());
      expect(responseData['equipmentId'], equals(testEquipmentId));
      expect(responseData['latitude'], equals(40.7128));
      expect(responseData['longitude'], equals(-74.0060));
      expect(responseData['timestamp'], isA<String>());
      expect(responseData['remoteUrl'], isA<String>());
    });

    test('should return 400 when latitude is missing', () async {
      // Arrange
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/equipment/$testEquipmentId/photos'),
      );
      request.headers['Authorization'] = 'Bearer $testToken';
      request.fields['longitude'] = '-74.0060';
      request.fields['timestamp'] = DateTime.now().toIso8601String();
      request.files.add(
        http.MultipartFile.fromString('photo', 'fake-image-data'),
      );

      // Act
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      // Assert
      expect(response.statusCode, equals(400));
    });

    test('should return 400 when longitude is missing', () async {
      // Arrange
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/equipment/$testEquipmentId/photos'),
      );
      request.headers['Authorization'] = 'Bearer $testToken';
      request.fields['latitude'] = '40.7128';
      request.fields['timestamp'] = DateTime.now().toIso8601String();
      request.files.add(
        http.MultipartFile.fromString('photo', 'fake-image-data'),
      );

      // Act
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      // Assert
      expect(response.statusCode, equals(400));
    });

    test('should return 400 when timestamp is missing', () async {
      // Arrange
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/equipment/$testEquipmentId/photos'),
      );
      request.headers['Authorization'] = 'Bearer $testToken';
      request.fields['latitude'] = '40.7128';
      request.fields['longitude'] = '-74.0060';
      request.files.add(
        http.MultipartFile.fromString('photo', 'fake-image-data'),
      );

      // Act
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      // Assert
      expect(response.statusCode, equals(400));
    });

    test('should return 400 when photo file is missing', () async {
      // Arrange
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/equipment/$testEquipmentId/photos'),
      );
      request.headers['Authorization'] = 'Bearer $testToken';
      request.fields['latitude'] = '40.7128';
      request.fields['longitude'] = '-74.0060';
      request.fields['timestamp'] = DateTime.now().toIso8601String();

      // Act
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      // Assert
      expect(response.statusCode, equals(400));
    });

    test('should return 401 without authentication', () async {
      // Arrange
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/equipment/$testEquipmentId/photos'),
      );
      request.fields['latitude'] = '40.7128';
      request.fields['longitude'] = '-74.0060';
      request.fields['timestamp'] = DateTime.now().toIso8601String();
      request.files.add(
        http.MultipartFile.fromString('photo', 'fake-image-data'),
      );

      // Act
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      // Assert
      expect(response.statusCode, equals(401));
    });

    test('should validate GPS coordinate ranges', () async {
      // Arrange - invalid latitude
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/equipment/$testEquipmentId/photos'),
      );
      request.headers['Authorization'] = 'Bearer $testToken';
      request.fields['latitude'] = '95.0'; // Invalid: > 90
      request.fields['longitude'] = '-74.0060';
      request.fields['timestamp'] = DateTime.now().toIso8601String();
      request.files.add(
        http.MultipartFile.fromString('photo', 'fake-image-data'),
      );

      // Act
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      // Assert
      expect(response.statusCode, equals(400));
    });
  });
}
