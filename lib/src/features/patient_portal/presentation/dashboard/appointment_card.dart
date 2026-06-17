part of 'dashboard_content.dart';

class _AppointmentCard extends ConsumerWidget {
  const _AppointmentCard({required this.onNavigate});

  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nextAsync = ref.watch(nextAppointmentProvider);

    return nextAsync.when(
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.section),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (e, st) => Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Text('Could not load appointments: $e'),
        ),
      ),
      data: (appointment) {
        if (appointment == null) {
          return _EmptyAppointmentCard(onBook: () => onNavigate(1));
        }
        return _NextAppointmentCard(appointment: appointment);
      },
    );
  }
}

class _EmptyAppointmentCard extends StatelessWidget {
  const _EmptyAppointmentCard({required this.onBook});

  final VoidCallback onBook;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Next appointment',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(AppRadius.medium),
                  ),
                  child: const Icon(
                    Icons.event_available_rounded,
                    color: AppColors.primary,
                    size: 32,
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'No upcoming appointments',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Book a consultation with a verified specialist.',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton.icon(
              onPressed: onBook,
              icon: const Icon(Icons.calendar_month_outlined),
              label: const Text('Book appointment'),
            ),
          ],
        ),
      ),
    );
  }
}

class _NextAppointmentCard extends ConsumerWidget {
  const _NextAppointmentCard({required this.appointment});

  final Appointment appointment;

  StatusPill _statusPill() {
    switch (appointment.status) {
      case AppointmentStatus.confirmed:
        return const StatusPill(
          label: 'Confirmed',
          foreground: AppColors.success,
          background: AppColors.successSoft,
          icon: Icons.check_circle_outline_rounded,
        );
      default:
        return const StatusPill(
          label: 'Pending',
          foreground: AppColors.warning,
          background: AppColors.warningSoft,
          icon: Icons.schedule_rounded,
        );
    }
  }

  Future<void> _messageDoctor(BuildContext context, WidgetRef ref) async {
    final threadId = await ref
        .read(chatRepositoryProvider)
        .openThread(
          patientId: appointment.patientId,
          patientName: appointment.patientName,
          doctorId: appointment.doctorId,
          doctorName: appointment.doctorName,
        );
    if (!context.mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          threadId: threadId,
          otherPartyName: appointment.doctorName,
        ),
      ),
    );
  }

  Future<void> _cancel(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel appointment?'),
        content: Text(
          'Your appointment with ${appointment.doctorName} on '
          '${DateFormat('MMM dd, hh:mm a').format(appointment.dateTime)} '
          'will be cancelled.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep it'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Cancel appointment',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref
        .read(appointmentRepositoryProvider)
        .updateStatus(appointment.id, AppointmentStatus.cancelled);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final when = DateFormat(
      'EEE, MMM dd · hh:mm a',
    ).format(appointment.dateTime);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Next appointment',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                _statusPill(),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(AppRadius.medium),
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: AppColors.primary,
                    size: 32,
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment.doctorName,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        appointment.specialization.isEmpty
                            ? 'Specialist consultation'
                            : appointment.specialization,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _IconLabel(
                        icon: Icons.calendar_today_outlined,
                        label: when,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            const Divider(),
            const SizedBox(height: AppSpacing.lg),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _messageDoctor(context, ref),
                  icon: const Icon(Icons.chat_bubble_outline_rounded),
                  label: const Text('Message doctor'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _cancel(context, ref),
                  icon: const Icon(Icons.close_rounded),
                  label: const Text('Cancel'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
