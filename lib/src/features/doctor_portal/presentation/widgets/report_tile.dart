import 'package:flutter/material.dart';

import '../../../../app/theme/theme.dart';
import '../../../../shared/presentation/widgets/status_pill.dart';
import '../../demo/doctor_workspace_models.dart';
import '../dialogs/doctor_workspace_dialogs.dart';

class ReportTile extends StatelessWidget {
  const ReportTile({
    super.key,
    required this.report,
    required this.reviewed,
    required this.onReviewed,
  });

  final DiagnosticReport report;
  final bool reviewed;
  final VoidCallback onReviewed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: report.iconBackground,
              borderRadius: BorderRadius.circular(AppRadius.medium),
            ),
            child: Icon(report.icon, color: report.iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        report.type,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    if (report.priority == 'High')
                      const StatusPill(
                        label: 'High priority',
                        foreground: AppColors.error,
                        background: AppColors.errorSoft,
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text('${report.patient} · ${report.ordered}'),
                const SizedBox(height: 8),
                Text(
                  report.summary,
                  style: TextStyle(color: context.hos.textPrimary),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => showReportSheet(context, report),
                      icon: const Icon(Icons.visibility_outlined, size: 18),
                      label: const Text('Open report'),
                    ),
                    if (!reviewed && report.status == 'Needs review')
                      TextButton.icon(
                        onPressed: onReviewed,
                        icon: const Icon(Icons.check_rounded, size: 18),
                        label: const Text('Mark reviewed'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
