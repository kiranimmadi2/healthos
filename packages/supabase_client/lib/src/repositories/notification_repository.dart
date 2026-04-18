import 'package:core/core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../client_initializer.dart';
import 'repository_logger.dart';

class NotificationRepository with RepositoryLogger {
  SupabaseClient get _client => SupabaseClientInitializer.client;

  Future<List<AppNotification>> getByPatientId(
    String patientId, {
    int limit = 50,
    int offset = 0,
  }) =>
      loggedOp(
        'getByPatientId(patientId=$patientId)',
        () async {
          final response = await _client
              .from(SupabaseTables.notifications)
              .select()
              .eq('patient_id', patientId)
              .order('created_at', ascending: false)
              .range(offset, offset + limit - 1);
          return response.map((e) => AppNotification.fromJson(e)).toList();
        },
      );

  Future<List<AppNotification>> getByDoctorId(
    String doctorId, {
    int limit = 50,
    int offset = 0,
  }) =>
      loggedOp(
        'getByDoctorId(doctorId=$doctorId)',
        () async {
          final response = await _client
              .from(SupabaseTables.notifications)
              .select()
              .eq('doctor_id', doctorId)
              .order('created_at', ascending: false)
              .range(offset, offset + limit - 1);
          return response.map((e) => AppNotification.fromJson(e)).toList();
        },
      );

  Future<int> getUnreadCountForPatient(String patientId) => loggedOp(
        'getUnreadCountForPatient(patientId=$patientId)',
        () async {
          final response = await _client
              .from(SupabaseTables.notifications)
              .select()
              .eq('patient_id', patientId)
              .isFilter('read_at', null);
          return response.length;
        },
      );

  Future<int> getUnreadCountForDoctor(String doctorId) => loggedOp(
        'getUnreadCountForDoctor(doctorId=$doctorId)',
        () async {
          final response = await _client
              .from(SupabaseTables.notifications)
              .select()
              .eq('doctor_id', doctorId)
              .isFilter('read_at', null);
          return response.length;
        },
      );

  Future<void> markAsRead(String id) => loggedOp(
        'markAsRead(id=$id)',
        () async {
          await _client
              .from(SupabaseTables.notifications)
              .update({'read_at': DateTime.now().toIso8601String()})
              .eq('id', id);
        },
      );

  Future<void> markAllAsReadForPatient(String patientId) => loggedOp(
        'markAllAsReadForPatient(patientId=$patientId)',
        () async {
          await _client
              .from(SupabaseTables.notifications)
              .update({'read_at': DateTime.now().toIso8601String()})
              .eq('patient_id', patientId)
              .isFilter('read_at', null);
        },
      );

  Future<void> markAllAsReadForDoctor(String doctorId) => loggedOp(
        'markAllAsReadForDoctor(doctorId=$doctorId)',
        () async {
          await _client
              .from(SupabaseTables.notifications)
              .update({'read_at': DateTime.now().toIso8601String()})
              .eq('doctor_id', doctorId)
              .isFilter('read_at', null);
        },
      );
}
