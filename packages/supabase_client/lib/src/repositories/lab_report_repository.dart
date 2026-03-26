import 'package:core/core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../client_initializer.dart';

class LabReportRepository {
  SupabaseClient get _client => SupabaseClientInitializer.client;

  Future<List<LabReport>> getByPatientId(
    String patientId, {
    int limit = 20,
    int offset = 0,
    String? reportType,
  }) async {
    var query = _client
        .from(SupabaseTables.labReports)
        .select()
        .eq('patient_id', patientId);

    if (reportType != null) {
      query = query.eq('report_type', reportType);
    }

    final response = await query
        .order('report_date', ascending: false)
        .range(offset, offset + limit - 1);
    return response.map((e) => LabReport.fromJson(e)).toList();
  }

  Future<LabReport?> getById(String id) async {
    final response = await _client
        .from(SupabaseTables.labReports)
        .select()
        .eq('id', id)
        .maybeSingle();
    if (response == null) return null;
    return LabReport.fromJson(response);
  }

  Future<LabReport> create(Map<String, dynamic> data) async {
    final response = await _client
        .from(SupabaseTables.labReports)
        .insert(data)
        .select()
        .single();
    return LabReport.fromJson(response);
  }

  Future<LabReport> update(String id, Map<String, dynamic> data) async {
    final response = await _client
        .from(SupabaseTables.labReports)
        .update(data)
        .eq('id', id)
        .select()
        .single();
    return LabReport.fromJson(response);
  }

  Future<List<LabReport>> getAll({
    int limit = 50,
    int offset = 0,
    String? status,
  }) async {
    var query = _client.from(SupabaseTables.labReports).select();
    if (status != null) {
      query = query.eq('status', status);
    }
    final response = await query
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);
    return response.map((e) => LabReport.fromJson(e)).toList();
  }

  Future<List<String>> getReportTypes(String patientId) async {
    final response = await _client
        .from(SupabaseTables.labReports)
        .select('report_type')
        .eq('patient_id', patientId);
    final types = response.map((e) => e['report_type'] as String).toSet();
    return types.toList()..sort();
  }
}
