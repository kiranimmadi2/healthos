import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Visit', () {
    final json = {
      'id': 'v1-12345678-abcd-ef01-2345-678901234567',
      'patient_id': 'p1-12345678-abcd-ef01-2345-678901234567',
      'doctor_id': 'd1-12345678-abcd-ef01-2345-678901234567',
      'hospital_id': 'h1-12345678-abcd-ef01-2345-678901234567',
      'visited_at': '2024-09-15T14:30:00.000',
      'chief_complaint': 'Persistent chest pain for 3 days',
      'diagnosis': 'Costochondritis',
      'notes': 'Patient advised rest and prescribed NSAIDs.',
      'created_at': '2024-09-15T14:30:00.000',
    };

    test('fromJson parses all fields correctly', () {
      final visit = Visit.fromJson(json);

      expect(visit.id, 'v1-12345678-abcd-ef01-2345-678901234567');
      expect(visit.patientId, 'p1-12345678-abcd-ef01-2345-678901234567');
      expect(visit.doctorId, 'd1-12345678-abcd-ef01-2345-678901234567');
      expect(visit.hospitalId, 'h1-12345678-abcd-ef01-2345-678901234567');
      expect(visit.visitedAt, DateTime.parse('2024-09-15T14:30:00.000'));
      expect(visit.chiefComplaint, 'Persistent chest pain for 3 days');
      expect(visit.diagnosis, 'Costochondritis');
      expect(visit.notes, 'Patient advised rest and prescribed NSAIDs.');
      expect(visit.createdAt, DateTime.parse('2024-09-15T14:30:00.000'));
    });

    test('fromJson and toJson round-trip', () {
      final visit = Visit.fromJson(json);
      final serialized = visit.toJson();
      final roundTripped = Visit.fromJson(serialized);
      expect(roundTripped, visit);
    });

    test('copyWith creates modified copy', () {
      final visit = Visit(
        id: 'v-1',
        patientId: 'p-1',
        visitedAt: DateTime(2024, 9, 15),
      );

      final updated = visit.copyWith(
        diagnosis: 'Viral Fever',
        notes: 'Follow up in 5 days',
      );

      expect(updated.diagnosis, 'Viral Fever');
      expect(updated.notes, 'Follow up in 5 days');
      expect(updated.id, 'v-1');
      expect(updated.patientId, 'p-1');
      expect(updated.visitedAt, DateTime(2024, 9, 15));
    });

    test('copyWith preserves all fields when none changed', () {
      final visit = Visit.fromJson(json);
      final copy = visit.copyWith();
      expect(copy, visit);
    });

    test('defaults are applied', () {
      final visit = Visit(
        id: 'v-1',
        patientId: 'p-1',
        visitedAt: DateTime(2024, 9, 15),
      );

      expect(visit.doctorId, isNull);
      expect(visit.hospitalId, isNull);
      expect(visit.chiefComplaint, isNull);
      expect(visit.diagnosis, isNull);
      expect(visit.notes, isNull);
      expect(visit.createdAt, isNull);
    });

    test('fromJson handles minimal JSON (only required fields)', () {
      final minimalJson = {
        'id': 'v-min',
        'patient_id': 'p-min',
        'visited_at': '2024-09-15T14:30:00.000',
      };

      final visit = Visit.fromJson(minimalJson);
      expect(visit.id, 'v-min');
      expect(visit.patientId, 'p-min');
      expect(visit.visitedAt, DateTime.parse('2024-09-15T14:30:00.000'));
      expect(visit.doctorId, isNull);
      expect(visit.hospitalId, isNull);
      expect(visit.chiefComplaint, isNull);
      expect(visit.diagnosis, isNull);
      expect(visit.notes, isNull);
      expect(visit.createdAt, isNull);
    });

    test('fromJson handles null optional fields explicitly', () {
      final jsonWithNulls = {
        'id': 'v-null',
        'patient_id': 'p-null',
        'visited_at': '2024-09-15T14:30:00.000',
        'doctor_id': null,
        'hospital_id': null,
        'chief_complaint': null,
        'diagnosis': null,
        'notes': null,
        'created_at': null,
      };

      final visit = Visit.fromJson(jsonWithNulls);
      expect(visit.doctorId, isNull);
      expect(visit.hospitalId, isNull);
      expect(visit.chiefComplaint, isNull);
      expect(visit.diagnosis, isNull);
      expect(visit.notes, isNull);
      expect(visit.createdAt, isNull);
    });
  });
}
