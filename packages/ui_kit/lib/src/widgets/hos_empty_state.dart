import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'hos_button.dart';

class HosEmptyState extends StatelessWidget {
  const HosEmptyState({
    super.key,
    this.title,
    this.message,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
    this.actionIcon,
  })  : assert(title != null || message != null,
            'Provide at least a title or a message');

  final String? title;
  final String? message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData? actionIcon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: AppSpacing.screenPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 36, color: theme.colorScheme.primary),
            ),
            const SizedBox(height: AppSpacing.md),
            if (title != null)
              Text(
                title!,
                textAlign: TextAlign.center,
                style: AppTypography.h4,
              ),
            if (title != null && message != null)
              const SizedBox(height: AppSpacing.xs),
            if (message != null)
              Text(
                message!,
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.lg),
              HosButton.primary(
                label: actionLabel!,
                onPressed: onAction,
                icon: actionIcon,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
