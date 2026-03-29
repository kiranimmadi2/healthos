import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Patient', () {
    final json = {
      'id': '123e4567-e89b-12d3-a456-426614174000',
      'auth_id': 'auth-123',
      'health_id': 'HOS-2024-AB12',
      'phone': '+919876543210',
      'full_name': 'John Doe',
      'date_of_birth': '2024-01-15T00:00:00.000',
      'gender': 'male',
      'blood_group': 'O+',
      'avatar_url': 'https://cdn.example.com/avatars/patient1.png',
      'allergies': ['Penicillin', 'Peanuts'],
      'chronic_conditions': ['Diabetes'],
      'emergency_contact': {
        'name': 'Jane Doe',
        'phone': '+919876543211',
        'relationship': 'Spouse',
      },
      'created_at': '2024-01-01T00:00:00.000',
      'updated_at': '2024-06-01T12:00:00.000',
    };

    test('fromJson parses all fields correctly', () {
      final patient = Patient.fromJson(json);

      expect(patient.id, '123e4567-e89b-12d3-a456-426614174000');
      expect(patient.authId, 'auth-123');
      expect(patient.healthId, 'HOS-2024-AB12');
      expect(patient.phone, '+919876543210');
      expect(patient.fullName, 'John Doe');
      expect(patient.dateOfBirth, DateTime.parse('2024-01-15T00:00:00.000'));
      expect(patient.gender, 'male');
      expect(patient.bloodGroup, 'O+');
      expect(patient.avatarUrl,
          'https://cdn.example.com/avatars/patient1.png');
      expect(patient.allergies, ['Penicillin', 'Peanuts']);
      expect(patient.chronicConditions, ['Diabetes']);
      expect(patient.emergencyContact?['name'], 'Jane Doe');
      expect(patient.emergencyContact?['relationship'], 'Spouse');
      expect(patient.createdAt, DateTime.parse('2024-01-01T00:00:00.000'));
      expect(patient.updatedAt, DateTime.parse('2024-06-01T12:00:00.000'));
    });

    test('fromJson and toJson round-trip', () {
      final patient = Patient.fromJson(json);
      final serialized = patient.toJson();
      final roundTripped = Patient.fromJson(serialized);
      expect(roundTripped, patient);
    });

    test('copyWith creates modified copy', () {
      final patient = Patient(
        id: '1',
        healthId: 'HOS-2024-AB12',
        phone: '+91123',
      );

      final updated = patient.copyWith(fullName: 'Jane Doe');

      expect(updated.fullName, 'Jane Doe');
      expect(updated.id, '1');
      expect(updated.healthId, 'HOS-2024-AB12');
      expect(updated.phone, '+91123');
    });

    test('copyWith preserves all fields when none changed', () {
      final patient = Patient.fromJson(json);
      final copy = patient.copyWith();
      expect(copy, patient);
    });

    test('defaults are applied for minimal required fields', () {
      final patient = Patient(
        id: '1',
        healthId: 'HOS-2024-AB12',
        phone: '+91123',
      );

      expect(patient.allergies, isEmpty);
      expect(patient.chronicConditions, isEmpty);
      expect(patient.avatarUrl, isNull);
      expect(patient.authId, isNull);
      expect(patient.fullName, isNull);
      expect(patient.dateOfBirth, isNull);
      expect(patient.gender, isNull);
      expect(patient.bloodGroup, isNull);
      expect(patient.emergencyContact, isNull);
      expect(patient.createdAt, isNull);
      expect(patient.updatedAt, isNull);
    });

    test('fromJson handles minimal JSON (only required fields)', () {
      final minimalJson = {
        'id': 'p-minimal',
        'health_id': 'HOS-MIN-001',
        'phone': '+910000000000',
      };

      final patient = Patient.fromJson(minimalJson);
      expect(patient.id, 'p-minimal');
      expect(patient.healthId, 'HOS-MIN-001');
      expect(patient.phone, '+910000000000');
      expect(patient.fullName, isNull);
      expect(patient.allergies, isEmpty);
      expect(patient.chronicConditions, isEmpty);
    });

    test('fromJson handles empty lists for allergies and conditions', () {
      final jsonWithEmptyLists = {
        'id': 'p-empty',
        'health_id': 'HOS-EMPTY-001',
        'phone': '+910000000000',
        'allergies': <String>[],
        'chronic_conditions': <String>[],
      };

      final patient = Patient.fromJson(jsonWithEmptyLists);
      expect(patient.allergies, isEmpty);
      expect(patient.chronicConditions, isEmpty);
    });

    test('fromJson handles null optional fields explicitly', () {
      final jsonWithNulls = {
        'id': 'p-null',
        'health_id': 'HOS-NULL-001',
        'phone': '+910000000000',
        'auth_id': null,
        'full_name': null,
        'date_of_birth': null,
        'gender': null,
        'blood_group': null,
        'avatar_url': null,
        'emergency_contact': null,
        'created_at': null,
        'updated_at': null,
      };

      final patient = Patient.fromJson(jsonWithNulls);
      expect(patient.authId, isNull);
      expect(patient.fullName, isNull);
      expect(patient.dateOfBirth, isNull);
      expect(patient.gender, isNull);
      expect(patient.bloodGroup, isNull);
      expect(patient.avatarUrl, isNull);
      expect(patient.emergencyContact, isNull);
      expect(patient.createdAt, isNull);
      expect(patient.updatedAt, isNull);
    });
  });
}
