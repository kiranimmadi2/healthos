import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../../providers/patient_provider.dart';
import '../providers/vaccinations_provider.dart';

class AddVaccinationScreen extends ConsumerStatefulWidget {
  const AddVaccinationScreen({super.key});

  @override
  ConsumerState<AddVaccinationScreen> createState() =>
      _AddVaccinationScreenState();
}

class _AddVaccinationScreenState extends ConsumerState<AddVaccinationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _manufacturer = TextEditingController();
  final _lot = TextEditingController();
  final _administered = TextEditingController();
  final _notes = TextEditingController();
  int? _doseNumber;
  int? _totalDoses;
  DateTime _dateGiven = DateTime.now();
  DateTime? _nextDue;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _manufacturer.dispose();
    _lot.dispose();
    _administered.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final patient = ref.read(currentPatientProvider).valueOrNull;
      if (patient == null) throw Exception('No patient profile.');
      final repo = ref.read(vaccinationRepoProvider);
      await repo.create({
        'patient_id': patient.id,
        'vaccine_name': _name.text.trim(),
        'manufacturer':
            _manufacturer.text.trim().isEmpty ? null : _manufacturer.text.trim(),
        'dose_number': _doseNumber,
        'total_doses': _totalDoses,
        'date_given': _fmt(_dateGiven),
        'next_due': _nextDue == null ? null : _fmt(_nextDue!),
        'lot_number': _lot.text.trim().isEmpty ? null : _lot.text.trim(),
        'administered_at':
            _administered.text.trim().isEmpty ? null : _administered.text.trim(),
        'notes': _notes.text.trim().isEmpty ? null : _notes.text.trim(),
      });
      ref.invalidate(vaccinationsProvider);
      ref.invalidate(upcomingVaccinationsProvider);
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

  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: HosIconButton(
          icon: HosIcons.back,
          onPressed: () => context.pop(),
        ),
        title: const Text('Add vaccination'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: AppSpacing.screenPadding,
          children: [
            HosTextField(
              label: 'Vaccine name',
              hint: 'e.g. COVID-19 (Pfizer) or Tetanus',
              controller: _name,
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: AppSpacing.md),
            HosTextField(
              label: 'Manufacturer (optional)',
              controller: _manufacturer,
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: HosTextField(
                    label: 'Dose #',
                    hint: '1',
                    keyboardType: TextInputType.number,
                    onChanged: (v) =>
                        _doseNumber = int.tryParse(v.trim()),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: HosTextField(
                    label: 'Total doses',
                    hint: '2',
                    keyboardType: TextInputType.number,
                    onChanged: (v) =>
                        _totalDoses = int.tryParse(v.trim()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            HosDateField(
              label: 'Date given',
              value: _dateGiven,
              onChanged: (d) => setState(() => _dateGiven = d ?? _dateGiven),
            ),
            const SizedBox(height: AppSpacing.md),
            HosDateField(
              label: 'Next dose due (optional)',
              value: _nextDue,
              onChanged: (d) => setState(() => _nextDue = d),
            ),
            const SizedBox(height: AppSpacing.md),
            HosTextField(
              label: 'Clinic / place (optional)',
              controller: _administered,
            ),
            const SizedBox(height: AppSpacing.md),
            HosTextField(
              label: 'Lot number (optional)',
              controller: _lot,
            ),
            const SizedBox(height: AppSpacing.md),
            HosTextField(
              label: 'Notes (optional)',
              controller: _notes,
              maxLines: 3,
            ),
            const SizedBox(height: AppSpacing.xl),
            HosButton.primary(
              label: 'Save vaccination',
              icon: HosIcons.success,
              onPressed: _save,
              isLoading: _saving,
              expand: true,
            ),
          ],
        ),
      ),
    );
  }
}