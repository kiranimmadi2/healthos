class SymptomRequest {
  const SymptomRequest({
    required this.patientId,
    required this.symptoms,
    this.sessionId,
  });

  final String patientId;
  final String symptoms;
  final String? sessionId;

  Map<String, dynamic> toJson() => {
        'patient_id': patientId,
        'symptoms': symptoms,
        if (sessionId != null) 'session_id': sessionId,
      };
}
