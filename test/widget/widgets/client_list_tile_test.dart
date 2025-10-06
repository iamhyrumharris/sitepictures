import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sitepictures/widgets/client_list_tile.dart';
import 'package:sitepictures/models/client.dart';

void main() {
  Widget createTestWidget(Client client) {
    return MaterialApp(
      home: Scaffold(
        body: ClientListTile(
          client: client,
          onTap: () {},
        ),
      ),
    );
  }

  testWidgets('Client list tile displays client name', (WidgetTester tester) async {
    final client = Client(
      id: 'test-id',
      name: 'ACME Industrial',
      createdBy: 'user-id',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isActive: true,
    );

    await tester.pumpWidget(createTestWidget(client));

    expect(find.text('ACME Industrial'), findsOneWidget);
  });

  testWidgets('Client list tile displays description when available', (WidgetTester tester) async {
    final client = Client(
      id: 'test-id',
      name: 'ACME Industrial',
      description: 'Manufacturing company',
      createdBy: 'user-id',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isActive: true,
    );

    await tester.pumpWidget(createTestWidget(client));

    expect(find.text('Manufacturing company'), findsOneWidget);
  });

  testWidgets('Client list tile is tappable', (WidgetTester tester) async {
    bool tapped = false;
    final client = Client(
      id: 'test-id',
      name: 'ACME Industrial',
      createdBy: 'user-id',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isActive: true,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ClientListTile(
            client: client,
            onTap: () {
              tapped = true;
            },
          ),
        ),
      ),
    );

    await tester.tap(find.byType(ClientListTile));
    await tester.pumpAndSettle();

    expect(tapped, isTrue);
  });
}
