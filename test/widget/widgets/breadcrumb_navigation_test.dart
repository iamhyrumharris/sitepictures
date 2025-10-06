import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sitepictures/widgets/breadcrumb_navigation.dart';
import 'package:sitepictures/providers/navigation_state.dart';

void main() {
  Widget createTestWidget(List<BreadcrumbItem> breadcrumbs) {
    return MaterialApp(
      home: Scaffold(
        body: BreadcrumbNavigation(
          breadcrumbs: breadcrumbs,
          onTap: (index) {},
        ),
      ),
    );
  }

  testWidgets('Breadcrumb displays single item', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget([
      BreadcrumbItem(id: '1', title: 'Home', route: '/'),
    ]));

    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets('Breadcrumb displays multiple items with separators', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget([
      BreadcrumbItem(id: '1', title: 'Home', route: '/'),
      BreadcrumbItem(id: '2', title: 'Client', route: '/client/123'),
      BreadcrumbItem(id: '3', title: 'Site', route: '/site/456'),
    ]));

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Client'), findsOneWidget);
    expect(find.text('Site'), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right), findsNWidgets(2)); // 2 separators
  });

  testWidgets('Breadcrumb items are tappable', (WidgetTester tester) async {
    int tappedIndex = -1;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BreadcrumbNavigation(
            breadcrumbs: [
              BreadcrumbItem(id: '1', title: 'Home', route: '/'),
              BreadcrumbItem(id: '2', title: 'Client', route: '/client/123'),
            ],
            onTap: (index) {
              tappedIndex = index;
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();

    expect(tappedIndex, equals(0));
  });

  testWidgets('Breadcrumb handles long text', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget([
      BreadcrumbItem(
        id: '1',
        title: 'Very Long Client Name That Should Be Truncated',
        route: '/client/123',
      ),
    ]));

    expect(find.textContaining('Very Long'), findsOneWidget);
  });
}
