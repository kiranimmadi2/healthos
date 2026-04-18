import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_client/supabase_client.dart';

import '../../../providers/patient_provider.dart';

final notificationRepoProvider = Provider<NotificationRepository>(
  (ref) => NotificationRepository(),
);

final realtimeServiceProvider = Provider<RealtimeService>(
  (ref) => RealtimeService(),
);

/// Stream provider that fetches notifications initially, then re-fetches
/// whenever a new notification is inserted via Supabase Realtime.
final patientNotificationsProvider = StreamProvider<List<AppNotification>>((ref) async* {
  final patient = await ref.watch(currentPatientProvider.future);
  if (patient == null) {
    yield [];
    return;
  }

  final repo = ref.watch(notificationRepoProvider);
  final realtime = ref.watch(realtimeServiceProvider);

  // Initial fetch
  final initial = await repo.getByPatientId(patient.id);
  yield initial;

  // Listen for realtime inserts and re-fetch the full list
  final controller = StreamController<List<AppNotification>>();

  final channel = realtime.subscribeToTable(
    table: SupabaseTables.notifications,
    filterColumn: 'patient_id',
    filterValue: patient.id,
    onInsert: (_) async {
      final updated = await repo.getByPatientId(patient.id);
      if (!controller.isClosed) {
        controller.add(updated);
      }
    },
    onUpdate: (_) async {
      final updated = await repo.getByPatientId(patient.id);
      if (!controller.isClosed) {
        controller.add(updated);
      }
    },
  );

  // Clean up the realtime subscription when the provider is disposed
  ref.onDispose(() {
    realtime.unsubscribe(channel);
    controller.close();
  });

  yield* controller.stream;
});

/// Unread count that automatically updates when the notifications stream changes.
final unreadNotificationCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(patientNotificationsProvider).valueOrNull ?? [];
  return notifications.where((n) => n.readAt == null).length;
});
