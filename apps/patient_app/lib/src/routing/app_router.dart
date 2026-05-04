import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import '../features/auth/screens/phone_input_screen.dart';
import '../features/auth/screens/otp_verify_screen.dart';
import '../features/auth/screens/profile_setup_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/records/screens/reports_list_screen.dart';
import '../features/records/screens/report_detail_screen.dart';
import '../features/symptoms/screens/symptom_checker_screen.dart';
import '../features/access/screens/access_grant_screen.dart';
import '../features/access/screens/grant_doctor_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/profile/screens/profile_edit_screen.dart';
import '../features/qr/screens/qr_display_screen.dart';
import '../features/notifications/screens/notifications_screen.dart';
import '../features/appointments/screens/appointments_screen.dart';
import '../features/appointments/screens/book_appointment_screen.dart';
import '../features/documents/screens/documents_list_screen.dart';
import '../features/documents/screens/upload_document_screen.dart';
import '../features/family/screens/family_hub_screen.dart';
import '../features/family/screens/add_family_member_screen.dart';
import '../features/family/screens/family_member_detail_screen.dart';
import '../features/family/screens/edit_family_member_screen.dart';
import '../features/medications/screens/medications_list_screen.dart';
import '../features/medications/screens/add_medication_schedule_screen.dart';
import '../features/vaccinations/screens/vaccinations_list_screen.dart';
import '../features/vaccinations/screens/add_vaccination_screen.dart';
import '../providers/auth_provider.dart';
import '../providers/patient_provider.dart';
import 'app_shell.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = ValueNotifier<int>(0);
  
  ref.listen(authStateProvider, (prev, next) {
    debugPrint('[Router] authStateProvider changed → ${next.valueOrNull?.uid}');
    refreshNotifier.value++;
  });
  ref.listen(patientProfileStateProvider, (prev, next) {
    debugPrint('[Router] patientProfileStateProvider changed → $prev → $next');
    refreshNotifier.value++;
  });

  return GoRouter(
    refreshListenable: refreshNotifier,
    initialLocation: '/auth',
    redirect: (context, state) {
      if (kDebugMode && state.matchedLocation == '/design') return null;
      final isAuthenticated = ref.read(authStateProvider).valueOrNull != null;
      final isAuthRoute = state.matchedLocation.startsWith('/auth');
      final profileState = ref.read(patientProfileStateProvider);

      debugPrint('[Router] redirect — location=${state.matchedLocation} '
          'isAuth=$isAuthenticated isAuthRoute=$isAuthRoute profileState=$profileState');

      if (!isAuthenticated && !isAuthRoute) return '/auth';

      if (isAuthenticated) {
        if (profileState == PatientProfileState.loading) {
          debugPrint('[Router] → staying (profile loading)');
          return null;
        }
        if (profileState == PatientProfileState.missing) {
          debugPrint('[Router] → /auth/setup (no profile)');
          return '/auth/setup';
        }
        if (isAuthRoute) {
          debugPrint('[Router] → /home (profile exists, leaving auth)');
          return '/home';
        }
      }
      return null;
    },
    routes: [
      if (kDebugMode)
        GoRoute(
          path: '/design',
          builder: (context, state) => const DesignGallery(),
        ),
      GoRoute(
        path: '/auth',
        builder: (context, state) => const PhoneInputScreen(),
        routes: [
          GoRoute(
            path: 'verify',
            builder: (context, state) {
              final extra = state.extra as Map<String, String>? ?? {};
              return OtpVerifyScreen(
                phone: extra['phone'],
                email: extra['email'],
              );
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
            routes: [
              GoRoute(
                path: 'grant',
                builder: (context, state) => const GrantDoctorScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
            routes: [
              GoRoute(
                path: 'edit',
                builder: (context, state) => const ProfileEditScreen(),
              ),
              GoRoute(
                path: 'family',
                builder: (context, state) => const FamilyHubScreen(),
                routes: [
                  GoRoute(
                    path: 'add',
                    builder: (context, state) => const AddFamilyMemberScreen(),
                  ),
                  GoRoute(
                    path: ':memberId',
                    builder: (context, state) => FamilyMemberDetailScreen(
                      memberId: state.pathParameters['memberId']!,
                    ),
                    routes: [
                      GoRoute(
                        path: 'edit',
                        builder: (context, state) => EditFamilyMemberScreen(
                          memberId: state.pathParameters['memberId']!,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: '/qr',
            builder: (context, state) => const QrDisplayScreen(),
          ),
          GoRoute(
            path: '/notifications',
            builder: (context, state) => const NotificationsScreen(),
          ),
          GoRoute(
            path: '/appointments',
            builder: (context, state) => const AppointmentsScreen(),
            routes: [
              GoRoute(
                path: 'book',
                builder: (context, state) => const BookAppointmentScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/medications',
            builder: (context, state) => const MedicationsListScreen(),
            routes: [
              GoRoute(
                path: 'add',
                builder: (context, state) =>
                    const AddMedicationScheduleScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/documents',
            builder: (context, state) => const DocumentsListScreen(),
            routes: [
              GoRoute(
                path: 'upload',
                builder: (context, state) => const UploadDocumentScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/vaccinations',
            builder: (context, state) => const VaccinationsListScreen(),
            routes: [
              GoRoute(
                path: 'add',
                builder: (context, state) => const AddVaccinationScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
