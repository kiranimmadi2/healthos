import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/user_repository.dart';
import '../domain/user_profile.dart';
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

/// Typed view of [userProfileProvider].
///
/// Prefer this over the raw map. The map provider is kept while screens are
/// converted; both are backed by the same stream, so there is no extra read.
final currentUserProfileProvider = Provider<AsyncValue<UserProfile?>>((ref) {
  final user = ref.watch(authStateProvider).value;
  return ref.watch(userProfileProvider).whenData((data) {
    if (data == null || user == null) return null;
    return UserProfile.fromMap(user.uid, data);
  });
});

final userRoleProvider = Provider<AsyncValue<String?>>((ref) {
  final profileAsync = ref.watch(userProfileProvider);
  return profileAsync.whenData((data) => data?['role'] as String?);
});

final allPatientsProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(userRepositoryProvider).watchPatients();
});
