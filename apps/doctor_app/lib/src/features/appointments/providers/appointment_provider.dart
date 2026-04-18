import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_client/supabase_client.dart';

import '../../../providers/doctor_provider.dart';

final appointmentRepoProvider = Provider<AppointmentRepository>(
  (ref) => AppointmentRepository(),
);

final doctorAppointmentsProvider = FutureProvider<List<Appointment>>((ref) async {
  final doctor = await ref.watch(currentDoctorProvider.future);
  if (doctor == null) return [];

  final repo = ref.watch(appointmentRepoProvider);
  return repo.getByDoctorId(doctor.id);
});

final doctorAppointmentsForDateProvider = FutureProvider.family<List<Appointment>, DateTime>((ref, date) async {
  final doctor = await ref.watch(currentDoctorProvider.future);
  if (doctor == null) return [];

  final repo = ref.watch(appointmentRepoProvider);
  return repo.getByDoctorIdForDate(doctor.id, date);
});

final doctorUpcomingAppointmentsProvider = FutureProvider<List<Appointment>>((ref) async {
  final doctor = await ref.watch(currentDoctorProvider.future);
  if (doctor == null) return [];

  final repo = ref.watch(appointmentRepoProvider);
  return repo.getUpcomingForDoctor(doctor.id);
});
