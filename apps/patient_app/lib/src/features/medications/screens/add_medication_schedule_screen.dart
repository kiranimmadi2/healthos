import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../../providers/patient_provider.dart';
import '../providers/medications_provider.dart';

class AddMedicationScheduleScreen extends ConsumerStatefulWidget {
  const AddMedicationScheduleScreen({super.key});

  @override
  ConsumerState<AddMedicationScheduleScreen> createState() =>
      _AddMedicationScheduleScreenState();
}

class _AddMedicationScheduleScreenState
    extends ConsumerState<AddMedicationScheduleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _drugController = TextEditingController();
  final _dosageController = TextEditingController();
  final _instructionsController = TextEditingController();

  final List<TimeOfDay> _doseTimes = [
    const TimeOfDay(hour: 8, minute: 0),
  ];
  final Set<int> _weekdays = {1, 2, 3, 4, 5, 6, 7};
  DateTime _startedOn = DateTime.now();
  DateTime? _endedOn;
  bool _saving = false;

  @override
  void dispose() {
    _drugController.dispose();
    _dosageController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  Future<void> _addDoseTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 14, minute: 0),
    );
    if (picked != null) setState(() => _doseTimes.add(picked));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_doseTimes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one dose time.')),
      );
      return;
    }
    if (_weekdays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pick at least one day.')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final patient = ref.read(currentPatientProvider).valueOrNull;
      if (patient == null) throw Exception('No active patient profile.');

      final repo = ref.read(medicationRepoProvider);
      await repo.createSchedule({
        'patient_id': patient.id,
        'drug_name': _drugController.text.trim(),
        'dosage': _dosageController.text.trim(),
        'instructions': _instructionsController.text.trim().isEmpty
            ? null
            : _instructionsController.text.trim(),
        'dose_times': _doseTimes
            .map((t) =>
                '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}')
            .toList(),
        'weekdays': _weekdays.length == 7 ? [] : _weekdays.toList()..sort(),
        'started_on': _fmtDate(_startedOn),
        'ended_on': _endedOn == null ? null : _fmtDate(_endedOn!),
        'is_active': true,
      });

      ref.invalidate(activeSchedulesProvider);
      ref.invalidate(todayDosesProvider);
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _fmtDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: HosIconButton(
          icon: HosIcons.back,
          onPressed: () => context.pop(),
        ),
        title: const Text('Add medication'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: AppSpacing.screenPadding,
          children: [
            HosTextField(
              label: 'Medication name',
              hint: 'e.g. Metformin',
              controller: _drugController,
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: AppSpacing.md),
            HosTextField(
              label: 'Dosage',
              hint: 'e.g. 500 mg',
              controller: _dosageController,
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: AppSpacing.md),
            HosTextField(
              label: 'Instructions (optional)',
              hint: 'Take with food',
              controller: _instructionsController,
              maxLines: 2,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Dose times', style: AppTypography.label),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (var i = 0; i < _doseTimes.length; i++)
                  InputChip(
                    avatar: const Icon(HosIcons.pending, size: 16),
                    label: Text(_formatTime(_doseTimes[i])),
                    onDeleted: () => setState(() => _doseTimes.removeAt(i)),
                  ),
                ActionChip(
                  avatar: const Icon(HosIcons.add, size: 16),
                  label: const Text('Add time'),
                  onPressed: _addDoseTime,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Days of the week', style: AppTypography.label),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: AppSpacing.sm,
              children: [
                for (var wd = 1; wd <= 7; wd++)
                  FilterChip(
                    label: Text(_weekdayLabel(wd)),
                    selected: _weekdays.contains(wd),
                    onSelected: (s) {
                      setState(() {
                        if (s) {
                          _weekdays.add(wd);
                        } else {
                          _weekdays.remove(wd);
                        }
                      });
                    },
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            HosDateField(
              label: 'Start date',
              value: _startedOn,
              onChanged: (d) => setState(() => _startedOn = d ?? _startedOn),
            ),
            const SizedBox(height: AppSpacing.md),
            HosDateField(
              label: 'End date (optional)',
              value: _endedOn,
              onChanged: (d) => setState(() => _endedOn = d),
            ),
            const SizedBox(height: AppSpacing.xl),
            HosButton.primary(
              label: 'Save medication',
              icon: HosIcons.success,
              onPressed: _save,
              isLoading: _saving,
              expand: true,
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }

  String _formatTime(TimeOfDay t) {
    final h = t.hour == 0
        ? 12
        : t.hour > 12
            ? t.hour - 12
            : t.hour;
    final m = t.minute.toString().padLeft(2, '0');
    final ampm = t.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $ampm';
  }

  String _weekdayLabel(int wd) {
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return labels[wd - 1];
  }
}
