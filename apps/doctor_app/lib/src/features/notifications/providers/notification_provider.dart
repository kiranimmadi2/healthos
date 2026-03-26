import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_client/supabase_client.dart';

import '../../../providers/doctor_provider.dart';

final notificationRepoProvider = Provider<NotificationRepository>(
  (ref) => NotificationRepository(),
);

final doctorNotificationsProvider = FutureProvider<List<AppNotification>>((ref) async {
  final doctor = await ref.watch(currentDoctorProvider.future);
  if (doctor == null) return [];

  final repo = ref.watch(notificationRepoProvider);
  return repo.getByDoctorId(doctor.id);
});

final doctorUnreadCountProvider = FutureProvider<int>((ref) async {
  final doctor = await ref.watch(currentDoctorProvider.future);
  if (doctor == null) return 0;

  final repo = ref.watch(notificationRepoProvider);
  return repo.getUnreadCountForDoctor(doctor.id);
});
