import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_client/supabase_client.dart';

import '../../../providers/patient_provider.dart';

final medicationRepoProvider = Provider<MedicationRepository>(
  (ref) => MedicationRepository(),
);

/// All active medication schedules for the current patient.
final activeSchedulesProvider =
    FutureProvider<List<MedicationSchedule>>((ref) async {
  final patient = await ref.watch(currentPatientProvider.future);
  if (patient == null) return [];
  final repo = ref.watch(medicationRepoProvider);
  return repo.getActiveForPatient(patient.id);
});

/// Today's scheduled doses — derived from active schedules.
/// Each entry is a `(schedule, scheduledAt)` pair.
final todayDosesProvider =
    FutureProvider<List<TodayDose>>((ref) async {
  final schedules = await ref.watch(activeSchedulesProvider.future);
  final now = DateTime.now();
  final weekday = now.weekday; // 1-7
  final today = DateTime(now.year, now.month, now.day);

  final doses = <TodayDose>[];
  for (final s in schedules) {
    // Skip if not scheduled today
    if (s.weekdays.isNotEmpty && !s.weekdays.contains(weekday)) continue;
    if (s.endedOn != null && today.isAfter(s.endedOn!)) continue;
    if (today.isBefore(DateTime(s.startedOn.year, s.startedOn.month, s.startedOn.day))) continue;

    for (final t in s.doseTimes) {
      final parts = t.split(':');
      if (parts.length != 2) continue;
      final h = int.tryParse(parts[0]);
      final m = int.tryParse(parts[1]);
      if (h == null || m == null) continue;
      doses.add(TodayDose(
        schedule: s,
        scheduledAt: DateTime(now.year, now.month, now.day, h, m),
      ));
    }
  }

  doses.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
  return doses;
});

/// Today's logs keyed by `{scheduleId}_{hh:mm}` so UI can quickly see which
/// doses have been taken/skipped.
final todayLogMapProvider =
    FutureProvider<Map<String, MedicationLog>>((ref) async {
  final patient = await ref.watch(currentPatientProvider.future);
  if (patient == null) return {};
  final repo = ref.watch(medicationRepoProvider);
  final logs = await repo.getLogsForDay(patient.id, DateTime.now());
  return {
    for (final l in logs)
      '${l.scheduleId}_${l.scheduledAt.hour.toString().padLeft(2, '0')}:${l.scheduledAt.minute.toString().padLeft(2, '0')}':
          l,
  };
});

final scheduleByIdProvider = FutureProvider.family<MedicationSchedule?, String>(
  (ref, id) async {
    final repo = ref.watch(medicationRepoProvider);
    return repo.getScheduleById(id);
  },
);

class TodayDose {
  const TodayDose({required this.schedule, required this.scheduledAt});

  final MedicationSchedule schedule;
  final DateTime scheduledAt;

  String get key =>
      '${schedule.id}_${scheduledAt.hour.toString().padLeft(2, '0')}:${scheduledAt.minute.toString().padLeft(2, '0')}';
}
