import 'package:google_generative_ai/google_generative_ai.dart';

class AIService {
  // Using the provided API Key for standalone Google AI
  static const String _apiKey = 'AIzaSyDmvsFflSUzeU04f1LyDi2hw1_0TRE5MFY';

  final GenerativeModel _flashModel = GenerativeModel(
    model: 'gemini-2.5-flash',
    apiKey: _apiKey,
  );

  final GenerativeModel _proModel = GenerativeModel(
    model: 'gemini-2.5-pro',
    apiKey: _apiKey,
  );

  /// Builds a readable patient context block from the Firestore user document
  /// so the model can personalize its answer.
  String _patientContext(Map<String, dynamic>? profile) {
    if (profile == null || profile.isEmpty) return '';

    final parts = <String>[];

    final name = profile['name'] as String?;
    if (name != null && name.isNotEmpty) parts.add('Name: $name');

    final dob = DateTime.tryParse(profile['dob'] as String? ?? '');
    if (dob != null) {
      final now = DateTime.now();
      var age = now.year - dob.year;
      if (now.month < dob.month ||
          (now.month == dob.month && now.day < dob.day)) {
        age--;
      }
      parts.add('Age: $age years');
    }

    final gender = profile['gender'] as String?;
    if (gender != null && gender != 'Prefer not to say') {
      parts.add('Gender: $gender');
    }

    final height = (profile['height'] as num?)?.toDouble();
    final weight = (profile['weight'] as num?)?.toDouble();
    if (height != null) parts.add('Height: ${height.toStringAsFixed(0)} cm');
    if (weight != null) parts.add('Weight: ${weight.toStringAsFixed(0)} kg');
    if (height != null && weight != null && height > 0) {
      final heightM = height / 100;
      final bmi = weight / (heightM * heightM);
      parts.add('BMI: ${bmi.toStringAsFixed(1)}');
    }

    if (parts.isEmpty) return '';
    return 'Patient profile:\n${parts.map((p) => '- $p').join('\n')}\n';
  }

  Future<String> getTriage(
    String input, {
    Map<String, dynamic>? patientProfile,
  }) async {
    final prompt =
        '''
You are a friendly medical assistant inside the HealthOS app, talking directly to the patient.

${_patientContext(patientProfile)}
Patient's message: $input

Instructions:
- If the message describes symptoms, triage it into exactly one category and start your reply with it:
  1. EMERGENCY: Go to ER immediately.
  2. SEE DOCTOR: Book an appointment soon.
  3. HOME CARE: Rest and monitor.
  Then give a concise explanation for your choice.
- If the message is a general health question (e.g. diet, fitness, weight gain/loss, sleep), answer it helpfully with practical, specific advice instead of triaging.
- Personalize the answer using the patient profile above (address them by first name; consider their age, gender, height, weight and BMI where relevant).
- Use plain text without markdown formatting. Keep it under 250 words.
- End with a one-line reminder that this is not a substitute for professional medical advice.
''';

    try {
      final response = await _flashModel.generateContent([
        Content.text(prompt),
      ]);
      return response.text ?? 'Error generating triage.';
    } catch (e) {
      return 'AI Error: $e';
    }
  }

  Future<String> getClinicalSummary(String medicalHistory) async {
    final prompt =
        '''
    You are a clinical assistant. Summarize the following patient medical history into 3 clear, actionable bullet points for a doctor.

    History: $medicalHistory
    ''';

    try {
      final response = await _proModel.generateContent([Content.text(prompt)]);
      return response.text ?? 'Error generating summary.';
    } catch (e) {
      return 'AI Error: $e';
    }
  }
}
