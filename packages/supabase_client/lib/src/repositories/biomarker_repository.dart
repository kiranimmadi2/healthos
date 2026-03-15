import 'package:core/core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../client_initializer.dart';

class BiomarkerRepository {
  SupabaseClient get _client => SupabaseClientInitializer.client;

  Future<List<Biomarker>> getByReportId(String reportId) async {
    final response = await _client
        .from(SupabaseTables.biomarkers)
        .select()
        .eq('report_id', reportId)
        .order('name');
    return response.map((e) => Biomarker.fromJson(e)).toList();
  }

  Future<List<Biomarker>> getTrend({
    required String patientId,
    required String biomarkerName,
    int limit = 20,
  }) async {
    final response = await _client
        .from(SupabaseTables.biomarkers)
        .select()
        .eq('patient_id', patientId)
        .eq('name', biomarkerName)
        .order('recorded_at', ascending: true)
        .limit(limit);
    return response.map((e) => Biomarker.fromJson(e)).toList();
  }

  Future<List<Biomarker>> getAbnormal(String patientId) async {
    final response = await _client
        .from(SupabaseTables.biomarkers)
        .select()
        .eq('patient_id', patientId)
        .eq('is_abnormal', true)
        .order('recorded_at', ascending: false);
    return response.map((e) => Biomarker.fromJson(e)).toList();
  }

  Future<List<String>> getDistinctNames(String patientId) async {
    final response = await _client
        .from(SupabaseTables.biomarkers)
        .select('name')
        .eq('patient_id', patientId);
    final names = response.map((e) => e['name'] as String).toSet();
    return names.toList()..sort();
  }

  Future<void> insertBatch(List<Map<String, dynamic>> biomarkers) async {
    await _client.from(SupabaseTables.biomarkers).insert(biomarkers);
  }
}
