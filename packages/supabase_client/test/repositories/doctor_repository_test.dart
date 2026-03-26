import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_client/supabase_client.dart';

void main() {
  group('Doctor.fromJson', () {
    test('parses a fully-populated JSON payload', () {
      final json = <String, dynamic>{
        'id': 'd-001',
        'auth_id': 'auth-doc-001',
        'full_name': 'Dr. Ananya Sharma',
        'specialization': 'Cardiology',
        'hospital_id': 'h-001',
        'license_number': 'MCI-12345',
        'verified': true,
        'phone': '+919876500000',
        'email': 'ananya@hospital.com',
        'avatar_url': 'https://storage.example.com/avatars/d-001.jpg',
        'created_at': '2025-02-01T10:00:00.000Z',
        'updated_at': '2025-03-15T12:00:00.000Z',
      };

      final doctor = Doctor.fromJson(json);

      expect(doctor.id, 'd-001');
      expect(doctor.authId, 'auth-doc-001');
      expect(doctor.fullName, 'Dr. Ananya Sharma');
      expect(doctor.specialization, 'Cardiology');
      expect(doctor.hospitalId, 'h-001');
      expect(doctor.licenseNumber, 'MCI-12345');
      expect(doctor.verified, isTrue);
      expect(doctor.phone, '+919876500000');
      expect(doctor.email, 'ananya@hospital.com');
      expect(doctor.avatarUrl, isNotNull);
      expect(doctor.createdAt, isNotNull);
      expect(doctor.updatedAt, isNotNull);
    });

    test('parses JSON with only required fields', () {
      final json = <String, dynamic>{
        'id': 'd-002',
        'full_name': 'Dr. Minimal',
        'license_number': 'MCI-99999',
      };

      final doctor = Doctor.fromJson(json);

      expect(doctor.id, 'd-002');
      expect(doctor.fullName, 'Dr. Minimal');
      expect(doctor.licenseNumber, 'MCI-99999');
      expect(doctor.authId, isNull);
      expect(doctor.specialization, isNull);
      expect(doctor.hospitalId, isNull);
      expect(doctor.verified, isFalse);
      expect(doctor.phone, isNull);
      expect(doctor.email, isNull);
      expect(doctor.avatarUrl, isNull);
      expect(doctor.createdAt, isNull);
      expect(doctor.updatedAt, isNull);
    });

    test('defaults verified to false when absent', () {
      final json = <String, dynamic>{
        'id': 'd-003',
        'full_name': 'Dr. Unverified',
        'license_number': 'MCI-00001',
      };

      final doctor = Doctor.fromJson(json);
      expect(doctor.verified, isFalse);
    });

    test('handles null optional fields explicitly', () {
      final json = <String, dynamic>{
        'id': 'd-004',
        'full_name': 'Dr. Null Fields',
        'license_number': 'MCI-00002',
        'auth_id': null,
        'specialization': null,
        'hospital_id': null,
        'phone': null,
        'email': null,
        'avatar_url': null,
        'created_at': null,
        'updated_at': null,
      };

      final doctor = Doctor.fromJson(json);

      expect(doctor.authId, isNull);
      expect(doctor.specialization, isNull);
      expect(doctor.hospitalId, isNull);
      expect(doctor.phone, isNull);
      expect(doctor.email, isNull);
      expect(doctor.avatarUrl, isNull);
      expect(doctor.createdAt, isNull);
      expect(doctor.updatedAt, isNull);
    });

    test('roundtrip: toJson then fromJson preserves data', () {
      final original = Doctor(
        id: 'd-005',
        fullName: 'Dr. Roundtrip',
        licenseNumber: 'MCI-55555',
        specialization: 'Neurology',
        verified: true,
        email: 'roundtrip@test.com',
      );

      final rebuilt = Doctor.fromJson(original.toJson());

      expect(rebuilt.id, original.id);
      expect(rebuilt.fullName, original.fullName);
      expect(rebuilt.licenseNumber, original.licenseNumber);
      expect(rebuilt.specialization, original.specialization);
      expect(rebuilt.verified, original.verified);
      expect(rebuilt.email, original.email);
    });
  });

  group('DoctorRepository instantiation', () {
    test('DoctorRepository can be constructed', () {
      final repo = DoctorRepository();
      expect(repo, isNotNull);
    });
  });
}
