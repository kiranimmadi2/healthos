import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_kit/ui_kit.dart';

import '../providers/reports_provider.dart';

class ReportDetailScreen extends ConsumerWidget {
  const ReportDetailScreen({super.key, required this.reportId});

  final String reportId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final biomarkersAsync = ref.watch(reportBiomarkersProvider(reportId));

    return Scaffold(
      appBar: AppBar(title: const Text('Report Details')),
      body: biomarkersAsync.when(
        data: (biomarkers) {
          if (biomarkers.isEmpty) {
            return const HosEmptyState(
              message: 'No biomarker data available',
              icon: Icons.science_outlined,
            );
          }
          return ListView(
            padding: AppSpacing.screenPadding,
            children: [
              Text('Biomarkers', style: AppTypography.h3),
              const SizedBox(height: AppSpacing.md),
              ...biomarkers.map((biomarker) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: HosCard(
                      onTap: () {},
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(biomarker.name, style: AppTypography.label),
                                Text(
                                  'Ref: ${biomarker.referenceRange}',
                                  style: AppTypography.caption,
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                biomarker.displayValue,
                                style: AppTypography.h4.copyWith(
                                  color: biomarker.isNormal
                                      ? AppColors.biomarkerNormal
                                      : biomarker.isHigh
                                          ? AppColors.biomarkerHigh
                                          : AppColors.biomarkerLow,
                                ),
                              ),
                              Text(
                                biomarker.statusLabel,
                                style: AppTypography.caption.copyWith(
                                  color: biomarker.isNormal
                                      ? AppColors.biomarkerNormal
                                      : AppColors.error,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )),
              const SizedBox(height: AppSpacing.lg),
              Text('Trend', style: AppTypography.h3),
              const SizedBox(height: AppSpacing.md),
              if (biomarkers.isNotEmpty)
                BiomarkerLineChart(biomarkers: biomarkers),
            ],
          );
        },
        loading: () => const HosLoading(message: 'Loading biomarkers...'),
        error: (error, _) => HosError(message: error.toString()),
      ),
    );
  }
}
