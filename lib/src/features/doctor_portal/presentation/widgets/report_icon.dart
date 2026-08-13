import 'package:flutter/material.dart';

import '../../../../app/theme/theme.dart';
import '../../../records/domain/medical_record.dart';
import '../../domain/doctor_workspace_models.dart';

/// The rounded icon badge on a diagnostic report.
///
/// The icon and tint used to be baked into [DiagnosticReport] by the provider
/// that built it, which put Flutter types in the application layer. They are
/// derived here instead, from the report's category and priority.
class ReportIcon extends StatelessWidget {
  const ReportIcon({super.key, required this.report, this.size = 44});

  final DiagnosticReport report;
  final double size;

  @override
  Widget build(BuildContext context) {
    final (icon, foreground, background) = _style;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      child: Icon(icon, color: foreground),
    );
  }

  /// High priority overrides the category tint, as it did before.
  (IconData, Color, Color) get _style {
    final icon = switch (report.category) {
      RecordCategory.labReport => Icons.science_outlined,
      RecordCategory.imaging => Icons.portrait_rounded,
      _ => Icons.description_outlined,
    };

    if (report.priority.isHigh) {
      return (icon, AppColors.error, AppColors.errorSoft);
    }

    return switch (report.category) {
      RecordCategory.labReport => (
        icon,
        AppColors.warning,
        AppColors.warningSoft,
      ),
      RecordCategory.imaging => (
        icon,
        AppColors.secondary,
        AppColors.secondarySoft,
      ),
      _ => (icon, AppColors.primary, AppColors.primarySoft),
    };
  }
}
