import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_client/supabase_client.dart';
import 'package:ui_kit/ui_kit.dart';

import 'quick_note_screen.dart';
import 'edit_medical_history_sheet.dart';

final patientByIdProvider =
    FutureProvider.family<Patient?, String>((ref, patientId) async {
  return PatientRepository().getById(patientId);
});

final patientVisitsProvider =
    FutureProvider.family<List<Visit>, String>((ref, patientId) async {
  return VisitRepository().getByPatientId(patientId);
});

final patientPrescriptionsProvider =
    FutureProvider.family<List<Prescription>, String>((ref, patientId) async {
  return PrescriptionRepository().getByPatientId(patientId);
});

final patientReportsProvider =
    FutureProvider.family<List<LabReport>, String>((ref, patientId) async {
  return LabReportRepository().getByPatientId(patientId);
});

final patientNotesProvider =
    FutureProvider.family<List<DoctorNote>, String>((ref, patientId) async {
  return DoctorNoteRepository().getByPatientId(patientId);
});

class PatientDetailScreen extends ConsumerStatefulWidget {
  const PatientDetailScreen({super.key, required this.patientId});
  final String patientId;

  @override
  ConsumerState<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends ConsumerState<PatientDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  bool _fabOpen = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _refresh() {
    ref.invalidate(patientByIdProvider(widget.patientId));
    ref.invalidate(patientVisitsProvider(widget.patientId));
    ref.invalidate(patientReportsProvider(widget.patientId));
    ref.invalidate(patientNotesProvider(widget.patientId));
  }

  @override
  Widget build(BuildContext context) {
    final patientAsync = ref.watch(patientByIdProvider(widget.patientId));

    return Scaffold(
      appBar: AppBar(
        title: patientAsync.when(
          data: (p) => Text(p?.fullName ?? 'Patient Detail'),
          loading: () => const Text('Loading...'),
          error: (_, _) => const Text('Patient Detail'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            tooltip: 'AI Summary',
            onPressed: () => context.go('/patients/${widget.patientId}/ai-summary'),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Timeline'),
            Tab(text: 'Notes'),
          ],
        ),
      ),
      floatingActionButton: _SpeedDialFab(
        patientId: widget.patientId,
        isOpen: _fabOpen,
        onToggle: () => setState(() => _fabOpen = !_fabOpen),
        onAction: (_) {
          setState(() => _fabOpen = false);
          _refresh();
        },
      ),
      body: patientAsync.when(
        data: (patient) {
          if (patient == null) {
            return const HosEmptyState(
              icon: Icons.person_off_outlined,
              message: 'Patient not found.',
            );
          }
          return TabBarView(
            controller: _tabController,
            children: [
              _TimelineTab(patientId: widget.patientId, patient: patient, onRefresh: _refresh),
              _NotesTab(patientId: widget.patientId),
            ],
          );
        },
        loading: () => const Center(child: HosLoading()),
        error: (error, _) => HosError(
          message: 'Failed to load patient details',
          onRetry: () => ref.invalidate(patientByIdProvider(widget.patientId)),
        ),
      ),
    );
  }
}

// ─── Speed Dial FAB ──────────────────────────────────────────────────────────

class _SpeedDialFab extends ConsumerWidget {
  const _SpeedDialFab({
    required this.patientId,
    required this.isOpen,
    required this.onToggle,
    required this.onAction,
  });

  final String patientId;
  final bool isOpen;
  final VoidCallback onToggle;
  final ValueChanged<String> onAction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (isOpen) ...[
          _FabItem(
            icon: Icons.add_circle_outline,
            label: 'New Visit',
            onTap: () {
              onAction('visit');
              context.go('/patients/$patientId/visit/create');
            },
          ),
          _FabItem(
            icon: Icons.medication_outlined,
            label: 'New Prescription',
            onTap: () {
              onAction('rx');
              context.go('/patients/$patientId/prescription/create');
            },
          ),
          _FabItem(
            icon: Icons.science_outlined,
            label: 'Add Lab Result',
            onTap: () {
              onAction('lab');
              context.go('/patients/$patientId/lab/add');
            },
          ),
          _FabItem(
            icon: Icons.note_add_outlined,
            label: 'Quick Note',
            onTap: () async {
              onAction('note');
              await QuickNoteScreen.show(context, patientId);
            },
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        FloatingActionButton(
          onPressed: onToggle,
          child: AnimatedRotation(
            turns: isOpen ? 0.125 : 0,
            duration: const Duration(milliseconds: 200),
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}

class _FabItem extends StatelessWidget {
  const _FabItem({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
            ),
            child: Text(label, style: AppTypography.caption),
          ),
          const SizedBox(width: AppSpacing.sm),
          FloatingActionButton.small(
            heroTag: label,
            onPressed: onTap,
            child: Icon(icon, size: 20),
          ),
        ],
      ),
    );
  }
}

