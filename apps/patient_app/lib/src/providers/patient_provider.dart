import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_client/supabase_client.dart';

import 'auth_provider.dart';

final patientRepositoryProvider = Provider<PatientRepository>(
  (ref) => PatientRepository(),
);

final currentPatientProvider = FutureProvider<Patient?>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  debugPrint('[PatientProvider] currentPatientProvider — userId=$userId');
  if (userId == null) return null;

  final repo = ref.watch(patientRepositoryProvider);
  final patient = await repo.getByAuthId(userId);
  debugPrint('[PatientProvider] getByAuthId result — id=${patient?.id} name=${patient?.fullName}');
  return patient;
});

enum PatientProfileState { loading, missing, exists }

/// Tri-state used by GoRouter redirect to handle Google OAuth → profile setup flow.
final patientProfileStateProvider = Provider<PatientProfileState>((ref) {
  final auth = ref.watch(authStateProvider);
  if (auth.isLoading) {
    debugPrint('[ProfileState] loading (auth loading)');
    return PatientProfileState.loading;
  }
  if (auth.valueOrNull == null) {
    debugPrint('[ProfileState] missing (no auth user)');
    return PatientProfileState.missing;
  }

  final patient = ref.watch(currentPatientProvider);
  if (patient.isLoading) {
    debugPrint('[ProfileState] loading (patient loading)');
    return PatientProfileState.loading;
  }
  if (patient.valueOrNull == null) {
    debugPrint('[ProfileState] missing (no patient profile)');
    return PatientProfileState.missing;
  }
  debugPrint('[ProfileState] exists — patientId=${patient.value?.id}');
  return PatientProfileState.exists;
});
