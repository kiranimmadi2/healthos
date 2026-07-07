import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/user_repository.dart';
import 'auth_providers.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(FirebaseFirestore.instance);
});

/// Full Firestore user document for the signed-in user.
final userProfileProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return null;

  return ref.watch(userRepositoryProvider).getUserData(user.uid);
});

final userRoleProvider = FutureProvider<String?>((ref) async {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return null;

  final data = await ref.watch(userRepositoryProvider).getUserData(user.uid);
  return data?['role'] as String?;
});

final allPatientsProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(userRepositoryProvider).watchPatients();
});
