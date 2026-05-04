import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_client/supabase_client.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../../providers/doctor_provider.dart';

class CreatePrescriptionScreen extends ConsumerStatefulWidget {
  const CreatePrescriptionScreen({super.key, required this.patientId});

  final String patientId;

  @override
  ConsumerState<CreatePrescriptionScreen> createState() =>
      _CreatePrescriptionScreenState();
}

class _CreatePrescriptionScreenState
    extends ConsumerState<CreatePrescriptionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  final List<_MedicationEntry> _medications = [_MedicationEntry()];
  bool _isLoading = false;

  @override
  void dispose() {
    _notesController.dispose();
    for (final med in _medications) {
      med.dispose();
    }
    super.dispose();
  }

  void _addMedication() {
    setState(() {
      _medications.add(_MedicationEntry());
    });
  }

  void _removeMedication(int index) {
    if (_medications.length <= 1) return;
    setState(() {
      _medications[index].dispose();
      _medications.removeAt(index);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final doctorId = ref.read(currentDoctorIdProvider);
      final repo = PrescriptionRepository();

      final medications = _medications
          .map((m) => {
                'name': m.nameController.text.trim(),
                'dose': m.doseController.text.trim(),
                'frequency': m.frequencyController.text.trim(),
                'duration': m.durationController.text.trim().isEmpty
                    ? null
                    : m.durationController.text.trim(),
              })
          .toList();

      await repo.create({
        'patient_id': widget.patientId,
        'doctor_id': doctorId,
        'medications': medications,
        'issued_at': DateTime.now().toIso8601String(),
        'notes': _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Prescription created successfully')),
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
      appBar: AppBar(
        title: const Text('Create Prescription'),
      ),
      body: SingleChildScrollView(
        child: HosPageContainer(
          maxWidth: 960,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                    Text('New Prescription', style: AppTypography.h2),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Add medications for this patient.',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Medication entries
                    ...List.generate(_medications.length, (index) {
                      return _MedicationFormCard(
                        key: ValueKey(_medications[index]),
                        entry: _medications[index],
                        index: index,
                        canRemove: _medications.length > 1,
                        onRemove: () => _removeMedication(index),
                      );
                    }),

                    // Add medication button
                    TextButton.icon(
                      onPressed: _addMedication,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Medication'),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Notes
                    HosTextField(
                      controller: _notesController,
                      label: 'Notes (optional)',
                      hint: 'Additional instructions or notes...',
                      prefixIcon: Icons.notes_outlined,
                      maxLines: 3,
                    ),
                    const SizedBox(height: AppSpacing.xl),

                HosButton(
                  label: 'Save Prescription',
                  onPressed: _submit,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Medication Entry Helper ─────────────────────────────────────────────────

class _MedicationEntry {
  final nameController = TextEditingController();
  final doseController = TextEditingController();
  final frequencyController = TextEditingController();
  final durationController = TextEditingController();

  void dispose() {
    nameController.dispose();
    doseController.dispose();
    frequencyController.dispose();
    durationController.dispose();
  }
}

class _MedicationFormCard extends StatelessWidget {
  const _MedicationFormCard({
    super.key,
    required this.entry,
    required this.index,
    required this.canRemove,
    required this.onRemove,
  });

  final _MedicationEntry entry;
  final int index;
  final bool canRemove;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return HosCard(
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Medication ${index + 1}',
                  style: AppTypography.label,
                ),
                const Spacer(),
                if (canRemove)
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: onRemove,
                    color: AppColors.error,
                    tooltip: 'Remove',
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            HosTextField(
              controller: entry.nameController,
              label: 'Medication Name',
              hint: 'e.g. Paracetamol',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: HosTextField(
                    controller: entry.doseController,
                    label: 'Dose',
                    hint: 'e.g. 500mg',
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Required';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: HosTextField(
                    controller: entry.frequencyController,
                    label: 'Frequency',
                    hint: 'e.g. Twice daily',
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Required';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            HosTextField(
              controller: entry.durationController,
              label: 'Duration (optional)',
              hint: 'e.g. 5 days',
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }
}
