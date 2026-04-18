import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/screens/doctor_login_screen.dart';
import '../features/auth/screens/doctor_not_found_screen.dart';
import '../features/dashboard/screens/dashboard_screen.dart';
import '../features/patients/screens/patient_detail_screen.dart';
import '../features/visits/screens/create_visit_screen.dart';
import '../features/prescriptions/screens/create_prescription_screen.dart';
import '../features/patients/screens/add_lab_result_screen.dart';
import '../features/ai_summary/screens/ai_summary_screen.dart';
import '../features/patients/screens/patient_list_screen.dart';
import '../features/profile/screens/doctor_profile_screen.dart';
import '../features/appointments/screens/appointments_screen.dart';
import '../features/appointments/screens/create_appointment_screen.dart';
import '../features/notifications/screens/notifications_screen.dart';
import '../providers/auth_provider.dart';
import '../providers/doctor_provider.dart';
import 'app_shell.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = ValueNotifier<int>(0);

  ref.listen(authStateProvider, (prev, next) => refreshNotifier.value++);
  ref.listen(currentDoctorProvider, (prev, next) => refreshNotifier.value++);

  return GoRouter(
    refreshListenable: refreshNotifier,
    initialLocation: '/auth',
    redirect: (context, state) {
      final isAuthenticated = ref.read(authStateProvider).valueOrNull != null;
      final isAuthRoute = state.matchedLocation.startsWith('/auth');

      if (!isAuthenticated && !isAuthRoute) return '/auth';

      if (isAuthenticated) {
        final doctor = ref.read(currentDoctorProvider);
        // Still loading — wait
        if (doctor.isLoading) return null;

        if (doctor.valueOrNull == null) {
          // Authenticated but no doctor profile
          if (state.matchedLocation != '/auth/not-found') return '/auth/not-found';
          return null;
        }
        // Has profile — leave auth routes
        if (isAuthRoute) return '/dashboard';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/auth',
        builder: (context, state) => const DoctorLoginScreen(),
        routes: [
          GoRoute(
            path: 'not-found',
            builder: (context, state) => const DoctorNotFoundScreen(),
          ),
        ],
      ),
      ShellRoute(
        builder: (context, state, child) => DoctorAppShell(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/patients',
            builder: (context, state) => const PatientListScreen(),
          ),
          GoRoute(
            path: '/patients/:id',
            builder: (context, state) {
              final patientId = state.pathParameters['id']!;
              return PatientDetailScreen(patientId: patientId);
            },
            routes: [
              GoRoute(
                path: 'visit/create',
                builder: (context, state) {
                  final patientId = state.pathParameters['id']!;
                  return CreateVisitScreen(patientId: patientId);
                },
              ),
              GoRoute(
                path: 'prescription/create',
                builder: (context, state) {
                  final patientId = state.pathParameters['id']!;
                  return CreatePrescriptionScreen(patientId: patientId);
                },
              ),
              GoRoute(
                path: 'ai-summary',
                builder: (context, state) {
                  final patientId = state.pathParameters['id']!;
                  return AiSummaryScreen(patientId: patientId);
                },
              ),
              GoRoute(
                path: 'lab/add',
                builder: (context, state) {
                  final patientId = state.pathParameters['id']!;
                  return AddLabResultScreen(patientId: patientId);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const DoctorProfileScreen(),
          ),
          GoRoute(
            path: '/appointments',
            builder: (context, state) => const DoctorAppointmentsScreen(),
            routes: [
              GoRoute(
                path: 'create',
                builder: (context, state) => const CreateAppointmentScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/notifications',
            builder: (context, state) => const DoctorNotificationsScreen(),
          ),
        ],
      ),
    ],
  );
});
