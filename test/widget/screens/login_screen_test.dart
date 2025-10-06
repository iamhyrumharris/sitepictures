import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sitepictures/screens/auth/login_screen.dart';
import 'package:sitepictures/providers/auth_state.dart';

void main() {
  Widget createTestWidget() {
    return ChangeNotifierProvider(
      create: (_) => AuthState(),
      child: const MaterialApp(
        home: LoginScreen(),
      ),
    );
  }

  testWidgets('Login screen displays email and password fields', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    expect(find.byType(TextFormField), findsNWidgets(2));
  });

  testWidgets('Login screen displays login button', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
  });

  testWidgets('Login screen validates empty email', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Tap login without entering credentials
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();

    // Should show validation error
    expect(find.text('Please enter your email'), findsOneWidget);
  });

  testWidgets('Login screen validates empty password', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Enter email only
    await tester.enterText(find.byType(TextFormField).first, 'test@example.com');

    // Tap login
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();

    // Should show validation error for password
    expect(find.text('Please enter your password'), findsOneWidget);
  });
}
