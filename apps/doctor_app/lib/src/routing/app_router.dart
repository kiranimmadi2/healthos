import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/screens/doctor_login_screen.dart';
import '../features/dashboard/screens/dashboard_screen.dart';
import '../features/patients/screens/patient_detail_screen.dart';
import '../features/visits/screens/create_visit_screen.dart';
import '../features/prescriptions/screens/create_prescription_screen.dart';
import '../features/ai_summary/screens/ai_summary_screen.dart';
import '../providers/auth_provider.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/auth',
    redirect: (context, state) {
      final isAuthenticated = authState.valueOrNull != null;
      final isAuthRoute = state.matchedLocation.startsWith('/auth');

      if (!isAuthenticated && !isAuthRoute) {
        return '/auth';
      }
      if (isAuthenticated && isAuthRoute) {
        return '/dashboard';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/auth',
        builder: (context, state) => const DoctorLoginScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
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
        ],
      ),
    ],
  );
});
