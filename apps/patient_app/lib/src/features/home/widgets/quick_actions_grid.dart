import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final actions = [
      _QuickAction(
        icon: HosIcons.symptoms,
        label: 'Check Symptoms',
        color: AppColors.primary,
        onTap: () => context.go('/symptoms'),
      ),
      _QuickAction(
        icon: HosIcons.labReport,
        label: 'Lab Reports',
        color: AppColors.secondary,
        onTap: () => context.go('/reports'),
      ),
      _QuickAction(
        icon: HosIcons.share,
        label: 'Share Access',
        color: AppColors.warning,
        onTap: () => context.go('/access'),
      ),
      _QuickAction(
        icon: HosIcons.appointment,
        label: 'Appointments',
        color: AppColors.info,
        onTap: () => context.go('/appointments'),
      ),
      _QuickAction(
        icon: HosIcons.qr,
        label: 'My QR Code',
        color: const Color(0xFF7C4DFF),
        onTap: () => context.go('/qr'),
      ),
      _QuickAction(
        icon: HosIcons.family,
        label: 'Family',
        color: AppColors.secondaryDark,
        onTap: () => context.go('/profile/family'),
      ),
      _QuickAction(
        icon: HosIcons.prescription,
        label: 'Medications',
        color: AppColors.error,
        onTap: () => context.go('/medications'),
      ),
      _QuickAction(
        icon: HosIcons.reports,
        label: 'Documents',
        color: AppColors.textPrimary,
        onTap: () => context.go('/documents'),
      ),
      _QuickAction(
        icon: HosIcons.injection,
        label: 'Vaccines',
        color: AppColors.success,
        onTap: () => context.go('/vaccinations'),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: AppSpacing.sm,
        mainAxisSpacing: AppSpacing.sm,
        childAspectRatio: 0.95,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) => actions[index],
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return HosCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
