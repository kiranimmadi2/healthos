import 'package:flutter/material.dart';

import '../../../../app/theme/theme.dart';
import '../../../../shared/presentation/widgets/status_pill.dart';
import '../../demo/doctor_workspace_models.dart';
import '../widgets/doctor_workspace_widgets.dart';

void showActionSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

Future<void> showAppointmentSheet(
  BuildContext context,
  DoctorAppointment appointment,
) {
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
                AvatarInitials(
                  initials: appointment.initials,
                  color: appointment.color,
                  radius: 28,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment.name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text('${appointment.time} · ${appointment.type}'),
                    ],
                  ),
                ),
                StatusPill(
                  label: appointment.status,
                  foreground: appointment.statusColor,
                  background: appointment.statusBackground,
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Visit details',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            DetailRow(
              icon: Icons.medical_services_outlined,
              label: 'Reason',
              value: appointment.reason,
            ),
            const DetailRow(
              icon: Icons.location_on_outlined,
              label: 'Location',
              value: 'Consultation room 204',
            ),
            const DetailRow(
              icon: Icons.notes_rounded,
              label: 'Clinical note',
              value: 'Review current medication and recent blood pressure log.',
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.chat_bubble_outline_rounded),
                    label: const Text('Message'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      showActionSnackBar(context, 'Consultation opened');
                    },
                    icon: const Icon(Icons.arrow_forward_rounded),
                    label: const Text('Open visit'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

Future<void> showPatientSheet(BuildContext context, DoctorPatient patient) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: SingleChildScrollView(
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
                  IconButton(
                    tooltip: 'More actions',
                    onPressed: () {},
                    icon: const Icon(Icons.more_horiz_rounded),
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
                'Recent clinical activity',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              const DetailRow(
                icon: Icons.monitor_heart_outlined,
                label: 'Vitals',
                value: 'BP 128/82 · Pulse 74 bpm · SpO₂ 98%',
              ),
              const DetailRow(
                icon: Icons.medication_outlined,
                label: 'Medication',
                value: 'Amlodipine 5 mg · once daily',
              ),
              const DetailRow(
                icon: Icons.event_note_outlined,
                label: 'Next step',
                value: 'Follow-up consultation in 4 weeks',
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
                      onPressed: () {
                        Navigator.pop(context);
                        showActionSnackBar(context, 'Patient chart opened');
                      },
                      icon: const Icon(Icons.folder_open_outlined),
                      label: const Text('Open chart'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
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
