import 'package:freezed_annotation/freezed_annotation.dart';

part 'symptom_session.freezed.dart';
part 'symptom_session.g.dart';

@freezed
class SymptomSession with _$SymptomSession {
  const factory SymptomSession({
    required String id,
    @JsonKey(name: 'patient_id') required String patientId,
    @JsonKey(name: 'symptoms_input') required String symptomsInput,
    @JsonKey(name: 'ai_response') required SymptomResponse aiResponse,
    @JsonKey(name: 'triage_level') String? triageLevel,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _SymptomSession;

  factory SymptomSession.fromJson(Map<String, dynamic> json) =>
      _$SymptomSessionFromJson(json);
}

@freezed
class SymptomResponse with _$SymptomResponse {
  const factory SymptomResponse({
    @Default([]) List<String> recommendations,
    @JsonKey(name: 'triage_level') String? triageLevel,
    @Default([]) @JsonKey(name: 'what_to_do') List<String> whatToDo,
    @Default([]) @JsonKey(name: 'what_to_avoid') List<String> whatToAvoid,
    @JsonKey(name: 'when_to_seek_help') String? whenToSeekHelp,
  }) = _SymptomResponse;

  factory SymptomResponse.fromJson(Map<String, dynamic> json) =>
      _$SymptomResponseFromJson(json);
}
