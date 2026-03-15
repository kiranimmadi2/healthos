class AiSummaryResponse {
  const AiSummaryResponse({
    required this.summary,
    required this.keyFindings,
    required this.riskFactors,
    required this.recommendations,
  });

  final String summary;
  final List<String> keyFindings;
  final List<String> riskFactors;
  final List<String> recommendations;

  factory AiSummaryResponse.fromJson(Map<String, dynamic> json) {
    return AiSummaryResponse(
      summary: json['summary'] as String? ?? '',
      keyFindings: List<String>.from(json['key_findings'] ?? []),
      riskFactors: List<String>.from(json['risk_factors'] ?? []),
      recommendations: List<String>.from(json['recommendations'] ?? []),
    );
  }
}
