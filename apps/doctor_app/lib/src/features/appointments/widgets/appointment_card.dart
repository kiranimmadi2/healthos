import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_client/supabase_client.dart';
import 'package:ui_kit/ui_kit.dart';

import '../providers/appointment_provider.dart';

final _patientRepoProvider = Provider<PatientRepository>((ref) => PatientRepository());
final _patientByIdProvider = FutureProvider.family<Patient?, String>((ref, id) async {
  final repo = ref.watch(_patientRepoProvider);
  return repo.getById(id);
});

class DoctorAppointmentCard extends ConsumerWidget {
  const DoctorAppointmentCard({super.key, required this.appointment, this.onTap});

  final Appointment appointment;
  final VoidCallback? onTap;

  Color _statusColor(String status) {
    switch (status) {
      case 'scheduled': return AppColors.info;
      case 'confirmed': return AppColors.success;
      case 'cancelled': return AppColors.error;
      case 'completed': return AppColors.textTertiary;
      default: return AppColors.textTertiary;
    }
  }

  Future<void> _confirmAppointment(WidgetRef ref) async {
    final repo = ref.read(appointmentRepoProvider);
    await repo.update(appointment.id, {'status': 'confirmed'});
    ref.invalidate(doctorAppointmentsProvider);
    ref.invalidate(doctorUpcomingAppointmentsProvider);
    ref.invalidate(doctorAppointmentsForDateProvider);
  }

  Future<void> _cancelAppointment(WidgetRef ref) async {
    final repo = ref.read(appointmentRepoProvider);
    await repo.cancel(appointment.id);
    ref.invalidate(doctorAppointmentsProvider);
    ref.invalidate(doctorUpcomingAppointmentsProvider);
    ref.invalidate(doctorAppointmentsForDateProvider);
  }

  Future<void> _completeAppointment(WidgetRef ref) async {
    final repo = ref.read(appointmentRepoProvider);
    await repo.update(appointment.id, {'status': 'completed'});
    ref.invalidate(doctorAppointmentsProvider);
    ref.invalidate(doctorUpcomingAppointmentsProvider);
    ref.invalidate(doctorAppointmentsForDateProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patientAsync = ref.watch(_patientByIdProvider(appointment.patientId));
    final status = appointment.status;

    return HosCard(
      onTap: onTap,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 56,
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Text(
                      '${appointment.scheduledAt.hour.toString().padLeft(2, '0')}:${appointment.scheduledAt.minute.toString().padLeft(2, '0')}',
                      style: AppTypography.h4.copyWith(color: AppColors.primary),
                    ),
                    Text('${appointment.durationMinutes}min', style: AppTypography.caption),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    patientAsync.when(
                      data: (patient) => Text(patient?.fullName ?? 'Unknown Patient', style: AppTypography.label),
                      loading: () => Text('Loading...', style: AppTypography.caption),
                      error: (_, __) => Text('Unknown Patient', style: AppTypography.label),
                    ),
                    if (appointment.reason != null)
                      Text(appointment.reason!, style: AppTypography.caption, maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              HosStatusChip(label: status.toUpperCase(), color: _statusColor(status)),
            ],
          ),
          if (status == 'scheduled' || status == 'confirmed') ...[
            const SizedBox(height: AppSpacing.sm),
            const Divider(height: 1),
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (status == 'scheduled')
                  TextButton.icon(
                    onPressed: () => _confirmAppointment(ref),
                    icon: const Icon(Icons.check_circle_outline, size: 18),
                    label: const Text('Confirm'),
                    style: TextButton.styleFrom(foregroundColor: AppColors.success),
                  ),
                if (status == 'confirmed')
                  TextButton.icon(
                    onPressed: () => _completeAppointment(ref),
                    icon: const Icon(Icons.task_alt, size: 18),
                    label: const Text('Complete'),
                    style: TextButton.styleFrom(foregroundColor: AppColors.success),
                  ),
                const SizedBox(width: AppSpacing.xs),
                TextButton.icon(
                  onPressed: () => _cancelAppointment(ref),
                  icon: const Icon(Icons.cancel_outlined, size: 18),
                  label: const Text('Cancel'),
                  style: TextButton.styleFrom(foregroundColor: AppColors.error),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
