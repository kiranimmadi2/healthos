import 'package:freezed_annotation/freezed_annotation.dart';

part 'family_member.freezed.dart';
part 'family_member.g.dart';

@freezed
class FamilyMember with _$FamilyMember {
  const factory FamilyMember({
    required String id,
    @JsonKey(name: 'primary_patient_id') required String primaryPatientId,
    @JsonKey(name: 'member_patient_id') String? memberPatientId,
    required String relationship,
    @JsonKey(name: 'full_name') required String fullName,
    @JsonKey(name: 'date_of_birth') DateTime? dateOfBirth,
    String? gender,
    String? phone,
    @Default(false) @JsonKey(name: 'is_dependent') bool isDependent,
    @Default(false) @JsonKey(name: 'can_view_records') bool canViewRecords,
    @Default(false) @JsonKey(name: 'can_manage_appointments') bool canManageAppointments,
    @Default('not_invited') @JsonKey(name: 'invite_status') String inviteStatus,
    @JsonKey(name: 'invited_at') DateTime? invitedAt,
    @JsonKey(name: 'linked_at') DateTime? linkedAt,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _FamilyMember;

  factory FamilyMember.fromJson(Map<String, dynamic> json) =>
      _$FamilyMemberFromJson(json);
}
