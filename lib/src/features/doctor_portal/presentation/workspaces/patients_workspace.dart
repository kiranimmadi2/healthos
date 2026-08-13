import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/theme.dart';
import '../../../../shared/presentation/shell/health_page.dart';
import '../../../../shared/presentation/widgets/hos_states.dart';
import '../../../../shared/presentation/widgets/hos_widgets.dart';
import '../../../appointments/application/appointment_providers.dart';
import '../../../appointments/domain/appointment.dart';
import '../../../auth/application/user_providers.dart';
import '../../application/doctor_portal_providers.dart';
import '../../demo/doctor_workspace_models.dart';
import '../dialogs/doctor_workspace_dialogs.dart';
import '../widgets/doctor_workspace_widgets.dart';
import '../widgets/patient_list_tile.dart';

class PatientsWorkspace extends ConsumerStatefulWidget {
  const PatientsWorkspace({super.key});

  @override
  ConsumerState<PatientsWorkspace> createState() => _PatientsWorkspaceState();
}

class _PatientsWorkspaceState extends ConsumerState<PatientsWorkspace> {
  final _searchController = TextEditingController();
  String _query = '';
  String _filter = 'All patients';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // The workspace header writes here; mirror it into the local field so a
    // search started from the app bar visibly lands on this screen.
    ref.listen<String>(workspaceSearchProvider, (previous, next) {
      if (next == _query) return;
      setState(() {
        _query = next;
        _searchController.text = next;
      });
    });

    final patientsAsync = ref.watch(allPatientsProvider);
    final appointments = ref.watch(doctorAppointmentsProvider).value ?? const [];

    final List<DoctorPatient> allPatients = patientsAsync.maybeWhen(
      data: (list) {
        return list.map((patientMap) {
          final uid = patientMap['uid'] as String? ?? '';
          final name = patientMap['name'] as String? ?? 'Patient';
          final gender = patientMap['gender'] as String? ?? 'Not specified';
          final dobStr = patientMap['dob'] as String?;

          int age = 0;
          if (dobStr != null) {
            final dob = DateTime.tryParse(dobStr);
            if (dob != null) {
              final now = DateTime.now();
              age = now.year - dob.year;
              if (now.month < dob.month ||
                  (now.month == dob.month && now.day < dob.day)) {
                age--;
              }
            }
          }

          final initials = name
              .split(' ')
              .map((e) => e.isNotEmpty ? e[0] : '')
              .take(2)
              .join()
              .toUpperCase();

          final patientAppointments =
              appointments.where((a) => a.patientId == uid).toList();
          String lastVisit = 'No visits yet';
          bool needsFollowUp = false;
          if (patientAppointments.isNotEmpty) {
            patientAppointments.sort((a, b) => b.dateTime.compareTo(a.dateTime));
            final latestAppt = patientAppointments.first;
            lastVisit = DateFormat('dd MMM yyyy').format(latestAppt.dateTime);
            needsFollowUp = latestAppt.status == AppointmentStatus.pending;
          }

          final colors = [
            AppColors.primary,
            AppColors.secondary,
            AppColors.warning,
            AppColors.error,
            const Color(0xFF7C3AED),
            const Color(0xFF0891B2),
          ];
          final colorIndex = name.hashCode.abs() % colors.length;
          final color = colors[colorIndex];

          return DoctorPatient(
            id: uid,
            name: name,
            initials: initials.isEmpty ? 'PT' : initials,
            age: age,
            gender: gender,
            condition: patientMap['condition'] as String? ?? 'Under observation',
            carePlan: patientMap['carePlan'] as String? ?? 'General wellness',
            lastVisit: lastVisit,
            color: color,
            needsFollowUp: needsFollowUp,
          );
        }).toList();
      },
      orElse: () => const <DoctorPatient>[],
    );

    final filteredPatients = allPatients.where((patient) {
      final matchesQuery =
          patient.name.toLowerCase().contains(_query.toLowerCase()) ||
          patient.condition.toLowerCase().contains(_query.toLowerCase());
      final matchesFilter =
          _filter == 'All patients' ||
          (_filter == 'Needs follow-up' && patient.needsFollowUp) ||
          (_filter == 'Recent' && patient.lastVisit != 'No visits yet');
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
              icon: const Icon(HosIcons.userAdd),
              label: const Text('Add patient'),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 700;
              final search = TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _query = value),
                decoration: InputDecoration(
                  hintText: 'Search by patient or condition',
                  prefixIcon: const Icon(HosIcons.search),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Clear search',
                          icon: const Icon(Icons.close_rounded, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            ref.read(workspaceSearchProvider.notifier).clear();
                            setState(() => _query = '');
                          },
                        ),
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
                '${filteredPatients.length} patients',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              Icon(Icons.swap_vert_rounded, color: context.hos.textMuted),
              const SizedBox(width: 4),
              const Text('Last visit'),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          patientsAsync.when(
            loading: () => const Card(
              child: Padding(
                padding: EdgeInsets.all(48.0),
                child: HosLoading(),
              ),
            ),
            error: (e, st) => HosErrorState(
              error: e,
              compact: true,
              title: 'Could not load patients',
            ),
            data: (_) {
              if (filteredPatients.isEmpty) {
                return const EmptyState(
                  icon: Icons.person_search_rounded,
                  title: 'No patients found',
                  description: 'Try another search or filter.',
                );
              }
              return Card(
                child: Column(
                  children: [
                    for (
                      var index = 0;
                      index < filteredPatients.length;
                      index++
                    ) ...[
                      PatientListTile(
                        patient: filteredPatients[index],
                        onTap: () =>
                            showPatientSheet(context, filteredPatients[index]),
                      ),
                      if (index != filteredPatients.length - 1) const Divider(),
                    ],
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
