import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/theme.dart';
import '../../../../shared/presentation/shell/health_page.dart';
import '../../../appointments/application/appointment_providers.dart';
import '../../../appointments/domain/appointment.dart';
import '../../../auth/application/user_providers.dart';
import '../../../chat/application/chat_providers.dart';
import '../../application/doctor_portal_providers.dart';

/// Returns a time-of-day greeting (Good morning / afternoon / evening).
String greetingForNow() {
  final hour = DateTime.now().hour;
  if (hour < 12) return 'Good morning';
  if (hour < 17) return 'Good afternoon';
  return 'Good evening';
}

class DoctorDashboard extends ConsumerWidget {
  const DoctorDashboard({super.key, required this.onOpenSection});

  final ValueChanged<int> onOpenSection;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointments =
        ref.watch(doctorAppointmentsProvider).value ?? const <Appointment>[];
    final conversations = ref.watch(chatThreadsProvider).value ?? const [];
    final stats = ref.watch(doctorStatsProvider);
    final doctorName = ref.watch(currentUserProfileProvider).value?.name.trim();

    final now = DateTime.now();
    final today = appointments.where((appointment) {
      return appointment.dateTime.year == now.year &&
          appointment.dateTime.month == now.month &&
          appointment.dateTime.day == now.day &&
          appointment.status != AppointmentStatus.cancelled;
    }).toList()..sort((a, b) => a.dateTime.compareTo(b.dateTime));

    return HealthPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DashboardHero(
            doctorName: doctorName,
            todayCount: today.length,
            pendingCount: stats.pendingAppointments,
            onOpenSchedule: () => onOpenSection(2),
          ),
          const SizedBox(height: AppSpacing.xl),
          _OverviewMetrics(
            onOpenSection: onOpenSection,
            appointmentCount: stats.activeAppointments,
            todayCount: stats.todayAppointments,
            reportsToReview: stats.reportsToReview,
            highPriorityReports: stats.highPriorityReports,
            messageCount: conversations.length,
          ),
          const SizedBox(height: AppSpacing.section),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 960;
              if (!wide) {
                return Column(
                  children: [
                    _TodaySchedule(
                      appointments: today,
                      onViewCalendar: () => onOpenSection(2),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _ClinicalTasks(
                      stats: stats,
                      onOpenReports: () => onOpenSection(4),
                      onOpenSchedule: () => onOpenSection(2),
                    ),
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 7,
                    child: _TodaySchedule(
                      appointments: today,
                      onViewCalendar: () => onOpenSection(2),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xl),
                  Expanded(
                    flex: 4,
                    child: _ClinicalTasks(
                      stats: stats,
                      onOpenReports: () => onOpenSection(4),
                      onOpenSchedule: () => onOpenSection(2),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DashboardHero extends StatelessWidget {
  const _DashboardHero({
    required this.doctorName,
    required this.todayCount,
    required this.pendingCount,
    required this.onOpenSchedule,
  });

  final String? doctorName;
  final int todayCount;
  final int pendingCount;
  final VoidCallback onOpenSchedule;

  @override
  Widget build(BuildContext context) {
    final displayName =
        (doctorName == null || doctorName!.isEmpty) ? 'Doctor' : doctorName!;
    final subtitle = pendingCount > 0
        ? 'You have $pendingCount booking request${pendingCount == 1 ? '' : 's'} to review.'
        : todayCount > 0
            ? 'You have $todayCount appointment${todayCount == 1 ? '' : 's'} scheduled today.'
            : 'No pending requests — your schedule is clear.';
    final scheduleHint = todayCount > 0
        ? '$todayCount appointment${todayCount == 1 ? '' : 's'} today'
        : 'Open to confirm pending bookings';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF172554), Color(0xFF1E3A8A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.large),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 680;
          final greeting = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${greetingForNow()}, $displayName',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  height: 1.2,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.76),
                  fontSize: 15,
                ),
              ),
            ],
          );
          final textColumn = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Live clinical schedule',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                scheduleHint,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          );

          final nextAppointment = Container(
            width: compact ? double.infinity : null,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.medium),
              border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.white,
                  child: Text(
                    'LIVE',
                    style: TextStyle(
                      color: Color(0xFF1E3A8A),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                if (compact) Expanded(child: textColumn) else textColumn,
                const SizedBox(width: 12),
                IconButton.filled(
                  tooltip: 'Open schedule',
                  onPressed: onOpenSchedule,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF1E3A8A),
                  ),
                  icon: const Icon(Icons.arrow_forward_rounded),
                ),
              ],
            ),
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [greeting, const SizedBox(height: 24), nextAppointment],
            );
          }
          return Row(
            children: [
              Expanded(child: greeting),
              const SizedBox(width: 20),
              nextAppointment,
            ],
          );
        },
      ),
    );
  }
}

class _OverviewMetrics extends StatelessWidget {
  const _OverviewMetrics({
    required this.onOpenSection,
    required this.appointmentCount,
    required this.todayCount,
    required this.reportsToReview,
    required this.highPriorityReports,
    required this.messageCount,
  });

  final ValueChanged<int> onOpenSection;
  final int appointmentCount;
  final int todayCount;
  final int reportsToReview;
  final int highPriorityReports;
  final int messageCount;

