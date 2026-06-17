import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/theme.dart';
import '../../../../shared/presentation/shell/health_page.dart';
import '../../../../shared/presentation/widgets/status_pill.dart';
import '../../../appointments/application/appointment_providers.dart';
import '../../../appointments/domain/appointment.dart';
import '../../../chat/application/chat_providers.dart';
import '../../../chat/presentation/chat_screen.dart';
import '../widgets/doctor_workspace_widgets.dart';

class ScheduleWorkspace extends ConsumerStatefulWidget {
  const ScheduleWorkspace({super.key});

  @override
  ConsumerState<ScheduleWorkspace> createState() => _ScheduleWorkspaceState();
}

class _ScheduleWorkspaceState extends ConsumerState<ScheduleWorkspace> {
  DateTime _selectedDate = DateTime.now();
  bool _showCompleted = true;

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  List<DateTime> get _days {
    final start = DateTime.now();
    return List.generate(14, (index) => start.add(Duration(days: index)));
  }

  Future<void> _updateStatus(Appointment appointment, String status) async {
    try {
      await ref
          .read(appointmentRepositoryProvider)
          .updateStatus(appointment.id, status);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not update booking: $e')));
      }
    }
  }

  Future<void> _message(Appointment appointment) async {
    final threadId = await ref
        .read(chatRepositoryProvider)
        .openThread(
          patientId: appointment.patientId,
          patientName: appointment.patientName,
          doctorId: appointment.doctorId,
          doctorName: appointment.doctorName,
        );
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          threadId: threadId,
          otherPartyName: appointment.patientName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appointmentsAsync = ref.watch(doctorAppointmentsProvider);

    return HealthPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const WorkspaceHeading(
            title: 'Clinical schedule',
            description:
                'Review booking requests and manage confirmed consultations.',
          ),
          const SizedBox(height: AppSpacing.xl),
          _DateSelector(
            days: _days,
            selectedDate: _selectedDate,
            onSelected: (date) => setState(() => _selectedDate = date),
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: Text(
                  DateFormat('EEEE, MMMM d').format(_selectedDate),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              FilterChip(
                label: const Text('Show completed'),
                selected: _showCompleted,
                onSelected: (value) => setState(() => _showCompleted = value),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          appointmentsAsync.when(
            loading: () => const Card(
              child: Padding(
                padding: EdgeInsets.all(48),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
            error: (e, st) => Card(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text('Could not load appointments: $e'),
              ),
            ),
            data: (appointments) {
              final visible = appointments.where((appointment) {
                if (!_isSameDay(appointment.dateTime, _selectedDate)) {
                  return false;
                }
                return _showCompleted ||
                    appointment.status != AppointmentStatus.completed;
              }).toList();

              if (visible.isEmpty) {
                return const EmptyState(
                  icon: Icons.event_available_rounded,
                  title: 'No appointments',
                  description: 'This day is open for consultations.',
                );
              }
              return Card(
                child: Column(
                  children: [
                    for (var index = 0; index < visible.length; index++) ...[
                      _LiveAppointmentTile(
                        appointment: visible[index],
                        onConfirm: () => _updateStatus(
                          visible[index],
                          AppointmentStatus.confirmed,
                        ),
                        onCancel: () => _updateStatus(
                          visible[index],
                          AppointmentStatus.cancelled,
                        ),
                        onComplete: () => _updateStatus(
                          visible[index],
                          AppointmentStatus.completed,
                        ),
                        onMessage: () => _message(visible[index]),
                      ),
                      if (index != visible.length - 1) const Divider(),
                    ],
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DateSelector extends StatelessWidget {
  const _DateSelector({
    required this.days,
    required this.selectedDate,
    required this.onSelected,
  });

  final List<DateTime> days;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 84,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final day = days[index];
          final selected =
              day.year == selectedDate.year &&
              day.month == selectedDate.month &&
              day.day == selectedDate.day;
          return SizedBox(
            width: 76,
            child: InkWell(
              onTap: () => onSelected(day),
              borderRadius: BorderRadius.circular(AppRadius.medium),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                  border: Border.all(
                    color: selected ? AppColors.primary : AppColors.border,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      DateFormat('EEE').format(day).toUpperCase(),
                      style: TextStyle(
                        color: selected ? Colors.white70 : AppColors.textMuted,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${day.day}',
                      style: TextStyle(
                        color: selected ? Colors.white : AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _LiveAppointmentTile extends StatelessWidget {
  const _LiveAppointmentTile({
    required this.appointment,
    required this.onConfirm,
    required this.onCancel,
    required this.onComplete,
    required this.onMessage,
  });

  final Appointment appointment;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final VoidCallback onComplete;
  final VoidCallback onMessage;

  StatusPill _status() {
    return switch (appointment.status) {
      AppointmentStatus.confirmed => const StatusPill(
        label: 'Confirmed',
        foreground: AppColors.success,
        background: AppColors.successSoft,
      ),
      AppointmentStatus.completed => const StatusPill(
        label: 'Completed',
        foreground: AppColors.secondary,
        background: AppColors.secondarySoft,
      ),
      AppointmentStatus.cancelled => const StatusPill(
        label: 'Cancelled',
        foreground: AppColors.error,
        background: AppColors.errorSoft,
      ),
      _ => const StatusPill(
        label: 'Pending',
        foreground: AppColors.warning,
        background: AppColors.warningSoft,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final active =
        appointment.status == AppointmentStatus.pending ||
        appointment.status == AppointmentStatus.confirmed;
    return Padding(
      padding: const EdgeInsets.all(18),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 600) {
            return _buildCompact(context, active);
          }
          return _buildWide(context, active);
        },
      ),
    );
  }

  Widget _buildCompact(BuildContext context, bool active) {
    final primaryAction = switch (appointment.status) {
      AppointmentStatus.pending => (
        label: 'Confirm booking',
        icon: Icons.check_rounded,
        action: onConfirm,
      ),
      AppointmentStatus.confirmed => (
        label: 'Mark complete',
        icon: Icons.task_alt_rounded,
        action: onComplete,
      ),
      _ => null,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(AppRadius.small),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.schedule_rounded,
                    size: 17,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    DateFormat('h:mm a').format(appointment.dateTime),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            _status(),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.primarySoft,
              child: Text(
                appointment.patientName.isEmpty
                    ? '?'
                    : appointment.patientName[0].toUpperCase(),
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'BOOKED PATIENT',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.7,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    appointment.patientName,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    appointment.symptoms?.isNotEmpty == true
                        ? appointment.symptoms!
                        : 'General consultation',
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        const Divider(),
        const SizedBox(height: 14),
        if (primaryAction != null) ...[
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: primaryAction.action,
              icon: Icon(primaryAction.icon),
              label: Text(primaryAction.label),
            ),
          ),
          const SizedBox(height: 10),
        ],
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onMessage,
            icon: const Icon(Icons.chat_bubble_outline_rounded),
            label: const Text('Message patient'),
          ),
        ),
        if (active) ...[
          const SizedBox(height: 4),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: onCancel,
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              icon: const Icon(Icons.close_rounded),
              label: const Text('Cancel appointment'),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildWide(BuildContext context, bool active) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 82,
          child: Text(
            DateFormat('h:mm a').format(appointment.dateTime),
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        CircleAvatar(
          backgroundColor: AppColors.primarySoft,
          child: Text(
            appointment.patientName.isEmpty
                ? '?'
                : appointment.patientName[0].toUpperCase(),
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                appointment.patientName,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                appointment.symptoms?.isNotEmpty == true
                    ? appointment.symptoms!
                    : 'General consultation',
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (appointment.status == AppointmentStatus.pending)
                    FilledButton.tonal(
                      onPressed: onConfirm,
                      child: const Text('Confirm'),
                    ),
                  if (appointment.status == AppointmentStatus.confirmed)
                    FilledButton.tonal(
                      onPressed: onComplete,
                      child: const Text('Complete'),
                    ),
                  if (active)
                    OutlinedButton(
                      onPressed: onCancel,
                      child: const Text('Cancel'),
                    ),
                  OutlinedButton.icon(
                    onPressed: onMessage,
                    icon: const Icon(Icons.chat_bubble_outline_rounded),
                    label: const Text('Message patient'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        _status(),
      ],
    );
  }
}
