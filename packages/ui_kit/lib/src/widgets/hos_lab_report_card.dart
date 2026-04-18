import 'package:flutter/material.dart';

import '../icons/hos_icons.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'hos_card.dart';
import 'hos_status_chip.dart';

/// Lab report summary card used on reports list and patient home feed.
/// Left icon badge + title + date + status chip + optional abnormal count.
class HosLabReportCard extends StatelessWidget {
  const HosLabReportCard({
    super.key,
    required this.title,
    required this.date,
    this.lab,
    this.status = HosLabReportStatus.reviewed,
    this.abnormalCount = 0,
    this.onTap,
  });

  final String title;
  final DateTime date;
  final String? lab;
  final HosLabReportStatus status;
  final int abnormalCount;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return HosCard(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.borderRadiusSm),
            ),
            child: Icon(HosIcons.labReport,
                color: theme.colorScheme.secondary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.h4,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${_fmtDate(date)}${lab == null ? '' : ' · $lab'}',
                  style: AppTypography.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    _statusChip(status),
                    if (abnormalCount > 0) ...[
                      const SizedBox(width: AppSpacing.xs),
                      HosStatusChip(
                        label:
                            '$abnormalCount abnormal${abnormalCount == 1 ? '' : 's'}',
                        color: AppColors.error,
                        icon: HosIcons.warning,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          const Icon(HosIcons.forward,
              size: HosIcons.sizeSm, color: AppColors.textTertiary),
        ],
      ),
    );
  }

  Widget _statusChip(HosLabReportStatus s) {
    return switch (s) {
      HosLabReportStatus.pending => HosStatusChip(
          label: 'Pending',
          color: AppColors.warning,
          icon: HosIcons.pending,
        ),
      HosLabReportStatus.reviewed => HosStatusChip(
          label: 'Reviewed',
          color: AppColors.info,
          icon: HosIcons.verified,
        ),
      HosLabReportStatus.delivered => HosStatusChip(
          label: 'Delivered',
          color: AppColors.success,
          icon: HosIcons.success,
        ),
      HosLabReportStatus.abnormal => HosStatusChip(
          label: 'Abnormal',
          color: AppColors.error,
          icon: HosIcons.warning,
        ),
    };
  }

  static String _fmtDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }
}

enum HosLabReportStatus { pending, reviewed, delivered, abnormal }
