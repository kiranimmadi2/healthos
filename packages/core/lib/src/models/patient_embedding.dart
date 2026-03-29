import 'package:freezed_annotation/freezed_annotation.dart';

part 'patient_embedding.freezed.dart';
part 'patient_embedding.g.dart';

/// Converts pgvector's string representation (e.g. "[0.1,0.2,0.3]") to List<double>.
class VectorConverter implements JsonConverter<List<double>?, dynamic> {
  const VectorConverter();

  @override
  List<double>? fromJson(dynamic json) {
    if (json == null) return null;
    if (json is List) return json.cast<num>().map((e) => e.toDouble()).toList();
    if (json is String) {
      final trimmed = json.replaceAll(RegExp(r'[\[\]]'), '').trim();
      if (trimmed.isEmpty) return null;
      return trimmed.split(',').map((e) => double.parse(e.trim())).toList();
    }
    return null;
  }

  @override
  dynamic toJson(List<double>? object) => object;
}

@freezed
class PatientEmbedding with _$PatientEmbedding {
  const factory PatientEmbedding({
    required String id,
    @JsonKey(name: 'patient_id') required String patientId,
    required String content,
    @VectorConverter() List<double>? embedding,
    @JsonKey(name: 'source_type') required String sourceType,
    @JsonKey(name: 'source_id') required String sourceId,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    Map<String, dynamic>? metadata,
  }) = _PatientEmbedding;

  factory PatientEmbedding.fromJson(Map<String, dynamic> json) =>
      _$PatientEmbeddingFromJson(json);
}
