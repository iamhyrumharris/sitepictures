import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:sitepictures/widgets/bottom_nav.dart';

Widget _wrapWithRouter(BottomNav nav) {
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => Scaffold(bottomNavigationBar: nav),
      ),
    ],
  );

  return MaterialApp.router(routerConfig: router);
}

void main() {
  testWidgets('BottomNav shows Home, All Photos, and Settings labels', (
    tester,
  ) async {
    await tester.pumpWidget(_wrapWithRouter(const BottomNav(currentIndex: 0)));
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('All Photos'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });

  testWidgets('BottomNav highlights selected index with primary color', (
    tester,
  ) async {
    await tester.pumpWidget(_wrapWithRouter(const BottomNav(currentIndex: 1)));
    await tester.pumpAndSettle();

    final allPhotosLabel = tester.widget<Text>(find.text('All Photos'));
    expect(allPhotosLabel.style?.color, const Color(0xFF4A90E2));
    expect(allPhotosLabel.style?.fontWeight, FontWeight.bold);
  });
}
