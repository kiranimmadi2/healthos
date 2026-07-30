import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/theme.dart';
import '../../../../shared/presentation/layout/responsive_layout.dart';
import '../../../../shared/presentation/shell/health_page.dart';
import '../../../../shared/presentation/widgets/status_pill.dart';
import '../../../appointments/appointments.dart';
import '../../../auth/application/auth_providers.dart';
import '../../../auth/application/user_providers.dart';
import '../../../chat/chat.dart';

part 'appointment_card.dart';
part 'care_updates.dart';
part 'dashboard_widgets.dart';
part 'health_summary_card.dart';
part 'quick_actions.dart';

class DashboardContent extends ConsumerWidget {
  const DashboardContent({super.key, required this.onNavigate});

  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    final profile = ref.watch(userProfileProvider).value;
    final rawName =
        (profile?['name'] as String?)?.split(' ').first ??
        user?.displayName?.split(' ').first ??
        'there';
    final userName = rawName.isNotEmpty
        ? '${rawName[0].toUpperCase()}${rawName.substring(1).toLowerCase()}'
        : 'there';

    return HealthPage(
      bottomPadding: 104,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _WelcomeHeader(name: userName),
          const SizedBox(height: AppSpacing.xxl),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 900;
              if (wide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 7,
                      child: _AppointmentCard(onNavigate: onNavigate),
                    ),
                    const SizedBox(width: AppSpacing.xl),
                    const Expanded(flex: 4, child: _HealthSummaryCard()),
                  ],
                );
              }
              return Column(
                children: [
                  _AppointmentCard(onNavigate: onNavigate),
                  const SizedBox(height: AppSpacing.lg),
                  const _HealthSummaryCard(),
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.section),
          const _SectionHeader(
            title: 'Quick actions',
            subtitle: 'Common tasks, one tap away',
          ),
          const SizedBox(height: AppSpacing.lg),
          _QuickActions(onNavigate: onNavigate),
          const SizedBox(height: AppSpacing.section),
          const _SectionHeader(
            title: 'Care updates',
            subtitle: 'Recent activity across your health record',
          ),
          const SizedBox(height: AppSpacing.lg),
          const _CareUpdates(),
        ],
      ),
    );
  }
}

class _WelcomeHeader extends StatelessWidget {
  const _WelcomeHeader({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final greeting = now.hour < 12
        ? 'Good morning'
        : now.hour < 17
        ? 'Good afternoon'
        : 'Good evening';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$greeting, $name',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Here is what matters for your health today.',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
