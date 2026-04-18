import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_kit/ui_kit.dart';

void main() {
  group('HosCard', () {
    testWidgets('renders child widget', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HosCard(
              child: Text('Card Content'),
            ),
          ),
        ),
      );

      expect(find.text('Card Content'), findsOneWidget);
    });

    testWidgets('handles tap when onTap provided', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HosCard(
              onTap: () => tapped = true,
              child: Text('Tappable Card'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Tappable Card'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('applies padding', (tester) async {
      const customPadding = EdgeInsets.all(32.0);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HosCard(
              padding: customPadding,
              child: Text('Padded Card'),
            ),
          ),
        ),
      );

      final paddingWidget = tester.widget<Padding>(
        find.ancestor(
          of: find.text('Padded Card'),
          matching: find.byType(Padding),
        ).first,
      );

      expect(paddingWidget.padding, equals(customPadding));
    });
  });
}
