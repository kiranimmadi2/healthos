import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_kit/ui_kit.dart';

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

  // Sample data - will be replaced with Supabase queries
  static const _doctors = [
    _DoctorRow(
      name: 'Dr. Anil Kumar',
      specialization: 'Cardiology',
      email: 'anil.kumar@hospital.com',
      status: 'Active',
    ),
    _DoctorRow(
      name: 'Dr. Meera Reddy',
      specialization: 'Dermatology',
      email: 'meera.reddy@hospital.com',
      status: 'Active',
    ),
    _DoctorRow(
      name: 'Dr. Sanjay Gupta',
      specialization: 'Orthopedics',
      email: 'sanjay.gupta@hospital.com',
      status: 'Active',
    ),
    _DoctorRow(
      name: 'Dr. Priya Nair',
      specialization: 'Pediatrics',
      email: 'priya.nair@hospital.com',
      status: 'On Leave',
    ),
    _DoctorRow(
      name: 'Dr. Rajesh Sharma',
      specialization: 'General Medicine',
      email: 'rajesh.sharma@hospital.com',
      status: 'Active',
    ),
    _DoctorRow(
      name: 'Dr. Lakshmi Iyer',
      specialization: 'Neurology',
      email: 'lakshmi.iyer@hospital.com',
      status: 'Active',
    ),
    _DoctorRow(
      name: 'Dr. Vikram Singh',
      specialization: 'Ophthalmology',
      email: 'vikram.singh@hospital.com',
      status: 'Inactive',
    ),
  ];

  List<_DoctorRow> get _filteredDoctors {
    if (_searchQuery.isEmpty) return _doctors;
    final query = _searchQuery.toLowerCase();
    return _doctors
        .where((d) =>
            d.name.toLowerCase().contains(query) ||
            d.specialization.toLowerCase().contains(query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
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
                  onPressed: () {
                    // TODO: Navigate to add doctor form
                  },
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
              child: HosCard(
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
                      rows: _filteredDoctors.map((doctor) {
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
                                      doctor.name
                                          .split(' ')
                                          .last[0]
                                          .toUpperCase(),
                                      style:
                                          AppTypography.labelSmall.copyWith(
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Text(doctor.name,
                                      style: AppTypography.bodyMedium),
                                ],
                              ),
                            ),
                            DataCell(Text(doctor.specialization)),
                            DataCell(Text(doctor.email)),
                            DataCell(_StatusChip(status: doctor.status)),
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined,
                                        size: 18),
                                    onPressed: () {},
                                    tooltip: 'Edit',
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                        Icons.visibility_outlined,
                                        size: 18),
                                    onPressed: () {},
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DoctorRow {
  final String name;
  final String specialization;
  final String email;
  final String status;

  const _DoctorRow({
    required this.name,
    required this.specialization,
    required this.email,
    required this.status,
  });
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
