import 'package:freezed_annotation/freezed_annotation.dart';

part 'vaccination.freezed.dart';
part 'vaccination.g.dart';

@freezed
class Vaccination with _$Vaccination {
  const factory Vaccination({
    required String id,
    @JsonKey(name: 'patient_id') required String patientId,
    @JsonKey(name: 'vaccine_name') required String vaccineName,
    String? manufacturer,
    @JsonKey(name: 'dose_number') int? doseNumber,
    @JsonKey(name: 'total_doses') int? totalDoses,
    @JsonKey(name: 'date_given') required DateTime dateGiven,
    @JsonKey(name: 'next_due') DateTime? nextDue,
    @JsonKey(name: 'lot_number') String? lotNumber,
    @JsonKey(name: 'administered_at') String? administeredAt,
    @JsonKey(name: 'document_id') String? documentId,
    String? notes,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _Vaccination;

  factory Vaccination.fromJson(Map<String, dynamic> json) =>
      _$VaccinationFromJson(json);
}
