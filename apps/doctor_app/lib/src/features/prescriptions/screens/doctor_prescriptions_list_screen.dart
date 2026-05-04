import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../patients/screens/patient_detail_screen.dart';
import '../providers/doctor_prescriptions_provider.dart';

class DoctorPrescriptionsListScreen extends ConsumerWidget {
  const DoctorPrescriptionsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prescriptionsAsync = ref.watch(doctorPrescriptionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Prescriptions'),
      ),
      body: prescriptionsAsync.when(
        data: (prescriptions) {
          if (prescriptions.isEmpty) {
            return const HosEmptyState(
              icon: HosIcons.prescription,
              title: 'No prescriptions',
              message: 'Prescriptions you write will appear here.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: prescriptions.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final prescription = prescriptions[index];
              return _PrescriptionListTile(
                prescription: prescription,
              );
            },
          );
        },
        loading: () => const HosLoading(message: 'Loading prescriptions...'),
        error: (error, _) => HosError(
          message: error.toString(),
          onRetry: () => ref.invalidate(doctorPrescriptionsProvider),
        ),
      ),
    );
  }
}

class _PrescriptionListTile extends ConsumerWidget {
  const _PrescriptionListTile({required this.prescription});

  final Prescription prescription;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patientAsync = ref.watch(patientByIdProvider(prescription.patientId));

    return HosCard(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PatientDetailScreen(patientId: prescription.patientId),
          ),
        );
      },
      child: Row(
        children: [
          patientAsync.when(
            data: (patient) => HosAvatar(
              name: patient?.fullName,
              imageUrl: patient?.avatarUrl,
              radius: 20,
            ),
            loading: () => Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.divider,
                shape: BoxShape.circle,
              ),
            ),
            error: (_, _) => Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.divider,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                patientAsync.when(
                  data: (patient) => Text(
                    patient?.fullName ?? 'Unknown',
                    style: AppTypography.label,
                  ),
                  loading: () => Text('Loading...', style: AppTypography.caption),
                  error: (_, _) => Text('Unknown', style: AppTypography.label),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatMedications(prescription.medications),
                  style: AppTypography.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  AppDateUtils.formatDate(prescription.issuedAt),
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          Icon(HosIcons.forward, size: 18, color: AppColors.textTertiary),
        ],
      ),
    );
  }

  String _formatMedications(List<Medication> medications) {
    if (medications.isEmpty) return 'No medications';
    return medications.map((m) => m.name).join(', ');
  }
}
