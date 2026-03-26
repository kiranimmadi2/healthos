import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final actions = [
      _QuickAction(
        icon: Icons.chat_bubble_outline,
        label: 'Check Symptoms',
        color: AppColors.primary,
        onTap: () => context.go('/symptoms'),
      ),
      _QuickAction(
        icon: Icons.science_outlined,
        label: 'Lab Reports',
        color: AppColors.secondary,
        onTap: () => context.go('/reports'),
      ),
      _QuickAction(
        icon: Icons.share_outlined,
        label: 'Share Access',
        color: AppColors.warning,
        onTap: () => context.go('/access'),
      ),
      _QuickAction(
        icon: Icons.calendar_month_outlined,
        label: 'Appointments',
        color: AppColors.info,
        onTap: () => context.go('/appointments'),
      ),
      _QuickAction(
        icon: Icons.qr_code_2,
        label: 'My QR Code',
        color: const Color(0xFF7C4DFF),
        onTap: () => context.go('/qr'),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: AppSpacing.sm,
        mainAxisSpacing: AppSpacing.sm,
        childAspectRatio: 1.0,
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.borderRadiusSm),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            label,
            style: AppTypography.label,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
