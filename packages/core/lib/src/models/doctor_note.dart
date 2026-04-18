import 'package:freezed_annotation/freezed_annotation.dart';

part 'doctor_note.freezed.dart';
part 'doctor_note.g.dart';

@freezed
class DoctorNote with _$DoctorNote {
  const factory DoctorNote({
    required String id,
    @JsonKey(name: 'patient_id') required String patientId,
    @JsonKey(name: 'doctor_id') required String doctorId,
    required String content,
    @Default(true) @JsonKey(name: 'is_private') bool isPrivate,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _DoctorNote;

  factory DoctorNote.fromJson(Map<String, dynamic> json) =>
      _$DoctorNoteFromJson(json);
}
