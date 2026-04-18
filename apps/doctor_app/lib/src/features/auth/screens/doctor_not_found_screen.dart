import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../../providers/auth_provider.dart';

class DoctorNotFoundScreen extends ConsumerWidget {
  const DoctorNotFoundScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.screenPadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.person_off_outlined, size: 80, color: AppColors.textTertiary),
              const SizedBox(height: AppSpacing.xl),
              Text('Account Not Found', style: AppTypography.h2, textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Your Google account is not linked to a HealthOS doctor profile.\n\n'
                'Doctor accounts are created by your hospital administrator. '
                'Please contact your hospital admin or support team.',
                style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xxl),
              HosButton(
                label: 'Sign Out',
                onPressed: () => ref.read(authServiceProvider).signOut(),
                isOutlined: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
