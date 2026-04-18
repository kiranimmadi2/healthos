import 'package:freezed_annotation/freezed_annotation.dart';

part 'medication_schedule.freezed.dart';
part 'medication_schedule.g.dart';

@freezed
class MedicationSchedule with _$MedicationSchedule {
  const factory MedicationSchedule({
    required String id,
    @JsonKey(name: 'patient_id') required String patientId,
    @JsonKey(name: 'prescription_id') String? prescriptionId,
    @JsonKey(name: 'drug_name') required String drugName,
    required String dosage,
    String? instructions,
    @Default([]) @JsonKey(name: 'dose_times') List<String> doseTimes,
    @Default([]) List<int> weekdays,
    @JsonKey(name: 'started_on') required DateTime startedOn,
    @JsonKey(name: 'ended_on') DateTime? endedOn,
    @Default(true) @JsonKey(name: 'is_active') bool isActive,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _MedicationSchedule;

  factory MedicationSchedule.fromJson(Map<String, dynamic> json) =>
      _$MedicationScheduleFromJson(json);
}
