import 'package:core/core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../client_initializer.dart';

class DoctorNoteRepository {
  SupabaseClient get _client => SupabaseClientInitializer.client;

  Future<List<DoctorNote>> getByPatientId(
    String patientId, {
    bool includePrivate = true,
    int limit = 50,
    int offset = 0,
  }) async {
    var query = _client
        .from(SupabaseTables.doctorNotes)
        .select()
        .eq('patient_id', patientId);
    if (!includePrivate) query = query.eq('is_private', false);
    final response = await query
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);
    return response.map((e) => DoctorNote.fromJson(e)).toList();
  }

  Future<DoctorNote> create(Map<String, dynamic> data) async {
    final response = await _client
        .from(SupabaseTables.doctorNotes)
        .insert(data)
        .select()
        .single();
    return DoctorNote.fromJson(response);
  }

  Future<DoctorNote> update(String id, Map<String, dynamic> data) async {
    final response = await _client
        .from(SupabaseTables.doctorNotes)
        .update(data)
        .eq('id', id)
        .select()
        .single();
    return DoctorNote.fromJson(response);
  }

  Future<void> delete(String id) async {
    await _client
        .from(SupabaseTables.doctorNotes)
        .delete()
        .eq('id', id);
  }
}
