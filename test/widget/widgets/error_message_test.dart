import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sitepictures/widgets/error_message.dart';

void main() {
  Widget createTestWidget(String message) {
    return MaterialApp(
      home: Scaffold(
        body: ErrorMessage(message: message),
      ),
    );
  }

  testWidgets('Error message displays the provided message', (WidgetTester tester) async {
    const testMessage = 'An error occurred';
    await tester.pumpWidget(createTestWidget(testMessage));

    expect(find.text(testMessage), findsOneWidget);
  });

  testWidgets('Error message displays icon', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget('Error'));

    expect(find.byType(Icon), findsOneWidget);
  });

  testWidgets('Error message is centered', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget('Error'));

    expect(find.byType(Center), findsOneWidget);
  });
}
