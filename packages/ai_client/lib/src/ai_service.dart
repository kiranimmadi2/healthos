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

  /// Streams the raw response from the ai-symptom Edge Function as
  /// Server-Sent Event (SSE) / chunked text fragments.
  ///
  /// Each emitted [String] is one chunk of the HTTP response body as it
  /// arrives over the wire.  The caller is responsible for accumulating
  /// and parsing the final JSON once the stream closes.
  ///
  /// The existing [checkSymptoms] method is left unchanged for callers
  /// that prefer a single-shot Future-based API.
  Stream<String> checkSymptomsStream(SymptomRequest request) async* {
    final client = http.Client();
    try {
      final httpRequest = http.Request(
        'POST',
        Uri.parse('$supabaseUrl/functions/v1/ai-symptom'),
      );
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
