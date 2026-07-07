import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/theme.dart';
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
                                  '${patient.age} years · ${patient.gender} · ${patient.id}',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
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
                      const SizedBox(height: 28),
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
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primary,
                                ),
                              ),
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
                                      showActionSnackBar(context, 'AI error: $e');
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
                      const SizedBox(height: 28),
                      Text(
                        'Patient Medical Vault',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      recordsAsync.when(
                        loading: () => const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        error: (err, _) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text('Error loading vault: $err'),
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
                                            ? Icons.science_outlined
                                            : record.category == RecordCategory.imaging
                                                ? Icons.portrait_rounded
                                                : Icons.description_outlined,
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
                                            icon: const Icon(Icons.info_outline, color: AppColors.textMuted),
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
              icon: Icons.science_outlined,
              label: 'Key finding',
              value: 'One value falls outside the reference range.',
            ),
            const DetailRow(
              icon: Icons.lightbulb_outline_rounded,
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
                icon: const Icon(Icons.check_rounded),
                label: const Text('Acknowledge report'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
