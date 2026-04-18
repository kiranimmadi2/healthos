import 'package:freezed_annotation/freezed_annotation.dart';

part 'visit_vitals.freezed.dart';
part 'visit_vitals.g.dart';

@freezed
class VisitVitals with _$VisitVitals {
  const factory VisitVitals({
    required String id,
    @JsonKey(name: 'visit_id') required String visitId,
    @JsonKey(name: 'patient_id') required String patientId,
    @JsonKey(name: 'bp_systolic') int? bpSystolic,
    @JsonKey(name: 'bp_diastolic') int? bpDiastolic,
    @JsonKey(name: 'heart_rate') int? heartRate,
    @JsonKey(name: 'temperature_c') double? temperatureC,
    @JsonKey(name: 'weight_kg') double? weightKg,
    @JsonKey(name: 'height_cm') double? heightCm,
    @JsonKey(name: 'spo2_percent') double? spo2Percent,
    @JsonKey(name: 'recorded_at') DateTime? recordedAt,
    @JsonKey(name: 'recorded_by') String? recordedBy,
  }) = _VisitVitals;

  factory VisitVitals.fromJson(Map<String, dynamic> json) =>
      _$VisitVitalsFromJson(json);
}
