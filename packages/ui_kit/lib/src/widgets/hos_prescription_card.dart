import 'package:flutter/material.dart';

import '../icons/hos_icons.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'hos_card.dart';

/// Card used to display a single prescription/medication in both patient
/// records and doctor prescription previews.
class HosPrescriptionCard extends StatelessWidget {
  const HosPrescriptionCard({
    super.key,
    required this.drugName,
    required this.dosage,
    required this.frequency,
    this.duration,
    this.instructions,
    this.trailing,
    this.onTap,
  });

  final String drugName;
  final String dosage;
  final String frequency;
  final String? duration;
  final String? instructions;
  final Widget? trailing;
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
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.borderRadiusSm),
            ),
            child: Icon(HosIcons.prescription,
                color: theme.colorScheme.primary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(drugName, style: AppTypography.h4),
                const SizedBox(height: 2),
                Text(
                  '$dosage · $frequency${duration == null ? '' : ' · $duration'}',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                if (instructions != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    instructions!,
                    style: AppTypography.caption,
                  ),
                ],
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
