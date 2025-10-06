import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../models/user.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  User? _currentUser;
  String? _token;

  factory AuthService() => _instance;

  AuthService._internal();

  User? get currentUser => _currentUser;
  String? get token => _token;
  bool get isAuthenticated => _token != null && _currentUser != null;

  Future<void> initialize() async {
    await _loadStoredCredentials();
  }

  Future<void> _loadStoredCredentials() async {
    try {
      _token = await _storage.read(key: _tokenKey);
      final userData = await _storage.read(key: _userKey);

      if (_token != null && userData != null) {
        final userMap = jsonDecode(userData) as Map<String, dynamic>;
        _currentUser = User.fromJson(userMap);
      }
    } catch (e) {
      // If loading fails, clear credentials
      await clearCredentials();
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      // Development mode: Use test credentials
      if (email == 'test@test.com' && password == 'test123') {
        final testUser = User(
          id: 'test-user-001',
          email: email,
          name: 'Test User',
          role: UserRole.admin,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        _token = 'dev-token-${DateTime.now().millisecondsSinceEpoch}';
        _currentUser = testUser;

        await _storage.write(key: _tokenKey, value: _token);
        await _storage.write(key: _userKey, value: jsonEncode(testUser.toJson()));

        return true;
      }

      // TODO: Replace with actual API endpoint when backend is ready
      final response = await http.post(
        Uri.parse('https://api.sitepictures.com/v1/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        _token = data['token'] as String;
        _currentUser = User.fromJson(data['user'] as Map<String, dynamic>);

        await _storage.write(key: _tokenKey, value: _token);
        await _storage.write(key: _userKey, value: jsonEncode(data['user']));

        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    await clearCredentials();
  }

  Future<void> clearCredentials() async {
    _token = null;
    _currentUser = null;
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey);
  }

  Map<String, String> getAuthHeaders() {
    if (_token == null) {
      return {};
    }
    return {
      'Authorization': 'Bearer $_token',
      'Content-Type': 'application/json',
    };
  }

  Future<bool> refreshToken() async {
    if (_token == null) return false;

    try {
      // TODO: Implement token refresh logic
      // For now, return true if we have a token
      return true;
    } catch (e) {
      return false;
    }
  }

  bool hasPermission(String permission) {
    if (_currentUser == null) return false;

    switch (permission) {
      case 'create':
        return _currentUser!.role == UserRole.admin ||
            _currentUser!.role == UserRole.technician;
      case 'edit':
        return _currentUser!.role == UserRole.admin ||
            _currentUser!.role == UserRole.technician;
      case 'delete':
        return _currentUser!.role == UserRole.admin;
      case 'view':
        return true; // All authenticated users can view
      default:
        return false;
    }
  }
}
