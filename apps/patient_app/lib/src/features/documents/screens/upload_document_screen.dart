import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../../providers/patient_provider.dart';
import '../providers/documents_provider.dart';

class UploadDocumentScreen extends ConsumerStatefulWidget {
  const UploadDocumentScreen({super.key});

  @override
  ConsumerState<UploadDocumentScreen> createState() =>
      _UploadDocumentScreenState();
}

class _UploadDocumentScreenState extends ConsumerState<UploadDocumentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  String _kind = 'report';
  PlatformFile? _file;
  bool _uploading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'webp'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    setState(() {
      _file = result.files.first;
      if (_titleController.text.isEmpty) {
        _titleController.text = _file!.name
            .replaceAll('.pdf', '')
            .replaceAll('.jpg', '')
            .replaceAll('.jpeg', '')
            .replaceAll('.png', '')
            .replaceAll('.webp', '');
      }
    });
  }

  Future<void> _upload() async {
    if (_file == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pick a file first.')),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    setState(() => _uploading = true);
    try {
      final patient = ref.read(currentPatientProvider).valueOrNull;
      if (patient == null) throw Exception('No patient profile.');
      final repo = ref.read(patientDocumentRepoProvider);
      await repo.uploadAndCreate(
        patientId: patient.id,
        title: _titleController.text.trim(),
        kind: _kind,
        fileName: _file!.name,
        bytes: _file!.bytes!,
        mimeType: _mimeOf(_file!.name),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );
      ref.invalidate(patientDocumentsProvider);
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  String _mimeOf(String name) {
    final ext = name.split('.').last.toLowerCase();
    return switch (ext) {
      'pdf' => 'application/pdf',
      'jpg' || 'jpeg' => 'image/jpeg',
      'png' => 'image/png',
      'webp' => 'image/webp',
      _ => 'application/octet-stream',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: HosIconButton(
          icon: HosIcons.back,
          onPressed: () => context.pop(),
        ),
        title: const Text('Upload document'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: AppSpacing.screenPadding,
          children: [
            _DropZone(file: _file, onTap: _pickFile),
            const SizedBox(height: AppSpacing.lg),
            HosTextField(
              label: 'Title',
              hint: 'e.g. Apollo Hospital — Bloodwork Jan 2026',
              controller: _titleController,
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: AppSpacing.md),
            HosDropdownField<String>(
              label: 'Type',
              value: _kind,
              items: const [
                HosDropdownItem(
                  label: 'Report / lab result',
                  value: 'report',
                  icon: HosIcons.labReport,
                ),
                HosDropdownItem(
                  label: 'Prescription',
                  value: 'prescription',
                  icon: HosIcons.prescription,
                ),
                HosDropdownItem(
                  label: 'Insurance card / policy',
                  value: 'insurance',
                  icon: HosIcons.verified,
                ),
                HosDropdownItem(
                  label: 'Vaccine certificate',
                  value: 'vaccine_cert',
                  icon: HosIcons.injection,
                ),
                HosDropdownItem(
                  label: 'Other',
                  value: 'other',
                  icon: HosIcons.reports,
                ),
              ],
              onChanged: (v) => setState(() => _kind = v ?? 'report'),
            ),
            const SizedBox(height: AppSpacing.md),
            HosTextField(
              label: 'Notes (optional)',
              controller: _notesController,
              maxLines: 3,
            ),
            const SizedBox(height: AppSpacing.xl),
            HosButton.primary(
              label: 'Upload',
              icon: HosIcons.upload,
              onPressed: _upload,
              isLoading: _uploading,
              expand: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _DropZone extends StatelessWidget {
  const _DropZone({required this.file, required this.onTap});

  final PlatformFile? file;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.4),
            width: 1.5,
            style: BorderStyle.solid,
          ),
        ),
        alignment: Alignment.center,
        child: file == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(HosIcons.upload,
                      size: 36, color: theme.colorScheme.primary),
                  const SizedBox(height: AppSpacing.sm),
                  Text('Tap to pick a file',
                      style: AppTypography.label.copyWith(
                        color: theme.colorScheme.primary,
                      )),
                  const SizedBox(height: 2),
                  Text('PDF, JPG, PNG or WebP',
                      style: AppTypography.caption),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(HosIcons.success,
                      size: 32, color: AppColors.success),
                  const SizedBox(height: AppSpacing.sm),
                  Text(file!.name,
                      style: AppTypography.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(
                    '${(file!.size / 1024).toStringAsFixed(0)} KB · tap to change',
                    style: AppTypography.caption,
                  ),
                ],
              ),
      ),
    );
  }
}