import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/screens/lab_login_screen.dart';
import '../features/upload/screens/report_upload_screen.dart';
import '../features/reports/screens/reports_list_screen.dart';
import '../features/reports/screens/report_review_screen.dart';
import '../features/patients/screens/patient_search_screen.dart';
import '../layout/lab_shell.dart';
import '../providers/auth_provider.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = ValueNotifier<int>(0);
  
  ref.listen(authStateProvider, (prev, next) => refreshNotifier.value++);

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
        return '/upload';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LabLoginScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => LabShell(child: child),
        routes: [
          GoRoute(
            path: '/upload',
            builder: (context, state) => const ReportUploadScreen(),
          ),
          GoRoute(
            path: '/reports',
            builder: (context, state) => const ReportsListScreen(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (context, state) {
                  final reportId = state.pathParameters['id']!;
                  return ReportReviewScreen(reportId: reportId);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/patients',
            builder: (context, state) => const PatientSearchScreen(),
          ),
        ],
      ),
    ],
  );
});
