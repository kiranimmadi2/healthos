import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class HosHealthIdBadge extends StatelessWidget {
  const HosHealthIdBadge({
    super.key,
    required this.healthId,
    this.showCopyButton = true,
  });

  final String healthId;
  final bool showCopyButton;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm + 4,
        vertical: AppSpacing.xs + 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSpacing.borderRadiusSm),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.badge_outlined,
            size: 16,
            color: AppColors.primary,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            healthId,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
              letterSpacing: 0.5,
              fontFamily: 'monospace',
            ),
          ),
          if (showCopyButton) ...[
            const SizedBox(width: AppSpacing.xs),
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: healthId));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Health ID copied')),
                );
              },
              child: const Icon(
                Icons.copy,
                size: 14,
                color: AppColors.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
