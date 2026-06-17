import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/theme.dart';
import '../../../../shared/presentation/shell/health_page.dart';
import '../../../appointments/application/appointment_providers.dart';
import '../../../appointments/domain/appointment.dart';
import '../../../chat/application/chat_providers.dart';

class DoctorDashboard extends ConsumerWidget {
  const DoctorDashboard({super.key, required this.onOpenSection});

  final ValueChanged<int> onOpenSection;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointments =
        ref.watch(doctorAppointmentsProvider).value ?? const <Appointment>[];
    final conversations = ref.watch(chatThreadsProvider).value ?? const [];
    final now = DateTime.now();
    final today = appointments.where((appointment) {
      return appointment.dateTime.year == now.year &&
          appointment.dateTime.month == now.month &&
          appointment.dateTime.day == now.day &&
          appointment.status != AppointmentStatus.cancelled;
    }).toList();
    final activeCount = appointments.where((appointment) {
      return appointment.status == AppointmentStatus.pending ||
          appointment.status == AppointmentStatus.confirmed;
    }).length;

    return HealthPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DashboardHero(onOpenSchedule: () => onOpenSection(2)),
          const SizedBox(height: AppSpacing.xl),
          _OverviewMetrics(
            onOpenSection: onOpenSection,
            appointmentCount: activeCount,
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
                    _ClinicalTasks(onOpenReports: () => onOpenSection(4)),
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
                      onOpenReports: () => onOpenSection(4),
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
  const _DashboardHero({required this.onOpenSchedule});

  final VoidCallback onOpenSchedule;

  @override
  Widget build(BuildContext context) {
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
              const Text(
                'Good morning, Dr. Sharma',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  height: 1.2,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Review new booking requests and patient messages.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.76),
                  fontSize: 15,
                ),
              ),
            ],
          );
          final nextAppointment = Container(
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
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Live clinical schedule',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Open to confirm pending bookings',
                      style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 12),
                    ),
                  ],
                ),
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
    required this.messageCount,
  });

  final ValueChanged<int> onOpenSection;
  final int appointmentCount;
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
        'Waiting now',
        '3',
        '12 min average',
        Icons.groups_outlined,
        AppColors.secondary,
        AppColors.secondarySoft,
        1,
      ),
      _MetricData(
        'Reports to review',
        '5',
        '2 high priority',
        Icons.description_outlined,
        AppColors.warning,
        AppColors.warningSoft,
        4,
      ),
      _MetricData(
        'Messages',
        '$messageCount',
        'conversations',
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

class _ClinicalTasks extends StatefulWidget {
  const _ClinicalTasks({required this.onOpenReports});

  final VoidCallback onOpenReports;

  @override
  State<_ClinicalTasks> createState() => _ClinicalTasksState();
}

class _ClinicalTasksState extends State<_ClinicalTasks> {
  final _completed = <String>{};

  @override
  Widget build(BuildContext context) {
    const tasks = [
      (
        'Review lab results',
        '5 reports',
        Icons.description_outlined,
        AppColors.warning,
      ),
      (
        'Sign prescriptions',
        '3 pending',
        Icons.medication_outlined,
        AppColors.primary,
      ),
      (
        'Schedule follow-ups',
        '4 patients',
        Icons.event_repeat_outlined,
        AppColors.secondary,
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
                icon: task.$3,
                color: task.$4,
                title: task.$1,
                detail: _completed.contains(task.$1) ? 'Completed' : task.$2,
                completed: _completed.contains(task.$1),
                onTap: () => setState(() {
                  if (!_completed.add(task.$1)) {
                    _completed.remove(task.$1);
                  }
                }),
              ),
              if (task != tasks.last) const SizedBox(height: AppSpacing.md),
            ],
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: widget.onOpenReports,
                child: const Text('Open task list'),
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
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppRadius.medium),
          border: Border.all(color: AppColors.border),
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
              completed ? Icons.undo_rounded : Icons.chevron_right_rounded,
              color: AppColors.textMuted,
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
