import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_client/supabase_client.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../../providers/doctor_provider.dart';
import '../widgets/patient_tile.dart';

/// Provider that fetches patients who have granted access to the current doctor.
final grantedPatientsProvider =
    FutureProvider.family<List<_PatientWithGrant>, String>(
        (ref, doctorId) async {
  final accessRepo = AccessGrantRepository();
  final patientRepo = PatientRepository();

  final grants = await accessRepo.getByDoctorId(doctorId);

  final patients = <_PatientWithGrant>[];
  for (final grant in grants) {
    final patient = await patientRepo.getById(grant.patientId);
    if (patient != null) {
      patients.add(_PatientWithGrant(patient: patient, grant: grant));
    }
  }

  return patients;
});

class _PatientWithGrant {
  const _PatientWithGrant({required this.patient, required this.grant});
  final Patient patient;
  final AccessGrant grant;
}

class PatientListScreen extends ConsumerStatefulWidget {
  const PatientListScreen({
    super.key,
    this.selectedPatientId,
    this.onPatientSelected,
  });

  final String? selectedPatientId;
  final ValueChanged<String>? onPatientSelected;

  @override
  ConsumerState<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends ConsumerState<PatientListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final doctorId = ref.watch(currentDoctorIdProvider);

    if (doctorId == null) {
      return const Center(child: HosLoading());
    }

    final patientsAsync = ref.watch(grantedPatientsProvider(doctorId));

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(
              bottom: BorderSide(color: AppColors.divider, width: 0.5),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('My Patients', style: AppTypography.h3),
              const SizedBox(height: AppSpacing.sm),
              HosTextField(
                controller: _searchController,
                hint: 'Search by name or health ID...',
                prefixIcon: Icons.search,
                onChanged: (value) {
                  setState(() => _searchQuery = value.toLowerCase());
                },
              ),
            ],
          ),
        ),

        // Patient list
        Expanded(
          child: patientsAsync.when(
            data: (patients) {
              final filtered = _searchQuery.isEmpty
                  ? patients
                  : patients.where((p) {
                      final name =
                          (p.patient.fullName ?? '').toLowerCase();
                      final healthId = p.patient.healthId.toLowerCase();
                      return name.contains(_searchQuery) ||
                          healthId.contains(_searchQuery);
                    }).toList();

              if (filtered.isEmpty) {
                return HosEmptyState(
                  icon: Icons.people_outline,
                  message: _searchQuery.isEmpty
                      ? 'No patients yet. Patients will appear here once they grant you access.'
                      : 'No patients found. Try a different search term.',
                );
              }

              return RefreshIndicator(
                onRefresh: () =>
                    ref.refresh(grantedPatientsProvider(doctorId).future),
                child: ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    return PatientTile(
                      patient: item.patient,
                      lastVisitDate: item.grant.grantedAt,
                      isSelected:
                          item.patient.id == widget.selectedPatientId,
                      onTap: () =>
                          widget.onPatientSelected?.call(item.patient.id),
                    );
                  },
                ),
              );
            },
            loading: () => const Center(child: HosLoading()),
            error: (error, _) => HosError(
              message: 'Failed to load patients',
              onRetry: () =>
                  ref.invalidate(grantedPatientsProvider(doctorId)),
            ),
          ),
        ),
      ],
    );
  }
}
