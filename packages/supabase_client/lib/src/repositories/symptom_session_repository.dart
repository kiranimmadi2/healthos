import 'package:core/core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../client_initializer.dart';
import 'repository_logger.dart';

class SymptomSessionRepository with RepositoryLogger {
  SupabaseClient get _client => SupabaseClientInitializer.client;

  Future<List<SymptomSession>> getByPatientId(
    String patientId, {
    int limit = 20,
    int offset = 0,
  }) =>
      loggedOp(
        'getByPatientId(patientId=$patientId)',
        () async {
          final response = await _client
              .from(SupabaseTables.symptomSessions)
              .select()
              .eq('patient_id', patientId)
              .order('created_at', ascending: false)
              .range(offset, offset + limit - 1);
          return response.map((e) => SymptomSession.fromJson(e)).toList();
        },
      );

  Future<SymptomSession?> getById(String id) => loggedOp(
        'getById(id=$id)',
        () async {
          final response = await _client
              .from(SupabaseTables.symptomSessions)
              .select()
              .eq('id', id)
              .maybeSingle();
          if (response == null) return null;
          return SymptomSession.fromJson(response);
        },
      );

  Future<SymptomSession> create(Map<String, dynamic> data) => loggedOp(
        'create',
        () async {
          final response = await _client
              .from(SupabaseTables.symptomSessions)
              .insert(data)
              .select()
              .single();
          return SymptomSession.fromJson(response);
        },
      );
}
