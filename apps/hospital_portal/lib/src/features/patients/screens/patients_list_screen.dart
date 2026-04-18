import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_client/supabase_client.dart';
import 'package:ui_kit/ui_kit.dart';

final patientRepositoryProvider =
    Provider<PatientRepository>((ref) => PatientRepository());

final allPatientsProvider = FutureProvider<List<Patient>>((ref) {
  final repo = ref.read(patientRepositoryProvider);
  return repo.search('', limit: 200);
});

/// Fetches the most recent visit for a given patient.
final lastVisitProvider =
    FutureProvider.family<Visit?, String>((ref, patientId) async {
  final repo = VisitRepository();
  final visits = await repo.getByPatientId(patientId, limit: 1);
  return visits.isNotEmpty ? visits.first : null;
});

class PatientsListScreen extends ConsumerStatefulWidget {
  const PatientsListScreen({super.key});

  @override
  ConsumerState<PatientsListScreen> createState() =>
      _PatientsListScreenState();
}

class _PatientsListScreenState extends ConsumerState<PatientsListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Patient> _filterPatients(List<Patient> patients) {
    if (_searchQuery.isEmpty) return patients;
    final query = _searchQuery.toLowerCase();
    return patients
        .where((p) =>
            (p.fullName?.toLowerCase().contains(query) ?? false) ||
            p.healthId.toLowerCase().contains(query))
        .toList();
  }

  String _computeAge(DateTime? dateOfBirth) {
    if (dateOfBirth == null) return 'N/A';
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age.toString();
  }

  @override
  Widget build(BuildContext context) {
    final patientsAsync = ref.watch(allPatientsProvider);

    return Scaffold(
      body: Padding(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.lg),
            Text('Patients', style: AppTypography.h1),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Manage and view all registered patients.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: 360,
              child: HosTextField(
                controller: _searchController,
                hint: 'Search by name or Health ID...',
                prefixIcon: Icons.search,
                onChanged: (value) {
                  setState(() => _searchQuery = value);
                },
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Expanded(
              child: patientsAsync.when(
                loading: () => const Center(child: HosLoading()),
                error: (e, _) => HosError(
                  message: e.toString(),
                  onRetry: () => ref.invalidate(allPatientsProvider),
                ),
                data: (patients) {
                  final filtered = _filterPatients(patients);
                  if (filtered.isEmpty) {
                    return const HosEmptyState(
                      message: 'No patients found.',
                      icon: Icons.people_outline,
                    );
                  }
                  return HosCard(
                    child: SingleChildScrollView(
                      child: SizedBox(
                        width: double.infinity,
                        child: DataTable(
                          headingRowColor: WidgetStateProperty.all(
                            AppColors.surface,
                          ),
                          columns: const [
                            DataColumn(label: Text('Name')),
                            DataColumn(label: Text('Health ID')),
                            DataColumn(label: Text('Age')),
                            DataColumn(label: Text('Gender')),
                            DataColumn(label: Text('Last Visit')),
                            DataColumn(label: Text('Actions')),
                          ],
                          rows: filtered.map((patient) {
                            final name = patient.fullName ?? 'Unknown';
                            return DataRow(
                              cells: [
                                DataCell(
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CircleAvatar(
                                        radius: 16,
                                        backgroundColor: AppColors.primary
                                            .withValues(alpha: 0.1),
                                        child: Text(
                                          name[0].toUpperCase(),
                                          style:
                                              AppTypography.caption.copyWith(
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.sm),
                                      Text(name,
                                          style: AppTypography.bodyMedium),
                                    ],
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    patient.healthId,
                                    style: AppTypography.bodySmall.copyWith(
                                      fontFamily: 'monospace',
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                                DataCell(
                                    Text(_computeAge(patient.dateOfBirth))),
                                DataCell(Text(patient.gender ?? 'N/A')),
                                DataCell(_LastVisitCell(
                                    patientId: patient.id)),
                                DataCell(
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                            Icons.visibility_outlined,
                                            size: 18),
                                        onPressed: () => context.push('/patients/${patient.id}'),
                                        tooltip: 'View Records',
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                            Icons.history_outlined,
                                            size: 18),
                                        onPressed: () => context.push('/patients/${patient.id}'),
                                        tooltip: 'Visit History',
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Inline widget that asynchronously displays the last visit date for a patient.
class _LastVisitCell extends ConsumerWidget {
  const _LastVisitCell({required this.patientId});

  final String patientId;

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visitAsync = ref.watch(lastVisitProvider(patientId));
    return visitAsync.when(
      loading: () => const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      error: (_, _) => Text(
        'Error',
        style: AppTypography.bodySmall.copyWith(color: AppColors.error),
      ),
      data: (visit) => Text(
        visit != null ? _formatDate(visit.visitedAt) : 'No visits',
        style: AppTypography.bodySmall.copyWith(
          color: visit != null ? AppColors.textPrimary : AppColors.textSecondary,
        ),
      ),
    );
  }
}
