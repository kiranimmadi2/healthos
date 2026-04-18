import 'package:freezed_annotation/freezed_annotation.dart';

part 'patient_document.freezed.dart';
part 'patient_document.g.dart';

@freezed
class PatientDocument with _$PatientDocument {
  const factory PatientDocument({
    required String id,
    @JsonKey(name: 'patient_id') required String patientId,
    required String title,
    required String kind,
    String? notes,
    @JsonKey(name: 'storage_path') required String storagePath,
    @JsonKey(name: 'file_url') String? fileUrl,
    @JsonKey(name: 'mime_type') String? mimeType,
    @JsonKey(name: 'size_bytes') int? sizeBytes,
    @JsonKey(name: 'uploaded_at') DateTime? uploadedAt,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _PatientDocument;

  factory PatientDocument.fromJson(Map<String, dynamic> json) =>
      _$PatientDocumentFromJson(json);
}
