import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_client/supabase_client.dart';

import 'patient_provider.dart';

final familyMemberRepoProvider = Provider<FamilyMemberRepository>(
  (ref) => FamilyMemberRepository(),
);

final familyMembersProvider = FutureProvider<List<FamilyMember>>((ref) async {
  final patient = await ref.watch(currentPatientProvider.future);
  if (patient == null) return [];
  return ref.read(familyMemberRepoProvider).getByPrimaryPatient(patient.id);
});

final familyMemberByIdProvider =
    FutureProvider.family<FamilyMember?, String>((ref, memberId) async {
  return ref.read(familyMemberRepoProvider).getById(memberId);
});

/// Tracks which family member an appointment is being booked for.
/// null = booking for the primary patient (self).
final selectedBookingMemberProvider = StateProvider<FamilyMember?>((ref) => null);