  @override
  Widget build(BuildContext context) {
    final metrics = [
      _MetricData(
        'Appointments',
        '$appointmentCount',
        'active bookings',
        Icons.calendar_today_outlined,
        AppColors.primary,
        AppColors.primarySoft,
        2,
      ),
      _MetricData(
        'Today',
        '$todayCount',
        todayCount == 1 ? 'appointment' : 'appointments',
        Icons.groups_outlined,
        AppColors.secondary,
        AppColors.secondarySoft,
        2,
      ),
      _MetricData(
        'Reports to review',
        '$reportsToReview',
        highPriorityReports > 0
            ? '$highPriorityReports high priority'
            : 'all normal priority',
        Icons.description_outlined,
        AppColors.warning,
        AppColors.warningSoft,
        4,
      ),
      _MetricData(
        'Messages',
        '$messageCount',
        messageCount == 1 ? 'conversation' : 'conversations',
        Icons.chat_bubble_outline_rounded,
        AppColors.error,
        AppColors.errorSoft,
        3,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 960 ? 4 : 2;
        const spacing = 16.0;
        final width =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final metric in metrics)
              SizedBox(
                width: width,
                child: _MetricCard(
                  data: metric,
                  onTap: () => onOpenSection(metric.section),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.data, required this.onTap});

  final _MetricData data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: data.background,
                      borderRadius: BorderRadius.circular(AppRadius.medium),
                    ),
                    child: Icon(data.icon, color: data.color),
                  ),
                  const Spacer(),
                  Text(
                    data.value,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(data.label, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 2),
              Text(data.detail),
            ],
          ),
        ),
      ),
    );
  }
}

class _TodaySchedule extends StatelessWidget {
  const _TodaySchedule({
    required this.appointments,
    required this.onViewCalendar,
  });

  final List<Appointment> appointments;
  final VoidCallback onViewCalendar;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Today's schedule",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(DateFormat('EEEE, MMMM d').format(DateTime.now())),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: onViewCalendar,
                  child: const Text('View calendar'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            if (appointments.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 28),
                child: Center(child: Text('No appointments scheduled today')),
              )
            else
              for (var index = 0; index < appointments.length; index++) ...[
                _DashboardAppointment(appointment: appointments[index]),
                if (index != appointments.length - 1) const Divider(),
              ],
          ],
        ),
      ),
    );
  }
}

class _DashboardAppointment extends StatelessWidget {
  const _DashboardAppointment({required this.appointment});

  final Appointment appointment;

  @override
  Widget build(BuildContext context) {
    final pending = appointment.status == AppointmentStatus.pending;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: SizedBox(
        width: 74,
        child: Text(
          DateFormat('hh:mm a').format(appointment.dateTime),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      title: Text(appointment.patientName),
      subtitle: Text(
        appointment.symptoms?.isNotEmpty == true
            ? appointment.symptoms!
            : 'General consultation',
      ),
      trailing: Text(
        pending ? 'Pending' : 'Confirmed',
        style: TextStyle(
          color: pending ? AppColors.warning : AppColors.success,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ClinicalTasks extends StatelessWidget {
  const _ClinicalTasks({
    required this.stats,
    required this.onOpenReports,
    required this.onOpenSchedule,
  });

  final DoctorStats stats;
  final VoidCallback onOpenReports;
  final VoidCallback onOpenSchedule;

  @override
  Widget build(BuildContext context) {
    final tasks = <({String title, String detail, IconData icon, Color color, VoidCallback onTap, bool done})>[
      (
        title: 'Review lab results',
        detail: stats.reportsToReview == 0
            ? 'All caught up'
            : '${stats.reportsToReview} report${stats.reportsToReview == 1 ? '' : 's'}',
        icon: Icons.description_outlined,
        color: AppColors.warning,
        onTap: onOpenReports,
        done: stats.reportsToReview == 0,
      ),
      (
        title: 'Confirm booking requests',
        detail: stats.pendingAppointments == 0
            ? 'Nothing pending'
            : '${stats.pendingAppointments} pending',
        icon: Icons.event_available_outlined,
        color: AppColors.primary,
        onTap: onOpenSchedule,
        done: stats.pendingAppointments == 0,
      ),
      (
        title: 'Follow up with patients',
        detail: stats.confirmedAppointments == 0
            ? 'No upcoming visits'
            : '${stats.confirmedAppointments} confirmed',
        icon: Icons.event_repeat_outlined,
        color: AppColors.secondary,
        onTap: onOpenSchedule,
        done: false,
      ),
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Clinical tasks',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            const Text('Items that need your attention'),
            const SizedBox(height: AppSpacing.xl),
            for (final task in tasks) ...[
              _TaskTile(
                icon: task.icon,
                color: task.color,
                title: task.title,
                detail: task.detail,
                completed: task.done,
                onTap: task.onTap,
              ),
              if (task != tasks.last) const SizedBox(height: AppSpacing.md),
            ],
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onOpenReports,
                child: const Text('Open reports'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskTile extends StatelessWidget {
  const _TaskTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.detail,
    required this.completed,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String detail;
  final bool completed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.medium),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.hos.background,
          borderRadius: BorderRadius.circular(AppRadius.medium),
          border: Border.all(color: context.hos.border),
        ),
        child: Row(
          children: [
            Icon(completed ? Icons.check_circle_rounded : icon, color: color),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      decoration: completed ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  Text(detail),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: context.hos.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricData {
  const _MetricData(
    this.label,
    this.value,
    this.detail,
    this.icon,
    this.color,
    this.background,
    this.section,
  );

  final String label;
  final String value;
  final String detail;
  final IconData icon;
  final Color color;
  final Color background;
  final int section;
}
