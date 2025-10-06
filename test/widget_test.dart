import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sitepictures/main.dart';

void main() {
  testWidgets('SitePictures app launches successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SitePicturesApp());

    // Give time for async initialization
    await tester.pumpAndSettle();

    // Basic test - app should launch without crashing
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}