import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_client/supabase_client.dart';

final storageServiceProvider =
    Provider<StorageService>((ref) => StorageService());

/// State for the upload process
class UploadState {
  final bool isUploading;
  final bool isProcessing;
  final String? uploadedUrl;
  final String? errorMessage;
  final String? reportId;

  const UploadState({
    this.isUploading = false,
    this.isProcessing = false,
    this.uploadedUrl,
    this.errorMessage,
    this.reportId,
  });

  UploadState copyWith({
    bool? isUploading,
    bool? isProcessing,
    String? uploadedUrl,
    String? errorMessage,
    String? reportId,
  }) {
    return UploadState(
      isUploading: isUploading ?? this.isUploading,
      isProcessing: isProcessing ?? this.isProcessing,
      uploadedUrl: uploadedUrl ?? this.uploadedUrl,
      errorMessage: errorMessage ?? this.errorMessage,
      reportId: reportId ?? this.reportId,
    );
  }
}

/// Handles file upload to Supabase Storage and triggers OCR via Edge Function
class UploadNotifier extends StateNotifier<UploadState> {
  UploadNotifier(this._storageService) : super(const UploadState());

  final StorageService _storageService;

  Future<void> uploadReport({
    required String patientId,
    required String fileName,
    required Uint8List fileBytes,
    required String reportType,
    String? mimeType,
  }) async {
    state = const UploadState(isUploading: true);

    try {
      // Upload the file to Supabase Storage
      final url = await _storageService.uploadLabReport(
        patientId: patientId,
        fileName: fileName,
        fileBytes: fileBytes,
        mimeType: mimeType,
      );

      state = state.copyWith(
        isUploading: false,
        isProcessing: true,
        uploadedUrl: url,
      );

      // Trigger OCR processing via Supabase Edge Function
      final client = SupabaseClientInitializer.client;
      final response = await client.functions.invoke(
        'process-lab-report',
        body: {
          'patient_id': patientId,
          'file_url': url,
          'report_type': reportType,
          'file_name': fileName,
        },
      );

      final reportId = response.data?['report_id'] as String?;

      state = UploadState(
        isUploading: false,
        isProcessing: false,
        uploadedUrl: url,
        reportId: reportId,
      );
    } catch (e) {
      state = UploadState(
        isUploading: false,
        isProcessing: false,
        errorMessage: e.toString(),
      );
    }
  }

  void reset() {
    state = const UploadState();
  }
}

final uploadProvider =
    StateNotifierProvider<UploadNotifier, UploadState>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  return UploadNotifier(storageService);
});
