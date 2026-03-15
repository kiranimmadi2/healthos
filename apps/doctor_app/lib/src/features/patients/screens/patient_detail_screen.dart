import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_client/supabase_client.dart';
import 'package:ui_kit/ui_kit.dart';

/// Fetches a patient by ID.
final patientByIdProvider =
    FutureProvider.family<Patient?, String>((ref, patientId) async {
  final repo = PatientRepository();
  return repo.getById(patientId);
});

/// Fetches visits for a patient.
final patientVisitsProvider =
    FutureProvider.family<List<Visit>, String>((ref, patientId) async {
  final repo = VisitRepository();
  return repo.getByPatientId(patientId);
});

/// Fetches prescriptions for a patient.
final patientPrescriptionsProvider =
    FutureProvider.family<List<Prescription>, String>((ref, patientId) async {
  final repo = PrescriptionRepository();
  return repo.getByPatientId(patientId);
});

/// Fetches lab reports for a patient.
final patientReportsProvider =
    FutureProvider.family<List<LabReport>, String>((ref, patientId) async {
  final repo = LabReportRepository();
  return repo.getByPatientId(patientId);
});

class PatientDetailScreen extends ConsumerWidget {
  const PatientDetailScreen({super.key, required this.patientId});

  final String patientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patientAsync = ref.watch(patientByIdProvider(patientId));
    final visitsAsync = ref.watch(patientVisitsProvider(patientId));
    final prescriptionsAsync =
        ref.watch(patientPrescriptionsProvider(patientId));
    final reportsAsync = ref.watch(patientReportsProvider(patientId));

    return Scaffold(
      appBar: AppBar(
        title: patientAsync.when(
          data: (p) => Text(p?.fullName ?? 'Patient Detail'),
          loading: () => const Text('Loading...'),
          error: (_, __) => const Text('Patient Detail'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            tooltip: 'AI Summary',
            onPressed: () => context.go('/patients/$patientId/ai-summary'),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'New Visit',
            onPressed: () => context.go('/patients/$patientId/visit/create'),
          ),
          IconButton(
            icon: const Icon(Icons.medication_outlined),
            tooltip: 'New Prescription',
            onPressed: () =>
                context.go('/patients/$patientId/prescription/create'),
          ),
        ],
      ),
      body: patientAsync.when(
        data: (patient) {
          if (patient == null) {
            return const HosEmptyState(
              icon: Icons.person_off_outlined,
              message: 'Patient not found. This patient record could not be located.',
            );
          }

          return SingleChildScrollView(
            padding: AppSpacing.screenPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Patient info card
                _PatientInfoCard(patient: patient),
                const SizedBox(height: AppSpacing.lg),

                // Timeline header
                Text('Patient Timeline', style: AppTypography.h3),
                const SizedBox(height: AppSpacing.md),

                // Visits
                _SectionHeader(
                  icon: Icons.event_note,
                  title: 'Visits',
                  count: visitsAsync.valueOrNull?.length,
                ),
                visitsAsync.when(
                  data: (visits) => visits.isEmpty
                      ? _EmptySection(label: 'No visits recorded')
                      : Column(
                          children: visits
                              .map((v) => _VisitCard(visit: v))
                              .toList(),
                        ),
                  loading: () => const Padding(
                    padding: EdgeInsets.all(AppSpacing.md),
                    child: HosLoading(),
                  ),
                  error: (e, _) => _ErrorSection(message: e.toString()),
                ),
                const SizedBox(height: AppSpacing.md),

                // Lab Reports
                _SectionHeader(
                  icon: Icons.science_outlined,
                  title: 'Lab Reports',
                  count: reportsAsync.valueOrNull?.length,
                ),
                reportsAsync.when(
                  data: (reports) => reports.isEmpty
                      ? _EmptySection(label: 'No lab reports')
                      : Column(
                          children: reports
                              .map((r) => _LabReportCard(report: r))
                              .toList(),
                        ),
                  loading: () => const Padding(
                    padding: EdgeInsets.all(AppSpacing.md),
                    child: HosLoading(),
                  ),
                  error: (e, _) => _ErrorSection(message: e.toString()),
                ),
                const SizedBox(height: AppSpacing.md),

                // Prescriptions
                _SectionHeader(
                  icon: Icons.medication,
                  title: 'Prescriptions',
                  count: prescriptionsAsync.valueOrNull?.length,
                ),
                prescriptionsAsync.when(
                  data: (prescriptions) => prescriptions.isEmpty
                      ? _EmptySection(label: 'No prescriptions')
                      : Column(
                          children: prescriptions
                              .map((p) => _PrescriptionCard(prescription: p))
                              .toList(),
                        ),
                  loading: () => const Padding(
                    padding: EdgeInsets.all(AppSpacing.md),
                    child: HosLoading(),
                  ),
                  error: (e, _) => _ErrorSection(message: e.toString()),
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          );
        },
        loading: () => const Center(child: HosLoading()),
        error: (error, _) => HosError(
          message: 'Failed to load patient details',
          onRetry: () => ref.invalidate(patientByIdProvider(patientId)),
        ),
      ),
    );
  }
}

