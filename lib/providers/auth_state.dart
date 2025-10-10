import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthState extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _currentUser;
  bool _isAuthenticated = false;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    await _authService.initialize();
    _currentUser = _authService.currentUser;
    _isAuthenticated = _authService.isAuthenticated;

    // Development mode: Auto-login with test user if not authenticated
    if (!_isAuthenticated) {
      debugPrint('AuthState: No stored credentials, attempting auto-login...');
      final success = await login('test@test.com', 'test123');
      if (success) {
        debugPrint('AuthState: Auto-login successful');
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    final success = await _authService.login(email, password);

    if (success) {
      _currentUser = _authService.currentUser;
      _isAuthenticated = true;
    }

    _isLoading = false;
    notifyListeners();

    return success;
  }

  Future<void> logout() async {
    await _authService.logout();
    _currentUser = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  bool hasPermission(String permission) {
    return _authService.hasPermission(permission);
  }
}
