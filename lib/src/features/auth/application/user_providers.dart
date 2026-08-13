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

/// Typed view of [userProfileProvider]. Prefer this over the raw map.
///
/// Both are backed by the same stream, so reading this costs nothing extra.
/// The uid comes from the document itself, falling back to the signed-in user;
/// depending on the auth stream here would blank out a cached profile whenever
/// auth had not yet resolved, which defeats the offline cache in
/// [UserRepository] and makes the provider awkward to test.
final currentUserProfileProvider = Provider<AsyncValue<UserProfile?>>((ref) {
  final fallbackUid = ref.watch(authStateProvider).value?.uid ?? '';
  return ref.watch(userProfileProvider).whenData((data) {
    if (data == null) return null;
    return UserProfile.fromMap(fallbackUid, data);
  });
});

final userRoleProvider = Provider<AsyncValue<String?>>((ref) {
  return ref.watch(currentUserProfileProvider).whenData(
        (profile) => profile?.role.isEmpty ?? true ? null : profile!.role,
      );
});

/// Every user with the patient role, as typed profiles.
///
/// TODO(phase-10b): this streams every patient in the database to any doctor.
/// It should be scoped to the doctor's own patients once appointments carry a
/// care-team link.
final allPatientsProvider = StreamProvider<List<UserProfile>>((ref) {
  return ref.watch(userRepositoryProvider).watchPatients().map(
        (patients) => patients
            .map((data) => UserProfile.fromMap(data['uid'] as String? ?? '', data))
            .toList(),
      );
});
