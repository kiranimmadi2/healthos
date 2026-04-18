import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_client/supabase_client.dart';

import '../../../providers/patient_provider.dart';

final appointmentRepoProvider = Provider<AppointmentRepository>(
  (ref) => AppointmentRepository(),
);

final upcomingAppointmentsProvider = FutureProvider<List<Appointment>>((ref) async {
  final patient = await ref.watch(currentPatientProvider.future);
  if (patient == null) return [];

  final repo = ref.watch(appointmentRepoProvider);
  return repo.getUpcoming(patient.id);
});

final allAppointmentsProvider = FutureProvider<List<Appointment>>((ref) async {
  final patient = await ref.watch(currentPatientProvider.future);
  if (patient == null) return [];

  final repo = ref.watch(appointmentRepoProvider);
  return repo.getByPatientId(patient.id);
});
