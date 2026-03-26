import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import '../providers/reports_provider.dart';

final _searchQueryProvider = StateProvider<String>((ref) => '');
final _statusFilterProvider = StateProvider<String?>((ref) => null);

class ReportsListScreen extends ConsumerWidget {
  const ReportsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(patientReportsProvider);
    final searchQuery = ref.watch(_searchQueryProvider);
    final statusFilter = ref.watch(_statusFilterProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Lab Reports')),
      body: reportsAsync.when(
        data: (reports) {
          // Apply filters
          var filtered = reports;
          if (searchQuery.isNotEmpty) {
            final q = searchQuery.toLowerCase();
            filtered = filtered
                .where((r) =>
                    r.reportType.toLowerCase().contains(q) ||
                    (r.labName?.toLowerCase().contains(q) ?? false))
                .toList();
          }
          if (statusFilter != null) {
            filtered = filtered.where((r) => r.status == statusFilter).toList();
          }

          return Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
                child: HosTextField(
                  label: 'Search reports',
                  prefixIcon: Icons.search,
                  hint: 'Search by type or lab name',
                  onChanged: (value) =>
                      ref.read(_searchQueryProvider.notifier).state = value,
                ),
              ),
              // Filter chips
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterChip(
                        label: 'All',
                        selected: statusFilter == null,
                        onSelected: () =>
                            ref.read(_statusFilterProvider.notifier).state = null,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      _FilterChip(
                        label: 'Ready',
                        selected: statusFilter == 'ready',
                        color: AppColors.success,
                        onSelected: () =>
                            ref.read(_statusFilterProvider.notifier).state = 'ready',
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      _FilterChip(
                        label: 'Processing',
                        selected: statusFilter == 'processing',
                        color: AppColors.warning,
                        onSelected: () =>
                            ref.read(_statusFilterProvider.notifier).state =
                                'processing',
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      _FilterChip(
                        label: 'Error',
                        selected: statusFilter == 'error',
                        color: AppColors.error,
                        onSelected: () =>
                            ref.read(_statusFilterProvider.notifier).state = 'error',
                      ),
                    ],
                  ),
                ),
              ),
              // Reports list
              Expanded(
                child: filtered.isEmpty
                    ? const HosEmptyState(
                        message: 'No lab reports found',
                        icon: Icons.science_outlined,
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (context, index) {
                          final report = filtered[index];
                          return HosCard(
                            onTap: () => context.go('/reports/${report.id}'),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(AppSpacing.sm),
                                  decoration: BoxDecoration(
                                    color:
                                        AppColors.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(
                                        AppSpacing.borderRadiusSm),
                                  ),
                                  child: const Icon(Icons.science,
                                      color: AppColors.primary),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(report.reportType,
                                          style: AppTypography.label),
                                      Text(
                                        AppDateUtils.formatDate(
                                            report.reportDate),
                                        style: AppTypography.bodySmall,
                                      ),
                                      if (report.labName != null)
                                        Text(report.labName!,
                                            style: AppTypography.caption),
                                    ],
                                  ),
                                ),
                                HosStatusChip(
                                  label: report.status.toUpperCase(),
                                  color: _statusColor(report.status),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
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

  static Color _statusColor(String status) {
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
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
    this.color,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      selectedColor: (color ?? AppColors.primary).withValues(alpha: 0.15),
      checkmarkColor: color ?? AppColors.primary,
    );
  }
}