// ─── Private Widgets ─────────────────────────────────────────────────────────

class _PatientInfoCard extends StatelessWidget {
  const _PatientInfoCard({required this.patient});
  final Patient patient;

  @override
  Widget build(BuildContext context) {
    return HosCard(
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Row(
          children: [
            HosAvatar(
              name: patient.fullName ?? 'Unknown',
              imageUrl: patient.avatarUrl,
              radius: 32,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    patient.fullName ?? 'Unknown Patient',
                    style: AppTypography.h3,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  HosHealthIdBadge(healthId: patient.healthId),
                  const SizedBox(height: AppSpacing.xs),
                  Wrap(
                    spacing: AppSpacing.md,
                    runSpacing: AppSpacing.xs,
                    children: [
                      if (patient.gender != null)
                        _InfoChip(
                          icon: Icons.person_outline,
                          label: patient.gender!,
                        ),
                      if (patient.bloodGroup != null)
                        _InfoChip(
                          icon: Icons.bloodtype,
                          label: patient.bloodGroup!,
                        ),
                      if (patient.dateOfBirth != null)
                        _InfoChip(
                          icon: Icons.cake_outlined,
                          label: AppDateUtils.formatDate(patient.dateOfBirth!),
                        ),
                    ],
                  ),
                  if (patient.allergies.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.xs,
                      children: patient.allergies
                          .map((a) => Chip(
                                label: Text(a, style: AppTypography.caption),
                                backgroundColor:
                                    AppColors.error.withOpacity(0.1),
                                side: BorderSide.none,
                                padding: EdgeInsets.zero,
                                visualDensity: VisualDensity.compact,
                              ))
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(label, style: AppTypography.bodySmall),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.title,
    this.count,
  });
  final IconData icon;
  final String title;
  final int? count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: AppSpacing.sm),
          Text(title, style: AppTypography.h4),
          if (count != null) ...[
            const SizedBox(width: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$count',
                style: AppTypography.caption.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _VisitCard extends StatelessWidget {
  const _VisitCard({required this.visit});
  final Visit visit;

  @override
  Widget build(BuildContext context) {
    return HosCard(
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.event, size: 16, color: AppColors.primary),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  AppDateUtils.formatDate(visit.visitedAt),
                  style: AppTypography.label,
                ),
              ],
            ),
            if (visit.chiefComplaint != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Chief Complaint: ${visit.chiefComplaint}',
                style: AppTypography.bodyMedium,
              ),
            ],
            if (visit.diagnosis != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Diagnosis: ${visit.diagnosis}',
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            if (visit.notes != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                visit.notes!,
                style: AppTypography.bodySmall,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LabReportCard extends StatelessWidget {
  const _LabReportCard({required this.report});
  final LabReport report;

  @override
  Widget build(BuildContext context) {
    return HosCard(
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSpacing.borderRadiusSm),
              ),
              child: const Icon(
                Icons.science_outlined,
                color: AppColors.info,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(report.reportType, style: AppTypography.label),
                  const SizedBox(height: 2),
                  Text(
                    AppDateUtils.formatDate(report.reportDate),
                    style: AppTypography.caption,
                  ),
                  if (report.labName != null)
                    Text(report.labName!, style: AppTypography.caption),
                ],
              ),
            ),
            _StatusBadge(status: report.status),
          ],
        ),
      ),
    );
  }
}

class _PrescriptionCard extends StatelessWidget {
  const _PrescriptionCard({required this.prescription});
  final Prescription prescription;

  @override
  Widget build(BuildContext context) {
    return HosCard(
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.medication, size: 16, color: AppColors.secondary),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Issued: ${AppDateUtils.formatDate(prescription.issuedAt)}',
                  style: AppTypography.label,
                ),
                const Spacer(),
                if (prescription.validUntil != null)
                  Text(
                    'Until: ${AppDateUtils.formatDate(prescription.validUntil!)}',
                    style: AppTypography.caption,
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            ...prescription.medications.map(
              (med) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: Row(
                  children: [
                    const Icon(Icons.circle, size: 6, color: AppColors.textTertiary),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        '${med.name} - ${med.dose}, ${med.frequency}${med.duration != null ? ' (${med.duration})' : ''}',
                        style: AppTypography.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (prescription.notes != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                prescription.notes!,
                style: AppTypography.caption,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final String status;

  Color get _color {
    switch (status) {
      case 'completed':
        return AppColors.success;
      case 'pending':
        return AppColors.warning;
      case 'failed':
        return AppColors.error;
      default:
        return AppColors.textTertiary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: AppTypography.caption.copyWith(
          color: _color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _EmptySection extends StatelessWidget {
  const _EmptySection({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Center(
        child: Text(label, style: AppTypography.bodySmall),
      ),
    );
  }
}

class _ErrorSection extends StatelessWidget {
  const _ErrorSection({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Center(
        child: Text(
          'Error: $message',
          style: AppTypography.bodySmall.copyWith(color: AppColors.error),
        ),
      ),
    );
  }
}
