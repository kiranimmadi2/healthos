import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../../providers/repository_providers.dart';

final reportsProvider = FutureProvider<List<LabReport>>((ref) {
  final repo = ref.read(labReportRepoProvider);
  return repo.getAll();
});

/// Looks up a patient name by ID; caches per patient.
final patientNameProvider =
    FutureProvider.family<String, String>((ref, patientId) async {
  final repo = ref.read(patientRepoProvider);
  final patient = await repo.getById(patientId);
  return patient?.fullName ?? 'Unknown';
});

class ReportsListScreen extends ConsumerStatefulWidget {
  const ReportsListScreen({super.key});

  @override
  ConsumerState<ReportsListScreen> createState() =>
      _ReportsListScreenState();
}

class _ReportsListScreenState extends ConsumerState<ReportsListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _statusFilter = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending Review';
      case 'ready':
        return 'Verified';
      case 'processing':
        return 'Processing';
      case 'failed':
        return 'Failed';
      default:
        return status;
    }
  }

  String _dbStatus(String uiStatus) {
    switch (uiStatus) {
      case 'Pending Review':
        return 'pending';
      case 'Verified':
        return 'ready';
      case 'Processing':
        return 'processing';
      case 'Failed':
        return 'failed';
      default:
        return uiStatus.toLowerCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    final reportsAsync = ref.watch(reportsProvider);

    return Scaffold(
      body: Padding(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.lg),
            Text('Reports', style: AppTypography.h1),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'View and manage all uploaded lab reports.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                SizedBox(
                  width: 360,
                  child: HosTextField(
                    controller: _searchController,
                    hint: 'Search by patient, Health ID, or report type...',
                    prefixIcon: Icons.search,
                    onChanged: (value) {
                      setState(() => _searchQuery = value);
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                ChoiceChip(
                  label: const Text('All'),
                  selected: _statusFilter == 'All',
                  onSelected: (_) =>
                      setState(() => _statusFilter = 'All'),
                ),
                const SizedBox(width: AppSpacing.xs),
                ChoiceChip(
                  label: const Text('Pending Review'),
                  selected: _statusFilter == 'Pending Review',
                  onSelected: (_) =>
                      setState(() => _statusFilter = 'Pending Review'),
                ),
                const SizedBox(width: AppSpacing.xs),
                ChoiceChip(
                  label: const Text('Verified'),
                  selected: _statusFilter == 'Verified',
                  onSelected: (_) =>
                      setState(() => _statusFilter = 'Verified'),
                ),
                const SizedBox(width: AppSpacing.xs),
                ChoiceChip(
                  label: const Text('Processing'),
                  selected: _statusFilter == 'Processing',
                  onSelected: (_) =>
                      setState(() => _statusFilter = 'Processing'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Expanded(
              child: reportsAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline,
                          size: 48, color: Colors.red.shade300),
                      const SizedBox(height: AppSpacing.md),
                      Text('Failed to load reports: $error',
                          style: AppTypography.bodyMedium),
                      const SizedBox(height: AppSpacing.md),
                      OutlinedButton(
                        onPressed: () =>
                            ref.invalidate(reportsProvider),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
                data: (reports) {
                  var filtered = reports.toList();

                  // Apply status filter
                  if (_statusFilter != 'All') {
                    final dbStatus = _dbStatus(_statusFilter);
                    filtered = filtered
                        .where((r) =>
                            r.status.toLowerCase() == dbStatus)
                        .toList();
                  }

                  // Apply search filter
                  if (_searchQuery.isNotEmpty) {
                    final query = _searchQuery.toLowerCase();
                    filtered = filtered
                        .where((r) =>
                            r.reportType
                                .toLowerCase()
                                .contains(query) ||
                            r.patientId
                                .toLowerCase()
                                .contains(query) ||
                            (r.labName ?? '')
                                .toLowerCase()
                                .contains(query))
                        .toList();
                  }

                  if (filtered.isEmpty) {
                    return const HosEmptyState(
                      message: 'No reports found.',
                      icon: Icons.science_outlined,
                    );
                  }

                  return HosCard(
                    child: SingleChildScrollView(
                      child: SizedBox(
                        width: double.infinity,
                        child: DataTable(
                          headingRowColor: WidgetStateProperty.all(
                            AppColors.surface,
                          ),
                          columns: const [
                            DataColumn(label: Text('Report ID')),
                            DataColumn(label: Text('Patient')),
                            DataColumn(label: Text('Type')),
                            DataColumn(label: Text('Lab')),
                            DataColumn(label: Text('Uploaded')),
                            DataColumn(label: Text('Status')),
                            DataColumn(label: Text('Actions')),
                          ],
                          rows: filtered.map((report) {
                            final displayStatus =
                                _formatStatus(report.status);
                            final createdAt = report.createdAt != null
                                ? '${report.createdAt!.year}-${report.createdAt!.month.toString().padLeft(2, '0')}-${report.createdAt!.day.toString().padLeft(2, '0')} ${report.createdAt!.hour.toString().padLeft(2, '0')}:${report.createdAt!.minute.toString().padLeft(2, '0')}'
                                : '—';

                            return DataRow(
                              cells: [
                                DataCell(Text(
                                  report.id.length > 8
                                      ? report.id.substring(0, 8)
                                      : report.id,
                                  style:
                                      AppTypography.bodySmall.copyWith(
                                    fontFamily: 'monospace',
                                  ),
                                )),
                                DataCell(
                                    _PatientNameCell(
                                        patientId: report.patientId)),
                                DataCell(Text(report.reportType)),
                                DataCell(
                                    Text(report.labName ?? '—')),
                                DataCell(Text(createdAt)),
                                DataCell(_ReportStatusChip(
                                    status: displayStatus)),
                                DataCell(
                                  IconButton(
                                    icon: const Icon(
                                        Icons.rate_review_outlined,
                                        size: 18),
                                    onPressed: () {
                                      context.go(
                                          '/reports/${report.id}');
                                    },
                                    tooltip: 'Review',
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PatientNameCell extends ConsumerWidget {
  const _PatientNameCell({required this.patientId});

  final String patientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameAsync = ref.watch(patientNameProvider(patientId));
    return nameAsync.when(
      data: (name) => Text(name),
      loading: () => const SizedBox(
        width: 80,
        child: LinearProgressIndicator(minHeight: 2),
      ),
      error: (_, _) => Text(
        patientId.length > 8 ? patientId.substring(0, 8) : patientId,
        style: AppTypography.bodySmall.copyWith(
          fontFamily: 'monospace',
        ),
      ),
    );
  }
}

class _ReportStatusChip extends StatelessWidget {
  const _ReportStatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    switch (status) {
      case 'Verified':
        color = Colors.green;
        icon = Icons.check_circle_outline;
      case 'Pending Review':
        color = Colors.orange;
        icon = Icons.pending_outlined;
      case 'Processing':
        color = Colors.blue;
        icon = Icons.hourglass_top;
      case 'Failed':
        color = Colors.red;
        icon = Icons.error_outline;
      default:
        color = Colors.grey;
        icon = Icons.help_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            status,
            style: AppTypography.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
