import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../../providers/auth_provider.dart';
import '../../../providers/doctor_provider.dart';

class DoctorProfileScreen extends ConsumerStatefulWidget {
  const DoctorProfileScreen({super.key});

  @override
  ConsumerState<DoctorProfileScreen> createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends ConsumerState<DoctorProfileScreen> {
  bool _isEditing = false;
  bool _isLoading = false;
  final _nameController = TextEditingController();
  final _specializationController = TextEditingController();
  final _licenseController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  void _loadDoctorData() {
    final doctor = ref.read(currentDoctorProvider).valueOrNull;
    if (doctor != null) {
      _nameController.text = doctor.fullName ?? '';
      _specializationController.text = doctor.specialization ?? '';
      _licenseController.text = doctor.licenseNumber ?? '';
      _emailController.text = doctor.email ?? '';
      _phoneController.text = doctor.phone ?? '';
    }
  }

  @override
  void initState() {
    super.initState();
    _loadDoctorData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _specializationController.dispose();
    _licenseController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);
    try {
      final doctor = await ref.read(currentDoctorProvider.future);
      if (doctor == null) throw Exception('Doctor profile not found');

      final repo = ref.read(doctorRepositoryProvider);
      await repo.update(doctor.id, {
        'full_name': _nameController.text.trim(),
        'specialization': _specializationController.text.trim(),
        'license_number': _licenseController.text.trim(),
        'email': _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        'phone': _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      });

      ref.invalidate(currentDoctorProvider);

      if (mounted) {
        setState(() => _isEditing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final doctorAsync = ref.watch(currentDoctorProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                _loadDoctorData();
                setState(() => _isEditing = true);
              },
            ),
        ],
      ),
      body: doctorAsync.when(
        data: (doctor) {
          if (doctor == null) {
            return const HosError(message: 'Doctor profile not found');
          }
          return SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Padding(
                  padding: AppSpacing.screenPadding,
                  child: Column(
                    children: [
                      const SizedBox(height: AppSpacing.lg),
                      HosAvatar(
                        name: doctor.fullName,
                        imageUrl: doctor.avatarUrl,
                        radius: 48,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      if (!_isEditing) ...[
                        Text(doctor.fullName ?? 'Unknown', style: AppTypography.h3),
                        const SizedBox(height: AppSpacing.xs),
                        if (doctor.specialization != null)
                          Text(doctor.specialization!, style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
                        const SizedBox(height: AppSpacing.xl),
                        _InfoRow(icon: Icons.badge, label: 'License', value: doctor.licenseNumber ?? 'Not set'),
                        _InfoRow(icon: Icons.email, label: 'Email', value: doctor.email ?? 'Not set'),
                        _InfoRow(icon: Icons.phone, label: 'Phone', value: doctor.phone ?? 'Not set'),
                        if (doctor.verified)
                          Padding(
                            padding: const EdgeInsets.only(top: AppSpacing.md),
                            child: HosStatusChip(label: 'VERIFIED', color: AppColors.success, icon: Icons.verified),
                          ),
                      ] else ...[
                        const SizedBox(height: AppSpacing.md),
                        HosTextField(controller: _nameController, label: 'Full Name', prefixIcon: Icons.person),
                        const SizedBox(height: AppSpacing.md),
                        HosTextField(controller: _specializationController, label: 'Specialization', prefixIcon: Icons.medical_services),
                        const SizedBox(height: AppSpacing.md),
                        HosTextField(controller: _licenseController, label: 'License Number', prefixIcon: Icons.badge),
                        const SizedBox(height: AppSpacing.md),
                        HosTextField(controller: _emailController, label: 'Email', prefixIcon: Icons.email),
                        const SizedBox(height: AppSpacing.md),
                        HosTextField(controller: _phoneController, label: 'Phone', prefixIcon: Icons.phone),
                        const SizedBox(height: AppSpacing.xl),
                        Row(
                          children: [
                            Expanded(
                              child: HosButton(
                                label: 'Cancel',
                                isOutlined: true,
                                onPressed: () => setState(() => _isEditing = false),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: HosButton(
                                label: 'Save',
                                onPressed: _saveProfile,
                                isLoading: _isLoading,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: AppSpacing.xxl),
                      HosButton(
                        label: 'Sign Out',
                        isOutlined: true,
                        icon: Icons.logout,
                        onPressed: () async {
                          final authService = ref.read(authServiceProvider);
                          await authService.signOut();
                        },
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                  ),
                ),
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

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label, required this.value});
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
