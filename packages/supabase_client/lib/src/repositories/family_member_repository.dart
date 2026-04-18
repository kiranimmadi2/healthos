import 'package:core/core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../client_initializer.dart';

class FamilyMemberRepository {
  SupabaseClient get _client => SupabaseClientInitializer.client;

  Future<List<FamilyMember>> getByPrimaryPatient(String primaryPatientId) async {
    final response = await _client
        .from(SupabaseTables.familyMembers)
        .select()
        .eq('primary_patient_id', primaryPatientId)
        .order('created_at', ascending: true);
    return response.map((e) => FamilyMember.fromJson(e)).toList();
  }

  Future<FamilyMember?> getById(String id) async {
    final response = await _client
        .from(SupabaseTables.familyMembers)
        .select()
        .eq('id', id)
        .maybeSingle();
    if (response == null) return null;
    return FamilyMember.fromJson(response);
  }

  Future<FamilyMember> create(Map<String, dynamic> data) async {
    final response = await _client
        .from(SupabaseTables.familyMembers)
        .insert(data)
        .select()
        .single();
    return FamilyMember.fromJson(response);
  }

  Future<FamilyMember> update(String id, Map<String, dynamic> data) async {
    final response = await _client
        .from(SupabaseTables.familyMembers)
        .update(data)
        .eq('id', id)
        .select()
        .single();
    return FamilyMember.fromJson(response);
  }

  Future<void> delete(String id) async {
    await _client
        .from(SupabaseTables.familyMembers)
        .delete()
        .eq('id', id);
  }

  Future<FamilyMember> linkToPatient(String memberId, String linkedPatientId) async {
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
  }
}
