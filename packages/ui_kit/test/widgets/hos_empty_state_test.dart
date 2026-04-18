import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_kit/ui_kit.dart';

void main() {
  group('HosEmptyState', () {
    testWidgets('renders message text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HosEmptyState(
              message: 'No items found',
            ),
          ),
        ),
      );

      expect(find.text('No items found'), findsOneWidget);
    });

    testWidgets('shows icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HosEmptyState(
              message: 'Empty',
              icon: Icons.folder_open,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.folder_open), findsOneWidget);
    });

    testWidgets('shows default icon when none provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HosEmptyState(
              message: 'Empty',
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
    });

    testWidgets('shows action button when actionLabel provided',
        (tester) async {
      var actionCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HosEmptyState(
              message: 'No results',
              actionLabel: 'Refresh',
              onAction: () => actionCalled = true,
            ),
          ),
        ),
      );

      expect(find.text('Refresh'), findsOneWidget);

      await tester.tap(find.text('Refresh'));
      await tester.pump();

      expect(actionCalled, isTrue);
    });

    testWidgets('does not show action button when actionLabel is null',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HosEmptyState(
              message: 'No results',
            ),
          ),
        ),
      );

      expect(find.byType(ElevatedButton), findsNothing);
    });
  });
}
