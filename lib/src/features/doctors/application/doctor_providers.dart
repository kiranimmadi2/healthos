import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/doctor_repository.dart';
import '../domain/doctor_profile.dart';

final doctorRepositoryProvider = Provider(
  (ref) => DoctorRepository(FirebaseFirestore.instance),
);

final availableDoctorsProvider = StreamProvider<List<DoctorProfile>>((ref) {
  return ref.watch(doctorRepositoryProvider).watchAvailableDoctors();
});
