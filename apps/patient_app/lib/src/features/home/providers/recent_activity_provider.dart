import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_client/supabase_client.dart';

import '../../../providers/patient_provider.dart';
import '../../records/providers/reports_provider.dart';

class ActivityItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final DateTime date;
  final String? routePath;

  ActivityItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.date,
    this.routePath,
  });
}

final visitRepositoryProvider = Provider<VisitRepository>(
  (ref) => VisitRepository(),
);

final recentActivityProvider = FutureProvider<List<ActivityItem>>((ref) async {
  final patient = await ref.watch(currentPatientProvider.future);
  if (patient == null) return [];

  final visitRepo = ref.watch(visitRepositoryProvider);
  final reportRepo = ref.watch(labReportRepositoryProvider);

  final visits = await visitRepo.getByPatientId(patient.id, limit: 5);
  final reports = await reportRepo.getByPatientId(patient.id);

  final items = <ActivityItem>[];

  for (final visit in visits) {
    items.add(ActivityItem(
      title: visit.chiefComplaint ?? 'Doctor Visit',
      subtitle: visit.diagnosis ?? 'Consultation',
      icon: Icons.local_hospital,
      color: const Color(0xFF0066FF),
      date: visit.visitedAt,
    ));
  }

  for (final report in reports.take(5)) {
    items.add(ActivityItem(
      title: report.reportType,
      subtitle: report.labName ?? 'Lab Report',
      icon: Icons.science,
      color: const Color(0xFF00C48C),
      date: report.reportDate,
      routePath: '/reports/${report.id}',
    ));
  }

  items.sort((a, b) => b.date.compareTo(a.date));
  return items.take(5).toList();
});
