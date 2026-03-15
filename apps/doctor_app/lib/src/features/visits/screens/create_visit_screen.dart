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
  final _notesController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _chiefComplaintController.dispose();
    _diagnosisController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final doctorId = ref.read(currentDoctorIdProvider);
      final repo = VisitRepository();

      await repo.create({
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
      });

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
      appBar: AppBar(
        title: const Text('Create Visit'),
      ),
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
                    Text(
                      'New Visit Record',
                      style: AppTypography.h2,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Record the details of this patient visit.',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    HosTextField(
                      controller: _chiefComplaintController,
                      label: 'Chief Complaint',
                      hint: 'e.g. Persistent headache for 3 days',
                      prefixIcon: Icons.report_problem_outlined,
                      maxLines: 2,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Chief complaint is required';
                        }
                        return null;
                      },
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
                      controller: _notesController,
                      label: 'Notes',
                      hint: 'Additional clinical notes...',
                      prefixIcon: Icons.notes_outlined,
                      maxLines: 5,
                    ),
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
