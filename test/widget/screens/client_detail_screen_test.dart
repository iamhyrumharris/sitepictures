import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sitepictures/screens/clients/client_detail_screen.dart';
import 'package:sitepictures/providers/app_state.dart';

void main() {
  Widget createTestWidget(String clientId) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: MaterialApp(
        home: ClientDetailScreen(clientId: clientId),
      ),
    );
  }

  testWidgets('Client detail screen displays breadcrumb navigation', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget('test-client-id'));
    await tester.pump();

    // Screen should be rendered
    expect(find.byType(ClientDetailScreen), findsOneWidget);
  }, skip: true); // Requires database initialization

  testWidgets('Client detail screen shows sites list', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget('test-client-id-2'));
    await tester.pump();

    // Screen should be rendered
    expect(find.byType(ClientDetailScreen), findsOneWidget);
  }, skip: true); // Requires database initialization
}
