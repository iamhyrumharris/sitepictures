import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_server/module.dart' as auth;

class AccountEndpoint extends Endpoint {
  @override
  bool get requireLogin => false;

  Future<auth.AuthenticationResponse> registerUser(
    Session session,
    String email,
    String password,
    String fullName,
  ) async {
    final normalizedEmail = email.trim().toLowerCase();
    final trimmedName = fullName.trim();

    if (!_isValidEmail(normalizedEmail)) {
      throw Exception('Please provide a valid email address.');
    }
    if (password.length < auth.AuthConfig.current.minPasswordLength) {
      throw Exception(
        'Password must be at least ${auth.AuthConfig.current.minPasswordLength} characters.',
      );
    }

    final existing = await auth.Users.findUserByEmail(session, normalizedEmail);
    if (existing != null) {
      throw Exception('An account with this email already exists.');
    }

    final displayName = trimmedName.isNotEmpty
        ? trimmedName
        : normalizedEmail.split('@').first;

    final userInfo = await auth.Emails.createUser(
      session,
      displayName,
      normalizedEmail,
      password,
    );

    if (userInfo == null) {
      throw Exception('Unable to create account. Please try again.');
    }

    if (trimmedName.isNotEmpty && userInfo.id != null) {
      await auth.Users.changeFullName(session, userInfo.id!, trimmedName);
    }

    return await auth.Emails.authenticate(
      session,
      normalizedEmail,
      password,
    );
  }

  bool _isValidEmail(String input) {
    return input.contains('@') && input.contains('.');
  }
}
