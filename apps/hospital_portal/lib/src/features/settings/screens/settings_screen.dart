import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../../providers/auth_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

            // ── Hospital Profile Card ──
            Text('Hospital Profile', style: AppTypography.h3),
            const SizedBox(height: AppSpacing.md),
            HosCard(
              child: Column(
                children: [
                  _SettingsRow(
                    icon: Icons.local_hospital_outlined,
                    label: 'Hospital Name',
                    value: 'Configured via Supabase',
                  ),
                  const Divider(height: AppSpacing.lg),
                  _SettingsRow(
                    icon: Icons.location_on_outlined,
                    label: 'Address',
                    value: '--',
                  ),
                  const Divider(height: AppSpacing.lg),
                  _SettingsRow(
                    icon: Icons.phone_outlined,
                    label: 'Phone',
                    value: '--',
                  ),
                  const Divider(height: AppSpacing.lg),
                  _SettingsRow(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: '--',
                  ),
                ],
              ),
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
                    onTap: () {
                      // TODO: Navigate to admin account management
                    },
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
                    onTap: () {
                      // TODO: Navigate to user management
                    },
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
                    onTap: () {
                      // TODO: Navigate to configuration
                    },
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
