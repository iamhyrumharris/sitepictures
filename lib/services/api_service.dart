import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  static const String baseUrl = 'https://api.sitepictures.com/v1';

  final AuthService _authService = AuthService();

  factory ApiService() => _instance;

  ApiService._internal();

  Future<http.Response> get(String endpoint) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    return await http.get(
      uri,
      headers: _authService.getAuthHeaders(),
    );
  }

  Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    return await http.post(
      uri,
      headers: _authService.getAuthHeaders(),
      body: jsonEncode(body),
    );
  }

  Future<http.Response> put(String endpoint, Map<String, dynamic> body) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    return await http.put(
      uri,
      headers: _authService.getAuthHeaders(),
      body: jsonEncode(body),
    );
  }

  Future<http.Response> delete(String endpoint) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    return await http.delete(
      uri,
      headers: _authService.getAuthHeaders(),
    );
  }

  Future<http.StreamedResponse> uploadFile(
    String endpoint,
    String filePath,
    Map<String, String> fields,
  ) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final request = http.MultipartRequest('POST', uri);

    // Add authentication headers
    request.headers.addAll(_authService.getAuthHeaders());

    // Add form fields
    request.fields.addAll(fields);

    // Add file
    request.files.add(await http.MultipartFile.fromPath('photo', filePath));

    return await request.send();
  }
}
