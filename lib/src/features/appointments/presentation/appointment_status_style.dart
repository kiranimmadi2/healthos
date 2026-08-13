import 'package:flutter/material.dart';

import '../../../app/theme/theme.dart';
import '../../../shared/presentation/widgets/status_pill.dart';
import '../domain/appointment.dart';

/// How an appointment status is presented: label, colours and icon.
///
/// This mapping previously existed in three places — the patient care-updates
/// feed, the patient next-appointment card and the doctor schedule — and the
/// three had drifted apart (different icons, and two of them handled only a
/// subset of the statuses). Consolidating here keeps a status looking the same
/// wherever it appears, and means a new status has exactly one place to be
/// added.
enum AppointmentStatusStyle {
  pending(
    label: 'Pending',
    icon: Icons.schedule_rounded,
    foreground: AppColors.warning,
    background: AppColors.warningSoft,
    feedIcon: Icons.schedule_rounded,
  ),
  confirmed(
    label: 'Confirmed',
    icon: Icons.check_circle_outline_rounded,
    foreground: AppColors.success,
    background: AppColors.successSoft,
    feedIcon: Icons.event_available_rounded,
  ),
  completed(
    label: 'Completed',
    icon: Icons.task_alt_rounded,
    foreground: AppColors.secondary,
    background: AppColors.secondarySoft,
    feedIcon: Icons.task_alt_rounded,
  ),
  cancelled(
    label: 'Cancelled',
    icon: Icons.event_busy_rounded,
    foreground: AppColors.error,
    background: AppColors.errorSoft,
    feedIcon: Icons.event_busy_rounded,
  );

  const AppointmentStatusStyle({
    required this.label,
    required this.icon,
    required this.foreground,
    required this.background,
    required this.feedIcon,
  });

  final String label;

  /// Icon shown inside a [StatusPill].
  final IconData icon;

  final Color foreground;
  final Color background;

  /// Icon shown in the activity feed, where the emphasis is on what happened
  /// rather than on the current state.
  final IconData feedIcon;

  /// Resolves a raw [AppointmentStatus] string. Unknown values fall back to
  /// [pending], matching the previous `default:` branches.
  static AppointmentStatusStyle of(String status) {
    return switch (status) {
      AppointmentStatus.confirmed => confirmed,
      AppointmentStatus.completed => completed,
      AppointmentStatus.cancelled => cancelled,
      _ => pending,
    };
  }

  static AppointmentStatusStyle forAppointment(Appointment appointment) =>
      of(appointment.status);

  StatusPill toPill({bool showIcon = true}) {
    return StatusPill(
      label: label,
      foreground: foreground,
      background: background,
      icon: showIcon ? icon : null,
    );
  }
}
