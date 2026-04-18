import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Pill-style tab bar used across detail screens (Patient, Family, Biomarker).
/// Lighter-weight than Material's `TabBar` — no divider, no underline,
/// just a selected-pill look that matches the rest of the DS.
class HosTabBar extends StatelessWidget {
  const HosTabBar({
    super.key,
    required this.tabs,
    required this.currentIndex,
    required this.onTap,
    this.expand = true,
  });

  final List<String> tabs;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final children = [
      for (var i = 0; i < tabs.length; i++)
        _buildTab(context, i, tabs[i], theme),
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
      ),
      child: expand
          ? Row(
              children: [
                for (final child in children) Expanded(child: child),
              ],
            )
          : Row(mainAxisSize: MainAxisSize.min, children: children),
    );
  }

  Widget _buildTab(BuildContext context, int index, String label, ThemeData theme) {
    final isSelected = index == currentIndex;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      margin: EdgeInsets.only(right: index == tabs.length - 1 ? 0 : 4),
      decoration: BoxDecoration(
        color: isSelected ? theme.colorScheme.surface : Colors.transparent,
        borderRadius: BorderRadius.circular(AppSpacing.borderRadiusSm),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppSpacing.borderRadiusSm),
        child: InkWell(
          onTap: () => onTap(index),
          borderRadius: BorderRadius.circular(AppSpacing.borderRadiusSm),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: 10,
            ),
            child: Center(
              child: Text(
                label,
                style: AppTypography.label.copyWith(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
