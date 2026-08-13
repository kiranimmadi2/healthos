import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:healthos/src/features/ai_triage/data/ai_service.dart';
import 'package:healthos/src/features/food_nutrition/domain/meal_analysis.dart';

/// Guards against the fabrication patterns this refactor removed.
///
/// These are deliberately source-level assertions: the behaviours they protect
/// (a hardcoded API key, a keyword-to-calorie table, canned "clinical advice"
/// returned on failure) are exactly the kind of thing that gets quietly
/// reintroduced, and no runtime test would notice.
void main() {
  String read(String path) => File(path).readAsStringSync();

  group('no client-side AI credentials', () {
    test('no Google API key literal outside firebase_options.dart', () {
      final offenders = <String>[];

      for (final entity in Directory('lib').listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        if (entity.path.endsWith('firebase_options.dart')) continue;
        if (entity.path.contains('AIza')) continue;
        if (RegExp('AIza[0-9A-Za-z_-]{10,}').hasMatch(entity.readAsStringSync())) {
          offenders.add(entity.path);
        }
      }

      expect(
        offenders,
        isEmpty,
        reason:
            'A Google API key literal is back in application code. Requests '
            'must go through Firebase AI Logic, which needs no client key.',
      );
    });

    test('ai_service does not call the Gemini REST endpoint directly', () {
      final source = read('lib/src/features/ai_triage/data/ai_service.dart');
      expect(source, isNot(contains('generativelanguage.googleapis.com')));
      expect(source, isNot(contains('package:http/http.dart')));
    });
  });

  group('no fabricated clinical output', () {
    test('triage has no canned fallback response engine', () {
      final source = read('lib/src/features/ai_triage/data/ai_service.dart');
      expect(source, isNot(contains('_generateSmartFallbackTriage')));
      // The failure path must be a throw, not a substituted answer.
      expect(source, contains('AiUnavailableException'));
    });

    test('nutrition analysis has no hardcoded macro table', () {
      final source = read(
        'lib/src/features/food_nutrition/data/nutrition_ai_service.dart',
      );
      expect(source, isNot(contains('_runLocalDeterministicGemmaInference')));
      // The old table keyed calories off substrings like these.
      expect(source, isNot(contains("contains('pizza')")));
      expect(source, isNot(contains("contains('salad')")));
    });

    test('no on-device inference is claimed anywhere', () {
      for (final entity in Directory('lib').listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        final source = entity.readAsStringSync();
        // Doc comments explaining the removal are allowed; user-visible
        // strings and the old flag are not.
        expect(
          source,
          isNot(contains('isOnDeviceInference')),
          reason: '${entity.path} still marks results as on-device inference',
        );
        expect(
          source,
          isNot(contains('100% Offline')),
          reason: '${entity.path} still claims offline processing',
        );
      }
    });

    test('the doctor sheet no longer fabricates a prescription', () {
      final source = read(
        'lib/src/features/doctor_portal/presentation/dialogs/'
        'doctor_workspace_dialogs.dart',
      );
      expect(
        source,
        isNot(contains("medicationName: 'Amoxicillin 500mg'")),
        reason: 'A fake prescription must never be shown to a clinician.',
      );
      expect(
        source,
        isNot(contains("heartRate: '72 bpm'")),
        reason: 'Placeholder vitals must not look like measurements.',
      );
    });
  });

  group('AiUnavailableException', () {
    test('reads as user-facing copy, not a stack-shaped string', () {
      const exception = AiUnavailableException();
      expect(exception.toString(), isNot(contains('Exception')));
      expect(exception.toString(), contains('unavailable'));
    });
  });

  group('MealAnalysisResult', () {
    test('parses the renamed summary field and the legacy alias', () {
      expect(
        MealAnalysisResult.fromJson(const {'summary': 'Balanced.'}).summary,
        'Balanced.',
      );
      expect(
        MealAnalysisResult.fromJson(const {'gemmaSummary': 'Legacy.'}).summary,
        'Legacy.',
      );
    });

    test('does not invent a summary when the model gave none', () {
      expect(MealAnalysisResult.fromJson(const {}).summary, isEmpty);
    });

    test('round-trips without an on-device flag', () {
      final json = MealAnalysisResult.fromJson(const {
        'foodName': 'Oatmeal',
        'summary': 'Good fibre.',
      }).toJson();

      expect(json.containsKey('isOnDeviceInference'), isFalse);
      expect(json['summary'], 'Good fibre.');
    });
  });
}
