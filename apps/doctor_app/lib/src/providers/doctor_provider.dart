import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_client/supabase_client.dart';

import 'auth_provider.dart';

final doctorRepositoryProvider = Provider<DoctorRepository>((ref) {
  return DoctorRepository();
});

/// Provides the current doctor profile based on the authenticated user's auth ID.
final currentDoctorProvider = FutureProvider<Doctor?>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return null;

  final repo = ref.read(doctorRepositoryProvider);
  return repo.getByAuthId(userId);
});

/// Provides the current doctor's ID for convenience.
final currentDoctorIdProvider = Provider<String?>((ref) {
  return ref.watch(currentDoctorProvider).valueOrNull?.id;
});
