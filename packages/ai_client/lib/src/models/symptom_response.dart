class AiSymptomResponse {
  const AiSymptomResponse({
    this.sessionId,
    required this.recommendations,
    required this.triageLevel,
    required this.whatToDo,
    required this.whatToAvoid,
    required this.whenToSeekHelp,
  });

  final String? sessionId;
  final List<String> recommendations;
  final String triageLevel;
  final List<String> whatToDo;
  final List<String> whatToAvoid;
  final String whenToSeekHelp;

  factory AiSymptomResponse.fromJson(Map<String, dynamic> json) {
    return AiSymptomResponse(
      sessionId: json['session_id'] as String?,
      recommendations: List<String>.from(json['recommendations'] ?? []),
      triageLevel: json['triage_level'] as String? ?? 'see_doctor',
      whatToDo: List<String>.from(json['what_to_do'] ?? []),
      whatToAvoid: List<String>.from(json['what_to_avoid'] ?? []),
      whenToSeekHelp: json['when_to_seek_help'] as String? ?? '',
    );
  }
}
