import 'package:core/core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../client_initializer.dart';
import 'repository_logger.dart';

class FamilyMemberRepository with RepositoryLogger {
  SupabaseClient get _client => SupabaseClientInitializer.client;

  Future<List<FamilyMember>> getByPrimaryPatient(String primaryPatientId) =>
      loggedOp(
        'getByPrimaryPatient(primaryPatientId=$primaryPatientId)',
        () async {
          final response = await _client
              .from(SupabaseTables.familyMembers)
              .select()
              .eq('primary_patient_id', primaryPatientId)
              .order('created_at', ascending: true);
          return response.map((e) => FamilyMember.fromJson(e)).toList();
        },
      );

  Future<FamilyMember?> getById(String id) => loggedOp(
        'getById(id=$id)',
        () async {
          final response = await _client
              .from(SupabaseTables.familyMembers)
              .select()
              .eq('id', id)
              .maybeSingle();
          if (response == null) return null;
          return FamilyMember.fromJson(response);
        },
      );

  Future<FamilyMember> create(Map<String, dynamic> data) => loggedOp(
        'create',
        () async {
          final response = await _client
              .from(SupabaseTables.familyMembers)
              .insert(data)
              .select()
              .single();
          return FamilyMember.fromJson(response);
        },
      );

  Future<FamilyMember> update(String id, Map<String, dynamic> data) => loggedOp(
        'update(id=$id)',
        () async {
          final response = await _client
              .from(SupabaseTables.familyMembers)
              .update(data)
              .eq('id', id)
              .select()
              .single();
          return FamilyMember.fromJson(response);
        },
      );

  Future<void> delete(String id) => loggedOp(
        'delete(id=$id)',
        () async {
          await _client.from(SupabaseTables.familyMembers).delete().eq('id', id);
        },
      );

  Future<FamilyMember> linkToPatient(String memberId, String linkedPatientId) =>
      loggedOp(
        'linkToPatient(memberId=$memberId, linkedPatientId=$linkedPatientId)',
        () async {
          final response = await _client
              .from(SupabaseTables.familyMembers)
              .update({
                'member_patient_id': linkedPatientId,
                'invite_status': 'linked',
                'linked_at': DateTime.now().toIso8601String(),
              })
              .eq('id', memberId)
              .select()
              .single();
          return FamilyMember.fromJson(response);
        },
      );
}
