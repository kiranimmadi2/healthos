import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../access/providers/access_provider.dart';
import '../providers/appointments_provider.dart';

class AppointmentCard extends ConsumerWidget {
  const AppointmentCard({
    super.key,
    required this.appointment,
    this.onTap,
  });

  final Appointment appointment;
  final VoidCallback? onTap;

  bool get _isCancellable =>
      appointment.status == 'scheduled' || appointment.status == 'confirmed';

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

  Future<void> _confirmCancel(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Appointment'),
        content: const Text(
          'Are you sure you want to cancel this appointment? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No, Keep It'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final repo = ref.read(appointmentRepoProvider);
      await repo.cancel(appointment.id);

      ref.invalidate(upcomingAppointmentsProvider);
      ref.invalidate(allAppointmentsProvider);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Appointment cancelled successfully')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to cancel appointment: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doctorAsync = ref.watch(doctorByIdProvider(appointment.doctorId));

    return HosCard(
      onTap: onTap,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.borderRadiusSm),
                ),
                child: const Icon(HosIcons.appointment, color: AppColors.info, size: 24),
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
          if (_isCancellable) ...[
            const SizedBox(height: AppSpacing.sm),
            Align(
              alignment: Alignment.centerRight,
              child: HosButton.tertiary(
                label: 'Cancel',
                icon: HosIcons.close,
                onPressed: () => _confirmCancel(context, ref),
                size: HosButtonSize.sm,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
