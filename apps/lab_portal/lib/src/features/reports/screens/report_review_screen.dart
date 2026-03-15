import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

class ReportReviewScreen extends ConsumerStatefulWidget {
  const ReportReviewScreen({super.key, required this.reportId});

  final String reportId;

  @override
  ConsumerState<ReportReviewScreen> createState() =>
      _ReportReviewScreenState();
}

class _ReportReviewScreenState extends ConsumerState<ReportReviewScreen> {
  bool _isSaving = false;

  // Sample OCR-extracted biomarkers - will be replaced with actual data
  final List<_BiomarkerEntry> _biomarkers = [
    _BiomarkerEntry(
        name: 'Hemoglobin', value: '14.2', unit: 'g/dL', refRange: '13.0-17.0'),
    _BiomarkerEntry(
        name: 'WBC Count', value: '7500', unit: '/mcL', refRange: '4500-11000'),
    _BiomarkerEntry(
        name: 'RBC Count', value: '5.1', unit: 'million/mcL', refRange: '4.5-5.5'),
    _BiomarkerEntry(
        name: 'Platelet Count',
        value: '250000',
        unit: '/mcL',
        refRange: '150000-400000'),
    _BiomarkerEntry(
        name: 'Hematocrit', value: '42', unit: '%', refRange: '38.3-48.6'),
    _BiomarkerEntry(
        name: 'MCV', value: '88', unit: 'fL', refRange: '80-100'),
    _BiomarkerEntry(
        name: 'MCH', value: '29', unit: 'pg', refRange: '27-33'),
    _BiomarkerEntry(
        name: 'MCHC', value: '34', unit: 'g/dL', refRange: '32-36'),
  ];

  Future<void> _confirmAndSave() async {
    setState(() => _isSaving = true);

    try {
      // TODO: Save verified biomarkers to Supabase
      await Future.delayed(const Duration(seconds: 1)); // Simulated save

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Report verified and saved successfully!'),
            backgroundColor: Colors.green,
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
            HosCard(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    _InfoTile(
                      label: 'Patient',
                      value: 'Priya Patel',
                      icon: Icons.person_outlined,
                    ),
                    const SizedBox(width: AppSpacing.xl),
                    _InfoTile(
                      label: 'Health ID',
                      value: 'HID-20260102-002',
                      icon: Icons.badge_outlined,
                    ),
                    const SizedBox(width: AppSpacing.xl),
                    _InfoTile(
                      label: 'Report Type',
                      value: 'Complete Blood Count (CBC)',
                      icon: Icons.science_outlined,
                    ),
                    const SizedBox(width: AppSpacing.xl),
                    _InfoTile(
                      label: 'Uploaded',
                      value: '2026-03-15 09:15',
                      icon: Icons.access_time_outlined,
                    ),
                  ],
                ),
              ),
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
            HosCard(
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
                  rows: _biomarkers.map((biomarker) {
                    final isNormal = _isInRange(
                        biomarker.value, biomarker.refRange);
                    return DataRow(
                      cells: [
                        DataCell(Text(
                          biomarker.name,
                          style: AppTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        )),
                        DataCell(
                          SizedBox(
                            width: 100,
                            child: TextFormField(
                              initialValue: biomarker.value,
                              decoration: const InputDecoration(
                                isDense: true,
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 8,
                                ),
                              ),
                              onChanged: (val) {
                                setState(() {
                                  biomarker.value = val;
                                });
                              },
                            ),
                          ),
                        ),
                        DataCell(Text(biomarker.unit)),
                        DataCell(Text(biomarker.refRange)),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.xs,
                            ),
                            decoration: BoxDecoration(
                              color: isNormal
                                  ? Colors.green.withValues(alpha: 0.1)
                                  : Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              isNormal ? 'Normal' : 'Abnormal',
                              style: AppTypography.caption.copyWith(
                                color: isNormal
                                    ? Colors.green
                                    : Colors.red,
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

  bool _isInRange(String value, String refRange) {
    try {
      final numValue =
          double.parse(value.replaceAll(RegExp(r'[^0-9.]'), ''));
      final parts = refRange.split('-');
      if (parts.length == 2) {
        final low =
            double.parse(parts[0].replaceAll(RegExp(r'[^0-9.]'), ''));
        final high =
            double.parse(parts[1].replaceAll(RegExp(r'[^0-9.]'), ''));
        return numValue >= low && numValue <= high;
      }
    } catch (_) {}
    return true;
  }
}

class _BiomarkerEntry {
  final String name;
  String value;
  final String unit;
  final String refRange;

  _BiomarkerEntry({
    required this.name,
    required this.value,
    required this.unit,
    required this.refRange,
  });
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
