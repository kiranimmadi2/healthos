import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/user_repository.dart';
import 'auth_providers.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(FirebaseFirestore.instance);
});

/// Full user document for the signed-in user, backed by real-time updates and persistent local caching.
final userProfileProvider = StreamProvider<Map<String, dynamic>?>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(null);

  return ref.watch(userRepositoryProvider).watchUserData(user.uid);
});

final userRoleProvider = Provider<AsyncValue<String?>>((ref) {
  final profileAsync = ref.watch(userProfileProvider);
  return profileAsync.whenData((data) => data?['role'] as String?);
});

final allPatientsProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(userRepositoryProvider).watchPatients();
});
