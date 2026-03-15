import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

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

  // Sample data - will be replaced with Supabase queries
  static const _reports = [
    _ReportRow(
      id: 'RPT-001',
      patientName: 'Rahul Sharma',
      healthId: 'HID-20260101-001',
      reportType: 'Complete Blood Count (CBC)',
      uploadedAt: '2026-03-15 10:30',
      status: 'Verified',
    ),
    _ReportRow(
      id: 'RPT-002',
      patientName: 'Priya Patel',
      healthId: 'HID-20260102-002',
      reportType: 'Lipid Panel',
      uploadedAt: '2026-03-15 09:15',
      status: 'Pending Review',
    ),
    _ReportRow(
      id: 'RPT-003',
      patientName: 'Ankit Singh',
      healthId: 'HID-20260103-003',
      reportType: 'Thyroid Panel',
      uploadedAt: '2026-03-14 16:45',
      status: 'Processing',
    ),
    _ReportRow(
      id: 'RPT-004',
      patientName: 'Suresh Gupta',
      healthId: 'HID-20260104-004',
      reportType: 'Liver Function Test (LFT)',
      uploadedAt: '2026-03-14 14:20',
      status: 'Verified',
    ),
    _ReportRow(
      id: 'RPT-005',
      patientName: 'Kavita Desai',
      healthId: 'HID-20260105-005',
      reportType: 'HbA1c',
      uploadedAt: '2026-03-14 11:00',
      status: 'Pending Review',
    ),
    _ReportRow(
      id: 'RPT-006',
      patientName: 'Deepak Joshi',
      healthId: 'HID-20260106-006',
      reportType: 'Kidney Function Test (KFT)',
      uploadedAt: '2026-03-13 15:30',
      status: 'Failed',
    ),
  ];

  List<_ReportRow> get _filteredReports {
    var filtered = _reports.toList();

    if (_statusFilter != 'All') {
      filtered =
          filtered.where((r) => r.status == _statusFilter).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered
          .where((r) =>
              r.patientName.toLowerCase().contains(query) ||
              r.healthId.toLowerCase().contains(query) ||
              r.reportType.toLowerCase().contains(query))
          .toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
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
              child: HosCard(
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
                        DataColumn(label: Text('Health ID')),
                        DataColumn(label: Text('Type')),
                        DataColumn(label: Text('Uploaded')),
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: _filteredReports.map((report) {
                        return DataRow(
                          cells: [
                            DataCell(Text(
                              report.id,
                              style: AppTypography.bodySmall.copyWith(
                                fontFamily: 'monospace',
                              ),
                            )),
                            DataCell(Text(report.patientName)),
                            DataCell(Text(
                              report.healthId,
                              style: AppTypography.bodySmall.copyWith(
                                fontFamily: 'monospace',
                                color: AppColors.primary,
                              ),
                            )),
                            DataCell(Text(report.reportType)),
                            DataCell(Text(report.uploadedAt)),
                            DataCell(
                                _ReportStatusChip(status: report.status)),
                            DataCell(
                              IconButton(
                                icon: const Icon(
                                    Icons.rate_review_outlined,
                                    size: 18),
                                onPressed: () {
                                  context.go('/reports/${report.id}');
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportRow {
  final String id;
  final String patientName;
  final String healthId;
  final String reportType;
  final String uploadedAt;
  final String status;

  const _ReportRow({
    required this.id,
    required this.patientName,
    required this.healthId,
    required this.reportType,
    required this.uploadedAt,
    required this.status,
  });
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
