import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/theme.dart';
import '../../../shared/presentation/shell/health_page.dart';
import '../../../shared/presentation/widgets/hos_widgets.dart';

class HospitalDashboardScreen extends ConsumerStatefulWidget {
  const HospitalDashboardScreen({super.key});

  @override
  ConsumerState<HospitalDashboardScreen> createState() =>
      _HospitalDashboardScreenState();
}

class _HospitalDashboardScreenState
    extends ConsumerState<HospitalDashboardScreen> {
  final List<Map<String, String>> _doctorActivity = [
    {
      'name': 'Dr. Asha Sharma',
      'department': 'Cardiology',
      'patients': '28',
      'status': 'Active',
      'shift': 'Morning',
    },
    {
      'name': 'Dr. Rajesh Patel',
      'department': 'Pediatrics',
      'patients': '34',
      'status': 'Active',
      'shift': 'Full Day',
    },
    {
      'name': 'Dr. Anita Roy',
      'department': 'Neurology',
      'patients': '19',
      'status': 'On Leave',
      'shift': 'Night',
    },
    {
      'name': 'Dr. Vikram Singh',
      'department': 'Orthopedics',
      'patients': '42',
      'status': 'Active',
      'shift': 'Morning',
    },
    {
      'name': 'Dr. Meera Nair',
      'department': 'General Medicine',
      'patients': '50',
      'status': 'Active',
      'shift': 'Evening',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return HealthPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hospital Command Center',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Real-time metrics, doctor deployment, and operational logs.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textMuted,
                        ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Doctor onboarding form opened')),
                  );
                },
                icon: const Icon(HosIcons.userAdd),
                label: const Text('Onboard Doctor'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),

          // 4 Responsive Stat Cards
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 1000
                  ? 4
                  : constraints.maxWidth > 600
                      ? 2
                      : 1;

              return GridView.count(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: AppSpacing.md,
                mainAxisSpacing: AppSpacing.md,
                shrinkWrap: true,
                childAspectRatio: 2.8,
                physics: const NeverScrollableScrollPhysics(),
                children: const [
                  HosStatCard(
                    title: 'Total Patients',
                    value: '1,248',
                    subtitle: '+12% this month',
                    icon: HosIcons.user,
                    accentColor: AppColors.primary,
                  ),
                  HosStatCard(
                    title: 'Active Doctors',
                    value: '42',
                    subtitle: 'Across 8 departments',
                    icon: HosIcons.stethoscope,
                    accentColor: AppColors.secondary,
                  ),
                  HosStatCard(
                    title: 'Appointments Today',
                    value: '86',
                    subtitle: '14 pending check-in',
                    icon: HosIcons.calendar,
                    accentColor: AppColors.warning,
                  ),
                  HosStatCard(
                    title: 'Pending Verifications',
                    value: '5',
                    subtitle: 'Credentials review',
                    icon: HosIcons.shield,
                    accentColor: AppColors.error,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.xl),

          // Recent Activity & Doctor Directory Table using HosDataTable
          Text(
            'Doctor Roster & Operational Status',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppSpacing.md),
          HosDataTable<Map<String, String>>(
            columns: const [
              'Doctor Name',
              'Department',
              'Assigned Patients',
              'Shift',
              'Status',
              'Action',
            ],
            data: _doctorActivity,
            rowBuilder: (doc) => [
              Text(
                doc['name']!,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(doc['department']!),
              Text(doc['patients']!),
              Text(doc['shift']!),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: doc['status'] == 'Active'
                      ? AppColors.primarySoft
                      : AppColors.background,
                  borderRadius: BorderRadius.circular(AppRadius.small),
                  border: Border.all(
                    color: doc['status'] == 'Active'
                        ? AppColors.primary
                        : AppColors.border,
                  ),
                ),
                child: Text(
                  doc['status']!,
                  style: TextStyle(
                    fontSize: 12,
                    color: doc['status'] == 'Active'
                        ? AppColors.primary
                        : AppColors.textMuted,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              OutlinedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Managing ${doc['name']}')),
                  );
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                ),
                child: const Text('Manage'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
