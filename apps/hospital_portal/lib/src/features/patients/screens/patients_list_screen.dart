import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_kit/ui_kit.dart';

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

  // Sample data - will be replaced with Supabase queries
  static const _patients = [
    _PatientRow(
      name: 'Rahul Sharma',
      healthId: 'HID-20260101-001',
      lastVisit: '2026-03-14',
      age: '32',
      gender: 'Male',
    ),
    _PatientRow(
      name: 'Priya Patel',
      healthId: 'HID-20260102-002',
      lastVisit: '2026-03-13',
      age: '28',
      gender: 'Female',
    ),
    _PatientRow(
      name: 'Ankit Singh',
      healthId: 'HID-20260103-003',
      lastVisit: '2026-03-12',
      age: '45',
      gender: 'Male',
    ),
    _PatientRow(
      name: 'Suresh Gupta',
      healthId: 'HID-20260104-004',
      lastVisit: '2026-03-10',
      age: '56',
      gender: 'Male',
    ),
    _PatientRow(
      name: 'Kavita Desai',
      healthId: 'HID-20260105-005',
      lastVisit: '2026-03-09',
      age: '34',
      gender: 'Female',
    ),
    _PatientRow(
      name: 'Deepak Joshi',
      healthId: 'HID-20260106-006',
      lastVisit: '2026-03-08',
      age: '41',
      gender: 'Male',
    ),
    _PatientRow(
      name: 'Neha Verma',
      healthId: 'HID-20260107-007',
      lastVisit: '2026-03-07',
      age: '29',
      gender: 'Female',
    ),
  ];

  List<_PatientRow> get _filteredPatients {
    if (_searchQuery.isEmpty) return _patients;
    final query = _searchQuery.toLowerCase();
    return _patients
        .where((p) =>
            p.name.toLowerCase().contains(query) ||
            p.healthId.toLowerCase().contains(query))
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
                        DataColumn(label: Text('Health ID')),
                        DataColumn(label: Text('Age')),
                        DataColumn(label: Text('Gender')),
                        DataColumn(label: Text('Last Visit')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: _filteredPatients.map((patient) {
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
                                      patient.name[0].toUpperCase(),
                                      style:
                                          AppTypography.labelSmall.copyWith(
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Text(patient.name,
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
                            DataCell(Text(patient.age)),
                            DataCell(Text(patient.gender)),
                            DataCell(Text(patient.lastVisit)),
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                        Icons.visibility_outlined,
                                        size: 18),
                                    onPressed: () {},
                                    tooltip: 'View Records',
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                        Icons.history_outlined,
                                        size: 18),
                                    onPressed: () {},
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PatientRow {
  final String name;
  final String healthId;
  final String lastVisit;
  final String age;
  final String gender;

  const _PatientRow({
    required this.name,
    required this.healthId,
    required this.lastVisit,
    required this.age,
    required this.gender,
  });
}
