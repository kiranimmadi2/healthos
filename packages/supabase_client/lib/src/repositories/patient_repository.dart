import 'package:core/core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../client_initializer.dart';
import 'repository_logger.dart';

class PatientRepository with RepositoryLogger {
  SupabaseClient get _client => SupabaseClientInitializer.client;

  Future<Patient?> getByAuthId(String authId) => loggedOp(
        'getByAuthId(authId=$authId)',
        () async {
          final response = await _client
              .from(SupabaseTables.patients)
              .select()
              .eq('auth_id', authId)
              .maybeSingle();
          if (response == null) return null;
          return Patient.fromJson(response);
        },
      );

  Future<Patient?> getById(String id) => loggedOp(
        'getById(id=$id)',
        () async {
          final response = await _client
              .from(SupabaseTables.patients)
              .select()
              .eq('id', id)
              .maybeSingle();
          if (response == null) return null;
          return Patient.fromJson(response);
        },
      );

  Future<Patient?> getByHealthId(String healthId) => loggedOp(
        'getByHealthId(healthId=$healthId)',
        () async {
          final response = await _client
              .from(SupabaseTables.patients)
              .select()
              .eq('health_id', healthId)
              .maybeSingle();
          if (response == null) return null;
          return Patient.fromJson(response);
        },
      );

  Future<Patient> create(Map<String, dynamic> data) => loggedOp(
        'create',
        () async {
          final response = await _client
              .from(SupabaseTables.patients)
              .insert(data)
              .select()
              .single();
          return Patient.fromJson(response);
        },
      );

  Future<Patient> update(String id, Map<String, dynamic> data) => loggedOp(
        'update(id=$id)',
        () async {
          final response = await _client
              .from(SupabaseTables.patients)
              .update(data)
              .eq('id', id)
              .select()
              .single();
          return Patient.fromJson(response);
        },
      );

  Future<List<Patient>> search(String query, {int limit = 20}) => loggedOp(
        'search(query=$query)',
        () async {
          final response = await _client
              .from(SupabaseTables.patients)
              .select()
              .or('full_name.ilike.%$query%,health_id.ilike.%$query%,phone.ilike.%$query%')
              .limit(limit);
          return response.map((e) => Patient.fromJson(e)).toList();
        },
      );
}
