class SummaryRequest {
  const SummaryRequest({
    required this.patientId,
  });

  final String patientId;

  Map<String, dynamic> toJson() => {
        'patient_id': patientId,
      };
}
