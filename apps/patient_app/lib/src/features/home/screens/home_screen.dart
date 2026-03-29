import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../../providers/auth_provider.dart';
import '../../../providers/patient_provider.dart';
import '../../notifications/providers/notifications_provider.dart';
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
          error: (_, __) => const Text('HealthOS'),
        ),
        actions: [
          Consumer(
            builder: (context, ref, child) {
              final count = ref.watch(unreadNotificationCountProvider);
              return IconButton(
                icon: Badge(
                  isLabelVisible: count > 0,
                  label: Text('$count'),
                  child: const Icon(Icons.notifications_outlined),
                ),
                onPressed: () => context.go('/notifications'),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.qr_code),
            onPressed: () => context.go('/qr'),
          ),
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
          return SingleChildScrollView(
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
                Text('Recent Activity', style: AppTypography.h4),
                const SizedBox(height: AppSpacing.sm),
                const RecentActivityList(),
              ],
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
