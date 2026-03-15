import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import '../providers/reports_provider.dart';

class ReportsListScreen extends ConsumerWidget {
  const ReportsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(patientReportsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Lab Reports')),
      body: reportsAsync.when(
        data: (reports) {
          if (reports.isEmpty) {
            return const HosEmptyState(
              message: 'No lab reports yet',
              icon: Icons.science_outlined,
            );
          }
          return ListView.separated(
            padding: AppSpacing.screenPadding,
            itemCount: reports.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final report = reports[index];
              return HosCard(
                onTap: () => context.go('/reports/${report.id}'),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppSpacing.borderRadiusSm),
                      ),
                      child: const Icon(Icons.science, color: AppColors.primary),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(report.reportType, style: AppTypography.label),
                          Text(
                            AppDateUtils.formatDate(report.reportDate),
                            style: AppTypography.bodySmall,
                          ),
                          if (report.labName != null)
                            Text(report.labName!, style: AppTypography.caption),
                        ],
                      ),
                    ),
                    _StatusChip(status: report.status),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const HosLoading(message: 'Loading reports...'),
        error: (error, _) => HosError(
          message: error.toString(),
          onRetry: () => ref.invalidate(patientReportsProvider),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  Color get _color {
    switch (status) {
      case 'ready':
        return AppColors.success;
      case 'processing':
        return AppColors.warning;
      case 'error':
        return AppColors.error;
      default:
        return AppColors.textTertiary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: _color,
        ),
      ),
    );
  }
}
