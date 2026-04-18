import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AccessGrant', () {
    final json = {
      'id': 'ag-12345678-abcd-ef01-2345-678901234567',
      'patient_id': 'p1-12345678-abcd-ef01-2345-678901234567',
      'doctor_id': 'd1-12345678-abcd-ef01-2345-678901234567',
      'hospital_id': 'h1-12345678-abcd-ef01-2345-678901234567',
      'status': 'active',
      'access_level': 'write',
      'granted_at': '2024-06-01T09:00:00.000',
      'revoked_at': null,
      'expires_at': '2025-06-01T09:00:00.000',
    };

    test('fromJson parses all fields correctly', () {
      final grant = AccessGrant.fromJson(json);

      expect(grant.id, 'ag-12345678-abcd-ef01-2345-678901234567');
      expect(grant.patientId, 'p1-12345678-abcd-ef01-2345-678901234567');
      expect(grant.doctorId, 'd1-12345678-abcd-ef01-2345-678901234567');
      expect(grant.hospitalId, 'h1-12345678-abcd-ef01-2345-678901234567');
      expect(grant.status, 'active');
      expect(grant.accessLevel, 'write');
      expect(grant.grantedAt, DateTime.parse('2024-06-01T09:00:00.000'));
      expect(grant.revokedAt, isNull);
      expect(grant.expiresAt, DateTime.parse('2025-06-01T09:00:00.000'));
    });

    test('fromJson and toJson round-trip', () {
      final grant = AccessGrant.fromJson(json);
      final serialized = grant.toJson();
      final roundTripped = AccessGrant.fromJson(serialized);
      expect(roundTripped, grant);
    });

    test('copyWith creates modified copy', () {
      final grant = AccessGrant(
        id: 'ag-1',
        patientId: 'p-1',
        doctorId: 'd-1',
      );

      final revoked = grant.copyWith(
        status: 'revoked',
        revokedAt: DateTime(2024, 12, 1),
      );

      expect(revoked.status, 'revoked');
      expect(revoked.revokedAt, DateTime(2024, 12, 1));
      expect(revoked.id, 'ag-1');
      expect(revoked.patientId, 'p-1');
      expect(revoked.doctorId, 'd-1');
    });

    test('copyWith preserves all fields when none changed', () {
      final grant = AccessGrant.fromJson(json);
      final copy = grant.copyWith();
      expect(copy, grant);
    });

    test('defaults are applied', () {
      final grant = AccessGrant(
        id: 'ag-1',
        patientId: 'p-1',
        doctorId: 'd-1',
      );

      expect(grant.status, 'active');
      expect(grant.accessLevel, 'read');
      expect(grant.hospitalId, isNull);
      expect(grant.grantedAt, isNull);
      expect(grant.revokedAt, isNull);
      expect(grant.expiresAt, isNull);
    });

    test('fromJson handles minimal JSON (only required fields)', () {
      final minimalJson = {
        'id': 'ag-min',
        'patient_id': 'p-min',
        'doctor_id': 'd-min',
      };

      final grant = AccessGrant.fromJson(minimalJson);
      expect(grant.id, 'ag-min');
      expect(grant.patientId, 'p-min');
      expect(grant.doctorId, 'd-min');
      expect(grant.status, 'active');
      expect(grant.accessLevel, 'read');
    });

    test('fromJson handles null optional fields explicitly', () {
      final jsonWithNulls = {
        'id': 'ag-null',
        'patient_id': 'p-null',
        'doctor_id': 'd-null',
        'hospital_id': null,
        'granted_at': null,
        'revoked_at': null,
        'expires_at': null,
      };

      final grant = AccessGrant.fromJson(jsonWithNulls);
      expect(grant.hospitalId, isNull);
      expect(grant.grantedAt, isNull);
      expect(grant.revokedAt, isNull);
      expect(grant.expiresAt, isNull);
    });

    test('different status values are preserved', () {
      final revokedJson = {
        'id': 'ag-revoked',
        'patient_id': 'p-1',
        'doctor_id': 'd-1',
        'status': 'revoked',
        'access_level': 'admin',
      };

      final grant = AccessGrant.fromJson(revokedJson);
      expect(grant.status, 'revoked');
      expect(grant.accessLevel, 'admin');
    });
  });
}
