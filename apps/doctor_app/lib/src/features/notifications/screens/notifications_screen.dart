import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../../providers/doctor_provider.dart';
import '../providers/notification_provider.dart';

class DoctorNotificationsScreen extends ConsumerWidget {
  const DoctorNotificationsScreen({super.key});

  IconData _typeIcon(String type) {
    switch (type) {
      case 'access_granted': return Icons.share;
      case 'appointment_request': return Icons.calendar_month;
      case 'report_ready': return Icons.science;
      default: return Icons.notifications;
    }
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'access_granted': return AppColors.warning;
      case 'appointment_request': return AppColors.info;
      case 'report_ready': return AppColors.secondary;
      default: return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(doctorNotificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () async {
              final doctor = await ref.read(currentDoctorProvider.future);
              if (doctor == null) return;
              final repo = ref.read(notificationRepoProvider);
              await repo.markAllAsReadForDoctor(doctor.id);
              ref.invalidate(doctorNotificationsProvider);
              ref.invalidate(doctorUnreadCountProvider);
            },
            child: const Text('Mark all read'),
          ),
        ],
      ),
      body: notificationsAsync.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return const HosEmptyState(
              message: 'No notifications',
              icon: Icons.notifications_none,
            );
          }
          return ListView.separated(
            padding: AppSpacing.screenPadding,
            itemCount: notifications.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final n = notifications[index];
              final isUnread = n.readAt == null;
              return HosCard(
                onTap: () async {
                  if (isUnread) {
                    final repo = ref.read(notificationRepoProvider);
                    await repo.markAsRead(n.id);
                    ref.invalidate(doctorNotificationsProvider);
                    ref.invalidate(doctorUnreadCountProvider);
                  }
                  if (n.actionRoute != null && context.mounted) {
                    context.go(n.actionRoute!);
                  }
                },
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: _typeColor(n.type).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppSpacing.borderRadiusSm),
                      ),
                      child: Icon(_typeIcon(n.type), color: _typeColor(n.type), size: 20),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(n.title, style: AppTypography.label.copyWith(
                            fontWeight: isUnread ? FontWeight.w700 : FontWeight.w500,
                          )),
                          Text(n.body, style: AppTypography.caption, maxLines: 2, overflow: TextOverflow.ellipsis),
                          if (n.createdAt != null)
                            Text(AppDateUtils.formatDate(n.createdAt!), style: AppTypography.caption.copyWith(color: AppColors.textTertiary)),
                        ],
                      ),
                    ),
                    if (isUnread)
                      Container(
                        width: 8, height: 8,
                        decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                      ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const HosLoading(),
        error: (error, _) => HosError(
          message: error.toString(),
          onRetry: () => ref.invalidate(doctorNotificationsProvider),
        ),
      ),
    );
  }
}
