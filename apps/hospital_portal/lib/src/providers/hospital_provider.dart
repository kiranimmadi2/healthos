import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_client/supabase_client.dart';

import 'auth_provider.dart';

final hospitalRepositoryProvider = Provider<HospitalRepository>((ref) {
  return HospitalRepository();
});

/// Provides the current hospital for the authenticated admin user.
///
/// Resolution order:
/// 1. Check auth user's app_metadata for hospital_id
/// 2. Match hospital by admin's email
/// 3. Fall back to the first hospital (single-tenant MVP)
final currentHospitalProvider = FutureProvider<Hospital?>((ref) async {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return null;

  final repo = ref.read(hospitalRepositoryProvider);

  // 1. Try app_metadata.hospital_id (set via Supabase dashboard or edge fn)
  final hospitalId = user.appMetadata['hospital_id'] as String?;
  if (hospitalId != null) {
    final hospital = await repo.getById(hospitalId);
    if (hospital != null) return hospital;
  }

  // 2. Try matching by email
  final email = user.email;
  if (email != null) {
    final hospital = await repo.getByEmail(email);
    if (hospital != null) return hospital;
  }

  // 3. Fall back to first hospital (single-tenant MVP)
  return repo.getFirst();
});

/// Convenience provider for the current hospital's ID.
final currentHospitalIdProvider = Provider<String?>((ref) {
  return ref.watch(currentHospitalProvider).valueOrNull?.id;
});
