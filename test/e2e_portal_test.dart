import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:healthos/src/app/theme/theme.dart';
import 'package:healthos/src/features/auth/application/user_providers.dart';
import 'package:healthos/src/features/appointments/application/appointment_providers.dart';
import 'package:healthos/src/features/chat/application/chat_providers.dart';
import 'package:healthos/src/features/doctors/application/doctor_providers.dart';
import 'package:healthos/src/features/doctor_portal/doctor_portal.dart';
import 'package:healthos/src/features/doctor_portal/application/doctor_portal_providers.dart';
import 'package:healthos/src/features/hospital_portal/hospital_portal.dart';
import 'package:healthos/src/features/patient_portal/patient_portal.dart';

import 'package:healthos/src/features/doctors/domain/doctor_profile.dart';

void main() {
  group('HealthOS E2E Portal Integration Tests', () {
    testWidgets('Patient Portal E2E - renders dashboard and navigation', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userProfileProvider.overrideWith(
              (ref) => Stream.value(<String, dynamic>{
                'name': 'Alex Johnson',
                'role': 'patient',
                'height': 175,
                'weight': 70,
              }),
            ),
            patientAppointmentsProvider.overrideWithValue(const AsyncValue.data([])),
            availableDoctorsProvider.overrideWithValue(const AsyncValue.data([])),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const PatientHomeScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Alex'), findsOneWidget);
    });

    testWidgets('Doctor Portal E2E - renders dashboard and patient directory', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userProfileProvider.overrideWith(
              (ref) => Stream.value(<String, dynamic>{
                'name': 'Dr. Asha Sharma',
                'role': 'doctor',
                'hospital': 'Apollo City Hospital',
              }),
            ),
            allPatientsProvider.overrideWithValue(const AsyncValue.data([
              {
                'uid': 'p101',
                'name': 'Sarah Connor',
                'gender': 'Female',
                'dob': '1990-05-15',
                'condition': 'Hypertension',
                'carePlan': 'Sodium control & regular vitals log',
              }
            ])),
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

      expect(find.textContaining('Asha Sharma'), findsOneWidget);
      expect(find.text("Today's schedule"), findsOneWidget);

      // Navigate to Patients Directory
      await tester.tap(find.text('Patients').last);
      await tester.pumpAndSettle();
      expect(find.text('Patient directory'), findsOneWidget);
      expect(find.text('Sarah Connor'), findsOneWidget);
    });

    testWidgets('Hospital Portal E2E - renders command center and settings', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            availableDoctorsProvider.overrideWithValue(
              AsyncValue.data([
                DoctorProfile(
                  uid: 'd101',
                  name: 'Dr. Asha Sharma',
                  specialization: 'Cardiology',
                  hospital: 'Apollo City Hospital',
                  yearsOfExperience: 12,
                  isAvailable: true,
                ),
              ]),
            ),
            allPatientsProvider.overrideWithValue(
              const AsyncValue.data([
                {'uid': 'p101', 'name': 'Sarah Connor'},
              ]),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const Scaffold(
              body: HospitalDashboardScreen(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Hospital Command Center'), findsOneWidget);
      expect(find.text('Total Patients'), findsOneWidget);
      expect(find.text('1'), findsNWidgets(2));
      expect(find.text('Active Doctors'), findsOneWidget);
      expect(find.text('Dr. Asha Sharma'), findsOneWidget);
    });
  });
}
