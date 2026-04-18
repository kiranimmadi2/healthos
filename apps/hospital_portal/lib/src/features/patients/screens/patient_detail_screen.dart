import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_client/supabase_client.dart';
import 'package:ui_kit/ui_kit.dart';

/// Fetches a single patient by ID.
final hospitalPatientProvider =
    FutureProvider.family<Patient?, String>((ref, patientId) async {
  final repo = PatientRepository();
  return repo.getById(patientId);
});

/// Fetches visits for a given patient.
final patientVisitsProvider =
    FutureProvider.family<List<Visit>, String>((ref, patientId) async {
  final repo = VisitRepository();
  return repo.getByPatientId(patientId);
});

/// Fetches lab reports for a given patient.
final patientReportsProvider =
    FutureProvider.family<List<LabReport>, String>((ref, patientId) async {
  final repo = LabReportRepository();
  return repo.getByPatientId(patientId);
});

class PatientDetailScreen extends ConsumerWidget {
  const PatientDetailScreen({super.key, required this.patientId});

  final String patientId;

  String _computeAge(DateTime? dateOfBirth) {
    if (dateOfBirth == null) return 'N/A';
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return '$age yrs';
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patientAsync = ref.watch(hospitalPatientProvider(patientId));

    return Scaffold(
      appBar: AppBar(title: const Text('Patient Details')),
      body: patientAsync.when(
        loading: () => const Center(child: HosLoading()),
        error: (e, _) => HosError(
          message: e.toString(),
          onRetry: () => ref.invalidate(hospitalPatientProvider(patientId)),
        ),
        data: (patient) {
          if (patient == null) {
            return const HosEmptyState(
              message: 'Patient not found.',
              icon: Icons.person_off_outlined,
            );
          }

          return DefaultTabController(
            length: 2,
            child: Column(
              children: [
                // ── Patient Info Card ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.md,
                    AppSpacing.md,
                    0,
                  ),
                  child: HosCard(
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            HosAvatar(
                              imageUrl: patient.avatarUrl,
                              name: patient.fullName,
                              radius: 36,
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    patient.fullName ?? 'Unknown',
                                    style: AppTypography.h2,
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    patient.healthId,
                                    style: AppTypography.bodySmall.copyWith(
                                      fontFamily: 'monospace',
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: AppSpacing.xl),
                        _InfoRow(
                          icon: Icons.cake_outlined,
                          label: 'DOB / Age',
                          value: patient.dateOfBirth != null
                              ? '${_formatDate(patient.dateOfBirth!)} (${_computeAge(patient.dateOfBirth)})'
                              : 'N/A',
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        _InfoRow(
                          icon: Icons.wc_outlined,
                          label: 'Gender',
                          value: patient.gender ?? 'N/A',
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        _InfoRow(
                          icon: Icons.bloodtype_outlined,
                          label: 'Blood Group',
                          value: patient.bloodGroup ?? 'N/A',
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        _InfoRow(
                          icon: Icons.warning_amber_outlined,
                          label: 'Allergies',
                          value: patient.allergies.isNotEmpty
                              ? patient.allergies.join(', ')
                              : 'None',
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        _InfoRow(
                          icon: Icons.monitor_heart_outlined,
                          label: 'Chronic Conditions',
                          value: patient.chronicConditions.isNotEmpty
                              ? patient.chronicConditions.join(', ')
                              : 'None',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // ── Tabs ──
                const TabBar(
                  tabs: [
                    Tab(text: 'Visits'),
                    Tab(text: 'Lab Reports'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _VisitsTab(patientId: patientId, ref: ref),
                      _ReportsTab(patientId: patientId, ref: ref),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Visits Tab ──────────────────────────────────────────────────────────────

class _VisitsTab extends StatelessWidget {
  const _VisitsTab({required this.patientId, required this.ref});

  final String patientId;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final visitsAsync = ref.watch(patientVisitsProvider(patientId));

    return visitsAsync.when(
      loading: () => const Center(child: HosLoading()),
      error: (e, _) => HosError(
        message: e.toString(),
        onRetry: () => ref.invalidate(patientVisitsProvider(patientId)),
      ),
      data: (visits) {
        if (visits.isEmpty) {
          return const HosEmptyState(
            message: 'No visits recorded.',
            icon: Icons.event_busy_outlined,
          );
        }
        return ListView.builder(
          padding: AppSpacing.screenPadding,
          itemCount: visits.length,
          itemBuilder: (context, index) {
            final visit = visits[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: HosCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDate(visit.visitedAt),
                          style: AppTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (visit.doctorId != null)
                          Text(
                            'Doctor: ${visit.doctorId!.substring(0, 8)}...',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                    if (visit.chiefComplaint != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Chief Complaint: ${visit.chiefComplaint}',
                        style: AppTypography.bodySmall,
                      ),
                    ],
                    if (visit.diagnosis != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Diagnosis: ${visit.diagnosis}',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

// ── Reports Tab ─────────────────────────────────────────────────────────────

class _ReportsTab extends StatelessWidget {
  const _ReportsTab({required this.patientId, required this.ref});

  final String patientId;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final reportsAsync = ref.watch(patientReportsProvider(patientId));

    return reportsAsync.when(
      loading: () => const Center(child: HosLoading()),
      error: (e, _) => HosError(
        message: e.toString(),
        onRetry: () => ref.invalidate(patientReportsProvider(patientId)),
      ),
      data: (reports) {
        if (reports.isEmpty) {
          return const HosEmptyState(
            message: 'No lab reports found.',
            icon: Icons.science_outlined,
          );
        }
        return ListView.builder(
          padding: AppSpacing.screenPadding,
          itemCount: reports.length,
          itemBuilder: (context, index) {
            final report = reports[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: HosCard(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            report.reportType,
                            style: AppTypography.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            _formatDate(report.reportDate),
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          if (report.labName != null) ...[
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              report.labName!,
                              style: AppTypography.caption.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    HosStatusChip(
                      label: report.status.toUpperCase(),
                      color: _statusColor(report.status),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'verified':
        return AppColors.success;
      case 'pending':
        return AppColors.warning;
      case 'rejected':
        return AppColors.error;
      default:
        return AppColors.disabled;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

// ── Shared Info Row ─────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: AppSpacing.sm),
        Text(
          '$label: ',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Expanded(
          child: Text(value, style: AppTypography.bodyMedium),
        ),
      ],
    );
  }
}
