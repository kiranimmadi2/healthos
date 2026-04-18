import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_client/supabase_client.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../../providers/doctor_provider.dart';

class AddLabResultScreen extends ConsumerStatefulWidget {
  const AddLabResultScreen({super.key, required this.patientId});
  final String patientId;

  @override
  ConsumerState<AddLabResultScreen> createState() => _AddLabResultScreenState();
}

class _AddLabResultScreenState extends ConsumerState<AddLabResultScreen> {
  final _reportTypeController = TextEditingController();
  final _labNameController = TextEditingController();
  DateTime _reportDate = DateTime.now();
  bool _isLoading = false;

  final List<_BiomarkerEntry> _biomarkers = [_BiomarkerEntry()];

  static const _commonTests = [
    'Complete Blood Count (CBC)',
    'Lipid Panel',
    'Basic Metabolic Panel',
    'Comprehensive Metabolic Panel',
    'Thyroid Function (TSH)',
    'HbA1c',
    'Urinalysis',
    'Liver Function Tests',
    'Kidney Function Tests',
  ];

  @override
  void dispose() {
    _reportTypeController.dispose();
    _labNameController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _reportDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _reportDate = picked);
  }

  Future<void> _save() async {
    if (_reportTypeController.text.trim().isEmpty) return;
    final validBiomarkers = _biomarkers.where((b) => b.name.trim().isNotEmpty).toList();

    setState(() => _isLoading = true);
    try {
      final doctorId = ref.read(currentDoctorIdProvider);
      final repo = LabReportRepository();

      final report = await repo.create({
        'patient_id': widget.patientId,
        'report_type': _reportTypeController.text.trim(),
        'report_date': _reportDate.toIso8601String().split('T').first,
        'lab_name': _labNameController.text.trim().isEmpty
            ? null
            : _labNameController.text.trim(),
        'ordered_by_doctor_id': doctorId,
        'status': 'completed',
      });

      if (validBiomarkers.isNotEmpty) {
        await BiomarkerRepository().insertBatch(
          validBiomarkers.map((b) => {
            'lab_report_id': report.id,
            'patient_id': widget.patientId,
            'test_name': b.name.trim(),
            'value': b.value.trim(),
            'unit': b.unit.trim().isEmpty ? null : b.unit.trim(),
            'reference_range': b.refRange.trim().isEmpty ? null : b.refRange.trim(),
            'is_abnormal': b.isAbnormal,
          }).toList(),
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lab result saved')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Lab Result')),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.md),

            // Quick-select common test types
            Text('Common Tests', style: AppTypography.label.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: AppSpacing.sm),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _commonTests.map((t) => Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: ActionChip(
                    label: Text(t, style: AppTypography.caption),
                    onPressed: () => setState(() => _reportTypeController.text = t),
                  ),
                )).toList(),
              ),
            ),

            const SizedBox(height: AppSpacing.md),
            HosTextField(
              controller: _reportTypeController,
              label: 'Test / Report Type *',
              prefixIcon: Icons.science_outlined,
            ),
            const SizedBox(height: AppSpacing.md),
            HosTextField(
              controller: _labNameController,
              label: 'Lab Name (optional)',
              prefixIcon: Icons.local_hospital_outlined,
            ),
            const SizedBox(height: AppSpacing.md),
            GestureDetector(
              onTap: _selectDate,
              child: AbsorbPointer(
                child: HosTextField(
                  label: 'Report Date',
                  prefixIcon: Icons.calendar_today,
                  hint: AppDateUtils.formatDate(_reportDate),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.xl),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Biomarkers / Results', style: AppTypography.h4),
                TextButton.icon(
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Row'),
                  onPressed: () => setState(() => _biomarkers.add(_BiomarkerEntry())),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            ..._biomarkers.asMap().entries.map((entry) => _BiomarkerRow(
              index: entry.key,
              entry: entry.value,
              onRemove: _biomarkers.length > 1
                  ? () => setState(() => _biomarkers.removeAt(entry.key))
                  : null,
              onChanged: () => setState(() {}),
            )),

            const SizedBox(height: AppSpacing.xl),
            HosButton(
              label: 'Save Lab Result',
              onPressed: _reportTypeController.text.trim().isEmpty ? null : _save,
              isLoading: _isLoading,
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}

class _BiomarkerEntry {
  String name = '';
  String value = '';
  String unit = '';
  String refRange = '';
  bool isAbnormal = false;
}

class _BiomarkerRow extends StatelessWidget {
  const _BiomarkerRow({
    required this.index,
    required this.entry,
    required this.onChanged,
    this.onRemove,
  });

  final int index;
  final _BiomarkerEntry entry;
  final VoidCallback onChanged;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return HosCard(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Test name',
                    isDense: true,
                    border: InputBorder.none,
                  ),
                  onChanged: (v) { entry.name = v; onChanged(); },
                ),
              ),
              if (onRemove != null)
                IconButton(
                  icon: const Icon(Icons.close, size: 16),
                  onPressed: onRemove,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          const Divider(height: 1),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Value',
                    isDense: true,
                    border: InputBorder.none,
                  ),
                  onChanged: (v) => entry.value = v,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Unit',
                    isDense: true,
                    border: InputBorder.none,
                  ),
                  onChanged: (v) => entry.unit = v,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Ref range',
                    isDense: true,
                    border: InputBorder.none,
                  ),
                  onChanged: (v) => entry.refRange = v,
                ),
              ),
            ],
          ),
          Row(
            children: [
              const Icon(Icons.warning_amber, size: 14, color: AppColors.warning),
              const SizedBox(width: 4),
              Text('Abnormal', style: AppTypography.caption),
              const Spacer(),
              Switch(
                value: entry.isAbnormal,
                onChanged: (v) { entry.isAbnormal = v; onChanged(); },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
