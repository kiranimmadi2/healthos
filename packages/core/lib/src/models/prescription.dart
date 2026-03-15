import 'package:freezed_annotation/freezed_annotation.dart';

part 'prescription.freezed.dart';
part 'prescription.g.dart';

@freezed
class Prescription with _$Prescription {
  const factory Prescription({
    required String id,
    @JsonKey(name: 'patient_id') required String patientId,
    @JsonKey(name: 'visit_id') String? visitId,
    @JsonKey(name: 'doctor_id') String? doctorId,
    required List<Medication> medications,
    @JsonKey(name: 'issued_at') required DateTime issuedAt,
    @JsonKey(name: 'valid_until') DateTime? validUntil,
    String? notes,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _Prescription;

  factory Prescription.fromJson(Map<String, dynamic> json) =>
      _$PrescriptionFromJson(json);
}

@freezed
class Medication with _$Medication {
  const factory Medication({
    required String name,
    required String dose,
    required String frequency,
    String? duration,
    String? instructions,
  }) = _Medication;

  factory Medication.fromJson(Map<String, dynamic> json) =>
      _$MedicationFromJson(json);
}
