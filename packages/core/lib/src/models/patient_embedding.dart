import 'package:freezed_annotation/freezed_annotation.dart';

part 'patient_embedding.freezed.dart';
part 'patient_embedding.g.dart';

@freezed
class PatientEmbedding with _$PatientEmbedding {
  const factory PatientEmbedding({
    required String id,
    @JsonKey(name: 'patient_id') required String patientId,
    required String content,
    required List<double> embedding,
    @JsonKey(name: 'source_type') String? sourceType,
    @JsonKey(name: 'source_id') String? sourceId,
    @Default({}) Map<String, dynamic> metadata,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _PatientEmbedding;

  factory PatientEmbedding.fromJson(Map<String, dynamic> json) =>
      _$PatientEmbeddingFromJson(json);
}
