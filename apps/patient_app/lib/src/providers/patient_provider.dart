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

enum PatientProfileState { loading, missing, exists }

/// Tri-state used by GoRouter redirect to handle Google OAuth → profile setup flow.
final patientProfileStateProvider = Provider<PatientProfileState>((ref) {
  final auth = ref.watch(authStateProvider);
  if (auth.isLoading) return PatientProfileState.loading;
  if (auth.valueOrNull == null) return PatientProfileState.missing;

  final patient = ref.watch(currentPatientProvider);
  if (patient.isLoading) return PatientProfileState.loading;
  if (patient.valueOrNull == null) return PatientProfileState.missing;
  return PatientProfileState.exists;
});
