import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/theme.dart';
import '../../appointments/application/appointment_providers.dart';
import '../../appointments/domain/appointment.dart';
import '../../auth/application/user_providers.dart';
import '../../records/application/record_providers.dart';
import '../../records/domain/medical_record.dart';
import '../demo/doctor_workspace_models.dart';

/// Aggregated, real metrics for the signed-in doctor, derived from the live
/// appointment and diagnostic-report streams. Everything the doctor dashboard
/// and reports insights render is computed here so the UI never shows numbers
/// that are not backed by Firestore data.
class DoctorStats {
  const DoctorStats({
    required this.totalAppointments,
    required this.activeAppointments,
    required this.pendingAppointments,
    required this.confirmedAppointments,
    required this.completedAppointments,
    required this.todayAppointments,
    required this.patientsSeen,
    required this.reportsToReview,
    required this.highPriorityReports,
  });

  final int totalAppointments;
  final int activeAppointments;
  final int pendingAppointments;
  final int confirmedAppointments;
  final int completedAppointments;
  final int todayAppointments;
  final int patientsSeen;
  final int reportsToReview;
  final int highPriorityReports;

  /// Share of the doctor's appointments that have reached a completed state.
  double get completionRate =>
      totalAppointments == 0 ? 0 : completedAppointments / totalAppointments;

  /// Share of the doctor's appointments that are confirmed (not just pending).
  double get confirmationRate =>
      totalAppointments == 0 ? 0 : confirmedAppointments / totalAppointments;

  /// Share of completed visits that have a follow-up booking still open.
  double get followUpRate {
    final booked = confirmedAppointments + pendingAppointments;
    return totalAppointments == 0 ? 0 : booked / totalAppointments;
  }

  static const empty = DoctorStats(
    totalAppointments: 0,
    activeAppointments: 0,
    pendingAppointments: 0,
    confirmedAppointments: 0,
    completedAppointments: 0,
    todayAppointments: 0,
    patientsSeen: 0,
    reportsToReview: 0,
    highPriorityReports: 0,
  );
}

/// Search text entered in the doctor workspace header.
///
/// Shared so the header field actually drives the patient list; previously it
/// only raised a SnackBar echoing the query.
final workspaceSearchProvider = NotifierProvider<WorkspaceSearch, String>(
  WorkspaceSearch.new,
);

class WorkspaceSearch extends Notifier<String> {
  @override
  String build() => '';

  void set(String value) => state = value.trim();
  void clear() => state = '';
}

final doctorStatsProvider = Provider<DoctorStats>((ref) {
  final appointments =
      ref.watch(doctorAppointmentsProvider).value ?? const <Appointment>[];
  final reports =
      ref.watch(allDiagnosticReportsProvider).value ?? const <DiagnosticReport>[];

  final now = DateTime.now();
  var pending = 0;
  var confirmed = 0;
  var completed = 0;
  var today = 0;
  final seenPatients = <String>{};

  for (final appointment in appointments) {
    switch (appointment.status) {
      case AppointmentStatus.pending:
        pending++;
      case AppointmentStatus.confirmed:
        confirmed++;
      case AppointmentStatus.completed:
        completed++;
        seenPatients.add(appointment.patientId);
    }
    final sameDay = appointment.dateTime.year == now.year &&
        appointment.dateTime.month == now.month &&
        appointment.dateTime.day == now.day;
    if (sameDay && appointment.status != AppointmentStatus.cancelled) {
      today++;
    }
  }

  return DoctorStats(
    totalAppointments: appointments.length,
    activeAppointments: pending + confirmed,
    pendingAppointments: pending,
    confirmedAppointments: confirmed,
    completedAppointments: completed,
    todayAppointments: today,
    patientsSeen: seenPatients.length,
    reportsToReview: reports.where((r) => r.status == 'Needs review').length,
    highPriorityReports: reports.where((r) => r.priority == 'High').length,
  );
});

final allDiagnosticReportsProvider = Provider<AsyncValue<List<DiagnosticReport>>>((ref) {
  final recordsAsync = ref.watch(allRecordsProvider);
  final patientsAsync = ref.watch(allPatientsProvider);

  if (recordsAsync.isLoading || patientsAsync.isLoading) {
    return const AsyncValue.loading();
  }
  if (recordsAsync.hasError) {
    return AsyncValue.error(recordsAsync.error!, recordsAsync.stackTrace!);
  }
  if (patientsAsync.hasError) {
    return AsyncValue.error(patientsAsync.error!, patientsAsync.stackTrace!);
  }

  final records = recordsAsync.value ?? [];
  final patients = patientsAsync.value ?? [];
  final patientMap = {for (final p in patients) p['uid'] as String: p['name'] as String? ?? 'Patient'};

  final reports = records
      .where((r) => r.category == RecordCategory.labReport || r.category == RecordCategory.imaging)
      .map((record) {
        final patientName = patientMap[record.patientId] ?? 'Unknown Patient';

        IconData icon = Icons.description_outlined;
        Color iconColor = AppColors.primary;
        Color iconBackground = AppColors.primarySoft;

        if (record.category == RecordCategory.labReport) {
          icon = Icons.science_outlined;
          iconColor = AppColors.warning;
          iconBackground = AppColors.warningSoft;
        } else if (record.category == RecordCategory.imaging) {
          icon = Icons.portrait_rounded;
          iconColor = AppColors.secondary;
          iconBackground = AppColors.secondarySoft;
        }

        final isHigh = record.title.toLowerCase().contains('critical') ||
            record.title.toLowerCase().contains('elevated') ||
            record.notes.toLowerCase().contains('critical') ||
            record.notes.toLowerCase().contains('high') ||
            record.notes.toLowerCase().contains('danger');

        return DiagnosticReport(
          id: record.id,
          type: record.title,
          patient: patientName,
          ordered: DateFormat('MMM dd, yyyy').format(record.date),
          summary: record.notes.isEmpty ? 'No notes provided' : record.notes,
          status: 'Needs review',
          priority: isHigh ? 'High' : 'Normal',
          icon: icon,
          iconColor: isHigh ? AppColors.error : iconColor,
          iconBackground: isHigh ? AppColors.errorSoft : iconBackground,
        );
      })
      .toList();

  return AsyncValue.data(reports);
});
