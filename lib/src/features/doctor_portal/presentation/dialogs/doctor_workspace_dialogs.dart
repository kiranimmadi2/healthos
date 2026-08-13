import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/theme.dart';
import '../../../../shared/domain/app_failure.dart';
import '../../../../shared/presentation/widgets/hos_states.dart';
import '../../../../shared/presentation/widgets/hos_widgets.dart';
import '../../../ai_triage/application/ai_triage_providers.dart';
import '../../../records/application/record_providers.dart';
import '../../../records/domain/medical_record.dart';
import '../../demo/doctor_workspace_models.dart';
import '../widgets/doctor_workspace_widgets.dart';

void showActionSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

Future<void> showPatientSheet(BuildContext context, DoctorPatient patient) {
  bool generatingSummary = false;
  String? aiSummary;

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => Consumer(
      builder: (context, ref, child) {
        final recordsAsync = ref.watch(patientRecordsProvider(patient.id));

        return SafeArea(
          child: StatefulBuilder(
            builder: (context, setLocalState) {
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Patient Header
                      Row(
                        children: [
                          AvatarInitials(
                            initials: patient.initials,
                            color: patient.color,
                            radius: 30,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  patient.name,
                                  style: Theme.of(context).textTheme.headlineMedium,
                                ),
                                Text(
                                  '${patient.age} years · ${patient.gender} · Patient ID: ${patient.id}',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Patient Facts
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          PatientFact(
                            label: 'Primary condition',
                            value: patient.condition,
                          ),
                          PatientFact(label: 'Care plan', value: patient.carePlan),
                          PatientFact(label: 'Last visit', value: patient.lastVisit),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Vitals. Nothing in the app records these yet, so there
                      // is deliberately no card here: this previously rendered
                      // a const 72bpm / 120/80 / 98% / 98.6F card that was
                      // identical for every patient and looked measured.
                      Text(
                        'Recent Vitals',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      const HosEmptyState(
                        compact: true,
                        icon: Icons.monitor_heart_outlined,
                        title: 'No vitals recorded',
                        message:
                            'Vitals recorded during a visit will appear here.',
                      ),
                      const SizedBox(height: 24),

                      // Gemini AI Clinical Summary Section
                      Text(
                        'Clinical AI Insights',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      if (generatingSummary)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.primarySoft,
                            borderRadius: BorderRadius.circular(AppRadius.medium),
                          ),
                          child: const Row(
                            children: [
                              HosLoading(size: 20, color: AppColors.primary),
                              SizedBox(width: 12),
                              Text('Gemini is analyzing patient records...'),
                            ],
                          ),
                        )
                      else if (aiSummary != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0FDF4),
                            borderRadius: BorderRadius.circular(AppRadius.medium),
                            border: Border.all(color: const Color(0xFFDCFCE7)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.auto_awesome, color: Color(0xFF16A34A), size: 18),
                                  SizedBox(width: 8),
                                  Text(
                                    'Gemini Clinical Summary',
                                    style: TextStyle(
                                      color: Color(0xFF16A34A),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                aiSummary!,
                                style: const TextStyle(height: 1.5, color: Color(0xFF1F2937)),
                              ),
                            ],
                          ),
                        )
                      else
                        recordsAsync.maybeWhen(
                          data: (records) {
                            if (records.isEmpty) return const SizedBox.shrink();
                            return SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  setLocalState(() => generatingSummary = true);
                                  try {
                                    final historyText = records
                                        .map((r) => '${r.category} (${r.title}): ${r.notes}')
                                        .join('\n');
                                    final summary = await ref
                                        .read(aiServiceProvider)
                                        .getClinicalSummary(historyText);
                                    setLocalState(() {
                                      aiSummary = summary;
                                      generatingSummary = false;
                                    });
                                  } catch (e) {
                                    setLocalState(() => generatingSummary = false);
                                    if (context.mounted) {
                                      showActionSnackBar(
                                        context,
                                        describeFailure(e),
                                      );
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primarySoft,
                                  foregroundColor: AppColors.primary,
                                  elevation: 0,
                                ),
                                icon: const Icon(Icons.auto_awesome),
                                label: const Text('Generate AI Clinical Summary'),
                              ),
                            );
                          },
                          orElse: () => const SizedBox.shrink(),
                        ),
                      const SizedBox(height: 24),

                      // Patient-Owned Medication Schedules (Doctor Access)
                      Text(
                        'Active Medication Schedules',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .doc(patient.id)
                            .collection('medication_schedules')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const HosLoading();
                          }
                          final docs = snapshot.data?.docs ?? [];
                          if (docs.isEmpty) {
                            // Was a fabricated "Amoxicillin 500mg" card shown
                            // whenever a patient had no medications recorded --
                            // a prescription a clinician could have acted on
                            // that did not exist.
                            return const HosEmptyState(
                              compact: true,
                              icon: Icons.medication_outlined,
                              title: 'No active medications',
                              message: 'Prescriptions for this patient will '
                                  'appear here once recorded.',
                            );
                          }
                          return Column(
                            children: docs.map((doc) {
                              final d = doc.data();
                              return HosPrescriptionCard(
                                medicationName: d['name'] as String? ?? 'Medication',
                                dosage: d['dosage'] as String? ?? 'Standard dosage',
                                frequency: d['frequency'] as String? ?? 'Daily',
                                duration: d['duration'] as String? ?? 'Ongoing',
                                notes: d['instructions'] as String?,
                              );
                            }).toList(),
                          );
                        },
                      ),
                      const SizedBox(height: 24),

                      // Patient Medical Vault & Documents
                      Text(
                        'Patient Medical Vault & Documents',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      recordsAsync.when(
                        loading: () => const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: HosLoading(),
                          ),
                        ),
                        error: (err, _) => HosErrorState(
                          error: err,
                          compact: true,
                          title: 'Could not load records',
                        ),
                        data: (records) {
                          if (records.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Text(
                                'No documents uploaded to their vault yet.',
                                style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            );
                          }
                          return Column(
                            children: [
                              for (final record in records)
                                Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    color: AppColors.background,
                                    borderRadius: BorderRadius.circular(AppRadius.medium),
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: AppColors.primarySoft,
                                      child: Icon(
                                        record.category == RecordCategory.labReport
                                            ? HosIcons.stethoscope
                                            : record.category == RecordCategory.imaging
                                                ? HosIcons.user
                                                : HosIcons.fileText,
                                        color: AppColors.primary,
                                        size: 20,
                                      ),
                                    ),
                                    title: Text(
                                      record.title,
                                      style: const TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                    subtitle: Text(
                                      '${record.category} · ${DateFormat('MMM dd, yyyy').format(record.date)}',
                                    ),
                                    trailing: record.notes.isNotEmpty
                                        ? IconButton(
                                            icon: const Icon(HosIcons.alertCircle, color: AppColors.textMuted),
                                            onPressed: () {
                                              showDialog<void>(
                                                context: context,
                                                builder: (context) => AlertDialog(
                                                  title: Text(record.title),
                                                  content: Text(record.notes),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () => Navigator.pop(context),
                                                      child: const Text('Close'),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          )
                                        : null,
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 24),

                      // Patient Clinical Timeline
                      Text(
                        'Recent Clinical Timeline',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      // Built from this patient's actual records. Previously
                      // two invented entries ("Complete Blood Count (CBC)",
                      // "2 weeks ago") shown for every patient.
                      recordsAsync.when(
                        loading: () => const HosSkeletonList(
                          count: 2,
                          padding: EdgeInsets.zero,
                        ),
                        error: (err, _) => HosErrorState(
                          error: err,
                          compact: true,
                          title: 'Could not load timeline',
                        ),
                        data: (records) {
                          if (records.isEmpty) {
                            return const HosEmptyState(
                              compact: true,
                              icon: Icons.timeline_rounded,
                              title: 'No clinical history yet',
                              message:
                                  'Visits and records will build this timeline.',
                            );
                          }
                          final recent = records.take(5).toList();
                          return HosTimeline(
                            items: [
                              for (final record in recent)
                                HosTimelineItem(
                                  title: record.title,
                                  subtitle: record.notes.isEmpty
                                      ? record.category
                                      : record.notes,
                                  date: DateFormat(
                                    'MMM dd, yyyy',
                                  ).format(record.date),
                                  icon: _timelineIcon(record.category),
                                  color: _timelineColor(context, record.category),
                                ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 24),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                showActionSnackBar(context, 'Message thread opened');
                              },
                              icon: const Icon(Icons.chat_bubble_outline_rounded),
                              label: const Text('Message'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.close_rounded),
                              label: const Text('Close'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    ),
  );
}

IconData _timelineIcon(String category) {
  return switch (category) {
    RecordCategory.labReport => HosIcons.fileText,
    RecordCategory.prescription => HosIcons.pill,
    RecordCategory.imaging => Icons.document_scanner_rounded,
    RecordCategory.immunization => HosIcons.shield,
    _ => HosIcons.stethoscope,
  };
}

Color _timelineColor(BuildContext context, String category) {
  final hos = context.hos;
  return switch (category) {
    RecordCategory.labReport => hos.categoryLab,
    RecordCategory.prescription => hos.categoryPrescription,
    RecordCategory.imaging => hos.categoryImaging,
    RecordCategory.immunization => hos.categoryImmunization,
    _ => hos.categoryOther,
  };
}

Future<void> showReportSheet(BuildContext context, DiagnosticReport report) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: report.iconBackground,
                    borderRadius: BorderRadius.circular(AppRadius.medium),
                  ),
                  child: Icon(report.icon, color: report.iconColor),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        report.type,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text('${report.patient} · ${report.ordered}'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Clinical summary',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(report.summary),
            const SizedBox(height: 20),
            const DetailRow(
              icon: HosIcons.stethoscope,
              label: 'Key finding',
              value: 'One value falls outside the reference range.',
            ),
            const DetailRow(
              icon: HosIcons.alertCircle,
              label: 'Suggested action',
              value: 'Correlate with symptoms and repeat testing if indicated.',
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  showActionSnackBar(context, 'Report added to patient chart');
                },
                icon: const Icon(HosIcons.check),
                label: const Text('Acknowledge report'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
