import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_client/supabase_client.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../../providers/doctor_provider.dart';

class CreateVisitScreen extends ConsumerStatefulWidget {
  const CreateVisitScreen({super.key, required this.patientId});

  final String patientId;

  @override
  ConsumerState<CreateVisitScreen> createState() => _CreateVisitScreenState();
}

class _CreateVisitScreenState extends ConsumerState<CreateVisitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _chiefComplaintController = TextEditingController();
  final _diagnosisController = TextEditingController();
  final _icdCodeController = TextEditingController();
  final _notesController = TextEditingController();

  TriageLevel? _triageLevel;
  String? _visitType;
  DateTime? _followUpDate;
  bool _showVitals = false;
  bool _isLoading = false;

  // Vitals
  final _systolicController = TextEditingController();
  final _diastolicController = TextEditingController();
  final _heartRateController = TextEditingController();
  final _temperatureController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _spo2Controller = TextEditingController();

  static const _visitTypes = [
    ('consultation', 'Consultation'),
    ('follow_up', 'Follow-up'),
    ('emergency', 'Emergency'),
    ('procedure', 'Procedure'),
    ('telemedicine', 'Telemedicine'),
  ];

  @override
  void dispose() {
    _chiefComplaintController.dispose();
    _diagnosisController.dispose();
    _icdCodeController.dispose();
    _notesController.dispose();
    _systolicController.dispose();
    _diastolicController.dispose();
    _heartRateController.dispose();
    _temperatureController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _spo2Controller.dispose();
    super.dispose();
  }

  Future<void> _selectFollowUp() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _followUpDate = picked);
  }

  bool get _hasVitals =>
      _systolicController.text.isNotEmpty ||
      _heartRateController.text.isNotEmpty ||
      _temperatureController.text.isNotEmpty ||
      _weightController.text.isNotEmpty;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final doctorId = ref.read(currentDoctorIdProvider);
      final repo = VisitRepository();

      final visit = await repo.create({
        'patient_id': widget.patientId,
        'doctor_id': doctorId,
        'visited_at': DateTime.now().toIso8601String(),
        'chief_complaint': _chiefComplaintController.text.trim(),
        'diagnosis': _diagnosisController.text.trim().isEmpty
            ? null
            : _diagnosisController.text.trim(),
        'notes': _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        if (_triageLevel != null) 'triage_level': _triageLevel!.jsonValue,
        if (_visitType != null) 'visit_type': _visitType,
        if (_icdCodeController.text.trim().isNotEmpty)
          'icd_code': _icdCodeController.text.trim(),
        if (_followUpDate != null)
          'follow_up_date': _followUpDate!.toIso8601String().split('T').first,
      });

      // Save vitals if any were entered
      if (_hasVitals) {
        await VisitVitalsRepository().create({
          'visit_id': visit.id,
          'patient_id': widget.patientId,
          'recorded_by_doctor_id': doctorId,
          if (_systolicController.text.isNotEmpty)
            'blood_pressure_systolic': int.tryParse(_systolicController.text),
          if (_diastolicController.text.isNotEmpty)
            'blood_pressure_diastolic': int.tryParse(_diastolicController.text),
          if (_heartRateController.text.isNotEmpty)
            'heart_rate': int.tryParse(_heartRateController.text),
          if (_temperatureController.text.isNotEmpty)
            'temperature_celsius': double.tryParse(_temperatureController.text),
          if (_weightController.text.isNotEmpty)
            'weight_kg': double.tryParse(_weightController.text),
          if (_heightController.text.isNotEmpty)
            'height_cm': double.tryParse(_heightController.text),
          if (_spo2Controller.text.isNotEmpty)
            'spo2_percent': int.tryParse(_spo2Controller.text),
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Visit created successfully')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Visit')),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Padding(
              padding: AppSpacing.screenPadding,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('New Visit Record', style: AppTypography.h2),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Record the details of this patient visit.',
                      style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Visit type
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Visit Type',
                        prefixIcon: Icon(Icons.medical_services_outlined),
                      ),
                      initialValue: _visitType,
                      items: _visitTypes.map((t) {
                        final (value, label) = t;
                        return DropdownMenuItem(value: value, child: Text(label));
                      }).toList(),
                      onChanged: (v) => setState(() => _visitType = v),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    HosTextField(
                      controller: _chiefComplaintController,
                      label: 'Chief Complaint *',
                      hint: 'e.g. Persistent headache for 3 days',
                      prefixIcon: Icons.report_problem_outlined,
                      maxLines: 2,
                      validator: (value) =>
                          value == null || value.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: AppSpacing.md),

                    DropdownButtonFormField<TriageLevel>(
                      decoration: const InputDecoration(
                        labelText: 'Triage Level',
                        prefixIcon: Icon(Icons.priority_high),
                      ),
                      initialValue: _triageLevel,
                      items: TriageLevel.values.map((level) {
                        final color = level == TriageLevel.emergency
                            ? AppColors.error
                            : level == TriageLevel.seeDoctor
                                ? AppColors.warning
                                : AppColors.success;
                        return DropdownMenuItem(
                          value: level,
                          child: Row(
                            children: [
                              Container(
                                width: 12, height: 12,
                                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 8),
                              Text(level.displayName),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (v) => setState(() => _triageLevel = v),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    HosTextField(
                      controller: _diagnosisController,
                      label: 'Diagnosis',
                      hint: 'e.g. Tension-type headache',
                      prefixIcon: Icons.medical_information_outlined,
                      maxLines: 2,
                    ),
                    const SizedBox(height: AppSpacing.md),

                    HosTextField(
                      controller: _icdCodeController,
                      label: 'ICD-10 Code',
                      hint: 'e.g. G44.2',
                      prefixIcon: Icons.tag,
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Follow-up date
                    GestureDetector(
                      onTap: _selectFollowUp,
                      child: AbsorbPointer(
                        child: HosTextField(
                          label: 'Follow-up Date (optional)',
                          prefixIcon: Icons.event_repeat,
                          hint: _followUpDate != null
                              ? AppDateUtils.formatDate(_followUpDate!)
                              : 'Select follow-up date',
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    HosTextField(
                      controller: _notesController,
                      label: 'Notes',
                      hint: 'Additional clinical notes...',
                      prefixIcon: Icons.notes_outlined,
                      maxLines: 4,
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Vitals collapsible section
                    InkWell(
                      onTap: () => setState(() => _showVitals = !_showVitals),
                      borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                        child: Row(
                          children: [
                            const Icon(Icons.monitor_heart_outlined, color: AppColors.primary),
                            const SizedBox(width: AppSpacing.sm),
                            Text('Vitals', style: AppTypography.h4),
                            const Spacer(),
                            Icon(
                              _showVitals ? Icons.expand_less : Icons.expand_more,
                              color: AppColors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_showVitals) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          Expanded(
                            child: HosTextField(
                              controller: _systolicController,
                              label: 'Systolic (mmHg)',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: HosTextField(
                              controller: _diastolicController,
                              label: 'Diastolic (mmHg)',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          Expanded(
                            child: HosTextField(
                              controller: _heartRateController,
                              label: 'Heart Rate (bpm)',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: HosTextField(
                              controller: _temperatureController,
                              label: 'Temp (°C)',
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          Expanded(
                            child: HosTextField(
                              controller: _weightController,
                              label: 'Weight (kg)',
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: HosTextField(
                              controller: _heightController,
                              label: 'Height (cm)',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: HosTextField(
                              controller: _spo2Controller,
                              label: 'SpO₂ (%)',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: AppSpacing.xl),
                    HosButton(
                      label: 'Save Visit',
                      onPressed: _submit,
                      isLoading: _isLoading,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
