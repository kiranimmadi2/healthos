import 'package:core/core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../client_initializer.dart';
import 'repository_logger.dart';

class MedicationRepository with RepositoryLogger {
  SupabaseClient get _client => SupabaseClientInitializer.client;

  // ─── Schedules ─────────────────────────────────────────────────────────

  Future<List<MedicationSchedule>> getActiveForPatient(String patientId) =>
      loggedOp(
        'getActiveForPatient(patientId=$patientId)',
        () async {
          final response = await _client
              .from(SupabaseTables.medicationSchedules)
              .select()
              .eq('patient_id', patientId)
              .eq('is_active', true)
              .order('created_at', ascending: false);
          return response
              .map((e) => MedicationSchedule.fromJson(e))
              .toList();
        },
      );

  Future<MedicationSchedule?> getScheduleById(String id) => loggedOp(
        'getScheduleById(id=$id)',
        () async {
          final response = await _client
              .from(SupabaseTables.medicationSchedules)
              .select()
              .eq('id', id)
              .maybeSingle();
          if (response == null) return null;
          return MedicationSchedule.fromJson(response);
        },
      );

  Future<MedicationSchedule> createSchedule(Map<String, dynamic> data) =>
      loggedOp(
        'createSchedule',
        () async {
          final response = await _client
              .from(SupabaseTables.medicationSchedules)
              .insert(data)
              .select()
              .single();
          return MedicationSchedule.fromJson(response);
        },
      );

  Future<MedicationSchedule> updateSchedule(
    String id,
    Map<String, dynamic> data,
  ) =>
      loggedOp(
        'updateSchedule(id=$id)',
        () async {
          final response = await _client
              .from(SupabaseTables.medicationSchedules)
              .update(data)
              .eq('id', id)
              .select()
              .single();
          return MedicationSchedule.fromJson(response);
        },
      );

  Future<void> stopSchedule(String id) => loggedOp(
        'stopSchedule(id=$id)',
        () async {
          await _client
              .from(SupabaseTables.medicationSchedules)
              .update({
                'is_active': false,
                'ended_on':
                    DateTime.now().toIso8601String().split('T').first,
              })
              .eq('id', id);
        },
      );

  Future<void> deleteSchedule(String id) => loggedOp(
        'deleteSchedule(id=$id)',
        () async {
          await _client
              .from(SupabaseTables.medicationSchedules)
              .delete()
              .eq('id', id);
        },
      );

  // ─── Logs (dose taken / skipped) ───────────────────────────────────────

  Future<List<MedicationLog>> getLogsForSchedule(String scheduleId) => loggedOp(
        'getLogsForSchedule(scheduleId=$scheduleId)',
        () async {
          final response = await _client
              .from(SupabaseTables.medicationLogs)
              .select()
              .eq('schedule_id', scheduleId)
              .order('scheduled_at', ascending: false)
              .limit(200);
          return response.map((e) => MedicationLog.fromJson(e)).toList();
        },
      );

  Future<List<MedicationLog>> getLogsForDay(
    String patientId,
    DateTime day,
  ) =>
      loggedOp(
        'getLogsForDay(patientId=$patientId, day=$day)',
        () async {
          final start = DateTime(day.year, day.month, day.day);
          final end = start.add(const Duration(days: 1));
          final response = await _client
              .from(SupabaseTables.medicationLogs)
              .select()
              .eq('patient_id', patientId)
              .gte('scheduled_at', start.toIso8601String())
              .lt('scheduled_at', end.toIso8601String())
              .order('scheduled_at', ascending: true);
          return response.map((e) => MedicationLog.fromJson(e)).toList();
        },
      );

  Future<MedicationLog> logDose({
    required String scheduleId,
    required String patientId,
    required DateTime scheduledAt,
    required String status,
    String? note,
  }) =>
      loggedOp(
        'logDose(scheduleId=$scheduleId, status=$status)',
        () async {
          final response = await _client
              .from(SupabaseTables.medicationLogs)
              .insert({
                'schedule_id': scheduleId,
                'patient_id': patientId,
                'scheduled_at': scheduledAt.toIso8601String(),
                'taken_at': status == 'taken'
                    ? DateTime.now().toIso8601String()
                    : null,
                'status': status,
                'note': note,
              })
              .select()
              .single();
          return MedicationLog.fromJson(response);
        },
      );

  Future<MedicationLog> updateLog(
    String id,
    Map<String, dynamic> data,
  ) =>
      loggedOp(
        'updateLog(id=$id)',
        () async {
          final response = await _client
              .from(SupabaseTables.medicationLogs)
              .update(data)
              .eq('id', id)
              .select()
              .single();
          return MedicationLog.fromJson(response);
        },
      );
}
