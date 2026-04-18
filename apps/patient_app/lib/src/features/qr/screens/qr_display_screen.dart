import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../../providers/patient_provider.dart';

class QrDisplayScreen extends ConsumerWidget {
  const QrDisplayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patientAsync = ref.watch(currentPatientProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Health QR')),
      body: patientAsync.when(
        data: (patient) {
          if (patient == null) {
            return const HosError(message: 'Profile not found');
          }
          return Center(
            child: Padding(
              padding: AppSpacing.screenPadding,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Share your Health ID',
                    style: AppTypography.h3,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Show this QR code to your doctor to grant them access to your records.',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  HosQrCode(
                    data: 'healthos://patient/${patient.healthId}',
                    size: 220,
                    label: patient.healthId,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  HosHealthIdBadge(healthId: patient.healthId),
                  const SizedBox(height: AppSpacing.lg),
                  HosButton(
                    label: 'Share Health ID',
                    icon: Icons.share,
                    isOutlined: true,
                    onPressed: () {
                      Share.share(
                        'My HealthOS Health ID: ${patient.healthId}\nhealthos://patient/${patient.healthId}',
                        subject: 'My Health ID',
                      );
                    },
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
