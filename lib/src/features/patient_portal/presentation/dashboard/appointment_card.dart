part of 'dashboard_content.dart';

class _AppointmentCard extends ConsumerWidget {
  const _AppointmentCard({required this.onNavigate});

  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nextAsync = ref.watch(nextAppointmentProvider);

    return nextAsync.when(
      loading: () => const GlassContainer(
        borderRadius: 28,
        padding: EdgeInsets.all(AppSpacing.section),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, st) => GlassContainer(
        borderRadius: 28,
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Text('Could not load appointments: $e'),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GlassContainer(
      borderRadius: 28,
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF334155).withOpacity(0.8)
                      : Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? const Color(0xFF475569) : Colors.white,
                  ),
                ),
                child: Text(
                  'Your Appointment',
                  style: TextStyle(
                    color: isDark ? Colors.white : context.hos.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.event_available_rounded,
                  color: Colors.white,
                  size: 36,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'No Upcoming Appointment',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Book a consultation with our verified doctors & specialists.',
                      style: TextStyle(color: context.hos.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onBook,
            icon: const Icon(Icons.calendar_month_rounded, size: 20),
            label: const Text('Book Appointment'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
            ),
          ),
        ],
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white.withOpacity(0.95),
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
    final dateStr = DateFormat('EEEE, dd MMM yyyy · HH.mm').format(appointment.dateTime);

    return GlassContainer(
      borderRadius: 32,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Your Appointment',
                style: TextStyle(
                  color: context.hos.textMuted,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              _statusPill(),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment.doctorName,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 26,
                            letterSpacing: -0.5,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      appointment.specialization.isEmpty
                          ? 'General Specialist'
                          : appointment.specialization,
                      style: TextStyle(
                        fontSize: 15,
                        color: context.hos.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.primaryGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: 36,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Dark glass pill overlay matching the Hourglass reference card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B).withOpacity(0.85),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_rounded,
                  color: Colors.white70,
                  size: 16,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    dateStr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'A-03 · ${appointment.id.substring(0, 6).toUpperCase()}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _messageDoctor(context, ref),
                  icon: const Icon(Icons.chat_bubble_rounded, size: 18),
                  label: const Text('Message Doctor'),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: () => _cancel(context, ref),
                icon: const Icon(Icons.close_rounded, size: 18),
                label: const Text('Cancel'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

