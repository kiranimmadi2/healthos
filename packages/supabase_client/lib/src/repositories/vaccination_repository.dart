import 'package:core/core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../client_initializer.dart';
import 'repository_logger.dart';

class VaccinationRepository with RepositoryLogger {
  SupabaseClient get _client => SupabaseClientInitializer.client;

  Future<List<Vaccination>> getForPatient(String patientId) => loggedOp(
        'getForPatient(patientId=$patientId)',
        () async {
          final response = await _client
              .from(SupabaseTables.vaccinations)
              .select()
              .eq('patient_id', patientId)
              .order('date_given', ascending: false);
          return response.map((e) => Vaccination.fromJson(e)).toList();
        },
      );

  Future<List<Vaccination>> getUpcomingDue(String patientId) => loggedOp(
        'getUpcomingDue(patientId=$patientId)',
        () async {
          final today = DateTime.now()
              .toIso8601String()
              .split('T')
              .first;
          final response = await _client
              .from(SupabaseTables.vaccinations)
              .select()
              .eq('patient_id', patientId)
              .gte('next_due', today)
              .order('next_due', ascending: true);
          return response.map((e) => Vaccination.fromJson(e)).toList();
        },
      );

  Future<Vaccination?> getById(String id) => loggedOp(
        'getById(id=$id)',
        () async {
          final response = await _client
              .from(SupabaseTables.vaccinations)
              .select()
              .eq('id', id)
              .maybeSingle();
          if (response == null) return null;
          return Vaccination.fromJson(response);
        },
      );

  Future<Vaccination> create(Map<String, dynamic> data) => loggedOp(
        'create',
        () async {
          final response = await _client
              .from(SupabaseTables.vaccinations)
              .insert(data)
              .select()
              .single();
          return Vaccination.fromJson(response);
        },
      );

  Future<Vaccination> update(String id, Map<String, dynamic> data) => loggedOp(
        'update(id=$id)',
        () async {
          final response = await _client
              .from(SupabaseTables.vaccinations)
              .update(data)
              .eq('id', id)
              .select()
              .single();
          return Vaccination.fromJson(response);
        },
      );

  Future<void> delete(String id) => loggedOp(
        'delete(id=$id)',
        () async {
          await _client
              .from(SupabaseTables.vaccinations)
              .delete()
              .eq('id', id);
        },
      );
}
