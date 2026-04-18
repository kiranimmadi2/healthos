import 'package:freezed_annotation/freezed_annotation.dart';

part 'medication_log.freezed.dart';
part 'medication_log.g.dart';

@freezed
class MedicationLog with _$MedicationLog {
  const factory MedicationLog({
    required String id,
    @JsonKey(name: 'schedule_id') required String scheduleId,
    @JsonKey(name: 'patient_id') required String patientId,
    @JsonKey(name: 'scheduled_at') required DateTime scheduledAt,
    @JsonKey(name: 'taken_at') DateTime? takenAt,
    @Default('pending') String status,
    String? note,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _MedicationLog;

  factory MedicationLog.fromJson(Map<String, dynamic> json) =>
      _$MedicationLogFromJson(json);
}
