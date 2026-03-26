import 'package:core/core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../client_initializer.dart';

class AppointmentRepository {
  SupabaseClient get _client => SupabaseClientInitializer.client;

  Future<List<Appointment>> getByPatientId(
    String patientId, {
    int limit = 20,
    int offset = 0,
  }) async {
    final response = await _client
        .from(SupabaseTables.appointments)
        .select()
        .eq('patient_id', patientId)
        .order('scheduled_at', ascending: false)
        .range(offset, offset + limit - 1);
    return response.map((e) => Appointment.fromJson(e)).toList();
  }

  Future<List<Appointment>> getByDoctorId(
    String doctorId, {
    int limit = 20,
    int offset = 0,
  }) async {
    final response = await _client
        .from(SupabaseTables.appointments)
        .select()
        .eq('doctor_id', doctorId)
        .order('scheduled_at', ascending: false)
        .range(offset, offset + limit - 1);
    return response.map((e) => Appointment.fromJson(e)).toList();
  }

  Future<List<Appointment>> getUpcoming(String patientId) async {
    final response = await _client
        .from(SupabaseTables.appointments)
        .select()
        .eq('patient_id', patientId)
        .gte('scheduled_at', DateTime.now().toIso8601String())
        .inFilter('status', ['scheduled', 'confirmed'])
        .order('scheduled_at');
    return response.map((e) => Appointment.fromJson(e)).toList();
  }

  Future<List<Appointment>> getUpcomingForDoctor(String doctorId) async {
    final response = await _client
        .from(SupabaseTables.appointments)
        .select()
        .eq('doctor_id', doctorId)
        .gte('scheduled_at', DateTime.now().toIso8601String())
        .inFilter('status', ['scheduled', 'confirmed'])
        .order('scheduled_at');
    return response.map((e) => Appointment.fromJson(e)).toList();
  }

  Future<List<Appointment>> getByDoctorIdForDate(
    String doctorId,
    DateTime date,
  ) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    final response = await _client
        .from(SupabaseTables.appointments)
        .select()
        .eq('doctor_id', doctorId)
        .gte('scheduled_at', startOfDay.toIso8601String())
        .lt('scheduled_at', endOfDay.toIso8601String())
        .order('scheduled_at');
    return response.map((e) => Appointment.fromJson(e)).toList();
  }

  Future<Appointment?> getById(String id) async {
    final response = await _client
        .from(SupabaseTables.appointments)
        .select()
        .eq('id', id)
        .maybeSingle();
    if (response == null) return null;
    return Appointment.fromJson(response);
  }

  Future<Appointment> create(Map<String, dynamic> data) async {
    final response = await _client
        .from(SupabaseTables.appointments)
        .insert(data)
        .select()
        .single();
    return Appointment.fromJson(response);
  }

  Future<Appointment> update(String id, Map<String, dynamic> data) async {
    final response = await _client
        .from(SupabaseTables.appointments)
        .update({...data, 'updated_at': DateTime.now().toIso8601String()})
        .eq('id', id)
        .select()
        .single();
    return Appointment.fromJson(response);
  }

  Future<void> cancel(String id) async {
    await _client
        .from(SupabaseTables.appointments)
        .update({
          'status': 'cancelled',
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', id);
  }
}
