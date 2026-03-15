import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../../providers/patient_provider.dart';
import '../widgets/health_id_card.dart';
import '../widgets/quick_actions_grid.dart';

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
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
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
            return const HosError(message: 'Profile not found');
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
                HosCard(
                  child: const HosEmptyState(
                    message: 'No recent activity',
                    icon: Icons.history,
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const HosLoading(message: 'Loading your profile...'),
        error: (error, _) => HosError(
          message: error.toString(),
          onRetry: () => ref.invalidate(currentPatientProvider),
        ),
      ),
    );
  }
}
