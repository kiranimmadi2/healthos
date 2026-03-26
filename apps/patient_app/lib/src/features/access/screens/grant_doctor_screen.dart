import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../../providers/patient_provider.dart';
import '../providers/access_provider.dart';

class GrantDoctorScreen extends ConsumerStatefulWidget {
  const GrantDoctorScreen({super.key});

  @override
  ConsumerState<GrantDoctorScreen> createState() => _GrantDoctorScreenState();
}

class _GrantDoctorScreenState extends ConsumerState<GrantDoctorScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _grantAccess(Doctor doctor) async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      builder: (context) => _GrantConfirmSheet(doctor: doctor),
    );

    if (confirmed == true && mounted) {
      try {
        final patient = await ref.read(currentPatientProvider.future);
        if (patient == null) return;

        final repo = ref.read(accessGrantRepoProvider);
        await repo.grant(
          patientId: patient.id,
          doctorId: doctor.id,
          accessLevel: 'read',
        );

        ref.invalidate(activeGrantsProvider);

        if (mounted) {
          context.pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Access granted to Dr. ${doctor.fullName}')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Grant Doctor Access')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: HosTextField(
              controller: _searchController,
              label: 'Search Doctors',
              prefixIcon: Icons.search,
              hint: 'Search by name or specialization',
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),
          Expanded(
            child: _searchQuery.trim().length < 2
                ? Center(
                    child: Text(
                      'Type at least 2 characters to search',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  )
                : ref.watch(doctorSearchResultsProvider(_searchQuery)).when(
                    data: (doctors) {
                      if (doctors.isEmpty) {
                        return const HosEmptyState(
                          message: 'No doctors found',
                          icon: Icons.person_search,
                        );
                      }
                      return ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                        itemCount: doctors.length,
                        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (context, index) {
                          final doctor = doctors[index];
                          return HosCard(
                            onTap: () => _grantAccess(doctor),
                            child: Row(
                              children: [
                                HosAvatar(name: doctor.fullName, radius: 20),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Dr. ${doctor.fullName}',
                                          style: AppTypography.label),
                                      Text(doctor.specialization ?? 'General',
                                          style: AppTypography.caption),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.add_circle_outline,
                                    color: AppColors.primary),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    loading: () => const HosLoading(),
                    error: (error, _) => HosError(message: error.toString()),
                  ),
          ),
        ],
      ),
    );
  }
}

class _GrantConfirmSheet extends StatelessWidget {
  const _GrantConfirmSheet({required this.doctor});

  final Doctor doctor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          HosAvatar(name: doctor.fullName, radius: 32),
          const SizedBox(height: AppSpacing.md),
          Text('Grant Access to', style: AppTypography.bodyMedium),
          Text('Dr. ${doctor.fullName}', style: AppTypography.h4),
          if (doctor.specialization != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(doctor.specialization!, style: AppTypography.caption),
          ],
          const SizedBox(height: AppSpacing.lg),
          Text(
            'This doctor will be able to view your health records, lab reports, and medical history.',
            style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: HosButton(
                  label: 'Cancel',
                  isOutlined: true,
                  onPressed: () => Navigator.pop(context, false),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: HosButton(
                  label: 'Grant Access',
                  onPressed: () => Navigator.pop(context, true),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}
