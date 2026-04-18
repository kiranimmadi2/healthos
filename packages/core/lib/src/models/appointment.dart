import 'package:freezed_annotation/freezed_annotation.dart';

part 'appointment.freezed.dart';
part 'appointment.g.dart';

@freezed
class Appointment with _$Appointment {
  const factory Appointment({
    required String id,
    @JsonKey(name: 'patient_id') required String patientId,
    @JsonKey(name: 'doctor_id') required String doctorId,
    @JsonKey(name: 'hospital_id') String? hospitalId,
    @JsonKey(name: 'scheduled_at') required DateTime scheduledAt,
    @Default(30) @JsonKey(name: 'duration_minutes') int durationMinutes,
    @Default('scheduled') String status,
    String? reason,
    String? notes,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _Appointment;

  factory Appointment.fromJson(Map<String, dynamic> json) =>
      _$AppointmentFromJson(json);
}
