import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_client/supabase_client.dart';
import 'package:ui_kit/ui_kit.dart';

/// Fetches a single doctor by ID.
final doctorDetailProvider =
    FutureProvider.family<Doctor?, String>((ref, doctorId) async {
  final repo = DoctorRepository();
  return repo.getById(doctorId);
});

/// Fetches patients who have granted access to this doctor,
/// resolving each patient's name via PatientRepository.
final doctorPatientsProvider =
    FutureProvider.family<List<Patient>, String>((ref, doctorId) async {
  final accessRepo = AccessGrantRepository();
  final patientRepo = PatientRepository();

  final grants = await accessRepo.getByDoctorId(doctorId);

  final patients = <Patient>[];
  for (final grant in grants) {
    final patient = await patientRepo.getById(grant.patientId);
    if (patient != null) {
      patients.add(patient);
    }
  }
  return patients;
});

class DoctorDetailScreen extends ConsumerWidget {
  const DoctorDetailScreen({super.key, required this.doctorId});

  final String doctorId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doctorAsync = ref.watch(doctorDetailProvider(doctorId));
    final patientsAsync = ref.watch(doctorPatientsProvider(doctorId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Doctor',
            onPressed: () => context.go('/doctors/$doctorId/edit'),
          ),
        ],
      ),
      body: doctorAsync.when(
        loading: () => const Center(child: HosLoading()),
        error: (e, _) => HosError(
          message: e.toString(),
          onRetry: () => ref.invalidate(doctorDetailProvider(doctorId)),
        ),
        data: (doctor) {
          if (doctor == null) {
            return const HosEmptyState(
              message: 'Doctor not found.',
              icon: Icons.person_off_outlined,
            );
          }

          return SingleChildScrollView(
            padding: AppSpacing.screenPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Doctor Info Card ──
                HosCard(
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          HosAvatar(
                            imageUrl: doctor.avatarUrl,
                            name: doctor.fullName,
                            radius: 36,
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  doctor.fullName,
                                  style: AppTypography.h2,
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                if (doctor.specialization != null)
                                  Text(
                                    doctor.specialization!,
                                    style: AppTypography.bodyMedium.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                const SizedBox(height: AppSpacing.sm),
                                HosStatusChip(
                                  label: doctor.verified
                                      ? 'Verified'
                                      : 'Unverified',
                                  color: doctor.verified
                                      ? Colors.green
                                      : Colors.orange,
                                  icon: doctor.verified
                                      ? Icons.verified
                                      : Icons.pending_outlined,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: AppSpacing.xl),
                      _InfoRow(
                        icon: Icons.badge_outlined,
                        label: 'License Number',
                        value: doctor.licenseNumber,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _InfoRow(
                        icon: Icons.phone_outlined,
                        label: 'Phone',
                        value: doctor.phone ?? 'N/A',
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _InfoRow(
                        icon: Icons.email_outlined,
                        label: 'Email',
                        value: doctor.email ?? 'N/A',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // ── Patients with Access Section ──
                Text('Patients with Access', style: AppTypography.h3),
                const SizedBox(height: AppSpacing.md),
                patientsAsync.when(
                  loading: () => const Center(child: HosLoading()),
                  error: (e, _) => HosError(
                    message: e.toString(),
                    onRetry: () =>
                        ref.invalidate(doctorPatientsProvider(doctorId)),
                  ),
                  data: (patients) {
                    if (patients.isEmpty) {
                      return const HosEmptyState(
                        message: 'No patients have granted access yet.',
                        icon: Icons.people_outline,
                      );
                    }
                    return HosCard(
                      padding: EdgeInsets.zero,
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: patients.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final patient = patients[index];
                          return ListTile(
                            leading: HosAvatar(
                              name: patient.fullName,
                              radius: 18,
                            ),
                            title: Text(
                              patient.fullName ?? 'Unknown',
                              style: AppTypography.bodyMedium,
                            ),
                            subtitle: Text(
                              patient.healthId,
                              style: AppTypography.caption.copyWith(
                                color: AppColors.textSecondary,
                                fontFamily: 'monospace',
                              ),
                            ),
                            trailing: const Icon(
                              Icons.chevron_right,
                              color: AppColors.textSecondary,
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: AppSpacing.sm),
        Text(
          '$label: ',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Expanded(
          child: Text(value, style: AppTypography.bodyMedium),
        ),
      ],
    );
  }
}
