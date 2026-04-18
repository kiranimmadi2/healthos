import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_client/supabase_client.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../../providers/doctor_provider.dart';

/// Show as a bottom sheet: QuickNoteScreen.show(context, patientId).
class QuickNoteScreen extends ConsumerStatefulWidget {
  const QuickNoteScreen({super.key, required this.patientId});
  final String patientId;

  static Future<void> show(BuildContext context, String patientId) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => QuickNoteScreen(patientId: patientId),
    );
  }

  @override
  ConsumerState<QuickNoteScreen> createState() => _QuickNoteScreenState();
}

class _QuickNoteScreenState extends ConsumerState<QuickNoteScreen> {
  final _controller = TextEditingController();
  bool _isPrivate = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_controller.text.trim().isEmpty) return;
    setState(() => _isLoading = true);
    try {
      final doctorId = ref.read(currentDoctorIdProvider);
      await DoctorNoteRepository().create({
        'patient_id': widget.patientId,
        'doctor_id': doctorId,
        'content': _controller.text.trim(),
        'is_private': _isPrivate,
      });
      if (mounted) Navigator.pop(context);
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Quick Note', style: AppTypography.h4),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _controller,
            maxLines: 5,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Enter clinical note...',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              const Icon(Icons.lock_outline, size: 16, color: AppColors.warning),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Private note', style: AppTypography.bodyMedium),
                    Text(
                      _isPrivate ? 'Visible to doctors only' : 'Patient can also see this',
                      style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Switch(value: _isPrivate, onChanged: (v) => setState(() => _isPrivate = v)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          HosButton(
            label: 'Save Note',
            onPressed: _save,
            isLoading: _isLoading,
          ),
        ],
      ),
    );
  }
}
