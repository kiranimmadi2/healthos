import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_client/supabase_client.dart';

import '../../../providers/patient_provider.dart';

final vaccinationRepoProvider = Provider<VaccinationRepository>(
  (ref) => VaccinationRepository(),
);

final vaccinationsProvider =
    FutureProvider<List<Vaccination>>((ref) async {
  final patient = await ref.watch(currentPatientProvider.future);
  if (patient == null) return [];
  final repo = ref.watch(vaccinationRepoProvider);
  return repo.getForPatient(patient.id);
});

final upcomingVaccinationsProvider =
    FutureProvider<List<Vaccination>>((ref) async {
  final patient = await ref.watch(currentPatientProvider.future);
  if (patient == null) return [];
  final repo = ref.watch(vaccinationRepoProvider);
  return repo.getUpcomingDue(patient.id);
});
