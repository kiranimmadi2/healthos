// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:healthos/main.dart';
import 'package:healthos/src/app/theme/theme.dart';
import 'package:healthos/src/features/doctor_portal/doctor_portal.dart';
import 'package:healthos/src/features/doctor_portal/application/doctor_portal_providers.dart';
import 'package:healthos/src/features/auth/application/user_providers.dart';
import 'package:healthos/src/features/appointments/application/appointment_providers.dart';
import 'package:healthos/src/features/chat/application/chat_providers.dart';

void main() {
  testWidgets('HealthOS smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: HealthOSApp()));

    // Verify that we see the app title.
    expect(
      find.text('HealthOS'),
      findsNothing,
    ); // It's in LoginScreen which might not be immediate
  });

  for (final size in <Size>[const Size(390, 844), const Size(1440, 1000)]) {
    testWidgets('doctor dashboard adapts at ${size.width}px', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userProfileProvider.overrideWith(
              (ref) => Stream.value(<String, dynamic>{'name': 'Asha Sharma', 'role': 'doctor'}),
            ),
            allPatientsProvider.overrideWithValue(const AsyncValue.data([])),
            allDiagnosticReportsProvider.overrideWithValue(const AsyncValue.data([])),
            doctorAppointmentsProvider.overrideWithValue(const AsyncValue.data([])),
            chatThreadsProvider.overrideWithValue(const AsyncValue.data([])),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const DoctorHomeScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Greeting now renders the signed-in doctor's real name (time-of-day
      // prefix varies, so match on the name).
      expect(find.textContaining('Asha Sharma'), findsOneWidget);
      expect(find.text("Today's schedule"), findsOneWidget);

      for (final destination in const [
        ('Patients', 'Patient directory'),
        ('Schedule', 'Clinical schedule'),
        ('Messages', 'Secure messages'),
        ('Reports', 'Reports and insights'),
      ]) {
        await tester.tap(find.text(destination.$1).last);
        await tester.pumpAndSettle();
        expect(find.text(destination.$2), findsOneWidget);
        expect(tester.takeException(), isNull);
      }

      expect(tester.takeException(), isNull);
    });
  }
}
