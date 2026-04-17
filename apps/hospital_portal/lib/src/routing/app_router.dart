import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/screens/admin_login_screen.dart';
import '../features/dashboard/screens/dashboard_screen.dart';
import '../features/doctors/screens/doctor_detail_screen.dart';
import '../features/doctors/screens/doctor_form_screen.dart';
import '../features/doctors/screens/doctors_list_screen.dart';
import '../features/patients/screens/patient_detail_screen.dart' as patient_detail;
import '../features/patients/screens/patients_list_screen.dart';
import '../features/settings/screens/settings_screen.dart';
import '../layout/admin_shell.dart';
import '../providers/auth_provider.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = ValueNotifier<int>(0);
  
  ref.listen(authStateProvider, (_, __) {
    refreshNotifier.value++;
  });

  return GoRouter(
    refreshListenable: refreshNotifier,
    initialLocation: '/login',
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      final isAuthenticated = authState.valueOrNull != null;
      final isLoginRoute = state.matchedLocation == '/login';

      if (!isAuthenticated && !isLoginRoute) {
        return '/login';
      }
      if (isAuthenticated && isLoginRoute) {
        return '/dashboard';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const AdminLoginScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => AdminShell(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/doctors',
            builder: (context, state) => const DoctorsListScreen(),
            routes: [
              GoRoute(
                path: 'add',
                builder: (context, state) => const DoctorFormScreen(),
              ),
              GoRoute(
                path: ':id',
                builder: (context, state) {
                  final doctorId = state.pathParameters['id']!;
                  return DoctorDetailScreen(doctorId: doctorId);
                },
                routes: [
                  GoRoute(
                    path: 'edit',
                    builder: (context, state) {
                      final doctorId = state.pathParameters['id']!;
                      return DoctorFormScreen(doctorId: doctorId);
                    },
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: '/patients',
            builder: (context, state) => const PatientsListScreen(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (context, state) {
                  final patientId = state.pathParameters['id']!;
                  return patient_detail.PatientDetailScreen(patientId: patientId);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
  );
});
