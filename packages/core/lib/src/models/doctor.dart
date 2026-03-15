import 'package:freezed_annotation/freezed_annotation.dart';

part 'doctor.freezed.dart';
part 'doctor.g.dart';

@freezed
class Doctor with _$Doctor {
  const factory Doctor({
    required String id,
    @JsonKey(name: 'auth_id') String? authId,
    @JsonKey(name: 'full_name') required String fullName,
    String? specialization,
    @JsonKey(name: 'hospital_id') String? hospitalId,
    @JsonKey(name: 'license_number') required String licenseNumber,
    @Default(false) bool verified,
    String? phone,
    String? email,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _Doctor;

  factory Doctor.fromJson(Map<String, dynamic> json) =>
      _$DoctorFromJson(json);
}
