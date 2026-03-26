import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_client/supabase_client.dart';

void main() {
  group('Patient.fromJson', () {
    test('parses a fully-populated JSON payload', () {
      final json = <String, dynamic>{
        'id': 'p-001',
        'auth_id': 'auth-abc-123',
        'health_id': 'HOS-0001',
        'phone': '+919876543210',
        'full_name': 'Ravi Kumar',
        'date_of_birth': '1990-05-15T00:00:00.000Z',
        'gender': 'male',
        'blood_group': 'O+',
        'avatar_url': 'https://storage.example.com/avatars/p-001.jpg',
        'allergies': ['Penicillin', 'Dust'],
        'chronic_conditions': ['Diabetes', 'Hypertension'],
        'emergency_contact': {
          'name': 'Priya Kumar',
          'phone': '+919876543211',
          'relation': 'spouse',
        },
        'created_at': '2025-01-10T08:30:00.000Z',
        'updated_at': '2025-03-20T14:00:00.000Z',
      };

      final patient = Patient.fromJson(json);

      expect(patient.id, 'p-001');
      expect(patient.authId, 'auth-abc-123');
      expect(patient.healthId, 'HOS-0001');
      expect(patient.phone, '+919876543210');
      expect(patient.fullName, 'Ravi Kumar');
      expect(patient.dateOfBirth, DateTime.utc(1990, 5, 15));
      expect(patient.gender, 'male');
      expect(patient.bloodGroup, 'O+');
      expect(patient.avatarUrl, isNotNull);
      expect(patient.allergies, ['Penicillin', 'Dust']);
      expect(patient.chronicConditions, ['Diabetes', 'Hypertension']);
      expect(patient.emergencyContact, isA<Map<String, dynamic>>());
      expect(patient.emergencyContact!['relation'], 'spouse');
      expect(patient.createdAt, isNotNull);
      expect(patient.updatedAt, isNotNull);
    });

    test('parses JSON with only required fields', () {
      final json = <String, dynamic>{
        'id': 'p-002',
        'health_id': 'HOS-0002',
        'phone': '+911234567890',
      };

      final patient = Patient.fromJson(json);

      expect(patient.id, 'p-002');
      expect(patient.healthId, 'HOS-0002');
      expect(patient.phone, '+911234567890');
      expect(patient.authId, isNull);
      expect(patient.fullName, isNull);
      expect(patient.dateOfBirth, isNull);
      expect(patient.gender, isNull);
      expect(patient.bloodGroup, isNull);
      expect(patient.avatarUrl, isNull);
      expect(patient.allergies, isEmpty);
      expect(patient.chronicConditions, isEmpty);
      expect(patient.emergencyContact, isNull);
      expect(patient.createdAt, isNull);
      expect(patient.updatedAt, isNull);
    });

    test('defaults allergies and chronic_conditions to empty lists', () {
      final json = <String, dynamic>{
        'id': 'p-003',
        'health_id': 'HOS-0003',
        'phone': '+910000000000',
      };

      final patient = Patient.fromJson(json);

      expect(patient.allergies, isA<List<String>>());
      expect(patient.allergies, isEmpty);
      expect(patient.chronicConditions, isA<List<String>>());
      expect(patient.chronicConditions, isEmpty);
    });

    test('handles null optional fields explicitly set to null', () {
      final json = <String, dynamic>{
        'id': 'p-004',
        'health_id': 'HOS-0004',
        'phone': '+910000000001',
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

      final patient = Patient.fromJson(json);

      expect(patient.id, 'p-004');
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

    test('roundtrip: toJson then fromJson preserves data', () {
      final original = Patient(
        id: 'p-005',
        healthId: 'HOS-0005',
        phone: '+919999999999',
        fullName: 'Test User',
        allergies: ['Peanuts'],
        chronicConditions: ['Asthma'],
      );

      final rebuilt = Patient.fromJson(original.toJson());

      expect(rebuilt.id, original.id);
      expect(rebuilt.healthId, original.healthId);
      expect(rebuilt.phone, original.phone);
      expect(rebuilt.fullName, original.fullName);
      expect(rebuilt.allergies, original.allergies);
      expect(rebuilt.chronicConditions, original.chronicConditions);
    });
  });

  group('PatientRepository instantiation', () {
    test('PatientRepository can be constructed', () {
      // Verifies the class exists and has a default constructor.
      // Actual DB calls require a live Supabase client.
      final repo = PatientRepository();
      expect(repo, isNotNull);
    });
  });
}
