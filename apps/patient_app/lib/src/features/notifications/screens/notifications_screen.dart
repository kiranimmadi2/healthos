import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../../providers/patient_provider.dart';
import '../providers/notifications_provider.dart';
import '../widgets/notification_tile.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(patientNotificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () async {
              final patient = await ref.read(currentPatientProvider.future);
              if (patient == null) return;
              final repo = ref.read(notificationRepoProvider);
              await repo.markAllAsReadForPatient(patient.id);
              ref.invalidate(patientNotificationsProvider);
              ref.invalidate(unreadNotificationCountProvider);
            },
            child: const Text('Mark all read'),
          ),
        ],
      ),
      body: notificationsAsync.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return const HosEmptyState(
              message: 'No notifications yet',
              icon: Icons.notifications_none,
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(patientNotificationsProvider);
            },
            child: ListView.separated(
              padding: AppSpacing.screenPadding,
              itemCount: notifications.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return NotificationTile(
                  notification: notification,
                  onTap: () async {
                    if (notification.readAt == null) {
                      final repo = ref.read(notificationRepoProvider);
                      await repo.markAsRead(notification.id);
                      ref.invalidate(patientNotificationsProvider);
                      ref.invalidate(unreadNotificationCountProvider);
                    }
                    if (notification.actionRoute != null && context.mounted) {
                      context.go(notification.actionRoute!);
                    }
                  },
                );
              },
            ),
          );
        },
        loading: () => const HosLoading(),
        error: (error, _) => HosError(
          message: error.toString(),
          onRetry: () => ref.invalidate(patientNotificationsProvider),
        ),
      ),
    );
  }
}
