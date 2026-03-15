import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import '../providers/upload_provider.dart';
import '../widgets/upload_dropzone.dart';

class ReportUploadScreen extends ConsumerStatefulWidget {
  const ReportUploadScreen({super.key});

  @override
  ConsumerState<ReportUploadScreen> createState() =>
      _ReportUploadScreenState();
}

class _ReportUploadScreenState extends ConsumerState<ReportUploadScreen> {
  final _healthIdController = TextEditingController();
  String? _selectedReportType;
  String? _selectedFileName;
  PlatformFile? _selectedFile;

  static const _reportTypes = [
    'Complete Blood Count (CBC)',
    'Lipid Panel',
    'Liver Function Test (LFT)',
    'Kidney Function Test (KFT)',
    'Thyroid Panel',
    'HbA1c',
    'Urine Analysis',
    'Blood Glucose (Fasting)',
    'Vitamin D',
    'Iron Studies',
    'Other',
  ];

  @override
  void dispose() {
    _healthIdController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _selectedFile = result.files.first;
        _selectedFileName = result.files.first.name;
      });
    }
  }

  Future<void> _upload() async {
    final healthId = _healthIdController.text.trim();
    if (healthId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a patient Health ID')),
      );
      return;
    }
    if (_selectedReportType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a report type')),
      );
      return;
    }
    if (_selectedFile == null || _selectedFile!.bytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a file to upload')),
      );
      return;
    }

    await ref.read(uploadProvider.notifier).uploadReport(
          patientId: healthId,
          fileName: _selectedFile!.name,
          fileBytes: _selectedFile!.bytes!,
          reportType: _selectedReportType!,
          mimeType: _selectedFile!.extension == 'pdf'
              ? 'application/pdf'
              : 'image/${_selectedFile!.extension}',
        );

    final uploadState = ref.read(uploadProvider);
    if (uploadState.errorMessage != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${uploadState.errorMessage}')),
      );
    } else if (uploadState.reportId != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Report uploaded and OCR processing started!'),
          backgroundColor: Colors.green,
        ),
      );
      // Navigate to the review screen
      context.go('/reports/${uploadState.reportId}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final uploadState = ref.watch(uploadProvider);
    final isUploading = uploadState.isUploading || uploadState.isProcessing;

    return Scaffold(
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.lg),
            Text('Upload Report', style: AppTypography.h1),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Upload a lab report for a patient. The system will automatically extract biomarkers using OCR.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left column: Upload area
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Report File', style: AppTypography.h3),
                      const SizedBox(height: AppSpacing.md),
                      SizedBox(
                        height: 240,
                        child: UploadDropzone(
                          onTap: _pickFile,
                          isUploading: isUploading,
                          fileName: _selectedFileName,
                        ),
                      ),
                      if (uploadState.isProcessing) ...[
                        const SizedBox(height: AppSpacing.md),
                        HosCard(
                          child: Padding(
                            padding:
                                const EdgeInsets.all(AppSpacing.md),
                            child: Row(
                              children: [
                                const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Text(
                                  'Processing OCR... Extracting biomarkers from report.',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.xl),
                // Right column: Patient and report info
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Patient Information',
                          style: AppTypography.h3),
                      const SizedBox(height: AppSpacing.md),
                      HosTextField(
                        controller: _healthIdController,
                        label: 'Patient Health ID',
                        hint: 'HID-20260101-001',
                        prefixIcon: Icons.badge_outlined,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text('Report Type', style: AppTypography.h3),
                      const SizedBox(height: AppSpacing.md),
                      DropdownButtonFormField<String>(
                        value: _selectedReportType,
                        decoration: InputDecoration(
                          labelText: 'Select report type',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                        ),
                        items: _reportTypes
                            .map((type) => DropdownMenuItem(
                                  value: type,
                                  child: Text(type),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(
                              () => _selectedReportType = value);
                        },
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      SizedBox(
                        width: double.infinity,
                        child: HosButton(
                          label: isUploading
                              ? 'Processing...'
                              : 'Upload & Process',
                          onPressed: isUploading ? null : _upload,
                          isLoading: isUploading,
                          icon: Icons.cloud_upload_outlined,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
