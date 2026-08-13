import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthos/src/app/theme/app_theme.dart';
import 'package:healthos/src/features/appointments/data/appointment_repository.dart';
import 'package:healthos/src/shared/domain/app_failure.dart';
import 'package:healthos/src/shared/presentation/widgets/hos_states.dart';

Widget _wrap(Widget child) {
  return ProviderScope(
    overrides: [hosMotionEnabledProvider.overrideWithValue(false)],
    child: MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  group('describeFailure', () {
    test('maps Firestore permission-denied to plain language', () {
      final message = describeFailure(
        FirebaseException(plugin: 'firestore', code: 'permission-denied'),
      );
      expect(message, "You don't have access to this.");
      expect(message, isNot(contains('permission-denied')));
    });

    test('maps offline codes to an offline message', () {
      expect(
        describeFailure(
          FirebaseException(plugin: 'firestore', code: 'unavailable'),
        ),
        contains('offline'),
      );
    });

    test('explains a still-building index', () {
      expect(
        describeFailure(
          FirebaseException(plugin: 'firestore', code: 'failed-precondition'),
        ),
        contains('index'),
      );
    });

    test('passes through deliberately user-facing exception text', () {
      expect(
        describeFailure(const AppointmentSlotUnavailableException()),
        'This time was already booked. Please choose another.',
      );
    });

    test('falls back to a generic message for unknown errors', () {
      expect(describeFailure(StateError('internal detail')), 'Something went wrong.');
      expect(describeFailure(null), 'Something went wrong.');
    });
  });

  group('HosErrorState', () {
    testWidgets('shows friendly copy, not the raw exception', (tester) async {
      await tester.pumpWidget(
        _wrap(
          HosErrorState(
            error: FirebaseException(
              plugin: 'firestore',
              code: 'permission-denied',
            ),
          ),
        ),
      );

      expect(find.text("You don't have access to this."), findsOneWidget);
      expect(find.textContaining('FirebaseException'), findsNothing);
    });

    testWidgets('offers retry only when a callback is supplied', (tester) async {
      await tester.pumpWidget(_wrap(const HosErrorState(error: 'boom')));
      expect(find.text('Try again'), findsNothing);

      var retried = false;
      await tester.pumpWidget(
        _wrap(HosErrorState(error: 'boom', onRetry: () => retried = true)),
      );
      await tester.tap(find.text('Try again'));
      expect(retried, isTrue);
    });
  });

  group('HosEmptyState', () {
    testWidgets('renders title, message and action', (tester) async {
      await tester.pumpWidget(
        _wrap(
          HosEmptyState(
            icon: Icons.folder_outlined,
            title: 'Nothing here',
            message: 'Add your first record.',
            action: FilledButton(onPressed: () {}, child: const Text('Add')),
          ),
        ),
      );

      expect(find.text('Nothing here'), findsOneWidget);
      expect(find.text('Add your first record.'), findsOneWidget);
      expect(find.text('Add'), findsOneWidget);
    });
  });

  group('motion gating', () {
    testWidgets('skeletons settle when motion is disabled', (tester) async {
      await tester.pumpWidget(_wrap(const HosSkeletonList(count: 3)));

      // Would hang forever against a repeating shimmer.
      await tester.pumpAndSettle();
      expect(find.byType(HosSkeletonCard), findsNWidgets(3));
    });

    testWidgets('typing indicator settles when motion is disabled', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const HosTypingIndicator(label: 'Thinking')));
      await tester.pumpAndSettle();
      expect(find.text('Thinking'), findsOneWidget);
    });
  });

  group('hosWhen', () {
    testWidgets('renders data, skeletons and errors from one call', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const AsyncValue<int>.loading().hosWhen(data: (v) => Text('$v'))),
      );
      expect(find.byType(HosSkeletonCard), findsWidgets);

      await tester.pumpWidget(
        _wrap(const AsyncValue<int>.data(42).hosWhen(data: (v) => Text('$v'))),
      );
      expect(find.text('42'), findsOneWidget);

      await tester.pumpWidget(
        _wrap(
          AsyncValue<int>.error(
            FirebaseException(plugin: 'firestore', code: 'unavailable'),
            StackTrace.empty,
          ).hosWhen(data: (v) => Text('$v')),
        ),
      );
      expect(find.textContaining('offline'), findsOneWidget);
    });
  });
}
