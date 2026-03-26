import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../access/providers/access_provider.dart';

class AppointmentCard extends ConsumerWidget {
  const AppointmentCard({
    super.key,
    required this.appointment,
    this.onTap,
  });

  final Appointment appointment;
  final VoidCallback? onTap;

  Color _statusColor(String status) {
    switch (status) {
      case 'scheduled':
        return AppColors.info;
      case 'confirmed':
        return AppColors.success;
      case 'cancelled':
        return AppColors.error;
      case 'completed':
        return AppColors.textTertiary;
      default:
        return AppColors.textTertiary;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doctorAsync = ref.watch(doctorByIdProvider(appointment.doctorId));

    return HosCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.borderRadiusSm),
            ),
            child: const Icon(Icons.calendar_month, color: AppColors.info, size: 24),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                doctorAsync.when(
                  data: (doctor) => Text(
                    'Dr. ${doctor?.fullName ?? 'Unknown'}',
                    style: AppTypography.label,
                  ),
                  loading: () => Text('Loading...', style: AppTypography.caption),
                  error: (_, _) => Text('Unknown Doctor', style: AppTypography.label),
                ),
                Text(
                  AppDateUtils.formatDate(appointment.scheduledAt),
                  style: AppTypography.caption,
                ),
                if (appointment.reason != null)
                  Text(
                    appointment.reason!,
                    style: AppTypography.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          HosStatusChip(
            label: appointment.status.toUpperCase(),
            color: _statusColor(appointment.status),
          ),
        ],
      ),
    );
  }
}
