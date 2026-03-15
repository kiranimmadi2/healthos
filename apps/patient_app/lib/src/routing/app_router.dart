import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/screens/phone_input_screen.dart';
import '../features/auth/screens/otp_verify_screen.dart';
import '../features/auth/screens/profile_setup_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/records/screens/reports_list_screen.dart';
import '../features/records/screens/report_detail_screen.dart';
import '../features/symptoms/screens/symptom_checker_screen.dart';
import '../features/access/screens/access_grant_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/qr/screens/qr_display_screen.dart';
import '../providers/auth_provider.dart';
import 'app_shell.dart';

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
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/auth',
        builder: (context, state) => const PhoneInputScreen(),
        routes: [
          GoRoute(
            path: 'verify',
            builder: (context, state) {
              final phone = state.extra as String? ?? '';
              return OtpVerifyScreen(phone: phone);
            },
          ),
          GoRoute(
            path: 'setup',
            builder: (context, state) => const ProfileSetupScreen(),
          ),
        ],
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/reports',
            builder: (context, state) => const ReportsListScreen(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (context, state) {
                  final reportId = state.pathParameters['id']!;
                  return ReportDetailScreen(reportId: reportId);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/symptoms',
            builder: (context, state) => const SymptomCheckerScreen(),
          ),
          GoRoute(
            path: '/access',
            builder: (context, state) => const AccessGrantScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: '/qr',
            builder: (context, state) => const QrDisplayScreen(),
          ),
        ],
      ),
    ],
  );
});
