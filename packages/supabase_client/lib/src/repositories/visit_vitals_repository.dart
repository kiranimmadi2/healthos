import 'package:core/core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../client_initializer.dart';

class VisitVitalsRepository {
  SupabaseClient get _client => SupabaseClientInitializer.client;

  Future<VisitVitals?> getByVisitId(String visitId) async {
    final response = await _client
        .from(SupabaseTables.visitVitals)
        .select()
        .eq('visit_id', visitId)
        .maybeSingle();
    if (response == null) return null;
    return VisitVitals.fromJson(response);
  }

  Future<List<VisitVitals>> getByPatientId(
    String patientId, {
    int limit = 20,
    int offset = 0,
  }) async {
    final response = await _client
        .from(SupabaseTables.visitVitals)
        .select()
        .eq('patient_id', patientId)
        .order('recorded_at', ascending: false)
        .range(offset, offset + limit - 1);
    return response.map((e) => VisitVitals.fromJson(e)).toList();
  }

  Future<VisitVitals> create(Map<String, dynamic> data) async {
    final response = await _client
        .from(SupabaseTables.visitVitals)
        .insert(data)
        .select()
        .single();
    return VisitVitals.fromJson(response);
  }
}
