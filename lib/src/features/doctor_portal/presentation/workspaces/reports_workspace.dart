import 'package:flutter/material.dart';

import '../../../../app/theme/theme.dart';
import '../../../../shared/presentation/shell/health_page.dart';
import '../../demo/doctor_workspace_data.dart';
import '../../demo/doctor_workspace_models.dart';
import '../dialogs/doctor_workspace_dialogs.dart';
import '../widgets/doctor_workspace_widgets.dart';
import '../widgets/report_tile.dart';

class ReportsWorkspace extends StatefulWidget {
  const ReportsWorkspace({super.key});

  @override
  State<ReportsWorkspace> createState() => _ReportsWorkspaceState();
}

class _ReportsWorkspaceState extends State<ReportsWorkspace> {
  String _filter = 'Needs review';
  final _reviewed = <String>{};

  @override
  Widget build(BuildContext context) {
    final reports = doctorReports.where((report) {
      if (_filter == 'All reports') return true;
      if (_filter == 'Needs review') {
        return !_reviewed.contains(report.id) &&
            report.status == 'Needs review';
      }
      return report.priority == 'High';
    }).toList();

    return HealthPage(
      child: Column(
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
          const _ReportSummary(),
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
              const insights = _PracticeInsights();
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
                  const Expanded(flex: 4, child: insights),
                ],
              );
            },
          ),
        ],
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
          const EmptyState(
            icon: Icons.task_alt_rounded,
            title: 'All caught up',
            description: 'There are no reports in this view.',
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
  const _ReportSummary();

  @override
  Widget build(BuildContext context) {
    const summaries = [
      (
        'Pending review',
        '5',
        Icons.pending_actions_rounded,
        AppColors.warning,
        AppColors.warningSoft,
      ),
      (
        'Completed today',
        '12',
        Icons.task_alt_rounded,
        AppColors.success,
        AppColors.successSoft,
      ),
      (
        'High priority',
        '2',
        Icons.priority_high_rounded,
        AppColors.error,
        AppColors.errorSoft,
      ),
      (
        'Avg. turnaround',
        '4.2h',
        Icons.timer_outlined,
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
  const _PracticeInsights();

  @override
  Widget build(BuildContext context) {
    const insights = [
      ('Appointments completed', 0.82, '82%', AppColors.primary),
      ('On-time consultations', 0.91, '91%', AppColors.secondary),
      ('Follow-ups booked', 0.68, '68%', AppColors.warning),
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('This week', style: Theme.of(context).textTheme.titleLarge),
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
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '34',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'patients seen',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text('+12% from last week'),
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
                      style: const TextStyle(
                        color: AppColors.textPrimary,
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
                  backgroundColor: AppColors.surfaceMuted,
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
