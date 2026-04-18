import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../../providers/repository_providers.dart';

final reportDetailProvider =
    FutureProvider.family<LabReport?, String>((ref, reportId) {
  final repo = ref.read(labReportRepoProvider);
  return repo.getById(reportId);
});

final reportBiomarkersProvider =
    FutureProvider.family<List<Biomarker>, String>((ref, reportId) {
  final repo = ref.read(biomarkerRepoProvider);
  return repo.getByReportId(reportId);
});

final reportPatientProvider =
    FutureProvider.family<Patient?, String>((ref, patientId) {
  final repo = ref.read(patientRepoProvider);
  return repo.getById(patientId);
});

class ReportReviewScreen extends ConsumerStatefulWidget {
  const ReportReviewScreen({super.key, required this.reportId});

  final String reportId;

  @override
  ConsumerState<ReportReviewScreen> createState() =>
      _ReportReviewScreenState();
}

class _ReportReviewScreenState extends ConsumerState<ReportReviewScreen> {
  bool _isSaving = false;
  bool _isRejecting = false;

  Future<void> _rejectReport() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Report'),
        content: const Text(
          'Are you sure you want to reject this report? This will mark it as rejected and notify the uploader.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isRejecting = true);

    try {
      final repo = ref.read(labReportRepoProvider);
      await repo.update(widget.reportId, {'status': 'rejected'});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Report rejected.'),
            backgroundColor: AppColors.warning,
          ),
        );
        context.go('/reports');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error rejecting: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isRejecting = false);
    }
  }

  Future<void> _confirmAndSave() async {
    setState(() => _isSaving = true);

    try {
      final repo = ref.read(labReportRepoProvider);
      await repo.update(widget.reportId, {'status': 'ready'});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Report verified and saved successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        context.go('/reports');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final reportAsync = ref.watch(reportDetailProvider(widget.reportId));
    final biomarkersAsync =
        ref.watch(reportBiomarkersProvider(widget.reportId));

    return Scaffold(
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.go('/reports'),
                ),
                const SizedBox(width: AppSpacing.sm),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Review Report', style: AppTypography.h1),
                    Text(
                      'Report ID: ${widget.reportId}',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            // Report metadata
            reportAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => HosCard(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Text('Failed to load report: $error'),
                ),
              ),
              data: (report) {
                if (report == null) {
                  return HosCard(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Text('Report not found.',
                          style: AppTypography.bodyMedium),
                    ),
                  );
                }

                final createdAt = report.createdAt != null
                    ? '${report.createdAt!.year}-${report.createdAt!.month.toString().padLeft(2, '0')}-${report.createdAt!.day.toString().padLeft(2, '0')} ${report.createdAt!.hour.toString().padLeft(2, '0')}:${report.createdAt!.minute.toString().padLeft(2, '0')}'
                    : '—';

                return HosCard(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      children: [
                        _ReportPatientInfo(patientId: report.patientId),
                        const SizedBox(width: AppSpacing.xl),
                        _InfoTile(
                          label: 'Report Type',
                          value: report.reportType,
                          icon: Icons.science_outlined,
                        ),
                        const SizedBox(width: AppSpacing.xl),
                        _InfoTile(
                          label: 'Uploaded',
                          value: createdAt,
                          icon: Icons.access_time_outlined,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Extracted Biomarkers', style: AppTypography.h3),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Review and edit the OCR-extracted values below before confirming.',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            biomarkersAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => HosCard(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Text('Failed to load biomarkers: $error'),
                ),
              ),
              data: (biomarkers) {
                if (biomarkers.isEmpty) {
                  return HosCard(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Center(
                        child: Text(
                          'No biomarkers found for this report.',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  );
                }

                return HosCard(
                  child: SizedBox(
                    width: double.infinity,
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(
                        AppColors.surface,
                      ),
                      columns: const [
                        DataColumn(label: Text('Biomarker')),
                        DataColumn(label: Text('Value')),
                        DataColumn(label: Text('Unit')),
                        DataColumn(label: Text('Reference Range')),
                        DataColumn(label: Text('Status')),
                      ],
                      rows: biomarkers.map((biomarker) {
                        final isNormal = biomarker.isNormal;
                        return DataRow(
                          cells: [
                            DataCell(Text(
                              biomarker.name,
                              style: AppTypography.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            )),
                            DataCell(Text(
                                biomarker.value.toStringAsFixed(1))),
                            DataCell(Text(biomarker.unit ?? '—')),
                            DataCell(Text(biomarker.referenceRange)),
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.sm,
                                  vertical: AppSpacing.xs,
                                ),
                                decoration: BoxDecoration(
                                  color: isNormal
                                      ? AppColors.success.withValues(alpha: 0.1)
                                      : AppColors.error.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  biomarker.statusLabel,
                                  style: AppTypography.caption.copyWith(
                                    color: isNormal
                                        ? AppColors.success
                                        : AppColors.error,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => context.go('/reports'),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: AppSpacing.md),
                OutlinedButton.icon(
                  onPressed: _isRejecting ? null : _rejectReport,
                  icon: _isRejecting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.cancel_outlined, size: 18),
                  label: Text(_isRejecting ? 'Rejecting...' : 'Reject'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                HosButton(
                  label: 'Confirm & Save',
                  onPressed: _confirmAndSave,
                  isLoading: _isSaving,
                  icon: Icons.check_circle_outlined,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}

class _ReportPatientInfo extends ConsumerWidget {
  const _ReportPatientInfo({required this.patientId});

  final String patientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patientAsync = ref.watch(reportPatientProvider(patientId));
    return patientAsync.when(
      loading: () => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _InfoTile(
            label: 'Patient',
            value: 'Loading...',
            icon: Icons.person_outlined,
          ),
          const SizedBox(width: AppSpacing.xl),
          _InfoTile(
            label: 'Health ID',
            value: '...',
            icon: Icons.badge_outlined,
          ),
        ],
      ),
      error: (_, _) => _InfoTile(
        label: 'Patient',
        value: patientId.length > 8 ? patientId.substring(0, 8) : patientId,
        icon: Icons.person_outlined,
      ),
      data: (patient) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _InfoTile(
            label: 'Patient',
            value: patient?.fullName ?? 'Unknown',
            icon: Icons.person_outlined,
          ),
          const SizedBox(width: AppSpacing.xl),
          _InfoTile(
            label: 'Health ID',
            value: patient?.healthId ?? '—',
            icon: Icons.badge_outlined,
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: AppSpacing.sm),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            Text(value, style: AppTypography.bodyMedium),
          ],
        ),
      ],
    );
  }
}
