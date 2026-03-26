import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Doctor', () {
    test('fromJson and toJson round-trip', () {
      final json = {
        'id': 'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
        'auth_id': 'auth-doc-001',
        'full_name': 'Dr. Priya Sharma',
        'specialization': 'Cardiology',
        'hospital_id': 'h1b2c3d4-e5f6-7890-abcd-ef1234567890',
        'license_number': 'MCI-2024-78901',
        'verified': true,
        'phone': '+919876543210',
        'email': 'priya.sharma@hospital.com',
        'avatar_url': 'https://cdn.example.com/avatars/doc1.png',
        'created_at': '2024-03-01T10:00:00.000',
        'updated_at': '2024-06-15T14:30:00.000',
      };

      final doctor = Doctor.fromJson(json);

      expect(doctor.id, 'a1b2c3d4-e5f6-7890-abcd-ef1234567890');
      expect(doctor.authId, 'auth-doc-001');
      expect(doctor.fullName, 'Dr. Priya Sharma');
      expect(doctor.specialization, 'Cardiology');
      expect(doctor.hospitalId, 'h1b2c3d4-e5f6-7890-abcd-ef1234567890');
      expect(doctor.licenseNumber, 'MCI-2024-78901');
      expect(doctor.verified, true);
      expect(doctor.phone, '+919876543210');
      expect(doctor.email, 'priya.sharma@hospital.com');
      expect(doctor.avatarUrl, 'https://cdn.example.com/avatars/doc1.png');

      final serialized = doctor.toJson();
      final roundTripped = Doctor.fromJson(serialized);
      expect(roundTripped, doctor);
    });

    test('copyWith creates modified copy', () {
      final doctor = Doctor(
        id: 'doc-1',
        fullName: 'Dr. Arjun Mehta',
        licenseNumber: 'MCI-2024-12345',
      );

      final updated = doctor.copyWith(
        specialization: 'Neurology',
        verified: true,
      );

      expect(updated.specialization, 'Neurology');
      expect(updated.verified, true);
      expect(updated.id, 'doc-1');
      expect(updated.fullName, 'Dr. Arjun Mehta');
      expect(updated.licenseNumber, 'MCI-2024-12345');
    });

    test('defaults are applied', () {
      final doctor = Doctor(
        id: 'doc-1',
        fullName: 'Dr. Test',
        licenseNumber: 'LIC-001',
      );

      expect(doctor.verified, false);
      expect(doctor.authId, isNull);
      expect(doctor.specialization, isNull);
      expect(doctor.hospitalId, isNull);
      expect(doctor.phone, isNull);
      expect(doctor.email, isNull);
      expect(doctor.avatarUrl, isNull);
      expect(doctor.createdAt, isNull);
      expect(doctor.updatedAt, isNull);
    });
  });
}
