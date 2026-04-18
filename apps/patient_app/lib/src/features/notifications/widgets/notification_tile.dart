import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';

class NotificationTile extends StatelessWidget {
  const NotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
  });

  final AppNotification notification;
  final VoidCallback onTap;

  IconData get _icon {
    switch (notification.type) {
      case 'report_ready':
        return HosIcons.labReport;
      case 'access_granted':
        return HosIcons.share;
      case 'appointment_reminder':
        return HosIcons.appointment;
      case 'medication_reminder':
        return HosIcons.prescription;
      default:
        return HosIcons.notifications;
    }
  }

  Color get _color {
    switch (notification.type) {
      case 'report_ready':
        return AppColors.secondary;
      case 'access_granted':
        return AppColors.warning;
      case 'appointment_reminder':
        return AppColors.info;
      default:
        return AppColors.primary;
    }
  }

  bool get _isUnread => notification.readAt == null;

  @override
  Widget build(BuildContext context) {
    return HosCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: _color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.borderRadiusSm),
            ),
            child: Icon(_icon, color: _color, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  style: AppTypography.label.copyWith(
                    fontWeight: _isUnread ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
                Text(
                  notification.body,
                  style: AppTypography.caption,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (notification.createdAt != null)
                  Text(
                    AppDateUtils.formatDate(notification.createdAt!),
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
              ],
            ),
          ),
          if (_isUnread)
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}
