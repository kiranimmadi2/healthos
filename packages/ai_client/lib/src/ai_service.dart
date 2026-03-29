import 'dart:convert';

import 'package:http/http.dart' as http;

import 'models/models.dart';

class AiService {
  AiService({
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    this.accessToken,
    this.useMicroservices = true,
  });

  final String supabaseUrl;
  final String supabaseAnonKey;
  String? accessToken;

  /// When true, routes requests through the unified ai-service microservice.
  /// When false, uses legacy individual edge functions.
  final bool useMicroservices;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'apikey': supabaseAnonKey,
        if (accessToken != null) 'Authorization': 'Bearer $accessToken',
      };

  String _aiUrl(String path) => useMicroservices
      ? '$supabaseUrl/functions/v1/ai-service$path'
      : '$supabaseUrl/functions/v1/${path.replaceFirst('/', '')}';

  Future<AiSymptomResponse> checkSymptoms(SymptomRequest request) async {
    final url = useMicroservices
        ? _aiUrl('/symptoms')
        : '$supabaseUrl/functions/v1/ai-symptom';

    final response = await http.post(
      Uri.parse(url),
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
    final url = useMicroservices
        ? _aiUrl('/summary')
        : '$supabaseUrl/functions/v1/ai-summary';

    final response = await http.post(
      Uri.parse(url),
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

  Stream<String> checkSymptomsStream(SymptomRequest request) async* {
    final url = useMicroservices
        ? _aiUrl('/symptoms')
        : '$supabaseUrl/functions/v1/ai-symptom';

    final client = http.Client();
    try {
      final httpRequest = http.Request('POST', Uri.parse(url));
      httpRequest.headers.addAll(_headers);
      httpRequest.body = jsonEncode(request.toJson());

      final streamed = await client.send(httpRequest);

      if (streamed.statusCode != 200) {
        final body = await streamed.stream.bytesToString();
        throw Exception('Symptom check failed (${streamed.statusCode}): $body');
      }

      await for (final chunk in streamed.stream.transform(utf8.decoder)) {
        yield chunk;
      }
    } finally {
      client.close();
    }
  }

  Future<Map<String, dynamic>> processLabReport({
    required String reportUrl,
    required String patientId,
    required String reportId,
  }) async {
    final url = useMicroservices
        ? _aiUrl('/ocr')
        : '$supabaseUrl/functions/v1/ocr-report';

    final response = await http.post(
      Uri.parse(url),
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
