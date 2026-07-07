import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_providers.dart';
import '../data/record_repository.dart';
import '../domain/medical_record.dart';

final recordRepositoryProvider = Provider(
  (ref) => RecordRepository(FirebaseFirestore.instance),
);

final medicalRecordsProvider = StreamProvider<List<MedicalRecord>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(const []);
  return ref.watch(recordRepositoryProvider).watchRecords(user.uid);
});

final patientRecordsProvider = StreamProvider.family<List<MedicalRecord>, String>((ref, patientId) {
  if (patientId.isEmpty) return Stream.value(const []);
  return ref.watch(recordRepositoryProvider).watchRecords(patientId);
});

final allRecordsProvider = StreamProvider<List<MedicalRecord>>((ref) {
  return ref.watch(recordRepositoryProvider).watchAllRecords();
});
