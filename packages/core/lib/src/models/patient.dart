import 'package:freezed_annotation/freezed_annotation.dart';

part 'patient.freezed.dart';
part 'patient.g.dart';

@freezed
class Patient with _$Patient {
  const factory Patient({
    required String id,
    @JsonKey(name: 'auth_id') String? authId,
    @JsonKey(name: 'health_id') required String healthId,
    required String phone,
    @JsonKey(name: 'full_name') String? fullName,
    @JsonKey(name: 'date_of_birth') DateTime? dateOfBirth,
    String? gender,
    @JsonKey(name: 'blood_group') String? bloodGroup,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    @Default([]) List<String> allergies,
    @JsonKey(name: 'chronic_conditions') @Default([]) List<String> chronicConditions,
    @JsonKey(name: 'emergency_contact') Map<String, dynamic>? emergencyContact,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _Patient;

  factory Patient.fromJson(Map<String, dynamic> json) =>
      _$PatientFromJson(json);
}
