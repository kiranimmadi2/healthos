import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_client/supabase_client.dart';
import 'package:ui_kit/ui_kit.dart';

final doctorRepositoryProvider =
    Provider<DoctorRepository>((ref) => DoctorRepository());

final allDoctorsProvider = FutureProvider<List<Doctor>>((ref) {
  final repo = ref.read(doctorRepositoryProvider);
  return repo.search('', limit: 200);
});

class DoctorsListScreen extends ConsumerStatefulWidget {
  const DoctorsListScreen({super.key});

  @override
  ConsumerState<DoctorsListScreen> createState() => _DoctorsListScreenState();
}

class _DoctorsListScreenState extends ConsumerState<DoctorsListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Doctor> _filterDoctors(List<Doctor> doctors) {
    if (_searchQuery.isEmpty) return doctors;
    final query = _searchQuery.toLowerCase();
    return doctors
        .where((d) =>
            d.fullName.toLowerCase().contains(query) ||
            (d.specialization?.toLowerCase().contains(query) ?? false))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final doctorsAsync = ref.watch(allDoctorsProvider);

    return Scaffold(
      body: Padding(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Doctors', style: AppTypography.h1),
                HosButton(
                  label: 'Add Doctor',
                  onPressed: () => context.push('/doctors/add'),
                  icon: Icons.add,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: 360,
              child: HosTextField(
                controller: _searchController,
                hint: 'Search by name or specialization...',
                prefixIcon: Icons.search,
                onChanged: (value) {
                  setState(() => _searchQuery = value);
                },
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Expanded(
              child: doctorsAsync.when(
                loading: () => const Center(child: HosLoading()),
                error: (e, _) => HosError(
                  message: e.toString(),
                  onRetry: () => ref.invalidate(allDoctorsProvider),
                ),
                data: (doctors) {
                  final filtered = _filterDoctors(doctors);
                  if (filtered.isEmpty) {
                    return const HosEmptyState(
                      message: 'No doctors found.',
                      icon: Icons.medical_services_outlined,
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
                            DataColumn(label: Text('Specialization')),
                            DataColumn(label: Text('Email')),
                            DataColumn(label: Text('Status')),
                            DataColumn(label: Text('Actions')),
                          ],
                          rows: filtered.map((doctor) {
                            final status =
                                doctor.verified ? 'Active' : 'Inactive';
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
                                          doctor.fullName
                                              .split(' ')
                                              .last[0]
                                              .toUpperCase(),
                                          style: AppTypography.caption
                                              .copyWith(
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.sm),
                                      Text(doctor.fullName,
                                          style: AppTypography.bodyMedium),
                                    ],
                                  ),
                                ),
                                DataCell(Text(
                                    doctor.specialization ?? 'N/A')),
                                DataCell(Text(doctor.email ?? 'N/A')),
                                DataCell(_StatusChip(status: status)),
                                DataCell(
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit_outlined,
                                            size: 18),
                                        onPressed: () => context.push('/doctors/${doctor.id}/edit'),
                                        tooltip: 'Edit',
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                            Icons.visibility_outlined,
                                            size: 18),
                                        onPressed: () => context.push('/doctors/${doctor.id}'),
                                        tooltip: 'View',
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

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case 'Active':
        color = Colors.green;
      case 'On Leave':
        color = Colors.orange;
      case 'Inactive':
        color = Colors.red;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: AppTypography.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
