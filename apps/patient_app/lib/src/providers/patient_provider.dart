import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_client/supabase_client.dart';

import 'auth_provider.dart';

final patientRepositoryProvider = Provider<PatientRepository>(
  (ref) => PatientRepository(),
);

final currentPatientProvider = FutureProvider<Patient?>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return null;

  final repo = ref.watch(patientRepositoryProvider);
  return repo.getByAuthId(userId);
});
