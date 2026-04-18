import 'package:core/core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../client_initializer.dart';
import 'repository_logger.dart';

class HospitalRepository with RepositoryLogger {
  SupabaseClient get _client => SupabaseClientInitializer.client;

  Future<Hospital?> getById(String id) => loggedOp(
        'getById(id=$id)',
        () async {
          final response = await _client
              .from(SupabaseTables.hospitals)
              .select()
              .eq('id', id)
              .maybeSingle();
          if (response == null) return null;
          return Hospital.fromJson(response);
        },
      );

  Future<Hospital?> getByEmail(String email) => loggedOp(
        'getByEmail(email=$email)',
        () async {
          final response = await _client
              .from(SupabaseTables.hospitals)
              .select()
              .eq('email', email)
              .maybeSingle();
          if (response == null) return null;
          return Hospital.fromJson(response);
        },
      );

  /// Returns the first hospital — useful for single-tenant MVP setups.
  Future<Hospital?> getFirst() => loggedOp(
        'getFirst',
        () async {
          final response = await _client
              .from(SupabaseTables.hospitals)
              .select()
              .limit(1)
              .maybeSingle();
          if (response == null) return null;
          return Hospital.fromJson(response);
        },
      );

  Future<List<Hospital>> getAll({int limit = 50}) => loggedOp(
        'getAll(limit=$limit)',
        () async {
          final response = await _client
              .from(SupabaseTables.hospitals)
              .select()
              .order('name')
              .limit(limit);
          return response.map((e) => Hospital.fromJson(e)).toList();
        },
      );

  Future<Hospital> update(String id, Map<String, dynamic> data) => loggedOp(
        'update(id=$id)',
        () async {
          final response = await _client
              .from(SupabaseTables.hospitals)
              .update(data)
              .eq('id', id)
              .select()
              .single();
          return Hospital.fromJson(response);
        },
      );
}
