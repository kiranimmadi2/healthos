import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_client/supabase_client.dart';

import '../../../providers/doctor_provider.dart';

final prescriptionRepoProvider = Provider<PrescriptionRepository>(
  (ref) => PrescriptionRepository(),
);

final doctorPrescriptionsProvider = FutureProvider<List<Prescription>>((ref) async {
  final doctor = await ref.watch(currentDoctorProvider.future);
  if (doctor == null) return [];

  final repo = ref.watch(prescriptionRepoProvider);
  return repo.getByDoctorId(doctor.id);
});
