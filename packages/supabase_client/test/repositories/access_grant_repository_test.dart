import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_client/supabase_client.dart';

void main() {
  group('AccessGrant.fromJson', () {
    test('parses a fully-populated active grant', () {
      final json = <String, dynamic>{
        'id': 'ag-001',
        'patient_id': 'p-001',
        'doctor_id': 'd-001',
        'hospital_id': 'h-001',
        'status': 'active',
        'access_level': 'read',
        'granted_at': '2025-03-01T10:00:00.000Z',
        'revoked_at': null,
        'expires_at': '2025-06-01T10:00:00.000Z',
      };

      final grant = AccessGrant.fromJson(json);

      expect(grant.id, 'ag-001');
      expect(grant.patientId, 'p-001');
      expect(grant.doctorId, 'd-001');
      expect(grant.hospitalId, 'h-001');
      expect(grant.status, 'active');
      expect(grant.accessLevel, 'read');
      expect(grant.grantedAt, DateTime.utc(2025, 3, 1, 10));
      expect(grant.revokedAt, isNull);
      expect(grant.expiresAt, DateTime.utc(2025, 6, 1, 10));
    });

    test('parses a revoked grant', () {
      final json = <String, dynamic>{
        'id': 'ag-002',
        'patient_id': 'p-001',
        'doctor_id': 'd-002',
        'status': 'revoked',
        'access_level': 'read',
        'granted_at': '2025-01-15T08:00:00.000Z',
        'revoked_at': '2025-02-20T16:00:00.000Z',
      };

      final grant = AccessGrant.fromJson(json);

      expect(grant.status, 'revoked');
      expect(grant.revokedAt, DateTime.utc(2025, 2, 20, 16));
    });

    test('parses JSON with only required fields', () {
      final json = <String, dynamic>{
        'id': 'ag-003',
        'patient_id': 'p-002',
        'doctor_id': 'd-003',
      };

      final grant = AccessGrant.fromJson(json);

      expect(grant.id, 'ag-003');
      expect(grant.patientId, 'p-002');
      expect(grant.doctorId, 'd-003');
      expect(grant.hospitalId, isNull);
      expect(grant.status, 'active');
      expect(grant.accessLevel, 'read');
      expect(grant.grantedAt, isNull);
      expect(grant.revokedAt, isNull);
      expect(grant.expiresAt, isNull);
    });

    test('defaults status to active and access_level to read', () {
      final json = <String, dynamic>{
        'id': 'ag-004',
        'patient_id': 'p-003',
        'doctor_id': 'd-004',
      };

      final grant = AccessGrant.fromJson(json);

      expect(grant.status, 'active');
      expect(grant.accessLevel, 'read');
    });

    test('parses write access level', () {
      final json = <String, dynamic>{
        'id': 'ag-005',
        'patient_id': 'p-004',
        'doctor_id': 'd-005',
        'access_level': 'write',
        'status': 'active',
      };

      final grant = AccessGrant.fromJson(json);
      expect(grant.accessLevel, 'write');
    });

    test('handles explicit null optional fields', () {
      final json = <String, dynamic>{
        'id': 'ag-006',
        'patient_id': 'p-005',
        'doctor_id': 'd-006',
        'hospital_id': null,
        'granted_at': null,
        'revoked_at': null,
        'expires_at': null,
      };

      final grant = AccessGrant.fromJson(json);

      expect(grant.hospitalId, isNull);
      expect(grant.grantedAt, isNull);
      expect(grant.revokedAt, isNull);
      expect(grant.expiresAt, isNull);
    });

    test('roundtrip: toJson then fromJson preserves data', () {
      final original = AccessGrant(
        id: 'ag-007',
        patientId: 'p-006',
        doctorId: 'd-007',
        hospitalId: 'h-002',
        status: 'active',
        accessLevel: 'read',
        grantedAt: DateTime.utc(2025, 3, 25, 9),
        expiresAt: DateTime.utc(2025, 9, 25, 9),
      );

      final rebuilt = AccessGrant.fromJson(original.toJson());

      expect(rebuilt.id, original.id);
      expect(rebuilt.patientId, original.patientId);
      expect(rebuilt.doctorId, original.doctorId);
      expect(rebuilt.hospitalId, original.hospitalId);
      expect(rebuilt.status, original.status);
      expect(rebuilt.accessLevel, original.accessLevel);
      expect(rebuilt.grantedAt, original.grantedAt);
      expect(rebuilt.expiresAt, original.expiresAt);
      expect(rebuilt.revokedAt, isNull);
    });
  });

  group('AccessGrantRepository instantiation', () {
    test('AccessGrantRepository can be constructed', () {
      final repo = AccessGrantRepository();
      expect(repo, isNotNull);
    });
  });
}
