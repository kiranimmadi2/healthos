import 'package:core/core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../client_initializer.dart';
import 'repository_logger.dart';

class AccessGrantRepository with RepositoryLogger {
  SupabaseClient get _client => SupabaseClientInitializer.client;

  Future<List<AccessGrant>> getByPatientId(String patientId) => loggedOp(
        'getByPatientId(patientId=$patientId)',
        () async {
          final response = await _client
              .from(SupabaseTables.accessGrants)
              .select()
              .eq('patient_id', patientId)
              .order('granted_at', ascending: false);
          return response.map((e) => AccessGrant.fromJson(e)).toList();
        },
      );

  Future<List<AccessGrant>> getActiveByPatientId(String patientId) => loggedOp(
        'getActiveByPatientId(patientId=$patientId)',
        () async {
          final response = await _client
              .from(SupabaseTables.accessGrants)
              .select()
              .eq('patient_id', patientId)
              .eq('status', 'active')
              .order('granted_at', ascending: false);
          return response.map((e) => AccessGrant.fromJson(e)).toList();
        },
      );

  Future<List<AccessGrant>> getByDoctorId(String doctorId) => loggedOp(
        'getByDoctorId(doctorId=$doctorId)',
        () async {
          final response = await _client
              .from(SupabaseTables.accessGrants)
              .select()
              .eq('doctor_id', doctorId)
              .eq('status', 'active')
              .order('granted_at', ascending: false);
          return response.map((e) => AccessGrant.fromJson(e)).toList();
        },
      );

  Future<AccessGrant> grant({
    required String patientId,
    required String doctorId,
    String? hospitalId,
    String accessLevel = 'read',
    DateTime? expiresAt,
  }) =>
      loggedOp(
        'grant(patientId=$patientId, doctorId=$doctorId)',
        () async {
          final response = await _client
              .from(SupabaseTables.accessGrants)
              .upsert({
                'patient_id': patientId,
                'doctor_id': doctorId,
                'hospital_id': hospitalId,
                'access_level': accessLevel,
                'status': 'active',
                'granted_at': DateTime.now().toIso8601String(),
                'expires_at': expiresAt?.toIso8601String(),
              }, onConflict: 'patient_id,doctor_id')
              .select()
              .single();
          return AccessGrant.fromJson(response);
        },
      );

  Future<void> revoke(String grantId) => loggedOp(
        'revoke(grantId=$grantId)',
        () async {
          await _client.from(SupabaseTables.accessGrants).update({
            'status': 'revoked',
            'revoked_at': DateTime.now().toIso8601String(),
          }).eq('id', grantId);
        },
      );

  Future<bool> hasAccess({
    required String patientId,
    required String doctorId,
  }) =>
      loggedOp(
        'hasAccess(patientId=$patientId, doctorId=$doctorId)',
        () async {
          final response = await _client
              .from(SupabaseTables.accessGrants)
              .select('id')
              .eq('patient_id', patientId)
              .eq('doctor_id', doctorId)
              .eq('status', 'active')
              .maybeSingle();
          return response != null;
        },
      );
}
