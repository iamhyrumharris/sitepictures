import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sitepictures/widgets/loading_indicator.dart';

void main() {
  Widget createTestWidget() {
    return const MaterialApp(
      home: Scaffold(
        body: LoadingIndicator(),
      ),
    );
  }

  testWidgets('Loading indicator displays circular progress indicator', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('Loading indicator is centered', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());

    expect(find.byType(Center), findsOneWidget);
  });
}
