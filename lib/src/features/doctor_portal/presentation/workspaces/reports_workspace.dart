import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/theme.dart';
import '../../../../shared/presentation/widgets/hos_states.dart';
import '../../../../shared//presentation/shell/health_page.dart';
import '../../application/doctor_portal_providers.dart';
import '../../domain/doctor_workspace_models.dart';
import '../dialogs/doctor_workspace_dialogs.dart';
import '../widgets/doctor_workspace_widgets.dart';
import '../widgets/report_tile.dart';

class ReportsWorkspace extends ConsumerStatefulWidget {
  const ReportsWorkspace({super.key});

  @override
  ConsumerState<ReportsWorkspace> createState() => _ReportsWorkspaceState();
}

class _ReportsWorkspaceState extends ConsumerState<ReportsWorkspace> {
  String _filter = 'Needs review';
  final _reviewed = <String>{};

  @override
  Widget build(BuildContext context) {
    final reportsAsync = ref.watch(allDiagnosticReportsProvider);

    return HealthPage(
      child: reportsAsync.when(
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.all(48.0),
            child: CircularProgressIndicator(),
          ),
        ),
        error: (e, st) => HosErrorState(
          error: e,
          compact: true,
          title: 'Could not load reports',
        ),
        data: (allReports) {
          final reports = allReports.where((report) {
            if (_filter == 'All reports') return true;
            if (_filter == 'Needs review') {
              return !_reviewed.contains(report.id) &&
                  report.status == 'Needs review';
            }
            return report.priority == 'High';
          }).toList();

          final pendingCount = allReports.where((r) => r.status == 'Needs review' && !_reviewed.contains(r.id)).length;
          final completedCount = _reviewed.length;
          final highPriorityCount = allReports.where((r) => r.priority == 'High' && !_reviewed.contains(r.id)).length;
          final stats = ref.watch(doctorStatsProvider);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WorkspaceHeading(
                title: 'Reports and insights',
                description:
                    'Review diagnostic results and monitor practice performance.',
                action: OutlinedButton.icon(
                  onPressed: () =>
                      showActionSnackBar(context, 'Monthly report exported'),
                  icon: const Icon(Icons.download_rounded),
                  label: const Text('Export'),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              _ReportSummary(
                pending: pendingCount,
                completed: completedCount,
                highPriority: highPriorityCount,
                total: allReports.length,
              ),
              const SizedBox(height: AppSpacing.section),
              LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth >= 940;
                  final reportsList = _buildReportsList(
                    reports: reports,
                    reviewed: _reviewed,
                    onReviewed: (report) {
                      setState(() => _reviewed.add(report.id));
                      showActionSnackBar(context, '${report.type} marked reviewed');
                    },
                  );
                  final insights = _PracticeInsights(stats: stats);
                  if (!wide) {
                    return Column(
                      children: [
                        reportsList,
                        const SizedBox(height: AppSpacing.xl),
                        insights,
                      ],
                    );
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 7, child: reportsList),
                      const SizedBox(width: AppSpacing.xl),
                      Expanded(flex: 4, child: insights),
                    ],
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildReportsList({
    required List<DiagnosticReport> reports,
    required Set<String> reviewed,
    required ValueChanged<DiagnosticReport> onReviewed,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Diagnostic reports',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            PopupMenuButton<String>(
              initialValue: _filter,
              onSelected: (value) => setState(() => _filter = value),
              itemBuilder: (context) => [
                for (final value in const [
                  'Needs review',
                  'High priority',
                  'All reports',
                ])
                  PopupMenuItem(value: value, child: Text(value)),
              ],
              child: Chip(
                avatar: const Icon(Icons.filter_list_rounded, size: 18),
                label: Text(_filter),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        if (reports.isEmpty)
          const Card(
              child: HosEmptyState(
                compact: true,
                icon: Icons.task_alt_rounded,
                title: 'All caught up',
                message: 'There are no reports in this view.',
              ),
          )
        else
          Card(
            child: Column(
              children: [
                for (var index = 0; index < reports.length; index++) ...[
                  ReportTile(
                    report: reports[index],
                    reviewed: reviewed.contains(reports[index].id),
                    onReviewed: () => onReviewed(reports[index]),
                  ),
                  if (index != reports.length - 1) const Divider(),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _ReportSummary extends StatelessWidget {
  const _ReportSummary({
    required this.pending,
    required this.completed,
    required this.highPriority,
    required this.total,
  });

  final int pending;
  final int completed;
  final int highPriority;
  final int total;

  @override
  Widget build(BuildContext context) {
    final summaries = [
      (
        'Pending review',
        '$pending',
        Icons.pending_actions_rounded,
        AppColors.warning,
        AppColors.warningSoft,
      ),
      (
        'Completed today',
        '$completed',
        Icons.task_alt_rounded,
        AppColors.success,
        AppColors.successSoft,
      ),
      (
        'High priority',
        '$highPriority',
        Icons.priority_high_rounded,
        AppColors.error,
        AppColors.errorSoft,
      ),
      (
        'Total reports',
        '$total',
        Icons.folder_open_outlined,
        AppColors.primary,
        AppColors.primarySoft,
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 900 ? 4 : 2;
        const gap = 16.0;
        final width = (constraints.maxWidth - (columns - 1) * gap) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final summary in summaries)
              SizedBox(
                width: width,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: summary.$5,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(summary.$3, color: summary.$4),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                summary.$2,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              Text(summary.$1),
                            ],
                          ),
                            ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _PracticeInsights extends StatelessWidget {
  const _PracticeInsights({required this.stats});

  final DoctorStats stats;

  @override
  Widget build(BuildContext context) {
    String pct(double value) => '${(value * 100).round()}%';
    final insights = [
      (
        'Appointments completed',
        stats.completionRate,
        pct(stats.completionRate),
        AppColors.primary,
      ),
      (
        'Bookings confirmed',
        stats.confirmationRate,
        pct(stats.confirmationRate),
        AppColors.secondary,
      ),
      (
        'Active follow-ups',
        stats.followUpRate,
        pct(stats.followUpRate),
        AppColors.warning,
      ),
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Overview', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            const Text('Practice performance at a glance'),
            const SizedBox(height: AppSpacing.xl),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(AppRadius.medium),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${stats.patientsSeen}',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'patients seen',
                    style: TextStyle(
                      color: context.hos.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text('${stats.completedAppointments} completed consultations'),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            for (final insight in insights) ...[
              Row(
                children: [
                  Expanded(
                    child: Text(
                      insight.$1,
                      style: TextStyle(
                        color: context.hos.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(insight.$3),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: insight.$2,
                  minHeight: 8,
                  backgroundColor: context.hos.surfaceMuted,
                  color: insight.$4,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ],
        ),
      ),
    );
  }
}
