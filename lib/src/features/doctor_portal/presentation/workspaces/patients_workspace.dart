import 'package:flutter/material.dart';

import '../../../../app/theme/theme.dart';
import '../../../../shared/presentation/shell/health_page.dart';
import '../../demo/doctor_workspace_data.dart';
import '../dialogs/doctor_workspace_dialogs.dart';
import '../widgets/doctor_workspace_widgets.dart';
import '../widgets/patient_list_tile.dart';

class PatientsWorkspace extends StatefulWidget {
  const PatientsWorkspace({super.key});

  @override
  State<PatientsWorkspace> createState() => _PatientsWorkspaceState();
}

class _PatientsWorkspaceState extends State<PatientsWorkspace> {
  String _query = '';
  String _filter = 'All patients';

  @override
  Widget build(BuildContext context) {
    final patients = doctorPatients.where((patient) {
      final matchesQuery =
          patient.name.toLowerCase().contains(_query.toLowerCase()) ||
          patient.condition.toLowerCase().contains(_query.toLowerCase());
      final matchesFilter =
          _filter == 'All patients' ||
          (_filter == 'Needs follow-up' && patient.needsFollowUp) ||
          (_filter == 'Recent' && patient.lastVisit.contains('Jun'));
      return matchesQuery && matchesFilter;
    }).toList();

    return HealthPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WorkspaceHeading(
            title: 'Patient directory',
            description:
                'Review clinical history, care plans, and recent activity.',
            action: ElevatedButton.icon(
              onPressed: () => showActionSnackBar(
                context,
                'New patient registration opened',
              ),
              icon: const Icon(Icons.person_add_alt_1_rounded),
              label: const Text('Add patient'),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 700;
              final search = TextField(
                onChanged: (value) => setState(() => _query = value),
                decoration: const InputDecoration(
                  hintText: 'Search by patient or condition',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
              );
              final filters = Wrap(
                spacing: 8,
                children: [
                  for (final filter in const [
                    'All patients',
                    'Needs follow-up',
                    'Recent',
                  ])
                    FilterChip(
                      label: Text(filter),
                      selected: _filter == filter,
                      onSelected: (_) => setState(() => _filter = filter),
                    ),
                ],
              );
              if (compact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [search, const SizedBox(height: 12), filters],
                );
              }
              return Row(
                children: [
                  Expanded(child: search),
                  const SizedBox(width: 16),
                  filters,
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Text(
                '${patients.length} patients',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              const Icon(Icons.swap_vert_rounded, color: AppColors.textMuted),
              const SizedBox(width: 4),
              const Text('Last visit'),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (patients.isEmpty)
            const EmptyState(
              icon: Icons.person_search_rounded,
              title: 'No patients found',
              description: 'Try another search or filter.',
            )
          else
            Card(
              child: Column(
                children: [
                  for (var index = 0; index < patients.length; index++) ...[
                    PatientListTile(
                      patient: patients[index],
                      onTap: () => showPatientSheet(context, patients[index]),
                    ),
                    if (index != patients.length - 1) const Divider(),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}
