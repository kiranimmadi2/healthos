part of 'dashboard_content.dart';

class _CareUpdates extends ConsumerWidget {
  const _CareUpdates();

  static (String, Color, IconData) _statusStyle(Appointment appointment) {
    switch (appointment.status) {
      case AppointmentStatus.confirmed:
        return ('Confirmed', AppColors.success, Icons.event_available_rounded);
      case AppointmentStatus.completed:
        return ('Completed', AppColors.secondary, Icons.task_alt_rounded);
      case AppointmentStatus.cancelled:
        return ('Cancelled', AppColors.error, Icons.event_busy_rounded);
      default:
        return ('Pending', AppColors.warning, Icons.schedule_rounded);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointmentsAsync = ref.watch(patientAppointmentsProvider);

    return appointmentsAsync.when(
      loading: () => const GlassContainer(
        borderRadius: 28,
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, st) => GlassContainer(
        borderRadius: 28,
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Text('Could not load updates: $e'),
      ),
      data: (appointments) {
        if (appointments.isEmpty) {
          return const GlassContainer(
            borderRadius: 28,
            padding: EdgeInsets.all(AppSpacing.xl),
            child: Text(
              'No activity yet. Book your first appointment to get started.',
            ),
          );
        }

        final recent = appointments.reversed.take(3).toList();
        return GlassContainer(
          borderRadius: 28,
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var i = 0; i < recent.length; i++) ...[
                if (i > 0) Divider(height: 1, color: Colors.white.withOpacity(0.4)),
                Builder(
                  builder: (context) {
                    final appointment = recent[i];
                    final (label, color, icon) = _statusStyle(appointment);
                    return _UpdateTile(
                      icon: icon,
                      color: color,
                      title:
                          '${appointment.doctorName} · ${label.toLowerCase()}',
                      subtitle: DateFormat(
                        'MMM dd, yyyy · hh:mm a',
                      ).format(appointment.dateTime),
                      trailing: StatusPill(
                        label: label,
                        foreground: color,
                        background: color.withOpacity(0.12),
                      ),
                      onTap: () {},
                    );
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _UpdateTile extends StatelessWidget {
  const _UpdateTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      minTileHeight: 76,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      onTap: onTap,
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.09),
          borderRadius: BorderRadius.circular(AppRadius.medium),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(title, style: Theme.of(context).textTheme.titleMedium),
      subtitle: Text(subtitle),
      trailing: trailing,
    );
  }
}
