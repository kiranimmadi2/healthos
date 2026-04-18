import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_client/supabase_client.dart';

import '../../../providers/patient_provider.dart';

final patientDocumentRepoProvider = Provider<PatientDocumentRepository>(
  (ref) => PatientDocumentRepository(),
);

final patientDocumentsProvider =
    FutureProvider<List<PatientDocument>>((ref) async {
  final patient = await ref.watch(currentPatientProvider.future);
  if (patient == null) return [];
  final repo = ref.watch(patientDocumentRepoProvider);
  return repo.getForPatient(patient.id);
});
