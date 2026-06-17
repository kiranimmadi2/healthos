import 'package:flutter/material.dart';

import '../../../../app/theme/theme.dart';
import '../../../../shared/presentation/widgets/status_pill.dart';
import '../../demo/doctor_workspace_models.dart';
import 'doctor_workspace_widgets.dart';

class PatientListTile extends StatelessWidget {
  const PatientListTile({
    super.key,
    required this.patient,
    required this.onTap,
  });

  final DoctorPatient patient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 620;
            return Row(
              children: [
                AvatarInitials(
                  initials: patient.initials,
                  color: patient.color,
                  radius: 24,
                ),
                const SizedBox(width: 14),
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patient.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        '${patient.age} yrs · ${patient.gender} · ${patient.id}',
                      ),
                      if (compact) ...[
                        const SizedBox(height: 5),
                        Text(
                          patient.condition,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text('Last visit ${patient.lastVisit}'),
                      ],
                    ],
                  ),
                ),
                if (!compact) ...[
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          patient.condition,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(patient.carePlan),
                      ],
                    ),
                  ),
                  Expanded(child: Text(patient.lastVisit)),
                ],
                if (patient.needsFollowUp)
                  const StatusPill(
                    label: 'Follow-up',
                    foreground: AppColors.warning,
                    background: AppColors.warningSoft,
                  ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textMuted,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
