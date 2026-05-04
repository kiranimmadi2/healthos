import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../../providers/auth_provider.dart';
import '../../../providers/patient_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patientAsync = ref.watch(currentPatientProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.push('/profile/edit'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final authService = ref.read(authServiceProvider);
              await authService.signOut();
            },
          ),
        ],
      ),
      body: patientAsync.when(
        data: (patient) {
          if (patient == null) {
            return const HosError(message: 'Profile not found');
          }
          return SingleChildScrollView(
            child: HosPageContainer(
              maxWidth: 720,
              child: Column(
                children: [
                const SizedBox(height: AppSpacing.lg),
                HosAvatar(
                  name: patient.fullName,
                  imageUrl: patient.avatarUrl,
                  radius: 48,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(patient.fullName ?? 'Unknown', style: AppTypography.h3),
                const SizedBox(height: AppSpacing.xs),
                HosHealthIdBadge(healthId: patient.healthId),
                const SizedBox(height: AppSpacing.xl),
                _ProfileField(
                  icon: Icons.phone,
                  label: 'Phone',
                  value: patient.phone,
                ),
                _ProfileField(
                  icon: Icons.cake,
                  label: 'Date of Birth',
                  value: patient.dateOfBirth != null
                      ? AppDateUtils.formatDate(patient.dateOfBirth!)
                      : 'Not set',
                ),
                _ProfileField(
                  icon: Icons.wc,
                  label: 'Gender',
                  value: patient.gender ?? 'Not set',
                ),
                _ProfileField(
                  icon: Icons.bloodtype,
                  label: 'Blood Group',
                  value: patient.bloodGroup ?? 'Not set',
                ),
                if (patient.allergies.isNotEmpty)
                  _ProfileField(
                    icon: Icons.warning_amber,
                    label: 'Allergies',
                    value: patient.allergies.join(', '),
                  ),
                if (patient.chronicConditions.isNotEmpty)
                  _ProfileField(
                    icon: Icons.medical_information,
                    label: 'Conditions',
                    value: patient.chronicConditions.join(', '),
                  ),
                const SizedBox(height: AppSpacing.xl),
                _SectionTile(
                  icon: Icons.family_restroom,
                  label: 'Family & Dependents',
                  subtitle: 'Manage family members and dependents',
                  onTap: () => context.push('/profile/family'),
                ),
                ],
              ),
            ),
          );
        },
        loading: () => const HosLoading(),
        error: (error, _) => HosError(message: error.toString()),
      ),
    );
  }
}

class _SectionTile extends StatelessWidget {
  const _SectionTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return HosCard(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                Text(subtitle, style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textTertiary),
        ],
      ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  const _ProfileField({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 20),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTypography.caption),
                Text(value, style: AppTypography.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
