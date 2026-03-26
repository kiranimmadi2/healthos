import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Medication', () {
    test('fromJson and toJson round-trip', () {
      final json = {
        'name': 'Amoxicillin',
        'dose': '500mg',
        'frequency': 'Twice daily',
        'duration': '7 days',
        'instructions': 'Take after meals',
      };

      final med = Medication.fromJson(json);

      expect(med.name, 'Amoxicillin');
      expect(med.dose, '500mg');
      expect(med.frequency, 'Twice daily');
      expect(med.duration, '7 days');
      expect(med.instructions, 'Take after meals');

      final serialized = med.toJson();
      final roundTripped = Medication.fromJson(serialized);
      expect(roundTripped, med);
    });

    test('defaults are applied', () {
      final med = Medication(
        name: 'Paracetamol',
        dose: '650mg',
        frequency: 'As needed',
      );

      expect(med.duration, isNull);
      expect(med.instructions, isNull);
    });
  });

  group('Prescription', () {
    test('fromJson and toJson round-trip', () {
      final json = {
        'id': 'rx-12345678-abcd-ef01-2345-678901234567',
        'patient_id': 'p1-12345678-abcd-ef01-2345-678901234567',
        'visit_id': 'v1-12345678-abcd-ef01-2345-678901234567',
        'doctor_id': 'd1-12345678-abcd-ef01-2345-678901234567',
        'medications': [
          {
            'name': 'Amoxicillin',
            'dose': '500mg',
            'frequency': 'Twice daily',
            'duration': '7 days',
            'instructions': 'Take after meals',
          },
          {
            'name': 'Ibuprofen',
            'dose': '400mg',
            'frequency': 'Three times daily',
            'duration': '5 days',
            'instructions': 'Take with food',
          },
        ],
        'issued_at': '2024-09-15T15:00:00.000',
        'valid_until': '2024-10-15T15:00:00.000',
        'notes': 'Complete the full course of antibiotics.',
        'created_at': '2024-09-15T15:00:00.000',
      };

      final prescription = Prescription.fromJson(json);

      expect(prescription.id, 'rx-12345678-abcd-ef01-2345-678901234567');
      expect(prescription.patientId,
          'p1-12345678-abcd-ef01-2345-678901234567');
      expect(
          prescription.visitId, 'v1-12345678-abcd-ef01-2345-678901234567');
      expect(
          prescription.doctorId, 'd1-12345678-abcd-ef01-2345-678901234567');
      expect(prescription.medications, hasLength(2));
      expect(prescription.medications[0].name, 'Amoxicillin');
      expect(prescription.medications[1].name, 'Ibuprofen');
      expect(prescription.issuedAt,
          DateTime.parse('2024-09-15T15:00:00.000'));
      expect(prescription.validUntil,
          DateTime.parse('2024-10-15T15:00:00.000'));
      expect(prescription.notes, 'Complete the full course of antibiotics.');

      final serialized = prescription.toJson();
      final roundTripped = Prescription.fromJson(serialized);
      expect(roundTripped, prescription);
    });

    test('copyWith creates modified copy', () {
      final prescription = Prescription(
        id: 'rx-1',
        patientId: 'p-1',
        medications: [
          Medication(name: 'Aspirin', dose: '75mg', frequency: 'Once daily'),
        ],
        issuedAt: DateTime(2024, 9, 15),
      );

      final updated = prescription.copyWith(
        notes: 'Updated instructions',
        validUntil: DateTime(2025, 3, 15),
      );

      expect(updated.notes, 'Updated instructions');
      expect(updated.validUntil, DateTime(2025, 3, 15));
      expect(updated.id, 'rx-1');
      expect(updated.medications, hasLength(1));
      expect(updated.medications[0].name, 'Aspirin');
    });

    test('defaults are applied', () {
      final prescription = Prescription(
        id: 'rx-1',
        patientId: 'p-1',
        medications: [],
        issuedAt: DateTime(2024, 9, 15),
      );

      expect(prescription.visitId, isNull);
      expect(prescription.doctorId, isNull);
      expect(prescription.validUntil, isNull);
      expect(prescription.notes, isNull);
      expect(prescription.createdAt, isNull);
    });

    test('empty medications list', () {
      final prescription = Prescription(
        id: 'rx-1',
        patientId: 'p-1',
        medications: [],
        issuedAt: DateTime(2024, 9, 15),
      );

      expect(prescription.medications, isEmpty);
    });
  });
}
