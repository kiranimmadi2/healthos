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

class DoctorCategoryNotifier extends Notifier<String> {
  @override
  String build() => 'All';

  void setCategory(String category) {
    state = category;
  }
}

final selectedDoctorCategoryProvider =
    NotifierProvider<DoctorCategoryNotifier, String>(DoctorCategoryNotifier.new);

class DoctorQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String query) {
    state = query;
  }
}

final selectedDoctorQueryProvider =
    NotifierProvider<DoctorQueryNotifier, String>(DoctorQueryNotifier.new);


