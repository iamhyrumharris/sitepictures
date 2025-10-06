import 'package:flutter_test/flutter_test.dart';
import 'package:sitepictures/models/user.dart';

void main() {
  group('UserRole', () {
    test('toUpperCase returns correct string', () {
      expect(UserRole.admin.toUpperCase(), 'ADMIN');
      expect(UserRole.technician.toUpperCase(), 'TECHNICIAN');
      expect(UserRole.viewer.toUpperCase(), 'VIEWER');
    });

    test('fromString parses correctly', () {
      expect(UserRole.fromString('ADMIN'), UserRole.admin);
      expect(UserRole.fromString('admin'), UserRole.admin);
      expect(UserRole.fromString('TECHNICIAN'), UserRole.technician);
      expect(UserRole.fromString('technician'), UserRole.technician);
      expect(UserRole.fromString('VIEWER'), UserRole.viewer);
      expect(UserRole.fromString('viewer'), UserRole.viewer);
    });

    test('fromString defaults to viewer for invalid role', () {
      expect(UserRole.fromString('invalid'), UserRole.viewer);
      expect(UserRole.fromString(''), UserRole.viewer);
    });
  });

  group('User', () {
    test('creates user with valid data', () {
      final user = User(
        email: 'test@example.com',
        name: 'Test User',
        role: UserRole.admin,
      );

      expect(user.email, 'test@example.com');
      expect(user.name, 'Test User');
      expect(user.role, UserRole.admin);
      expect(user.id, isNotEmpty);
      expect(user.createdAt, isNotNull);
      expect(user.updatedAt, isNotNull);
    });

    test('generates UUID when id not provided', () {
      final user1 = User(
        email: 'user1@example.com',
        name: 'User 1',
        role: UserRole.admin,
      );
      final user2 = User(
        email: 'user2@example.com',
        name: 'User 2',
        role: UserRole.admin,
      );

      expect(user1.id, isNotEmpty);
      expect(user2.id, isNotEmpty);
      expect(user1.id, isNot(equals(user2.id)));
    });

    test('uses provided id when given', () {
      const testId = 'test-uuid-123';
      final user = User(
        id: testId,
        email: 'test@example.com',
        name: 'Test User',
        role: UserRole.admin,
      );

      expect(user.id, testId);
    });

    test('isValid returns true for valid user', () {
      final user = User(
        email: 'test@example.com',
        name: 'Test User',
        role: UserRole.admin,
      );

      expect(user.isValid(), true);
    });

    test('isValid returns false for invalid email', () {
      final user1 = User(email: '', name: 'Test User', role: UserRole.admin);
      final user2 = User(
        email: 'not-an-email',
        name: 'Test User',
        role: UserRole.admin,
      );

      expect(user1.isValid(), false);
      expect(user2.isValid(), false);
    });

    test('isValid returns false for empty name', () {
      final user = User(
        email: 'test@example.com',
        name: '',
        role: UserRole.admin,
      );

      expect(user.isValid(), false);
    });

    group('Permissions', () {
      test('admin has all permissions', () {
        final admin = User(
          email: 'admin@example.com',
          name: 'Admin',
          role: UserRole.admin,
        );

        expect(admin.canCreate(), true);
        expect(admin.canEdit(), true);
        expect(admin.canDelete(), true);
        expect(admin.canManageUsers(), true);
        expect(admin.canView(), true);
      });

      test('technician has create and edit permissions', () {
        final tech = User(
          email: 'tech@example.com',
          name: 'Technician',
          role: UserRole.technician,
        );

        expect(tech.canCreate(), true);
        expect(tech.canEdit(), true);
        expect(tech.canDelete(), false);
        expect(tech.canManageUsers(), false);
        expect(tech.canView(), true);
      });

      test('viewer has only view permission', () {
        final viewer = User(
          email: 'viewer@example.com',
          name: 'Viewer',
          role: UserRole.viewer,
        );

        expect(viewer.canCreate(), false);
        expect(viewer.canEdit(), false);
        expect(viewer.canDelete(), false);
        expect(viewer.canManageUsers(), false);
        expect(viewer.canView(), true);
      });
    });

    group('Serialization', () {
      test('toMap converts to database format', () {
        final user = User(
          id: 'test-id',
          email: 'test@example.com',
          name: 'Test User',
          role: UserRole.admin,

          lastSyncAt: '2025-01-01T00:00:00.000Z',
        );

        final map = user.toMap();

        expect(map['id'], 'test-id');
        expect(map['email'], 'test@example.com');
        expect(map['name'], 'Test User');
        expect(map['role'], 'ADMIN');
        expect(map['last_sync_at'], '2025-01-01T00:00:00.000Z');
        expect(map['created_at'], isNotNull);
        expect(map['updated_at'], isNotNull);
      });

      test('fromMap creates user from database map', () {
        final map = {
          'id': 'test-id',
          'email': 'test@example.com',
          'name': 'Test User',
          'role': 'ADMIN',
          'created_at': '2025-01-01T00:00:00.000Z',
          'updated_at': '2025-01-01T00:00:00.000Z',
          'last_sync_at': '2025-01-01T00:00:00.000Z',
        };

        final user = User.fromMap(map);

        expect(user.id, 'test-id');
        expect(user.email, 'test@example.com');
        expect(user.name, 'Test User');
        expect(user.role, UserRole.admin);
        expect(user.lastSyncAt, '2025-01-01T00:00:00.000Z');
      });

      test('toJson converts to API format', () {
        final user = User(
          id: 'test-id',
          email: 'test@example.com',
          name: 'Test User',
          role: UserRole.technician,
        );

        final json = user.toJson();

        expect(json['id'], 'test-id');
        expect(json['email'], 'test@example.com');
        expect(json['name'], 'Test User');
        expect(json['role'], 'TECHNICIAN');
        expect(json['createdAt'], isNotNull);
        expect(json['updatedAt'], isNotNull);
      });

      test('fromJson creates user from API JSON', () {
        final json = {
          'id': 'test-id',
          'email': 'test@example.com',
          'name': 'Test User',
          'role': 'VIEWER',
          'createdAt': '2025-01-01T00:00:00.000Z',
          'updatedAt': '2025-01-01T00:00:00.000Z',
          'lastSyncAt': null,
        };

        final user = User.fromJson(json);

        expect(user.id, 'test-id');
        expect(user.email, 'test@example.com');
        expect(user.name, 'Test User');
        expect(user.role, UserRole.viewer);
      });
    });

    test('copyWith creates new instance with updated fields', () {
      final original = User(
        id: 'test-id',
        email: 'old@example.com',
        name: 'Old Name',
        role: UserRole.viewer,
      );

      final updated = original.copyWith(
        email: 'new@example.com',
        name: 'New Name',
        role: UserRole.admin,
      );

      expect(updated.id, original.id);
      expect(updated.email, 'new@example.com');
      expect(updated.name, 'New Name');
      expect(updated.role, UserRole.admin);
      expect(updated.createdAt, original.createdAt);
      expect(updated.updatedAt.isAfter(original.updatedAt), true);
    });

    test('toString returns readable format', () {
      final user = User(
        id: 'test-id',
        email: 'test@example.com',
        name: 'Test User',
        role: UserRole.admin,
      );

      final str = user.toString();

      expect(str.contains('test-id'), true);
      expect(str.contains('test@example.com'), true);
      expect(str.contains('Test User'), true);
      expect(str.contains('admin'), true);
    });

    test('equality based on id', () {
      final user1 = User(
        id: 'same-id',
        email: 'user1@example.com',
        name: 'User 1',
        role: UserRole.admin,
      );
      final user2 = User(
        id: 'same-id',
        email: 'user2@example.com',
        name: 'User 2',
        role: UserRole.viewer,
      );
      final user3 = User(
        id: 'different-id',
        email: 'user1@example.com',
        name: 'User 1',
        role: UserRole.admin,
      );

      expect(user1 == user2, true);
      expect(user1 == user3, false);
    });

    test('hashCode based on id', () {
      final user = User(
        id: 'test-id',
        email: 'test@example.com',
        name: 'Test User',
        role: UserRole.admin,
      );

      expect(user.hashCode, 'test-id'.hashCode);
    });
  });
}
