import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sitepictures/main.dart';

void main() {
  testWidgets('FieldPhoto app launches successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const FieldPhotoApp());

    // Verify that the app launches with correct title
    expect(find.text('FieldPhoto Pro'), findsOneWidget);

    // Verify main menu cards are displayed
    expect(find.text('Quick Capture'), findsOneWidget);
    expect(find.text('Equipment'), findsOneWidget);
    expect(find.text('Needs Assignment'), findsOneWidget);
    expect(find.text('GPS Boundaries'), findsOneWidget);

    // Verify offline status is shown
    expect(find.text('Offline Mode'), findsOneWidget);

    // Verify floating action button exists
    expect(find.byIcon(Icons.camera_alt), findsOneWidget);
  });
}