import 'package:freezed_annotation/freezed_annotation.dart';

part 'visit.freezed.dart';
part 'visit.g.dart';

@freezed
class Visit with _$Visit {
  const factory Visit({
    required String id,
    @JsonKey(name: 'patient_id') required String patientId,
    @JsonKey(name: 'doctor_id') String? doctorId,
    @JsonKey(name: 'hospital_id') String? hospitalId,
    @JsonKey(name: 'visited_at') required DateTime visitedAt,
    @JsonKey(name: 'chief_complaint') String? chiefComplaint,
    String? diagnosis,
    String? notes,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _Visit;

  factory Visit.fromJson(Map<String, dynamic> json) =>
      _$VisitFromJson(json);
}
