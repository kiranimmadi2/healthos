import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_client/supabase_client.dart';

import '../../../providers/patient_provider.dart';

final notificationRepoProvider = Provider<NotificationRepository>(
  (ref) => NotificationRepository(),
);

final patientNotificationsProvider = FutureProvider<List<AppNotification>>((ref) async {
  final patient = await ref.watch(currentPatientProvider.future);
  if (patient == null) return [];

  final repo = ref.watch(notificationRepoProvider);
  return repo.getByPatientId(patient.id);
});

final unreadNotificationCountProvider = FutureProvider<int>((ref) async {
  final patient = await ref.watch(currentPatientProvider.future);
  if (patient == null) return 0;

  final repo = ref.watch(notificationRepoProvider);
  return repo.getUnreadCountForPatient(patient.id);
});
