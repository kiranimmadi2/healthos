import 'package:core/core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../client_initializer.dart';
import 'repository_logger.dart';

class DoctorRepository with RepositoryLogger {
  SupabaseClient get _client => SupabaseClientInitializer.client;

  Future<Doctor?> getByAuthId(String authId) => loggedOp(
        'getByAuthId(authId=$authId)',
        () async {
          final response = await _client
              .from(SupabaseTables.doctors)
              .select()
              .eq('auth_id', authId)
              .maybeSingle();
          if (response == null) return null;
          return Doctor.fromJson(response);
        },
      );

  Future<Doctor?> getById(String id) => loggedOp(
        'getById(id=$id)',
        () async {
          final response = await _client
              .from(SupabaseTables.doctors)
              .select()
              .eq('id', id)
              .maybeSingle();
          if (response == null) return null;
          return Doctor.fromJson(response);
        },
      );

  Future<Doctor> create(Map<String, dynamic> data) => loggedOp(
        'create',
        () async {
          final response = await _client
              .from(SupabaseTables.doctors)
              .insert(data)
              .select()
              .single();
          return Doctor.fromJson(response);
        },
      );

  Future<Doctor> update(String id, Map<String, dynamic> data) => loggedOp(
        'update(id=$id)',
        () async {
          final response = await _client
              .from(SupabaseTables.doctors)
              .update(data)
              .eq('id', id)
              .select()
              .single();
          return Doctor.fromJson(response);
        },
      );

  Future<List<Doctor>> getByHospitalId(String hospitalId) => loggedOp(
        'getByHospitalId(hospitalId=$hospitalId)',
        () async {
          final response = await _client
              .from(SupabaseTables.doctors)
              .select()
              .eq('hospital_id', hospitalId)
              .order('full_name');
          return response.map((e) => Doctor.fromJson(e)).toList();
        },
      );

  Future<List<Doctor>> search(String query, {int limit = 20}) => loggedOp(
        'search(query=$query)',
        () async {
          final response = await _client
              .from(SupabaseTables.doctors)
              .select()
              .or('full_name.ilike.%$query%,license_number.ilike.%$query%,specialization.ilike.%$query%')
              .limit(limit);
          return response.map((e) => Doctor.fromJson(e)).toList();
        },
      );
}
