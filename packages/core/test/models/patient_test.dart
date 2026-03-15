import 'dart:convert';

import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Patient', () {
    test('fromJson and toJson round-trip', () {
      final json = {
        'id': '123e4567-e89b-12d3-a456-426614174000',
        'auth_id': 'auth-123',
        'health_id': 'HOS-2024-AB12',
        'phone': '+919876543210',
        'full_name': 'John Doe',
        'date_of_birth': '2024-01-15T00:00:00.000',
        'gender': 'male',
        'blood_group': 'O+',
        'allergies': ['Penicillin', 'Peanuts'],
        'chronic_conditions': ['Diabetes'],
        'created_at': '2024-01-01T00:00:00.000',
      };

      final patient = Patient.fromJson(json);

      expect(patient.id, '123e4567-e89b-12d3-a456-426614174000');
      expect(patient.healthId, 'HOS-2024-AB12');
      expect(patient.fullName, 'John Doe');
      expect(patient.phone, '+919876543210');
      expect(patient.gender, 'male');
      expect(patient.bloodGroup, 'O+');
      expect(patient.allergies, ['Penicillin', 'Peanuts']);
      expect(patient.chronicConditions, ['Diabetes']);

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
    });

    test('defaults are applied', () {
      final patient = Patient(
        id: '1',
        healthId: 'HOS-2024-AB12',
        phone: '+91123',
      );

      expect(patient.allergies, isEmpty);
      expect(patient.chronicConditions, isEmpty);
      expect(patient.avatarUrl, isNull);
    });
  });

  group('Biomarker', () {
    test('isLow/isHigh/isNormal computed correctly', () {
      final low = Biomarker(
        id: '1',
        reportId: 'r1',
        patientId: 'p1',
        name: 'Haemoglobin',
        value: 10.0,
        unit: 'g/dL',
        normalMin: 12.0,
        normalMax: 17.0,
        recordedAt: DateTime.now(),
      );

      expect(low.isLow, true);
      expect(low.isHigh, false);
      expect(low.isNormal, false);
      expect(low.statusLabel, 'Low');

      final high = low.copyWith(value: 20.0);
      expect(high.isHigh, true);
      expect(high.statusLabel, 'High');

      final normal = low.copyWith(value: 14.0);
      expect(normal.isNormal, true);
      expect(normal.statusLabel, 'Normal');
    });
  });
}