// ─── Timeline Tab ─────────────────────────────────────────────────────────────

class _TimelineTab extends ConsumerWidget {
  const _TimelineTab({
    required this.patientId,
    required this.patient,
    required this.onRefresh,
  });

  final String patientId;
  final Patient patient;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visitsAsync = ref.watch(patientVisitsProvider(patientId));
    final reportsAsync = ref.watch(patientReportsProvider(patientId));
    final prescriptionsAsync = ref.watch(patientPrescriptionsProvider(patientId));

    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PatientInfoCard(patient: patient, onEditHistory: () async {
            await EditMedicalHistorySheet.show(context, patient);
            onRefresh();
          }),
          const SizedBox(height: AppSpacing.lg),

          Text('Patient Timeline', style: AppTypography.h3),
          const SizedBox(height: AppSpacing.md),

          _SectionHeader(icon: Icons.event_note, title: 'Visits',
              count: visitsAsync.valueOrNull?.length),
          visitsAsync.when(
            data: (visits) => visits.isEmpty
                ? _EmptySection(label: 'No visits recorded')
                : Column(children: visits.map((v) => _VisitCard(visit: v)).toList()),
            loading: () => const Padding(padding: EdgeInsets.all(AppSpacing.md), child: HosLoading()),
            error: (e, _) => _ErrorSection(message: e.toString()),
          ),
          const SizedBox(height: AppSpacing.md),

          _SectionHeader(icon: Icons.science_outlined, title: 'Lab Reports',
              count: reportsAsync.valueOrNull?.length),
          reportsAsync.when(
            data: (reports) => reports.isEmpty
                ? _EmptySection(label: 'No lab reports')
                : Column(children: reports.map((r) => _LabReportCard(report: r)).toList()),
            loading: () => const Padding(padding: EdgeInsets.all(AppSpacing.md), child: HosLoading()),
            error: (e, _) => _ErrorSection(message: e.toString()),
          ),
          const SizedBox(height: AppSpacing.md),

          _SectionHeader(icon: Icons.medication, title: 'Prescriptions',
              count: prescriptionsAsync.valueOrNull?.length),
          prescriptionsAsync.when(
            data: (prescriptions) => prescriptions.isEmpty
                ? _EmptySection(label: 'No prescriptions')
                : Column(children: prescriptions.map((p) => _PrescriptionCard(prescription: p)).toList()),
            loading: () => const Padding(padding: EdgeInsets.all(AppSpacing.md), child: HosLoading()),
            error: (e, _) => _ErrorSection(message: e.toString()),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

// ─── Notes Tab ────────────────────────────────────────────────────────────────

class _NotesTab extends ConsumerWidget {
  const _NotesTab({required this.patientId});
  final String patientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(patientNotesProvider(patientId));

    return notesAsync.when(
      loading: () => const Center(child: HosLoading()),
      error: (e, _) => HosError(message: e.toString()),
      data: (notes) {
        if (notes.isEmpty) {
          return const HosEmptyState(
            icon: Icons.note_outlined,
            message: 'No notes yet. Use the + button to add a quick note.',
          );
        }
        return ListView.separated(
          padding: AppSpacing.screenPadding,
          itemCount: notes.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
          itemBuilder: (context, i) => _NoteCard(note: notes[i]),
        );
      },
    );
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard({required this.note});
  final DoctorNote note;

  @override
  Widget build(BuildContext context) {
    return HosCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                note.isPrivate ? Icons.lock_outline : Icons.note_outlined,
                size: 14,
                color: note.isPrivate ? AppColors.warning : AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                note.isPrivate ? 'Private' : 'Shared',
                style: AppTypography.caption.copyWith(
                  color: note.isPrivate ? AppColors.warning : AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              if (note.createdAt != null)
                Text(AppDateUtils.formatDate(note.createdAt!), style: AppTypography.caption),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(note.content, style: AppTypography.bodyMedium),
        ],
      ),
    );
  }
}

// ─── Private Widgets ─────────────────────────────────────────────────────────

class _PatientInfoCard extends StatelessWidget {
  const _PatientInfoCard({required this.patient, this.onEditHistory});
  final Patient patient;
  final VoidCallback? onEditHistory;

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
                                    AppColors.error.withValues(alpha: 0.1),
                                side: BorderSide.none,
                                padding: EdgeInsets.zero,
                                visualDensity: VisualDensity.compact,
                              ))
                          .toList(),
                    ),
                  ],
                  if (onEditHistory != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    TextButton.icon(
                      icon: const Icon(Icons.edit_outlined, size: 14),
                      label: const Text('Edit History'),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                      ),
                      onPressed: onEditHistory,
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
                color: AppColors.primary.withValues(alpha: 0.1),
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
                color: AppColors.info.withValues(alpha: 0.1),
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
        color: _color.withValues(alpha: 0.1),
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
