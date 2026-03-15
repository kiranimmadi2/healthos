import 'package:freezed_annotation/freezed_annotation.dart';

part 'access_grant.freezed.dart';
part 'access_grant.g.dart';

@freezed
class AccessGrant with _$AccessGrant {
  const factory AccessGrant({
    required String id,
    @JsonKey(name: 'patient_id') required String patientId,
    @JsonKey(name: 'doctor_id') required String doctorId,
    @JsonKey(name: 'hospital_id') String? hospitalId,
    @Default('active') String status,
    @JsonKey(name: 'access_level') @Default('read') String accessLevel,
    @JsonKey(name: 'granted_at') DateTime? grantedAt,
    @JsonKey(name: 'revoked_at') DateTime? revokedAt,
    @JsonKey(name: 'expires_at') DateTime? expiresAt,
  }) = _AccessGrant;

  factory AccessGrant.fromJson(Map<String, dynamic> json) =>
      _$AccessGrantFromJson(json);
}
