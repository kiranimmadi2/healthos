import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'hos_card.dart';

/// KPI card used on hospital_portal dashboard: icon + value + label,
/// with an optional trend delta (e.g. "+12% this week").
class HosStatCard extends StatelessWidget {
  const HosStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.accent,
    this.trend,
    this.trendPositive,
    this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color? accent;
  final String? trend;

  /// When trend is positive (growth), use success color; otherwise error.
  /// If null, uses a neutral label color.
  final bool? trendPositive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = accent ?? theme.colorScheme.primary;

    return HosCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppSpacing.borderRadiusSm),
                ),
                child: Icon(icon, color: accentColor, size: 20),
              ),
              const Spacer(),
              if (trend != null)
                Text(
                  trend!,
                  style: AppTypography.caption.copyWith(
                    fontWeight: FontWeight.w600,
                    color: trendPositive == null
                        ? AppColors.textSecondary
                        : trendPositive!
                            ? AppColors.success
                            : AppColors.error,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(value, style: AppTypography.h1.copyWith(height: 1.1)),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
