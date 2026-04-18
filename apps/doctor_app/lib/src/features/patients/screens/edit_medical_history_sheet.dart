import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_client/supabase_client.dart';
import 'package:ui_kit/ui_kit.dart';

/// Shows as a bottom sheet: EditMedicalHistorySheet.show(context, patient).
class EditMedicalHistorySheet extends ConsumerStatefulWidget {
  const EditMedicalHistorySheet({super.key, required this.patient});
  final Patient patient;

  static Future<void> show(BuildContext context, Patient patient) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EditMedicalHistorySheet(patient: patient),
    );
  }

  @override
  ConsumerState<EditMedicalHistorySheet> createState() =>
      _EditMedicalHistorySheetState();
}

class _EditMedicalHistorySheetState extends ConsumerState<EditMedicalHistorySheet> {
  late List<String> _allergies;
  late List<String> _conditions;
  final _allergyController = TextEditingController();
  final _conditionController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _allergies = List<String>.from(widget.patient.allergies);
    _conditions = List<String>.from(widget.patient.chronicConditions);
  }

  @override
  void dispose() {
    _allergyController.dispose();
    _conditionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _isLoading = true);
    try {
      final repo = PatientRepository();
      await repo.update(widget.patient.id, {
        'allergies': _allergies,
        'chronic_conditions': _conditions,
      });
      if (mounted) Navigator.pop(context, true);
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

  void _addAllergy() {
    final val = _allergyController.text.trim();
    if (val.isNotEmpty && !_allergies.contains(val)) {
      setState(() {
        _allergies.add(val);
        _allergyController.clear();
      });
    }
  }

  void _addCondition() {
    final val = _conditionController.text.trim();
    if (val.isNotEmpty && !_conditions.contains(val)) {
      setState(() {
        _conditions.add(val);
        _conditionController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.lg + bottom,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Medical History', style: AppTypography.h4),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // Allergies
            Text('Allergies', style: AppTypography.label),
            const SizedBox(height: AppSpacing.sm),
            if (_allergies.isNotEmpty)
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: _allergies.map((a) => Chip(
                  label: Text(a, style: AppTypography.caption),
                  backgroundColor: AppColors.error.withValues(alpha: 0.1),
                  side: BorderSide.none,
                  deleteIcon: const Icon(Icons.close, size: 14),
                  onDeleted: () => setState(() => _allergies.remove(a)),
                )).toList(),
              ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _allergyController,
                    decoration: const InputDecoration(
                      hintText: 'Add allergy',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _addAllergy(),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: AppColors.primary),
                  onPressed: _addAllergy,
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.lg),

            // Chronic Conditions
            Text('Chronic Conditions', style: AppTypography.label),
            const SizedBox(height: AppSpacing.sm),
            if (_conditions.isNotEmpty)
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: _conditions.map((c) => Chip(
                  label: Text(c, style: AppTypography.caption),
                  backgroundColor: AppColors.warning.withValues(alpha: 0.1),
                  side: BorderSide.none,
                  deleteIcon: const Icon(Icons.close, size: 14),
                  onDeleted: () => setState(() => _conditions.remove(c)),
                )).toList(),
              ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _conditionController,
                    decoration: const InputDecoration(
                      hintText: 'Add condition',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _addCondition(),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: AppColors.primary),
                  onPressed: _addCondition,
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.xl),
            HosButton(
              label: 'Save Changes',
              onPressed: _save,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
