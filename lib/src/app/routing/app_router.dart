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

/// Chooses the portal for the signed-in user's role.
class RootScreen extends ConsumerWidget {
  const RootScreen({super.key});

  /// A user with no recognised role has not finished onboarding.
  static Widget _portalFor(String? role) {
    return switch (role) {
      UserRole.patient => const PatientHomeScreen(),
      UserRole.doctor => const DoctorHomeScreen(),
      UserRole.hospital => const HospitalDashboardScreen(),
      _ => const ProfileSetupScreen(),
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(userRoleProvider).when(
          data: _portalFor,
          loading: () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
          // The role stream can fail transiently (offline, rules); fall back to
          // the last profile we have rather than bouncing to onboarding.
          error: (_, __) => _portalFor(
            ref.watch(currentUserProfileProvider).value?.role,
          ),
        );
  }
}
