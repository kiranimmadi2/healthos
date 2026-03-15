import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_kit/ui_kit.dart';

import '../widgets/stats_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.lg),
            Text('Dashboard', style: AppTypography.h1),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Welcome back! Here is your hospital overview.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth > 900
                    ? 4
                    : constraints.maxWidth > 600
                        ? 2
                        : 1;
                return GridView.count(
                  crossAxisCount: crossAxisCount,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: AppSpacing.md,
                  mainAxisSpacing: AppSpacing.md,
                  childAspectRatio: 1.6,
                  children: const [
                    StatsCard(
                      icon: Icons.people,
                      value: '1,284',
                      label: 'Total Patients',
                      trend: '+12%',
                      trendPositive: true,
                      iconColor: Colors.blue,
                      iconBackgroundColor: Color(0xFFE3F2FD),
                    ),
                    StatsCard(
                      icon: Icons.medical_services,
                      value: '47',
                      label: 'Total Doctors',
                      trend: '+3',
                      trendPositive: true,
                      iconColor: Colors.teal,
                      iconBackgroundColor: Color(0xFFE0F2F1),
                    ),
                    StatsCard(
                      icon: Icons.science,
                      value: '328',
                      label: 'Reports This Week',
                      trend: '+8%',
                      trendPositive: true,
                      iconColor: Colors.orange,
                      iconBackgroundColor: Color(0xFFFFF3E0),
                    ),
                    StatsCard(
                      icon: Icons.event_available,
                      value: '62',
                      label: 'Active Visits',
                      trend: '-5%',
                      trendPositive: false,
                      iconColor: Colors.purple,
                      iconBackgroundColor: Color(0xFFF3E5F5),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('Recent Activity', style: AppTypography.h3),
            const SizedBox(height: AppSpacing.md),
            HosCard(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 5,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final activities = [
                    _ActivityItem(
                      icon: Icons.person_add,
                      title: 'New patient registered',
                      subtitle: 'Rahul Sharma - HID-20260315-001',
                      time: '5 min ago',
                    ),
                    _ActivityItem(
                      icon: Icons.science,
                      title: 'Lab report uploaded',
                      subtitle: 'CBC Report for Priya Patel',
                      time: '12 min ago',
                    ),
                    _ActivityItem(
                      icon: Icons.calendar_today,
                      title: 'Appointment completed',
                      subtitle: 'Dr. Kumar with Ankit Singh',
                      time: '30 min ago',
                    ),
                    _ActivityItem(
                      icon: Icons.medical_services,
                      title: 'New doctor onboarded',
                      subtitle: 'Dr. Meera Reddy - Dermatology',
                      time: '1 hr ago',
                    ),
                    _ActivityItem(
                      icon: Icons.verified,
                      title: 'Report verified',
                      subtitle: 'Lipid Panel for Suresh Gupta',
                      time: '2 hrs ago',
                    ),
                  ];
                  final activity = activities[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          AppColors.primary.withValues(alpha: 0.1),
                      child: Icon(
                        activity.icon,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    title: Text(activity.title,
                        style: AppTypography.bodyMedium),
                    subtitle: Text(
                      activity.subtitle,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    trailing: Text(
                      activity.time,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final String time;

  const _ActivityItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
  });
}
