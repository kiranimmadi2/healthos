import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_client/supabase_client.dart';
import 'package:ui_kit/ui_kit.dart';

import '../widgets/stats_card.dart';

final dashboardStatsProvider =
    FutureProvider<Map<String, int>>((ref) async {
  final doctorRepo = DoctorRepository();
  final patientRepo = PatientRepository();
  final reportRepo = LabReportRepository();

  final results = await Future.wait([
    doctorRepo.search('', limit: 200),
    patientRepo.search('', limit: 200),
    reportRepo.getAll(limit: 200),
  ]);

  final doctors = results[0] as List<Doctor>;
  final patients = results[1] as List<Patient>;
  final reports = results[2] as List<LabReport>;

  final weekAgo = DateTime.now().subtract(const Duration(days: 7));
  final recentReports = reports
      .where((r) => r.createdAt != null && r.createdAt!.isAfter(weekAgo))
      .length;

  return {
    'doctors': doctors.length,
    'patients': patients.length,
    'reports_week': recentReports,
    'total_reports': reports.length,
  };
});

final recentActivityProvider =
    FutureProvider<List<_DashboardActivity>>((ref) async {
  final reportRepo = LabReportRepository();
  final patientRepo = PatientRepository();

  final reports = await reportRepo.getAll(limit: 5);
  final patients = await patientRepo.search('', limit: 5);

  final activities = <_DashboardActivity>[];

  for (final report in reports) {
    activities.add(_DashboardActivity(
      icon: Icons.science_rounded,
      title: 'Lab report: ${report.reportType}',
      subtitle: 'Status: ${report.status}',
      time: report.createdAt != null
          ? _formatTimeAgo(report.createdAt!)
          : 'Recently',
      timestamp: report.createdAt ?? DateTime.now(),
      color: AppColors.warning,
    ));
  }

  for (final patient in patients.take(3)) {
    activities.add(_DashboardActivity(
      icon: Icons.person_add_rounded,
      title: 'Patient: ${patient.fullName ?? 'Unknown'}',
      subtitle: patient.healthId,
      time: patient.createdAt != null
          ? _formatTimeAgo(patient.createdAt!)
          : 'Recently',
      timestamp: patient.createdAt ?? DateTime.now(),
      color: AppColors.primary,
    ));
  }

  activities.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  return activities.take(5).toList();
});

String _formatTimeAgo(DateTime dateTime) {
  final diff = DateTime.now().difference(dateTime);
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
  if (diff.inHours < 24) return '${diff.inHours} hr ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
}

class _DashboardActivity {
  final IconData icon;
  final String title;
  final String subtitle;
  final String time;
  final DateTime timestamp;
  final Color color;

  const _DashboardActivity({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.timestamp,
    required this.color,
  });
}

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    final activityAsync = ref.watch(recentActivityProvider);

    return Scaffold(
      body: SingleChildScrollView(
        child: HosPageContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Dashboard',
                style: AppTypography.responsive(context, AppTypography.h1),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Welcome back! Here is your hospital overview.',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              statsAsync.when(
                loading: () => const Center(child: HosLoading()),
                error: (e, _) => HosError(
                  message: e.toString(),
                  onRetry: () => ref.invalidate(dashboardStatsProvider),
                ),
                data: (stats) {
                  final patientCount = stats['patients'] ?? 0;
                  final doctorCount = stats['doctors'] ?? 0;
                  final reportsWeek = stats['reports_week'] ?? 0;
                  final totalReports = stats['total_reports'] ?? 0;

                  return HosResponsiveGrid(
                    mobileColumns: 1,
                    tabletColumns: 2,
                    desktopColumns: 3,
                    largeColumns: 4,
                    children: [
                      StatsCard(
                        icon: Icons.people_rounded,
                        value: patientCount.toString(),
                        label: 'Total Patients',
                        iconColor: AppColors.primary,
                        iconBackgroundColor:
                            AppColors.primary.withValues(alpha: 0.1),
                      ),
                      StatsCard(
                        icon: Icons.medical_services_rounded,
                        value: doctorCount.toString(),
                        label: 'Total Doctors',
                        iconColor: AppColors.secondary,
                        iconBackgroundColor:
                            AppColors.secondary.withValues(alpha: 0.1),
                      ),
                      StatsCard(
                        icon: Icons.science_rounded,
                        value: reportsWeek.toString(),
                        label: 'Reports This Week',
                        iconColor: AppColors.warning,
                        iconBackgroundColor:
                            AppColors.warning.withValues(alpha: 0.1),
                      ),
                      StatsCard(
                        icon: Icons.description_rounded,
                        value: totalReports.toString(),
                        label: 'Total Reports',
                        iconColor: AppColors.info,
                        iconBackgroundColor:
                            AppColors.info.withValues(alpha: 0.1),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                children: [
                  Text('Recent Activity', style: AppTypography.h3),
                  const Spacer(),
                  TextButton(
                    onPressed: () {},
                    child: const Text('View all'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              activityAsync.when(
                loading: () => const Center(child: HosLoading()),
                error: (e, _) => HosError(
                  message: e.toString(),
                  onRetry: () => ref.invalidate(recentActivityProvider),
                ),
                data: (activities) {
                  if (activities.isEmpty) {
                    return const HosEmptyState(
                      message: 'No recent activity.',
                      icon: Icons.history_rounded,
                    );
                  }
                  return HosCard(
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: activities.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final activity = activities[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                activity.color.withValues(alpha: 0.1),
                            child: Icon(
                              activity.icon,
                              color: activity.color,
                              size: 18,
                            ),
                          ),
                          title: Text(
                            activity.title,
                            style: AppTypography.bodyMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            activity.subtitle,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Text(
                            activity.time,
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textTertiary,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
