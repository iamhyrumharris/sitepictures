import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:serverpod_auth_client/serverpod_auth_client.dart' as auth;
import 'package:serverpod_client/serverpod_client.dart';
import '../models/user.dart';
import 'serverpod_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  static const String _userKey = 'user_data';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final ServerpodService _serverpodService = ServerpodService.instance;

  User? _currentUser;
  String? _token;

  factory AuthService() => _instance;

  AuthService._internal();

  User? get currentUser => _currentUser;
  String? get token => _token;
  bool get isAuthenticated => _token != null && _currentUser != null;

  Future<void> initialize() async {
    await _serverpodService.initialize();
    await _loadStoredCredentials();
  }

  Future<void> _loadStoredCredentials() async {
    try {
      final userData = await _storage.read(key: _userKey);

      if (userData != null) {
        final userMap = jsonDecode(userData) as Map<String, dynamic>;
        _currentUser = User.fromJson(userMap);
      }

      final storedKey = await _serverpodService.authKeyManager.get();
      if (storedKey != null) {
        _token = storedKey;
        if (_currentUser == null) {
          final remoteUser =
              await _serverpodService.authCaller.status.getUserInfo();
          if (remoteUser != null) {
            _currentUser = _mapUserInfo(remoteUser);
            await _persistUser(_currentUser!);
          }
        }
      }
    } catch (e) {
      // If loading fails, clear credentials
      await clearCredentials();
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      await _serverpodService.initialize();

      final authResponse = await _serverpodService.authCaller.email.authenticate(
        email,
        password,
      );

      if (authResponse.success &&
          authResponse.key != null &&
          authResponse.userInfo != null) {
        await _serverpodService.authKeyManager.put(authResponse.key!);
        _token = authResponse.key;
        _currentUser = _mapUserInfo(authResponse.userInfo!);
        await _persistUser(_currentUser!);
        return true;
      }

      // Development mode: Use test credentials
      if (email == 'test@test.com' && password == 'test123') {
        return _handleFallbackLogin(email);
      }

      // TODO: Replace with actual API endpoint when backend is ready
      final httpResponse = await http.post(
        Uri.parse('https://api.sitepictures.com/v1/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (httpResponse.statusCode == 200) {
        final data = jsonDecode(httpResponse.body) as Map<String, dynamic>;
        _token = data['token'] as String;
        _currentUser = User.fromJson(data['user'] as Map<String, dynamic>);

        await _persistUser(_currentUser!);

        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  Future<RegistrationResult> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      await _serverpodService.initialize();

      final response = await _serverpodService.client.account.registerUser(
        email.trim(),
        password,
        fullName.trim(),
      );

      if (response.success &&
          response.key != null &&
          response.userInfo != null) {
        await _serverpodService.authKeyManager.put(response.key!);
        _token = response.key;
        _currentUser = _mapUserInfo(response.userInfo!);
        await _persistUser(_currentUser!);
        return const RegistrationResult(success: true);
      }

      final message = _mapFailReason(response.failReason) ??
          'Registration failed. Please try again.';
      return RegistrationResult(success: false, message: message);
    } on ServerpodClientException catch (e) {
      return RegistrationResult(success: false, message: e.message);
    } catch (e) {
      return RegistrationResult(
        success: false,
        message: 'Registration failed. ${e.toString()}',
      );
    }
  }

  Future<void> logout() async {
    try {
      await _serverpodService.authCaller.status.signOutDevice();
    } catch (_) {
      // Ignore network errors during logout.
    }
    await clearCredentials();
  }

  Future<void> clearCredentials() async {
    _token = null;
    _currentUser = null;
    await _storage.delete(key: _userKey);
    await _serverpodService.authKeyManager.remove();
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
    try {
      await _serverpodService.initialize();
      final userInfo = await _serverpodService.authCaller.status.getUserInfo();
      if (userInfo != null) {
        _currentUser = _mapUserInfo(userInfo);
        _token = await _serverpodService.authKeyManager.get();
        if (_currentUser != null && _token != null) {
          await _persistUser(_currentUser!);
          return true;
        }
      }
      return false;
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

  Future<void> _persistUser(User user) async {
    await _storage.write(key: _userKey, value: jsonEncode(user.toJson()));
  }

  User _mapUserInfo(auth.UserInfo info) {
    final role = _roleFromScopes(info.scopeNames);
    return User(
      id: info.userIdentifier,
      email: info.email ?? 'unknown@sitepictures.dev',
      name: info.fullName ?? info.userName ?? info.userIdentifier,
      role: role,
      createdAt: info.created,
      updatedAt: DateTime.now(),
    );
  }

  UserRole _roleFromScopes(List<String> scopes) {
    if (scopes.any((scope) => scope.toLowerCase().contains('admin'))) {
      return UserRole.admin;
    }
    if (scopes.any((scope) => scope.toLowerCase().contains('editor'))) {
      return UserRole.technician;
    }
    return UserRole.viewer;
  }

  String? _mapFailReason(auth.AuthenticationFailReason? reason) {
    switch (reason) {
      case auth.AuthenticationFailReason.invalidCredentials:
        return 'Invalid credentials.';
      case auth.AuthenticationFailReason.userCreationDenied:
        return 'Account creation is not allowed.';
      case auth.AuthenticationFailReason.tooManyFailedAttempts:
        return 'Too many attempts. Please wait and try again.';
      case auth.AuthenticationFailReason.blocked:
        return 'Your account has been blocked.';
      case auth.AuthenticationFailReason.internalError:
        return 'Server error while creating account.';
      default:
        return null;
    }
  }

  Future<bool> _handleFallbackLogin(String email) async {
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

    await _persistUser(testUser);
    return true;
  }
}

class RegistrationResult {
  const RegistrationResult({required this.success, this.message});

  final bool success;
  final String? message;
}
