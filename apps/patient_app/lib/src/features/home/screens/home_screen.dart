import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../../providers/auth_provider.dart';
import '../../../providers/patient_provider.dart';
import '../../appointments/widgets/appointment_card.dart';
import '../../appointments/providers/appointments_provider.dart';
import '../../medications/widgets/today_doses_card.dart';
import '../../notifications/providers/notifications_provider.dart';
import '../widgets/family_health_card.dart';
import '../widgets/health_id_card.dart';
import '../widgets/quick_actions_grid.dart';
import '../widgets/recent_activity_list.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patientAsync = ref.watch(currentPatientProvider);

    return Scaffold(
      appBar: AppBar(
        title: patientAsync.when(
          data: (patient) => Text(
            'Hi, ${patient?.fullName?.split(' ').first ?? 'there'}',
            style: AppTypography.h4,
          ),
          loading: () => const Text('HealthOS'),
          error: (_, _) => const Text('HealthOS'),
        ),
        actions: [
          Consumer(
            builder: (context, ref, child) {
              final count = ref.watch(unreadNotificationCountProvider);
              return HosIconButton(
                icon: HosIcons.notifications,
                badgeCount: count,
                onPressed: () => context.go('/notifications'),
                tooltip: 'Notifications',
              );
            },
          ),
          HosIconButton(
            icon: HosIcons.qr,
            onPressed: () => context.go('/qr'),
            tooltip: 'My health QR',
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: patientAsync.when(
        data: (patient) {
          if (patient == null) {
            // No profile yet — redirect to setup
            Future.microtask(() {
              if (context.mounted) context.go('/auth/setup');
            });
            return const HosLoading(message: 'Setting up your profile...');
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(currentPatientProvider);
              ref.invalidate(upcomingAppointmentsProvider);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: AppSpacing.screenPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HealthIdCard(patient: patient),
                  const SizedBox(height: AppSpacing.lg),
                  Text('Quick Actions', style: AppTypography.h4),
                  const SizedBox(height: AppSpacing.sm),
                  const QuickActionsGrid(),
                  const SizedBox(height: AppSpacing.lg),
                  const TodayDosesCard(),
                  const SizedBox(height: AppSpacing.md),
                  _UpcomingAppointmentSection(),
                  const SizedBox(height: AppSpacing.lg),
                  const FamilyHealthCard(),
                  const SizedBox(height: AppSpacing.lg),
                  Text('Recent Activity', style: AppTypography.h4),
                  const SizedBox(height: AppSpacing.sm),
                  const RecentActivityList(),
                ],
              ),
            ),
          );
        },
        loading: () => const HosLoading(message: 'Loading your profile...'),
        error: (error, _) {
          // If auth token is stale/invalid, sign out to clear it
          final errorStr = error.toString();
          if (errorStr.contains('AuthRetryableFetchException') ||
              errorStr.contains('refresh_token') ||
              errorStr.contains('Invalid Refresh Token')) {
            Future.microtask(() async {
              await ref.read(authServiceProvider).signOut();
            });
            return const HosLoading(message: 'Redirecting to login...');
          }
          return HosError(
            message: errorStr,
            onRetry: () => ref.invalidate(currentPatientProvider),
          );
        },
      ),
    );
  }
}

class _UpcomingAppointmentSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(upcomingAppointmentsProvider);
    return async.when(
      loading: () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Upcoming', style: AppTypography.h4),
          const SizedBox(height: AppSpacing.sm),
          const HosSkeletonCard(lines: 2),
        ],
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (items) {
        if (items.isEmpty) return const SizedBox.shrink();
        final next = items.first;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('Upcoming appointment',
                      style: AppTypography.h4),
                ),
                if (items.length > 1)
                  HosButton.tertiary(
                    label: 'See all',
                    iconRight: HosIcons.forward,
                    onPressed: () => context.go('/appointments'),
                    size: HosButtonSize.sm,
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            AppointmentCard(
              appointment: next,
              onTap: () => context.go('/appointments'),
            ),
          ],
        );
      },
    );
  }
}
