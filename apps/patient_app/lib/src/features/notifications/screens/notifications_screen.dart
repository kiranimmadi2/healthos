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
    final unread = ref.watch(unreadNotificationCountProvider);

    return Scaffold(
      appBar: AppBar(
        leading: HosIconButton(
          icon: HosIcons.back,
          onPressed: () => context.pop(),
        ),
        title: Row(
          children: [
            const Text('Notifications'),
            if (unread > 0) ...[
              const SizedBox(width: AppSpacing.sm),
              HosStatusChip(
                label: '$unread new',
                color: AppColors.primary,
                icon: HosIcons.notificationsActive,
              ),
            ],
          ],
        ),
        actions: [
          if (unread > 0)
            HosButton.tertiary(
              label: 'Mark all',
              icon: HosIcons.success,
              size: HosButtonSize.sm,
              onPressed: () async {
                final patient = await ref.read(currentPatientProvider.future);
                if (patient == null) return;
                final repo = ref.read(notificationRepoProvider);
                await repo.markAllAsReadForPatient(patient.id);
                ref.invalidate(patientNotificationsProvider);
                ref.invalidate(unreadNotificationCountProvider);
              },
            ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: notificationsAsync.when(
        loading: () => ListView(
          padding: AppSpacing.screenPadding,
          children: const [
            HosSkeletonListTile(),
            HosSkeletonListTile(),
            HosSkeletonListTile(),
            HosSkeletonListTile(),
          ],
        ),
        error: (error, _) => HosError(
          message: error.toString(),
          onRetry: () => ref.invalidate(patientNotificationsProvider),
        ),
        data: (notifications) {
          if (notifications.isEmpty) {
            return const HosEmptyState(
              icon: HosIcons.notifications,
              title: 'You\'re all caught up',
              message: 'Appointment reminders, lab alerts, and doctor '
                  'messages will appear here.',
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(patientNotificationsProvider);
              ref.invalidate(unreadNotificationCountProvider);
            },
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: AppSpacing.screenPadding,
              itemCount: notifications.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return Dismissible(
                  key: ValueKey(notification.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius:
                          BorderRadius.circular(AppSpacing.borderRadius),
                    ),
                    child: const Icon(HosIcons.delete,
                        color: AppColors.error, size: HosIcons.sizeMd),
                  ),
                  onDismissed: (_) async {
                    final repo = ref.read(notificationRepoProvider);
                    await repo.markAsRead(notification.id);
                    ref.invalidate(patientNotificationsProvider);
                    ref.invalidate(unreadNotificationCountProvider);
                  },
                  child: NotificationTile(
                    notification: notification,
                    onTap: () async {
                      if (notification.readAt == null) {
                        final repo = ref.read(notificationRepoProvider);
                        await repo.markAsRead(notification.id);
                        ref.invalidate(patientNotificationsProvider);
                        ref.invalidate(unreadNotificationCountProvider);
                      }
                      if (notification.actionRoute != null &&
                          context.mounted) {
                        context.go(notification.actionRoute!);
                      }
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
