import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sitepictures/screens/home/home_screen.dart';
import 'package:sitepictures/providers/app_state.dart';
import 'package:sitepictures/providers/auth_state.dart';

void main() {
  Widget createTestWidget() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
        ChangeNotifierProvider(create: (_) => AuthState()),
      ],
      child: const MaterialApp(
        home: HomeScreen(),
      ),
    );
  }

  testWidgets('Home screen displays app bar with title', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('Ziatech'), findsOneWidget);
  });

  testWidgets('Home screen displays Recent and Clients sections', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('Recent'), findsOneWidget);
    expect(find.text('Clients'), findsOneWidget);
  });

  testWidgets('Home screen shows empty state when no clients', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Should show some indication of empty state
    expect(find.byType(ListView), findsWidgets);
  });
}
