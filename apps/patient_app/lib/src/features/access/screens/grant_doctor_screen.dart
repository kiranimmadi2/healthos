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
    final confirmed = await showHosBottomSheet<bool>(
      context: context,
      title: 'Grant access',
      child: _GrantConfirmSheet(doctor: doctor),
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
            SnackBar(
              content: Text('Access granted to Dr. ${doctor.fullName}'),
            ),
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
      appBar: AppBar(
        leading: HosIconButton(
          icon: HosIcons.back,
          onPressed: () => context.pop(),
        ),
        title: const Text('Grant doctor access'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: HosTextField(
              controller: _searchController,
              prefixIcon: HosIcons.search,
              hint: 'Search by name or specialty',
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          Expanded(
            child: _searchQuery.trim().length < 2
                ? Padding(
                    padding: AppSpacing.screenPadding,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(HosIcons.search,
                              size: 48, color: AppColors.textTertiary),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            'Find a doctor',
                            style: AppTypography.h4,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Type at least 2 characters to search by name or specialty.',
                            style: AppTypography.caption,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                : ref.watch(doctorSearchResultsProvider(_searchQuery)).when(
                      loading: () => ListView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                        ),
                        children: const [
                          HosSkeletonListTile(),
                          HosSkeletonListTile(),
                          HosSkeletonListTile(),
                        ],
                      ),
                      error: (error, _) => HosError(
                        message: error.toString(),
                        onRetry: () => ref.invalidate(
                          doctorSearchResultsProvider(_searchQuery),
                        ),
                      ),
                      data: (doctors) {
                        if (doctors.isEmpty) {
                          return const HosEmptyState(
                            icon: HosIcons.search,
                            title: 'No doctors found',
                            message: 'Try a different name or specialty.',
                          );
                        }
                        return ListView.separated(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                          ),
                          itemCount: doctors.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: AppSpacing.sm),
                          itemBuilder: (context, index) {
                            final doctor = doctors[index];
                            return HosCard(
                              onTap: () => _grantAccess(doctor),
                              child: Row(
                                children: [
                                  HosAvatar(
                                    name: doctor.fullName,
                                    radius: 20,
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Dr. ${doctor.fullName}',
                                          style: AppTypography.label,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          doctor.specialization ??
                                              'General practice',
                                          style: AppTypography.caption,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    HosIcons.add,
                                    color: AppColors.primary,
                                    size: HosIcons.sizeMd,
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        HosAvatar(name: doctor.fullName, radius: 32),
        const SizedBox(height: AppSpacing.md),
        Text('Dr. ${doctor.fullName}', style: AppTypography.h4),
        if (doctor.specialization != null) ...[
          const SizedBox(height: 2),
          Text(doctor.specialization!, style: AppTypography.caption),
        ],
        const SizedBox(height: AppSpacing.lg),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.info.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppSpacing.borderRadiusSm),
          ),
          child: Row(
            children: [
              const Icon(HosIcons.info, color: AppColors.info, size: 18),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'This doctor will be able to view your health records, '
                  'lab reports, and medical history. You can revoke access at any time.',
                  style: AppTypography.caption,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: HosButton.secondary(
                label: 'Cancel',
                onPressed: () => Navigator.pop(context, false),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: HosButton.primary(
                label: 'Grant access',
                icon: HosIcons.success,
                onPressed: () => Navigator.pop(context, true),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
