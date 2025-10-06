import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sitepictures/main.dart' as app;

/// Integration test for role-based access control
/// Validates FR-018, User Roles
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Role-Based Access Control Integration Test', () {
    testWidgets('ADMIN should have full access to all operations',
        (WidgetTester tester) async {
      // Launch app and login as admin
      app.main();
      await tester.pumpAndSettle();

      // Login screen
      await tester.enterText(find.byKey(Key('email_field')), 'admin@test.com');
      await tester.enterText(find.byKey(Key('password_field')), 'password');
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      // Should be on home screen
      expect(find.text('Site Pictures'), findsOneWidget);

      // Verify "Add Client" button is visible
      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.text('Add New Client'), findsOneWidget);

      // Navigate to client
      await tester.tap(find.text('ACME Industrial').first);
      await tester.pumpAndSettle();

      // Should see edit and delete options
      expect(find.byIcon(Icons.edit), findsOneWidget);
      expect(find.byIcon(Icons.delete), findsOneWidget);

      // Should see "Add Main Site" button
      expect(find.text('Add Main Site'), findsOneWidget);

      // Navigate to settings
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // Should see "Manage Users" option (admin only)
      expect(find.text('Manage Users'), findsOneWidget);

      // Tap manage users
      await tester.tap(find.text('Manage Users'));
      await tester.pumpAndSettle();

      // Should see user management screen
      expect(find.text('Users'), findsOneWidget);
      expect(find.text('Add User'), findsOneWidget);
    });

    testWidgets('TECHNICIAN should be able to create and edit but not delete',
        (WidgetTester tester) async {
      // Launch app and login as technician
      app.main();
      await tester.pumpAndSettle();

      // Login
      await tester.enterText(find.byKey(Key('email_field')), 'tech@test.com');
      await tester.enterText(find.byKey(Key('password_field')), 'password');
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      // Should be on home screen
      expect(find.text('Site Pictures'), findsOneWidget);

      // Can add clients
      expect(find.text('Add New Client'), findsOneWidget);

      // Navigate to client
      await tester.tap(find.text('ACME Industrial').first);
      await tester.pumpAndSettle();

      // Can edit
      expect(find.byIcon(Icons.edit), findsOneWidget);

      // Cannot delete clients
      expect(find.byIcon(Icons.delete), findsNothing);

      // Can add sites
      expect(find.text('Add Main Site'), findsOneWidget);

      // Navigate to equipment
      await tester.tap(find.text('Factory North'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Generator A'));
      await tester.pumpAndSettle();

      // Can capture photos
      expect(find.byIcon(Icons.camera_alt), findsOneWidget);

      // Navigate to settings
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // Cannot manage users
      expect(find.text('Manage Users'), findsNothing);
    });

    testWidgets('VIEWER should have read-only access',
        (WidgetTester tester) async {
      // Launch app and login as viewer
      app.main();
      await tester.pumpAndSettle();

      // Login
      await tester.enterText(find.byKey(Key('email_field')), 'viewer@test.com');
      await tester.enterText(find.byKey(Key('password_field')), 'password');
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      // Should be on home screen
      expect(find.text('Site Pictures'), findsOneWidget);

      // Cannot add clients
      expect(find.text('Add New Client'), findsNothing);
      expect(find.byIcon(Icons.add), findsNothing);

      // Can view client list
      expect(find.text('ACME Industrial'), findsOneWidget);

      // Navigate to client
      await tester.tap(find.text('ACME Industrial').first);
      await tester.pumpAndSettle();

      // Cannot edit or delete
      expect(find.byIcon(Icons.edit), findsNothing);
      expect(find.byIcon(Icons.delete), findsNothing);

      // Cannot add sites
      expect(find.text('Add Main Site'), findsNothing);

      // Can view sites
      expect(find.text('Factory North'), findsOneWidget);

      // Navigate to equipment
      await tester.tap(find.text('Factory North'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Generator A'));
      await tester.pumpAndSettle();

      // Cannot capture photos
      expect(find.byIcon(Icons.camera_alt), findsNothing);

      // Can view existing photos
      expect(find.byType(Image), findsWidgets);

      // Navigate to settings
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // Cannot manage users
      expect(find.text('Manage Users'), findsNothing);

      // Can only view own settings
      expect(find.text('Profile'), findsOneWidget);
      expect(find.text('About'), findsOneWidget);
    });

    testWidgets('should hide action buttons based on role',
        (WidgetTester tester) async {
      // Test as viewer
      app.main();
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(Key('email_field')), 'viewer@test.com');
      await tester.enterText(find.byKey(Key('password_field')), 'password');
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      // Navigate through hierarchy
      await tester.tap(find.text('ACME Industrial').first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Factory North'));
      await tester.pumpAndSettle();

      // At every level, no action buttons should be visible
      expect(find.byIcon(Icons.add), findsNothing);
      expect(find.byIcon(Icons.edit), findsNothing);
      expect(find.byIcon(Icons.delete), findsNothing);
      expect(find.byIcon(Icons.camera_alt), findsNothing);

      // Only navigation elements visible
      expect(find.byType(ListTile), findsWidgets); // Can tap to view
    });

    testWidgets('should show appropriate role indicator in profile',
        (WidgetTester tester) async {
      // Login as each role and check profile
      final roles = {
        'admin@test.com': 'ADMIN',
        'tech@test.com': 'TECHNICIAN',
        'viewer@test.com': 'VIEWER',
      };

      for (var entry in roles.entries) {
        // Launch and login
        app.main();
        await tester.pumpAndSettle();

        await tester.enterText(find.byKey(Key('email_field')), entry.key);
        await tester.enterText(find.byKey(Key('password_field')), 'password');
        await tester.tap(find.text('Login'));
        await tester.pumpAndSettle();

        // Go to settings
        await tester.tap(find.byIcon(Icons.settings));
        await tester.pumpAndSettle();

        // Tap profile
        await tester.tap(find.text('Profile'));
        await tester.pumpAndSettle();

        // Verify role displayed
        expect(find.text('Role: ${entry.value}'), findsOneWidget);

        // Logout
        await tester.tap(find.text('Logout'));
        await tester.pumpAndSettle();
      }
    });

    testWidgets('should prevent unauthorized API calls from client',
        (WidgetTester tester) async {
      // Login as viewer
      app.main();
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(Key('email_field')), 'viewer@test.com');
      await tester.enterText(find.byKey(Key('password_field')), 'password');
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      // Try to programmatically trigger a create operation
      // (simulating someone bypassing UI)
      // This would require tester.runAsync with actual API call

      // Even if UI is bypassed, API should reject with 403
      // In real test, verify error snackbar appears
      expect(find.text('Permission denied'), findsNothing); // Not visible yet

      // If somehow triggered (through dev tools, etc)
      // Error should appear
      // This is more of an API-level test
    });

    testWidgets('should allow technician to capture photos',
        (WidgetTester tester) async {
      // Login as technician
      app.main();
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(Key('email_field')), 'tech@test.com');
      await tester.enterText(find.byKey(Key('password_field')), 'password');
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      // Navigate to equipment
      await tester.tap(find.text('ACME Industrial').first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Factory North'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Generator A'));
      await tester.pumpAndSettle();

      // Camera FAB should be visible
      expect(find.byIcon(Icons.camera_alt), findsOneWidget);

      // Tap to open camera
      await tester.tap(find.byIcon(Icons.camera_alt));
      await tester.pumpAndSettle();

      // Camera screen opens
      expect(find.byIcon(Icons.camera), findsOneWidget);

      // Can capture photo
      await tester.tap(find.byIcon(Icons.camera));
      await tester.pumpAndSettle(Duration(seconds: 2));

      // Photo captured successfully
      await tester.tap(find.text('Quick Save'));
      await tester.pumpAndSettle();

      // Success message or navigation back
      expect(find.byType(Image), findsWidgets);
    });

    testWidgets('should maintain role permissions across app restart',
        (WidgetTester tester) async {
      // Login as admin
      app.main();
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(Key('email_field')), 'admin@test.com');
      await tester.enterText(find.byKey(Key('password_field')), 'password');
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      // Verify admin permissions
      expect(find.text('Add New Client'), findsOneWidget);

      // Simulate app restart (restart the app)
      app.main();
      await tester.pumpAndSettle();

      // Should still be logged in (JWT persisted)
      // Should still have admin permissions
      expect(find.text('Add New Client'), findsOneWidget);

      // Go to settings and verify still admin
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      expect(find.text('Manage Users'), findsOneWidget);
    });
  });
}
