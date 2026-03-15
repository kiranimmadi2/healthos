import 'package:core/core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../client_initializer.dart';

class VisitRepository {
  SupabaseClient get _client => SupabaseClientInitializer.client;

  Future<List<Visit>> getByPatientId(
    String patientId, {
    int limit = 20,
    int offset = 0,
  }) async {
    final response = await _client
        .from(SupabaseTables.visits)
        .select()
        .eq('patient_id', patientId)
        .order('visited_at', ascending: false)
        .range(offset, offset + limit - 1);
    return response.map((e) => Visit.fromJson(e)).toList();
  }

  Future<Visit?> getById(String id) async {
    final response = await _client
        .from(SupabaseTables.visits)
        .select()
        .eq('id', id)
        .maybeSingle();
    if (response == null) return null;
    return Visit.fromJson(response);
  }

  Future<Visit> create(Map<String, dynamic> data) async {
    final response = await _client
        .from(SupabaseTables.visits)
        .insert(data)
        .select()
        .single();
    return Visit.fromJson(response);
  }

  Future<Visit> update(String id, Map<String, dynamic> data) async {
    final response = await _client
        .from(SupabaseTables.visits)
        .update(data)
        .eq('id', id)
        .select()
        .single();
    return Visit.fromJson(response);
  }
}
