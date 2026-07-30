import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/auth.dart';
import '../../features/doctor_portal/doctor_portal.dart';
import '../../features/hospital_portal/hospital_portal.dart';
import '../../features/patient_portal/patient_portal.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final user = authState.value;
      final loggingIn = state.matchedLocation == '/login';

      if (user == null) {
        return loggingIn ? null : '/login';
      }

      if (loggingIn) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/', builder: (context, state) => const RootScreen()),
      GoRoute(
        path: '/hospital/dashboard',
        builder: (context, state) => const HospitalDashboardScreen(),
      ),
      GoRoute(
        path: '/hospital/settings',
        builder: (context, state) => const HospitalSettingsScreen(),
      ),
    ],
  );
});

class RootScreen extends ConsumerWidget {
  const RootScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roleAsync = ref.watch(userRoleProvider);

    return roleAsync.when(
      data: (role) {
        if (role == 'patient') {
          return const PatientHomeScreen();
        } else if (role == 'doctor') {
          return const DoctorHomeScreen();
        } else if (role == 'hospital') {
          return const HospitalDashboardScreen();
        } else {
          return const ProfileSetupScreen();
        }
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, st) => const ProfileSetupScreen(),
    );
  }
}
