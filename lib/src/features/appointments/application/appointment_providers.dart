import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_providers.dart';
import '../data/appointment_repository.dart';
import '../domain/appointment.dart';

final appointmentRepositoryProvider = Provider(
  (ref) => AppointmentRepository(FirebaseFirestore.instance),
);

/// Appointments where the signed-in user is the patient, sorted ascending.
final patientAppointmentsProvider = StreamProvider<List<Appointment>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(const []);
  return ref.watch(appointmentRepositoryProvider).watchForPatient(user.uid);
});

/// Appointments where the signed-in user is the doctor, sorted ascending.
final doctorAppointmentsProvider = StreamProvider<List<Appointment>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(const []);
  return ref.watch(appointmentRepositoryProvider).watchForDoctor(user.uid);
});

final doctorScheduleProvider = StreamProvider.family<List<Appointment>, String>(
  (ref, doctorId) {
    if (doctorId.isEmpty) return Stream.value(const []);
    return ref.watch(appointmentRepositoryProvider).watchForDoctor(doctorId);
  },
);

final nextAppointmentProvider = Provider<AsyncValue<Appointment?>>((ref) {
  return ref.watch(patientAppointmentsProvider).whenData((appointments) {
    final upcoming = appointments.where((a) => a.isUpcoming).toList();
    return upcoming.isEmpty ? null : upcoming.first;
  });
});
