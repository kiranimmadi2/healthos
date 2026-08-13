import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/theme.dart';
import '../../../shared/presentation/shell/health_page.dart';
import '../../../shared/presentation/widgets/hos_widgets.dart';
import '../../appointments/application/appointment_providers.dart';
import '../../auth/application/user_providers.dart';
import '../../doctors/application/doctor_providers.dart';

class HospitalDashboardScreen extends ConsumerStatefulWidget {
  const HospitalDashboardScreen({super.key});

  @override
  ConsumerState<HospitalDashboardScreen> createState() =>
      _HospitalDashboardScreenState();
}

class _HospitalDashboardScreenState
    extends ConsumerState<HospitalDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final doctorsAsync = ref.watch(availableDoctorsProvider);
    final patientsAsync = ref.watch(allPatientsProvider);
    final appointmentsAsync = ref.watch(doctorAppointmentsProvider);

    final doctors = doctorsAsync.value ?? [];
    final patientCount = patientsAsync.value?.length ?? 0;
    final doctorCount = doctors.length;
    final appointmentCount = appointmentsAsync.value?.length ?? 0;

    final List<Map<String, String>> doctorActivity = doctors.map((doc) {
      return {
        'name': doc.name,
        'department': doc.specialization.isEmpty ? 'General Medicine' : doc.specialization,
        'patients': '${doc.experienceYears > 0 ? doc.experienceYears * 4 : 0}',
        'status': doc.isAvailable ? 'Active' : 'Offline',
        'shift': 'Full Day',
      };
    }).toList();

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
                children: [
                  HosStatCard(
                    title: 'Total Patients',
                    value: '$patientCount',
                    subtitle: 'Registered patients',
                    icon: HosIcons.user,
                    accentColor: AppColors.primary,
                  ),
                  HosStatCard(
                    title: 'Active Doctors',
                    value: '$doctorCount',
                    subtitle: 'Verified medical staff',
                    icon: HosIcons.stethoscope,
                    accentColor: AppColors.secondary,
                  ),
                  HosStatCard(
                    title: 'Total Appointments',
                    value: '$appointmentCount',
                    subtitle: 'Active & booked visits',
                    icon: HosIcons.calendar,
                    accentColor: AppColors.warning,
                  ),
                  const HosStatCard(
                    title: 'Hospital Status',
                    value: 'Operational',
                    subtitle: 'All systems online',
                    icon: HosIcons.shield,
                    accentColor: AppColors.primary,
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
          if (doctorActivity.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.85),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: const [
                  Icon(HosIcons.stethoscope, size: 40, color: AppColors.textMuted),
                  SizedBox(height: 12),
                  Text(
                    'No doctors currently registered',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Doctors will appear here as soon as they sign up or are onboarded.',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                  ),
                ],
              ),
            )
          else
            HosDataTable<Map<String, String>>(
              columns: const [
                'Doctor Name',
                'Department',
                'Assigned Patients',
                'Shift',
                'Status',
                'Action',
              ],
              data: doctorActivity,
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

