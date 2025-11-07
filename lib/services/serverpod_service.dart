import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:serverpod_auth_client/module.dart' as auth;
import 'package:serverpod_client/serverpod_client.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';
import 'package:sitepictures_server_client/sitepictures_server_client.dart';

class SecureStorageAuthKeyManager extends AuthenticationKeyManager {
  SecureStorageAuthKeyManager();

  static const _keyName = 'serverpod_auth_key';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  @override
  Future<String?> get() => _storage.read(key: _keyName);

  @override
  Future<void> put(String key) => _storage.write(key: _keyName, value: key);

  @override
  Future<void> remove() => _storage.delete(key: _keyName);
}

/// Centralized access point for the generated Serverpod client.
class ServerpodService {
  ServerpodService._internal();

  static final ServerpodService instance = ServerpodService._internal();

  late final Client client;
  late final SecureStorageAuthKeyManager _authKeyManager;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    final baseUrl = _resolveBaseUrl();
    _authKeyManager = SecureStorageAuthKeyManager();

    client = Client(
      baseUrl,
      authenticationKeyManager: _authKeyManager,
    )..connectivityMonitor = FlutterConnectivityMonitor();

    _initialized = true;
  }

  SecureStorageAuthKeyManager get authKeyManager => _authKeyManager;

  auth.Caller get authCaller => client.modules.auth;

  String _resolveBaseUrl() {
    const envOverride = String.fromEnvironment('SERVERPOD_URL');
    if (envOverride.isNotEmpty) {
      return envOverride;
    }

    if (kIsWeb) {
      return 'http://localhost:8080/';
    }

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8080/';
    }

    return 'http://10.168.0.175:8080/';
  }
}
