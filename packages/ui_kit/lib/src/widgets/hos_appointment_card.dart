import 'package:flutter/material.dart';

import '../icons/hos_icons.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'hos_avatar.dart';
import 'hos_card.dart';
import 'hos_status_chip.dart';

/// Card for an appointment — shown on home, appointment list, and doctor
/// dashboard. Avatar left, doctor + specialization + date/time right.
class HosAppointmentCard extends StatelessWidget {
  const HosAppointmentCard({
    super.key,
    required this.personName,
    required this.when,
    this.personRole,
    this.photoUrl,
    this.status = HosAppointmentStatus.confirmed,
    this.onTap,
    this.forWhom,
    this.location,
  });

  final String personName;
  final String? personRole;
  final String? photoUrl;
  final DateTime when;
  final HosAppointmentStatus status;
  final String? forWhom;
  final String? location;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return HosCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HosAvatar(
                name: personName,
                imageUrl: photoUrl,
                radius: 24,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(personName, style: AppTypography.h4),
                    if (personRole != null) ...[
                      const SizedBox(height: 2),
                      Text(personRole!,
                          style: AppTypography.caption),
                    ],
                  ],
                ),
              ),
              _statusChip(status),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .primary
                  .withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(AppSpacing.borderRadiusSm),
            ),
            child: Row(
              children: [
                const Icon(HosIcons.appointment,
                    size: HosIcons.sizeSm, color: AppColors.textSecondary),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    _formatDateTime(when),
                    style: AppTypography.label,
                  ),
                ),
                if (location != null) ...[
                  const Icon(HosIcons.location,
                      size: HosIcons.sizeSm,
                      color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      location!,
                      style: AppTypography.caption,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (forWhom != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                const Icon(HosIcons.family,
                    size: HosIcons.sizeSm, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text('For $forWhom', style: AppTypography.caption),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _statusChip(HosAppointmentStatus s) {
    return switch (s) {
      HosAppointmentStatus.confirmed => HosStatusChip(
          label: 'Confirmed',
          color: AppColors.success,
          icon: HosIcons.success,
        ),
      HosAppointmentStatus.pending => HosStatusChip(
          label: 'Pending',
          color: AppColors.warning,
          icon: HosIcons.pending,
        ),
      HosAppointmentStatus.cancelled => HosStatusChip(
          label: 'Cancelled',
          color: AppColors.error,
          icon: HosIcons.close,
        ),
      HosAppointmentStatus.completed => HosStatusChip(
          label: 'Completed',
          color: AppColors.info,
          icon: HosIcons.verified,
        ),
    };
  }

  static String _formatDateTime(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final h = d.hour == 0
        ? 12
        : d.hour > 12
            ? d.hour - 12
            : d.hour;
    final m = d.minute.toString().padLeft(2, '0');
    final ampm = d.hour >= 12 ? 'PM' : 'AM';
    return '${months[d.month - 1]} ${d.day}, ${d.year} · $h:$m $ampm';
  }
}

enum HosAppointmentStatus { confirmed, pending, cancelled, completed }
