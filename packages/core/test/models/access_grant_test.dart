import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AccessGrant', () {
    test('fromJson and toJson round-trip', () {
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
  });
}
