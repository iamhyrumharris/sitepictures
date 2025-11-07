import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';

/// Authentication endpoint for user login and token management
class AuthEndpoint extends Endpoint {
  /// Login with email and basic auth
  /// Returns user object if successful
  Future<User?> login(Session session, String email, String password) async {
    // TODO: Implement proper password hashing and verification
    // For now, this is a placeholder implementation

    final user = await User.db.findFirstRow(
      session,
      where: (t) => t.email.equals(email),
    );

    if (user == null) {
      throw Exception('Invalid credentials');
    }

    // Update last sync time
    user.lastSyncAt = DateTime.now();
    await User.db.updateRow(session, user);

    return user;
  }

  /// Register a new user
  Future<User> register(
    Session session,
    String email,
    String name,
    String password,
    String role,
  ) async {
    // Check if user already exists
    final existing = await User.db.findFirstRow(
      session,
      where: (t) => t.email.equals(email),
    );

    if (existing != null) {
      throw Exception('User already exists');
    }

    // TODO: Hash password before storing
    final user = User(
      uuid: _generateUuid(),
      email: email,
      name: name,
      role: role,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await User.db.insertRow(session, user);
    return user;
  }

  /// Get current user by UUID
  Future<User?> getCurrentUser(Session session, String uuid) async {
    return await User.db.findFirstRow(
      session,
      where: (t) => t.uuid.equals(uuid),
    );
  }

  /// Logout (client-side token removal)
  Future<void> logout(Session session) async {
    // Token management would be handled client-side
    // This is a placeholder for any server-side logout logic
  }

  String _generateUuid() {
    return '${DateTime.now().millisecondsSinceEpoch}-${DateTime.now().microsecond % 10000}';
  }
}
