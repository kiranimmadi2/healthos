import 'package:flutter/material.dart';

import '../icons/hos_icons.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'hos_card.dart';

/// Displays a grid of a patient's vital signs. Each vital can carry a
/// status (normal / low / high) that tints the value color.
class HosVitalsCard extends StatelessWidget {
  const HosVitalsCard({
    super.key,
    required this.vitals,
    this.title = 'Vitals',
    this.trailing,
  });

  final List<HosVital> vitals;
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return HosCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(HosIcons.vitals, size: HosIcons.sizeSm,
                  color: AppColors.textSecondary),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: Text(title, style: AppTypography.h4)),
              ?trailing,
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          LayoutBuilder(
            builder: (context, constraints) {
              final cols = constraints.maxWidth > 500 ? 4 : 2;
              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: cols,
                mainAxisSpacing: AppSpacing.sm,
                crossAxisSpacing: AppSpacing.sm,
                childAspectRatio: 1.6,
                children: [
                  for (final v in vitals) _VitalTile(vital: v),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _VitalTile extends StatelessWidget {
  const _VitalTile({required this.vital});

  final HosVital vital;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = switch (vital.status) {
      HosVitalStatus.normal => AppColors.success,
      HosVitalStatus.low => AppColors.warning,
      HosVitalStatus.high => AppColors.error,
      HosVitalStatus.none => theme.colorScheme.onSurface,
    };

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppSpacing.borderRadiusSm),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(vital.icon, size: 14, color: statusColor),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  vital.label,
                  style: AppTypography.caption,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          RichText(
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              style: AppTypography.h3.copyWith(color: statusColor),
              children: [
                TextSpan(text: vital.value),
                if (vital.unit != null)
                  TextSpan(
                    text: ' ${vital.unit!}',
                    style: AppTypography.caption.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum HosVitalStatus { normal, low, high, none }

class HosVital {
  const HosVital({
    required this.label,
    required this.value,
    required this.icon,
    this.unit,
    this.status = HosVitalStatus.none,
  });

  final String label;
  final String value;
  final String? unit;
  final IconData icon;
  final HosVitalStatus status;
}
