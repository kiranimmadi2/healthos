import 'dart:convert';

import 'package:http/http.dart' as http;

import 'models/models.dart';

class AiService {
  AiService({
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    this.accessToken,
  });

  final String supabaseUrl;
  final String supabaseAnonKey;
  String? accessToken;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'apikey': supabaseAnonKey,
        if (accessToken != null) 'Authorization': 'Bearer $accessToken',
      };

  Future<AiSymptomResponse> checkSymptoms(SymptomRequest request) async {
    final response = await http.post(
      Uri.parse('$supabaseUrl/functions/v1/ai-symptom'),
      headers: _headers,
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Symptom check failed: ${response.body}');
    }

    return AiSymptomResponse.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<AiSummaryResponse> getPatientSummary(SummaryRequest request) async {
    final response = await http.post(
      Uri.parse('$supabaseUrl/functions/v1/ai-summary'),
      headers: _headers,
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Summary generation failed: ${response.body}');
    }

    return AiSummaryResponse.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<Map<String, dynamic>> processLabReport({
    required String reportUrl,
    required String patientId,
    required String reportId,
  }) async {
    final response = await http.post(
      Uri.parse('$supabaseUrl/functions/v1/ocr-report'),
      headers: _headers,
      body: jsonEncode({
        'report_url': reportUrl,
        'patient_id': patientId,
        'report_id': reportId,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('OCR processing failed: ${response.body}');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
