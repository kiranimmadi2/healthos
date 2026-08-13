import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/theme.dart';
import '../../../shared/domain/app_failure.dart';
import '../../../shared/presentation/widgets/glass_container.dart';
import '../../../shared/presentation/widgets/hos_states.dart';
import '../../auth/application/auth_providers.dart';
import '../application/record_providers.dart';
import '../domain/medical_record.dart';
import 'add_record_form.dart';

class RecordsScreen extends ConsumerWidget {
  const RecordsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordsAsync = ref.watch(medicalRecordsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 90),
        child: FloatingActionButton.extended(
          onPressed: () => _showAddRecordSheet(context, ref),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 4,
          icon: const Icon(Icons.add_rounded),
          label: const Text(
            'Add Record',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: recordsAsync.hosWhen(
            onRetry: () => ref.invalidate(medicalRecordsProvider),
            errorTitle: 'Could not load your records',
            data: (records) {
              if (records.isEmpty) return _buildEmptyState(context, ref);
              return ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 24,
                ),
                itemCount: records.length + 1,
                itemBuilder: (context, index) {
                  if (index == records.length) return const SizedBox(height: 160);
                  return _buildRecordCard(context, ref, records[index]);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return HosEmptyState(
      icon: Icons.folder_shared_rounded,
      title: 'Your Medical Vault is Empty',
      message:
          'Add lab reports, prescriptions, imaging scans, and immunization '
          'records to keep your complete health history in one secure location.',
      action: ElevatedButton.icon(
        onPressed: () => _showAddRecordSheet(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Upload Your First Record'),
      ),
    );
  }

  static (IconData, Color) _categoryStyle(BuildContext context, String category) {
    final hos = context.hos;
    return switch (category) {
      RecordCategory.labReport => (Icons.bloodtype_rounded, hos.categoryLab),
      RecordCategory.prescription => (
        Icons.medication_rounded,
        hos.categoryPrescription,
      ),
      RecordCategory.imaging => (
        Icons.document_scanner_rounded,
        hos.categoryImaging,
      ),
      RecordCategory.immunization => (
        Icons.shield_rounded,
        hos.categoryImmunization,
      ),
      _ => (Icons.description_rounded, hos.categoryOther),
    };
  }

  Widget _buildRecordCard(
    BuildContext context,
    WidgetRef ref,
    MedicalRecord record,
  ) {
    final hos = context.hos;
    final theme = Theme.of(context);
    final (icon, color) = _categoryStyle(context, record.category);

    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.title.toUpperCase(),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                    color: hos.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  record.notes.isEmpty ? record.category : record.notes,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: hos.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.calendar_today_rounded, size: 12, color: color),
                    const SizedBox(width: 6),
                    Text(
                      DateFormat('MMM dd, yyyy')
                          .format(record.date)
                          .toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Delete record',
            onPressed: () => _confirmDelete(context, ref, record),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: hos.surfaceMuted,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.delete_outline_rounded,
                color: hos.textSecondary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    MedicalRecord record,
  ) async {
    final hos = context.hos;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Delete record?'),
        content: Text('"${record.title}" will be permanently removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Delete', style: TextStyle(color: hos.dangerFg)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    final messenger = ScaffoldMessenger.maybeOf(context);
    try {
      await ref.read(recordRepositoryProvider).deleteRecord(user.uid, record.id);
    } catch (error) {
      messenger?.showSnackBar(
        SnackBar(content: Text(describeFailure(error))),
      );
    }
  }

  void _showAddRecordSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.hos.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: AddRecordForm(
          onSave: (record) async {
            final user = ref.read(authStateProvider).value;
            if (user == null) return;
            await ref
                .read(recordRepositoryProvider)
                .addRecord(user.uid, record);
          },
        ),
      ),
    );
  }
}
