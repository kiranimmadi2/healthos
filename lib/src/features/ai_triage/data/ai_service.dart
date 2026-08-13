import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/foundation.dart';

import '../../auth/domain/user_profile.dart';

/// Thrown when no model could produce a response.
///
/// This type exists so the UI can say "we could not reach the AI" instead of
/// showing invented text. The previous implementation silently fell back to
/// ~350 lines of hardcoded keyword-matched "clinical advice" that was
/// indistinguishable from a real model answer in the UI — including for
/// symptoms like chest pain.
class AiUnavailableException implements Exception {
  const AiUnavailableException([this.cause]);

  final Object? cause;

  @override
  String toString() =>
      'The AI service is unavailable right now. Please try again.';
}

/// Gemini access for triage and clinical summaries.
///
/// Requests go through Firebase AI Logic (`FirebaseAI.googleAI()`), which
/// authenticates with the Firebase app identity — there is no client-side API
/// key on this path. An earlier version also called the Gemini REST endpoint
/// directly with a key hardcoded in source; that path is gone.
class AIService {
  AIService({FirebaseAI? client}) : _client = client;

  final FirebaseAI? _client;

  /// Tried in order. Both are current; the 1.5 line is legacy.
  static const _models = ['gemini-2.5-flash', 'gemini-2.0-flash'];

  /// Higher-capability model for clinician-facing summarisation.
  static const _proModel = 'gemini-2.5-pro';

  FirebaseAI get _ai => _client ?? FirebaseAI.googleAI();

  /// Runs [prompt] against [models] in order, returning the first non-empty
  /// response. Throws [AiUnavailableException] if none succeed.
  Future<String> _generate(String prompt, List<String> models) async {
    Object? lastError;

    for (final name in models) {
      try {
        final model = _ai.generativeModel(model: name);
        final response = await model.generateContent([Content.text(prompt)]);
        final text = response.text?.trim();
        if (text != null && text.isNotEmpty) return text;
        lastError = StateError('Model $name returned an empty response.');
      } catch (error) {
        lastError = error;
        debugPrint('AIService: model $name failed: $error');
      }
    }

    throw AiUnavailableException(lastError);
  }

  /// Patient-facing symptom guidance.
  ///
  /// Throws [AiUnavailableException] rather than inventing a response.
  Future<String> getTriage(String input, {UserProfile? patientProfile}) {
    return _generate(_triagePrompt(input, patientProfile), _models);
  }

  /// Clinician-facing summary of a patient's history.
  ///
  /// Throws [AiUnavailableException] rather than returning filler bullets.
  Future<String> getClinicalSummary(String medicalHistory) {
    return _generate(
      '''
You are a clinical assistant. Summarise the following patient medical history
into 3 clear, actionable bullet points for a doctor. Base every point strictly
on the history provided; do not infer findings that are not present.

History:
$medicalHistory
''',
      const [_proModel, ..._models],
    );
  }

  String _triagePrompt(String input, UserProfile? profile) {
    return '''
You are a calm, empathetic clinical AI care assistant inside the HealthOS
platform, speaking directly to the patient.

${_patientContext(profile)}
Patient's reported symptom or question: "$input"

DIRECTIVES

1. PERSONALISE FROM THE PROFILE ABOVE
   - Connect your advice to the specific age, BMI, conditions, allergies and
     medications listed. If a field is absent, do not speculate about it.
   - Address the patient by first name where one is given.
   - State plainly which profile factors you took into account.

2. REQUIRED SECTIONS
   - What to eat: specific foods suited to this query and profile.
   - What to avoid: specific foods, habits or postures to avoid.
   - Recommended activity: exercises, stretches or ergonomic adjustments.

3. TRIAGE CLASSIFICATION — begin the response with exactly one of:
   - "EMERGENCY:" for life-threatening symptoms (chest pain, acute
     breathlessness, stroke signs, severe bleeding).
   - "SEE DOCTOR:" for severe pain, high fever or other high-risk symptoms.
   - "HOME CARE:" for non-urgent symptoms.
   - "HEALTH ADVICE:" for general wellbeing, diet or fitness questions.

4. SAFETY
   - Never diagnose, and never contradict a medication the patient is on.
   - Give clear red flags for when to seek in-person care.
   - Close with a one-line reminder that this is guidance, not a diagnosis.
''';
  }

  /// Renders the profile as prompt context.
  ///
  /// Takes a [UserProfile] so field-name handling lives in one place; this
  /// method previously probed four different aliases for "conditions" alone.
  String _patientContext(UserProfile? profile) {
    if (profile == null) {
      return 'Patient profile: no details recorded yet.\n';
    }

    final parts = <String>[
      if (profile.name.isNotEmpty) 'Name: ${profile.name}',
      if (profile.age != null) 'Age: ${profile.age} years',
      if (profile.gender != null && profile.gender != 'Prefer not to say')
        'Gender: ${profile.gender}',
      if (profile.heightCm != null)
        'Height: ${profile.heightCm!.toStringAsFixed(0)} cm',
      if (profile.weightKg != null)
        'Weight: ${profile.weightKg!.toStringAsFixed(0)} kg',
      if (profile.bmi != null)
        'BMI: ${profile.bmi!.toStringAsFixed(1)} kg/m² '
            '(${_bmiCategory(profile.bmi!)})',
      if (profile.bloodGroup != null) 'Blood group: ${profile.bloodGroup}',
      if (profile.allergies.isNotEmpty)
        'Known allergies: ${profile.allergies.join(', ')}',
      if (profile.medicalConditions.isNotEmpty)
        'Pre-existing conditions: ${profile.medicalConditions.join(', ')}',
      if (profile.medications.isNotEmpty)
        'Current medications: ${profile.medications.join(', ')}',
    ];

    if (parts.isEmpty) return 'Patient profile: no details recorded yet.\n';
    return 'Patient background:\n${parts.map((p) => '- $p').join('\n')}\n';
  }

  static String _bmiCategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal weight';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }
}
