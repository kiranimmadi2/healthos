import 'dart:convert';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/foundation.dart';

import '../../ai_triage/data/ai_service.dart' show AiUnavailableException;
import '../../auth/domain/user_profile.dart';
import '../domain/meal_analysis.dart';

/// Nutrition analysis backed by cloud Gemini.
///
/// This replaces `OnDeviceGemmaService`, which was misnamed and misleading:
/// there is no on-device model in this project (no `flutter_gemma`, no TFLite
/// or MediaPipe dependency, no bundled model asset). It called cloud
/// `gemini-2.5-flash` with a prompt telling the model to claim it was running
/// locally, flagged every result as locally inferred, and told the user their
/// data never left the device.
///
/// Its fallback was worse: when the call failed it returned a hardcoded
/// keyword-to-macro table (pizza -> 680 kcal, salad -> 340 kcal) presented as
/// analysis of the patient's actual meal, personalised against their recorded
/// conditions. That table is gone; failures now throw.
class NutritionAiService {
  NutritionAiService({FirebaseAI? client}) : _client = client;

  final FirebaseAI? _client;

  static const _model = 'gemini-2.5-flash';

  FirebaseAI get _ai => _client ?? FirebaseAI.googleAI();

  /// Schema the model must fill. Using a response schema removes the previous
  /// `indexOf('{')` / `lastIndexOf('}')` substring parsing.
  static final _schema = Schema.object(
    properties: {
      'foodName': Schema.string(),
      'mealType': Schema.string(),
      'suitability': Schema.enumString(
        enumValues: ['safe', 'moderateCaution', 'highRisk'],
      ),
      'suitabilityScore': Schema.integer(),
      'macros': Schema.object(
        properties: {
          'calories': Schema.integer(),
          'proteinGrams': Schema.number(),
          'carbsGrams': Schema.number(),
          'fatGrams': Schema.number(),
          'fiberGrams': Schema.number(),
          'sugarGrams': Schema.number(),
          'sodiumMg': Schema.number(),
          'glycemicIndex': Schema.integer(),
        },
      ),
      'healthWarnings': Schema.array(items: Schema.string()),
      'benefits': Schema.array(items: Schema.string()),
      'portionAdvice': Schema.string(),
      'summary': Schema.string(),
    },
  );

  /// Analyses a described meal for this patient.
  ///
  /// Throws [AiUnavailableException] when the model cannot be reached or
  /// returns something unusable. It never estimates nutrition locally.
  Future<MealAnalysisResult> analyzeMeal({
    required String foodDescription,
    required String mealType,
    UserProfile? patientProfile,
  }) async {
    final prompt = _prompt(foodDescription, mealType, patientProfile);

    try {
      final model = _ai.generativeModel(
        model: _model,
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
          responseSchema: _schema,
        ),
      );
      final response = await model.generateContent([Content.text(prompt)]);
      final raw = response.text?.trim();
      if (raw == null || raw.isEmpty) {
        throw const AiUnavailableException();
      }

      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      decoded['foodName'] ??= foodDescription;
      decoded['mealType'] ??= mealType;
      return MealAnalysisResult.fromJson(decoded);
    } on AiUnavailableException {
      rethrow;
    } catch (error) {
      debugPrint('NutritionAiService: analysis failed: $error');
      throw AiUnavailableException(error);
    }
  }

  String _prompt(String food, String mealType, UserProfile? profile) {
    return '''
You are a clinical nutrition assistant. Analyse the meal below for this
specific patient and return JSON matching the provided schema.

Patient context:
${_healthContext(profile)}

Meal: "$food"
Meal category: "$mealType"

Rules:
- Base macros on typical values for a single standard serving of the meal
  described. If the description is too vague to estimate, say so in `summary`
  and give conservative values.
- `healthWarnings` must reference the patient's own recorded conditions and
  allergies where relevant, and be empty when none apply.
- `suitabilityScore` is 0-100, where 100 is ideal for this patient.
- Do not claim to be a dietitian and do not diagnose.
''';
  }

  String _healthContext(UserProfile? profile) {
    if (profile == null) {
      return '- No profile recorded; assume a general adult with a standard '
          '2000 kcal daily intake.';
    }

    final parts = <String>[
      if (profile.age != null) 'Age: ${profile.age}',
      if (profile.gender != null) 'Gender: ${profile.gender}',
      if (profile.bmi != null)
        'BMI: ${profile.bmi!.toStringAsFixed(1)} '
            '(weight ${profile.weightKg}kg, height ${profile.heightCm}cm)',
      if (profile.medicalConditions.isNotEmpty)
        'Known conditions: ${profile.medicalConditions.join(', ')}',
      if (profile.allergies.isNotEmpty)
        'Allergies: ${profile.allergies.join(', ')}',
      if (profile.medications.isNotEmpty)
        'Current medications: ${profile.medications.join(', ')}',
      if (profile.dietGoal != null) 'Dietary goal: ${profile.dietGoal}',
    ];

    if (parts.isEmpty) {
      return '- No health details recorded yet.';
    }
    return parts.map((p) => '- $p').join('\n');
  }
}
