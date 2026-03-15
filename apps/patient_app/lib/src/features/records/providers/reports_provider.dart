import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_client/supabase_client.dart';

import '../../../providers/patient_provider.dart';

final labReportRepositoryProvider = Provider<LabReportRepository>(
  (ref) => LabReportRepository(),
);

final biomarkerRepositoryProvider = Provider<BiomarkerRepository>(
  (ref) => BiomarkerRepository(),
);

final patientReportsProvider = FutureProvider<List<LabReport>>((ref) async {
  final patient = await ref.watch(currentPatientProvider.future);
  if (patient == null) return [];

  final repo = ref.watch(labReportRepositoryProvider);
  return repo.getByPatientId(patient.id);
});

final reportBiomarkersProvider =
    FutureProvider.family<List<Biomarker>, String>((ref, reportId) async {
  final repo = ref.watch(biomarkerRepositoryProvider);
  return repo.getByReportId(reportId);
});

final biomarkerTrendProvider =
    FutureProvider.family<List<Biomarker>, String>((ref, biomarkerName) async {
  final patient = await ref.watch(currentPatientProvider.future);
  if (patient == null) return [];

  final repo = ref.watch(biomarkerRepositoryProvider);
  return repo.getTrend(patientId: patient.id, biomarkerName: biomarkerName);
});
