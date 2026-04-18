import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../../providers/auth_provider.dart';
import '../../../providers/hospital_provider.dart';

void _showComingSoon(BuildContext context, String feature) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('$feature — coming soon')),
  );
}

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hospitalAsync = ref.watch(currentHospitalProvider);
    final authUser = ref.watch(authStateProvider).valueOrNull;

    return Scaffold(
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.lg),
            Text('Hospital Settings', style: AppTypography.h1),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Manage hospital profile and administration.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // ── Admin Profile Card ──
            Text('Admin Profile', style: AppTypography.h3),
            const SizedBox(height: AppSpacing.md),
            HosCard(
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: Text(
                      _initials(authUser?.email),
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          authUser?.userMetadata?['full_name'] as String? ??
                              'Hospital Administrator',
                          style: AppTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          authUser?.email ?? '--',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        if (authUser?.lastSignInAt != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            'Last sign-in: ${_formatDate(authUser!.lastSignInAt!)}',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // ── Hospital Profile Card ──
            Text('Hospital Profile', style: AppTypography.h3),
            const SizedBox(height: AppSpacing.md),
            hospitalAsync.when(
              loading: () => const HosCard(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.lg),
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
              error: (error, _) => HosCard(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    children: [
                      Icon(Icons.error_outline,
                          color: Colors.red.shade400, size: 32),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Failed to load hospital data',
                        style: AppTypography.bodyMedium,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        error.toString(),
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextButton(
                        onPressed: () =>
                            ref.invalidate(currentHospitalProvider),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
              data: (hospital) {
                if (hospital == null) {
                  return HosCard(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        children: [
                          Icon(Icons.info_outline,
                              color: Colors.orange.shade400, size: 32),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'No hospital profile found',
                            style: AppTypography.bodyMedium,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Please contact support to link your account to a hospital.',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final address = hospital.address;
                final addressStr = address != null
                    ? [
                        address['street'],
                        address['city'],
                        address['state'],
                        address['zip'],
                      ].where((s) => s != null && s.toString().isNotEmpty).join(', ')
                    : '--';

                return HosCard(
                  child: Column(
                    children: [
                      _SettingsRow(
                        icon: Icons.local_hospital_outlined,
                        label: 'Hospital Name',
                        value: hospital.name,
                      ),
                      const Divider(height: AppSpacing.lg),
                      _SettingsRow(
                        icon: Icons.location_on_outlined,
                        label: 'Address',
                        value: addressStr,
                      ),
                      const Divider(height: AppSpacing.lg),
                      _SettingsRow(
                        icon: Icons.phone_outlined,
                        label: 'Phone',
                        value: hospital.phone ?? '--',
                      ),
                      const Divider(height: AppSpacing.lg),
                      _SettingsRow(
                        icon: Icons.email_outlined,
                        label: 'Email',
                        value: hospital.email ?? '--',
                      ),
                      const Divider(height: AppSpacing.lg),
                      _SettingsRow(
                        icon: Icons.badge_outlined,
                        label: 'License Number',
                        value: hospital.license ?? '--',
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.xl),

            // ── Administration Section ──
            Text('Administration', style: AppTypography.h3),
            const SizedBox(height: AppSpacing.md),
            HosCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.admin_panel_settings_outlined),
                    title: Text('Admin Account',
                        style: AppTypography.bodyMedium),
                    subtitle: Text(
                      'Manage your administrator account',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    trailing:
                        const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                    onTap: () => _showComingSoon(context, 'Admin Account Management'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.group_outlined),
                    title: Text('User Management',
                        style: AppTypography.bodyMedium),
                    subtitle: Text(
                      'Manage staff accounts and permissions',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    trailing:
                        const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                    onTap: () => _showComingSoon(context, 'User Management'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.settings_outlined),
                    title:
                        Text('Configuration', style: AppTypography.bodyMedium),
                    subtitle: Text(
                      'System preferences and integrations',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    trailing:
                        const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                    onTap: () => _showComingSoon(context, 'Configuration'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // ── System Section ──
            Text('System', style: AppTypography.h3),
            const SizedBox(height: AppSpacing.md),
            HosCard(
              padding: EdgeInsets.zero,
              child: ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: Text(
                  'Sign Out',
                  style: AppTypography.bodyMedium.copyWith(
                    color: Colors.red,
                  ),
                ),
                onTap: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Sign Out'),
                      content: const Text(
                          'Are you sure you want to sign out?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(true),
                          child: const Text(
                            'Sign Out',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true) {
                    await ref.read(authServiceProvider).signOut();
                  }
                },
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  String _initials(String? email) {
    if (email == null || email.isEmpty) return '?';
    final parts = email.split('@').first.split(RegExp(r'[._]'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return email[0].toUpperCase();
  }

  String _formatDate(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate);
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return isoDate;
    }
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
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
        Icon(icon, size: 20, color: AppColors.textSecondary),
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
