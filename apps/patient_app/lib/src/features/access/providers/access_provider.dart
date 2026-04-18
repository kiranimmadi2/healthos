import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_client/supabase_client.dart';

import '../../../providers/patient_provider.dart';

final accessGrantRepoProvider = Provider<AccessGrantRepository>(
  (ref) => AccessGrantRepository(),
);

final doctorRepositoryProvider = Provider<DoctorRepository>(
  (ref) => DoctorRepository(),
);

final activeGrantsProvider = FutureProvider<List<AccessGrant>>((ref) async {
  final patient = await ref.watch(currentPatientProvider.future);
  if (patient == null) return [];

  final repo = ref.watch(accessGrantRepoProvider);
  return repo.getActiveByPatientId(patient.id);
});

final doctorByIdProvider = FutureProvider.family<Doctor?, String>((ref, doctorId) async {
  final repo = ref.watch(doctorRepositoryProvider);
  return repo.getById(doctorId);
});

final doctorSearchResultsProvider = FutureProvider.family<List<Doctor>, String>((ref, query) async {
  if (query.trim().length < 2) return [];
  final repo = ref.watch(doctorRepositoryProvider);
  return repo.search(query.trim());
});
