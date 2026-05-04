import 'package:core/core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../client_initializer.dart';
import 'repository_logger.dart';

class PrescriptionRepository with RepositoryLogger {
  SupabaseClient get _client => SupabaseClientInitializer.client;

  Future<List<Prescription>> getByPatientId(
    String patientId, {
    int limit = 20,
    int offset = 0,
  }) =>
      loggedOp(
        'getByPatientId(patientId=$patientId)',
        () async {
          final response = await _client
              .from(SupabaseTables.prescriptions)
              .select()
              .eq('patient_id', patientId)
              .order('issued_at', ascending: false)
              .range(offset, offset + limit - 1);
          return response.map((e) => Prescription.fromJson(e)).toList();
        },
      );

  Future<List<Prescription>> getByDoctorId(
    String doctorId, {
    int limit = 50,
    int offset = 0,
  }) =>
      loggedOp(
        'getByDoctorId(doctorId=$doctorId)',
        () async {
          final response = await _client
              .from(SupabaseTables.prescriptions)
              .select()
              .eq('doctor_id', doctorId)
              .order('issued_at', ascending: false)
              .range(offset, offset + limit - 1);
          return response.map((e) => Prescription.fromJson(e)).toList();
        },
      );

  Future<Prescription?> getById(String id) => loggedOp(
        'getById(id=$id)',
        () async {
          final response = await _client
              .from(SupabaseTables.prescriptions)
              .select()
              .eq('id', id)
              .maybeSingle();
          if (response == null) return null;
          return Prescription.fromJson(response);
        },
      );

  Future<Prescription> create(Map<String, dynamic> data) => loggedOp(
        'create',
        () async {
          final response = await _client
              .from(SupabaseTables.prescriptions)
              .insert(data)
              .select()
              .single();
          return Prescription.fromJson(response);
        },
      );

  Future<List<Prescription>> getActive(String patientId) => loggedOp(
        'getActive(patientId=$patientId)',
        () async {
          final now = DateTime.now().toIso8601String();
          final response = await _client
              .from(SupabaseTables.prescriptions)
              .select()
              .eq('patient_id', patientId)
              .or('valid_until.is.null,valid_until.gte.$now')
              .order('issued_at', ascending: false);
          return response.map((e) => Prescription.fromJson(e)).toList();
        },
      );
}
