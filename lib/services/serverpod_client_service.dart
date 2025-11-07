import 'package:sitepictures_server_client/sitepictures_server_client.dart';

/// Serverpod client service for backend communication
/// This replaces the old HTTP-based ApiService with type-safe Serverpod calls
class ServerpodClientService {
  static final ServerpodClientService _instance = ServerpodClientService._internal();
  late Client _client;

  // Configuration
  static const String defaultServerUrl = 'http://localhost:8080/';

  factory ServerpodClientService() => _instance;

  ServerpodClientService._internal();

  /// Initialize the Serverpod client
  /// Call this during app startup
  void initialize({String? serverUrl}) {
    // Ensure URL ends with trailing slash (required by Serverpod)
    String url = serverUrl ?? defaultServerUrl;
    if (!url.endsWith('/')) {
      url = '$url/';
    }

    _client = Client(
      url,
      // authenticationKeyManager is optional and will be created by default
    );
  }

  /// Get the client instance
  /// Throws if not initialized
  Client get client {
    return _client;
  }

  /// Check if client is initialized
  bool get isInitialized {
    try {
      // Check if _client has been initialized
      // ignore: unnecessary_null_comparison
      return _client != null;
    } catch (e) {
      return false;
    }
  }

  /// Close the client connection
  void close() {
    _client.close();
  }
}
