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
      appBar: AppBar(title: const Text('Lab reports')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
            child: HosTextField(
              prefixIcon: HosIcons.search,
              hint: 'Search by type or lab name',
              onChanged: (value) =>
                  ref.read(_searchQueryProvider.notifier).state = value,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
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
                    onSelected: () => ref
                        .read(_statusFilterProvider.notifier)
                        .state = 'ready',
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  _FilterChip(
                    label: 'Processing',
                    selected: statusFilter == 'processing',
                    color: AppColors.warning,
                    onSelected: () => ref
                        .read(_statusFilterProvider.notifier)
                        .state = 'processing',
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  _FilterChip(
                    label: 'Error',
                    selected: statusFilter == 'error',
                    color: AppColors.error,
                    onSelected: () => ref
                        .read(_statusFilterProvider.notifier)
                        .state = 'error',
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: reportsAsync.when(
              loading: () => ListView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                children: const [
                  HosSkeletonListTile(),
                  HosSkeletonListTile(),
                  HosSkeletonListTile(),
                  HosSkeletonListTile(),
                ],
              ),
              error: (e, _) => HosError(
                message: e.toString(),
                onRetry: () => ref.invalidate(patientReportsProvider),
              ),
              data: (reports) {
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
                  filtered =
                      filtered.where((r) => r.status == statusFilter).toList();
                }
                if (filtered.isEmpty) {
                  return HosEmptyState(
                    icon: HosIcons.labReport,
                    title: reports.isEmpty
                        ? 'No lab reports yet'
                        : 'No matching reports',
                    message: reports.isEmpty
                        ? 'When a lab uploads results or your doctor records '
                            'biomarkers, they\'ll appear here.'
                        : 'Try a different search or filter.',
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async =>
                      ref.invalidate(patientReportsProvider),
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final r = filtered[index];
                      return HosLabReportCard(
                        title: r.reportType,
                        date: r.reportDate,
                        lab: r.labName,
                        status: _mapStatus(r.status),
                        abnormalCount: 0,
                        onTap: () => context.go('/reports/${r.id}'),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  static HosLabReportStatus _mapStatus(String raw) {
    switch (raw) {
      case 'ready':
        return HosLabReportStatus.reviewed;
      case 'processing':
        return HosLabReportStatus.pending;
      case 'error':
        return HosLabReportStatus.abnormal;
      default:
        return HosLabReportStatus.pending;
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
