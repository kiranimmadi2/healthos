import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/theme.dart';
import '../../../shared/presentation/widgets/hos_states.dart';
import '../../appointments/application/appointment_providers.dart';
import '../../appointments/domain/appointment.dart';

/// A single thing worth telling the user about, derived from real data.
class HealthAlert {
  const HealthAlert({
    required this.icon,
    required this.title,
    required this.body,
    required this.time,
    required this.tint,
  });

  final IconData icon;
  final String title;
  final String body;
  final DateTime time;
  final Color tint;
}

/// Alerts for the signed-in patient, derived from their appointment stream.
///
/// Deliberately derived rather than stored: the app has no notifications
/// collection, and inventing one would mean showing counts that no data backs.
final patientAlertsProvider = Provider<AsyncValue<List<HealthAlert>>>((ref) {
  return ref.watch(patientAppointmentsProvider).whenData((appointments) {
    final now = DateTime.now();
    final alerts = <HealthAlert>[];

    for (final a in appointments) {
      final upcoming = a.dateTime.isAfter(now);
      final within48h = a.dateTime.difference(now).inHours <= 48;

      if (upcoming && within48h && a.status == AppointmentStatus.confirmed) {
        alerts.add(
          HealthAlert(
            icon: Icons.event_available_rounded,
            title: 'Upcoming appointment',
            body:
                '${a.doctorName} on '
                '${DateFormat('MMM dd, hh:mm a').format(a.dateTime)}',
            time: a.dateTime,
            tint: AppColors.success,
          ),
        );
      } else if (upcoming && a.status == AppointmentStatus.pending) {
        alerts.add(
          HealthAlert(
            icon: Icons.schedule_rounded,
            title: 'Awaiting confirmation',
            body:
                '${a.doctorName} has not confirmed '
                '${DateFormat('MMM dd').format(a.dateTime)} yet.',
            time: a.dateTime,
            tint: AppColors.warning,
          ),
        );
      } else if (a.status == AppointmentStatus.cancelled && upcoming) {
        alerts.add(
          HealthAlert(
            icon: Icons.event_busy_rounded,
            title: 'Appointment cancelled',
            body:
                '${a.doctorName} on '
                '${DateFormat('MMM dd').format(a.dateTime)} was cancelled.',
            time: a.dateTime,
            tint: AppColors.error,
          ),
        );
      }
    }

    alerts.sort((a, b) => a.time.compareTo(b.time));
    return alerts;
  });
});

/// Bell icon whose badge appears only when there is something to report.
class NotificationsBell extends ConsumerWidget {
  const NotificationsBell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(patientAlertsProvider).value?.length ?? 0;

    final icon = Icon(
      count > 0
          ? Icons.notifications_active_rounded
          : Icons.notifications_none_rounded,
      size: 22,
    );

    return IconButton(
      tooltip: count > 0 ? '$count update${count == 1 ? '' : 's'}' : 'Notifications',
      onPressed: () => showNotificationsSheet(context),
      icon: count == 0
          ? icon
          : Badge(
              backgroundColor: AppColors.error,
              label: Text('$count'),
              child: icon,
            ),
    );
  }
}

Future<void> showNotificationsSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.hos.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (context) => const _NotificationsSheet(),
  );
}

class _NotificationsSheet extends ConsumerWidget {
  const _NotificationsSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hos = context.hos;
    final alertsAsync = ref.watch(patientAlertsProvider);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (context, scrollController) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: hos.borderStrong,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Updates',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: hos.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: alertsAsync.hosWhen(
                compact: true,
                errorTitle: 'Could not load updates',
                onRetry: () => ref.invalidate(patientAppointmentsProvider),
                loading: () => const HosSkeletonList(
                  count: 3,
                  padding: EdgeInsets.zero,
                ),
                data: (alerts) {
                  if (alerts.isEmpty) {
                    return const HosEmptyState(
                      compact: true,
                      icon: Icons.notifications_off_outlined,
                      title: "You're all caught up",
                      message: 'Appointment reminders and status changes '
                          'will show up here.',
                    );
                  }
                  return ListView.separated(
                    controller: scrollController,
                    itemCount: alerts.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) => _AlertTile(alert: alerts[i]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AlertTile extends StatelessWidget {
  const _AlertTile({required this.alert});

  final HealthAlert alert;

  @override
  Widget build(BuildContext context) {
    final hos = context.hos;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: hos.surfaceMuted,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: hos.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: alert.tint.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(alert.icon, color: alert.tint, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: hos.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  alert.body,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: hos.textMuted,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
