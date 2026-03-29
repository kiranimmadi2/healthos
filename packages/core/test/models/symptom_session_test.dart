import 'dart:convert';

import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SymptomResponse', () {
    final json = {
      'recommendations': [
        'Stay hydrated',
        'Rest for 24 hours',
        'Monitor temperature',
      ],
      'triage_level': 'low',
      'what_to_do': 'Take OTC fever reducers and rest.',
      'what_to_avoid': 'Avoid strenuous activity and cold exposure.',
      'when_to_seek_help':
          'If fever exceeds 103F or persists beyond 3 days.',
    };

    test('fromJson parses all fields correctly', () {
      final response = SymptomResponse.fromJson(json);

      expect(response.recommendations, hasLength(3));
      expect(response.recommendations[0], 'Stay hydrated');
      expect(response.recommendations[1], 'Rest for 24 hours');
      expect(response.recommendations[2], 'Monitor temperature');
      expect(response.triageLevel, 'low');
      expect(response.whatToDo, 'Take OTC fever reducers and rest.');
      expect(response.whatToAvoid,
          'Avoid strenuous activity and cold exposure.');
      expect(response.whenToSeekHelp,
          'If fever exceeds 103F or persists beyond 3 days.');
    });

    test('fromJson and toJson round-trip', () {
      final response = SymptomResponse.fromJson(json);
      final serialized = response.toJson();
      final roundTripped = SymptomResponse.fromJson(serialized);
      expect(roundTripped, response);
    });

    test('defaults are applied', () {
      final response = SymptomResponse();

      expect(response.recommendations, isEmpty);
      expect(response.triageLevel, isNull);
      expect(response.whatToDo, isNull);
      expect(response.whatToAvoid, isNull);
      expect(response.whenToSeekHelp, isNull);
    });

    test('copyWith creates modified copy', () {
      final response = SymptomResponse(
        recommendations: ['Rest'],
        triageLevel: 'low',
      );

      final updated = response.copyWith(
        triageLevel: 'medium',
        whatToDo: 'Visit a doctor',
      );

      expect(updated.triageLevel, 'medium');
      expect(updated.whatToDo, 'Visit a doctor');
      expect(updated.recommendations, ['Rest']);
    });

    test('fromJson handles empty recommendations list', () {
      final emptyRecsJson = {
        'recommendations': <String>[],
        'triage_level': 'low',
      };

      final response = SymptomResponse.fromJson(emptyRecsJson);
      expect(response.recommendations, isEmpty);
      expect(response.triageLevel, 'low');
    });

    test('fromJson handles null optional fields explicitly', () {
      final jsonWithNulls = {
        'triage_level': null,
        'what_to_do': null,
        'what_to_avoid': null,
        'when_to_seek_help': null,
      };

      final response = SymptomResponse.fromJson(jsonWithNulls);
      expect(response.triageLevel, isNull);
      expect(response.whatToDo, isNull);
      expect(response.whatToAvoid, isNull);
      expect(response.whenToSeekHelp, isNull);
    });
  });

  group('SymptomSession', () {
    final json = {
      'id': 'ss-12345678-abcd-ef01-2345-678901234567',
      'patient_id': 'p1-12345678-abcd-ef01-2345-678901234567',
      'symptoms_input':
          'I have a headache, mild fever, and body aches for 2 days.',
      'ai_response': {
        'recommendations': [
          'Take paracetamol 500mg',
          'Drink plenty of fluids',
        ],
        'triage_level': 'low',
        'what_to_do': 'Rest and take OTC medication.',
        'what_to_avoid': 'Avoid screen time.',
        'when_to_seek_help': 'If symptoms worsen in 48 hours.',
      },
      'triage_level': 'low',
      'created_at': '2024-10-01T08:30:00.000',
    };

    test('fromJson parses all fields correctly', () {
      final session = SymptomSession.fromJson(json);

      expect(session.id, 'ss-12345678-abcd-ef01-2345-678901234567');
      expect(session.patientId, 'p1-12345678-abcd-ef01-2345-678901234567');
      expect(session.symptomsInput,
          'I have a headache, mild fever, and body aches for 2 days.');
      expect(session.aiResponse.recommendations, hasLength(2));
      expect(session.aiResponse.recommendations[0],
          'Take paracetamol 500mg');
      expect(session.aiResponse.triageLevel, 'low');
      expect(
          session.aiResponse.whatToDo, 'Rest and take OTC medication.');
      expect(session.aiResponse.whatToAvoid, 'Avoid screen time.');
      expect(session.aiResponse.whenToSeekHelp,
          'If symptoms worsen in 48 hours.');
      expect(session.triageLevel, 'low');
      expect(
          session.createdAt, DateTime.parse('2024-10-01T08:30:00.000'));
    });

    test('fromJson and toJson round-trip', () {
      final session = SymptomSession.fromJson(json);
      final serialized = jsonDecode(jsonEncode(session.toJson())) as Map<String, dynamic>;
      final roundTripped = SymptomSession.fromJson(serialized);
      expect(roundTripped, session);
    });

    test('copyWith creates modified copy', () {
      final session = SymptomSession(
        id: 'ss-1',
        patientId: 'p-1',
        symptomsInput: 'Headache',
        aiResponse: SymptomResponse(
          recommendations: ['Rest'],
          triageLevel: 'low',
        ),
      );

      final updated = session.copyWith(triageLevel: 'medium');

      expect(updated.triageLevel, 'medium');
      expect(updated.id, 'ss-1');
      expect(updated.symptomsInput, 'Headache');
      expect(updated.aiResponse.recommendations, ['Rest']);
    });

    test('copyWith preserves all fields when none changed', () {
      final session = SymptomSession.fromJson(json);
      final copy = session.copyWith();
      expect(copy, session);
    });

    test('defaults are applied', () {
      final session = SymptomSession(
        id: 'ss-1',
        patientId: 'p-1',
        symptomsInput: 'Cough',
        aiResponse: SymptomResponse(),
      );

      expect(session.triageLevel, isNull);
      expect(session.createdAt, isNull);
    });

    test('fromJson handles minimal JSON (only required fields)', () {
      final minimalJson = {
        'id': 'ss-min',
        'patient_id': 'p-min',
        'symptoms_input': 'Sore throat',
        'ai_response': {
          'recommendations': <String>[],
        },
      };

      final session = SymptomSession.fromJson(minimalJson);
      expect(session.id, 'ss-min');
      expect(session.patientId, 'p-min');
      expect(session.symptomsInput, 'Sore throat');
      expect(session.aiResponse.recommendations, isEmpty);
      expect(session.triageLevel, isNull);
      expect(session.createdAt, isNull);
    });

    test('nested aiResponse preserves all fields through round-trip', () {
      final session = SymptomSession.fromJson(json);
      final serialized = jsonDecode(jsonEncode(session.toJson())) as Map<String, dynamic>;
      final roundTripped = SymptomSession.fromJson(serialized);

      expect(roundTripped.aiResponse.recommendations,
          session.aiResponse.recommendations);
      expect(roundTripped.aiResponse.triageLevel,
          session.aiResponse.triageLevel);
      expect(roundTripped.aiResponse.whatToDo,
          session.aiResponse.whatToDo);
      expect(roundTripped.aiResponse.whatToAvoid,
          session.aiResponse.whatToAvoid);
      expect(roundTripped.aiResponse.whenToSeekHelp,
          session.aiResponse.whenToSeekHelp);
    });
  });
}
