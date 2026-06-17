import 'package:flutter/material.dart';

import '../../../../app/theme/theme.dart';
import '../../../../shared/presentation/widgets/status_pill.dart';
import '../../demo/doctor_workspace_models.dart';
import '../dialogs/doctor_workspace_dialogs.dart';
import 'doctor_workspace_widgets.dart';

class AppointmentRow extends StatelessWidget {
  const AppointmentRow({super.key, required this.appointment, this.onTap});

  final DoctorAppointment appointment;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap ?? () => showAppointmentSheet(context, appointment),
      borderRadius: BorderRadius.circular(AppRadius.medium),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 520;
            return Row(
              children: [
                SizedBox(
                  width: 58,
                  child: Text(
                    appointment.time,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                AvatarInitials(
                  initials: appointment.initials,
                  color: appointment.color,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        '${appointment.type} · ${appointment.reason}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (compact) ...[
                        const SizedBox(height: 7),
                        StatusPill(
                          label: appointment.status,
                          foreground: appointment.statusColor,
                          background: appointment.statusBackground,
                        ),
                      ],
                    ],
                  ),
                ),
                if (!compact)
                  StatusPill(
                    label: appointment.status,
                    foreground: appointment.statusColor,
                    background: appointment.statusBackground,
                  ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textMuted,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
