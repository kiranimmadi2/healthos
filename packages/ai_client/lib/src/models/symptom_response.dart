class AiSymptomResponse {
  const AiSymptomResponse({
    required this.recommendations,
    required this.triageLevel,
    required this.whatToDo,
    required this.whatToAvoid,
    required this.whenToSeekHelp,
  });

  final List<String> recommendations;
  final String triageLevel;
  final String whatToDo;
  final String whatToAvoid;
  final String whenToSeekHelp;

  factory AiSymptomResponse.fromJson(Map<String, dynamic> json) {
    return AiSymptomResponse(
      recommendations: List<String>.from(json['recommendations'] ?? []),
      triageLevel: json['triage_level'] as String? ?? 'see_doctor',
      whatToDo: json['what_to_do'] as String? ?? '',
      whatToAvoid: json['what_to_avoid'] as String? ?? '',
      whenToSeekHelp: json['when_to_seek_help'] as String? ?? '',
    );
  }
}
