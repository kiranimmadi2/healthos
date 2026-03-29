import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Appointment', () {
    final json = {
      'id': 'apt-12345678-abcd-ef01-2345-678901234567',
      'patient_id': 'p1-12345678-abcd-ef01-2345-678901234567',
      'doctor_id': 'd1-12345678-abcd-ef01-2345-678901234567',
      'hospital_id': 'h1-12345678-abcd-ef01-2345-678901234567',
      'scheduled_at': '2024-11-10T10:00:00.000',
      'duration_minutes': 45,
      'status': 'confirmed',
      'reason': 'Follow-up for blood pressure management',
      'notes': 'Patient requested morning slot.',
      'created_at': '2024-10-25T12:00:00.000',
      'updated_at': '2024-10-28T09:00:00.000',
    };

    test('fromJson parses all fields correctly', () {
      final appointment = Appointment.fromJson(json);

      expect(appointment.id, 'apt-12345678-abcd-ef01-2345-678901234567');
      expect(appointment.patientId,
          'p1-12345678-abcd-ef01-2345-678901234567');
      expect(appointment.doctorId,
          'd1-12345678-abcd-ef01-2345-678901234567');
      expect(appointment.hospitalId,
          'h1-12345678-abcd-ef01-2345-678901234567');
      expect(appointment.scheduledAt,
          DateTime.parse('2024-11-10T10:00:00.000'));
      expect(appointment.durationMinutes, 45);
      expect(appointment.status, 'confirmed');
      expect(
          appointment.reason, 'Follow-up for blood pressure management');
      expect(appointment.notes, 'Patient requested morning slot.');
      expect(appointment.createdAt,
          DateTime.parse('2024-10-25T12:00:00.000'));
      expect(appointment.updatedAt,
          DateTime.parse('2024-10-28T09:00:00.000'));
    });

    test('fromJson and toJson round-trip', () {
      final appointment = Appointment.fromJson(json);
      final serialized = appointment.toJson();
      final roundTripped = Appointment.fromJson(serialized);
      expect(roundTripped, appointment);
    });

    test('copyWith creates modified copy', () {
      final appointment = Appointment(
        id: 'apt-1',
        patientId: 'p-1',
        doctorId: 'd-1',
        scheduledAt: DateTime(2024, 11, 10, 10, 0),
      );

      final updated = appointment.copyWith(
        status: 'cancelled',
        notes: 'Patient requested cancellation.',
        durationMinutes: 60,
      );

      expect(updated.status, 'cancelled');
      expect(updated.notes, 'Patient requested cancellation.');
      expect(updated.durationMinutes, 60);
      expect(updated.id, 'apt-1');
      expect(updated.patientId, 'p-1');
      expect(updated.doctorId, 'd-1');
      expect(updated.scheduledAt, DateTime(2024, 11, 10, 10, 0));
    });

    test('copyWith preserves all fields when none changed', () {
      final appointment = Appointment.fromJson(json);
      final copy = appointment.copyWith();
      expect(copy, appointment);
    });

    test('defaults are applied', () {
      final appointment = Appointment(
        id: 'apt-1',
        patientId: 'p-1',
        doctorId: 'd-1',
        scheduledAt: DateTime(2024, 11, 10),
      );

      expect(appointment.durationMinutes, 30);
      expect(appointment.status, 'scheduled');
      expect(appointment.hospitalId, isNull);
      expect(appointment.reason, isNull);
      expect(appointment.notes, isNull);
      expect(appointment.createdAt, isNull);
      expect(appointment.updatedAt, isNull);
    });

    test('fromJson handles minimal JSON (only required fields)', () {
      final minimalJson = {
        'id': 'apt-min',
        'patient_id': 'p-min',
        'doctor_id': 'd-min',
        'scheduled_at': '2024-11-10T10:00:00.000',
      };

      final appointment = Appointment.fromJson(minimalJson);
      expect(appointment.id, 'apt-min');
      expect(appointment.patientId, 'p-min');
      expect(appointment.doctorId, 'd-min');
      expect(appointment.durationMinutes, 30);
      expect(appointment.status, 'scheduled');
      expect(appointment.hospitalId, isNull);
      expect(appointment.reason, isNull);
      expect(appointment.notes, isNull);
    });

    test('fromJson handles null optional fields explicitly', () {
      final jsonWithNulls = {
        'id': 'apt-null',
        'patient_id': 'p-null',
        'doctor_id': 'd-null',
        'scheduled_at': '2024-11-10T10:00:00.000',
        'hospital_id': null,
        'reason': null,
        'notes': null,
        'created_at': null,
        'updated_at': null,
      };

      final appointment = Appointment.fromJson(jsonWithNulls);
      expect(appointment.hospitalId, isNull);
      expect(appointment.reason, isNull);
      expect(appointment.notes, isNull);
      expect(appointment.createdAt, isNull);
      expect(appointment.updatedAt, isNull);
    });

    test('different status values are preserved', () {
      final completedJson = {
        'id': 'apt-completed',
        'patient_id': 'p-1',
        'doctor_id': 'd-1',
        'scheduled_at': '2024-11-10T10:00:00.000',
        'status': 'completed',
      };

      final appointment = Appointment.fromJson(completedJson);
      expect(appointment.status, 'completed');
    });

    test('custom duration_minutes from JSON', () {
      final customDurationJson = {
        'id': 'apt-dur',
        'patient_id': 'p-1',
        'doctor_id': 'd-1',
        'scheduled_at': '2024-11-10T10:00:00.000',
        'duration_minutes': 90,
      };

      final appointment = Appointment.fromJson(customDurationJson);
      expect(appointment.durationMinutes, 90);
    });
  });
}
