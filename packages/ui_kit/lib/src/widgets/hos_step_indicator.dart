import 'package:flutter/material.dart';

import '../icons/hos_icons.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Horizontal step indicator (dot + line + dot) used in multi-step flows
/// like ProfileSetup, AddFamilyMember, BookAppointment.
class HosStepIndicator extends StatelessWidget {
  const HosStepIndicator({
    super.key,
    required this.steps,
    required this.currentStep,
    this.showLabels = true,
  });

  final List<String> steps;
  final int currentStep;
  final bool showLabels;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Row(
          children: [
            for (var i = 0; i < steps.length; i++) ...[
              _Dot(
                index: i,
                isCompleted: i < currentStep,
                isActive: i == currentStep,
                theme: theme,
              ),
              if (i < steps.length - 1)
                Expanded(
                  child: Container(
                    height: 2,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: i < currentStep
                          ? theme.colorScheme.primary
                          : theme.dividerColor,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ),
            ],
          ],
        ),
        if (showLabels) ...[
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              for (var i = 0; i < steps.length; i++) ...[
                Expanded(
                  child: Text(
                    steps[i],
                    textAlign: i == 0
                        ? TextAlign.start
                        : i == steps.length - 1
                            ? TextAlign.end
                            : TextAlign.center,
                    style: AppTypography.caption.copyWith(
                      color: i <= currentStep
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                      fontWeight:
                          i == currentStep ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({
    required this.index,
    required this.isCompleted,
    required this.isActive,
    required this.theme,
  });

  final int index;
  final bool isCompleted;
  final bool isActive;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final color = isCompleted || isActive
        ? theme.colorScheme.primary
        : theme.dividerColor;
    final bg = isActive ? theme.colorScheme.primary : Colors.transparent;
    final border = isActive || isCompleted
        ? theme.colorScheme.primary
        : theme.dividerColor;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isCompleted ? theme.colorScheme.primary : bg,
        border: Border.all(color: border, width: 2),
      ),
      alignment: Alignment.center,
      child: isCompleted
          ? const Icon(HosIcons.success, size: 16, color: AppColors.white)
          : Text(
              '${index + 1}',
              style: AppTypography.caption.copyWith(
                color: isActive ? AppColors.white : color,
                fontWeight: FontWeight.w700,
              ),
            ),
    );
  }
}
