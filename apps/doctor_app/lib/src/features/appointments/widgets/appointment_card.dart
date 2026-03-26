import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_client/supabase_client.dart';
import 'package:ui_kit/ui_kit.dart';

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patientAsync = ref.watch(_patientByIdProvider(appointment.patientId));

    return HosCard(
      onTap: onTap,
      child: Row(
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
          HosStatusChip(label: appointment.status.toUpperCase(), color: _statusColor(appointment.status)),
        ],
      ),
    );
  }
}
