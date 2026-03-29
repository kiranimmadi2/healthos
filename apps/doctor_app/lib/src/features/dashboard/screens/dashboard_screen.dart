import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../../layout/master_detail_layout.dart';
import '../../../providers/doctor_provider.dart';
import '../../notifications/providers/notification_provider.dart';
import '../../patients/screens/patient_detail_screen.dart';
import '../../patients/screens/patient_list_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  String? _selectedPatientId;

  @override
  Widget build(BuildContext context) {
    final doctorAsync = ref.watch(currentDoctorProvider);

    return Scaffold(
      appBar: AppBar(
        title: doctorAsync.when(
          data: (doctor) => Text(
            doctor != null
                ? 'Dr. ${doctor.fullName}'
                : 'HealthOS Doctor',
          ),
          loading: () => const Text('HealthOS Doctor'),
          error: (_, __) => const Text('HealthOS Doctor'),
        ),
        actions: [
          if (doctorAsync.valueOrNull != null) ...[
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: Center(
                child: Text(
                  doctorAsync.valueOrNull?.specialization ?? '',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ],
          Consumer(
            builder: (context, ref, child) {
              final count = ref.watch(doctorUnreadCountProvider);
              return IconButton(
                icon: Badge(
                  isLabelVisible: count > 0,
                  label: Text('$count'),
                  child: const Icon(Icons.notifications_outlined),
                ),
                onPressed: () => context.go('/notifications'),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outlined),
            tooltip: 'Profile',
            onPressed: () => context.go('/profile'),
          ),
        ],
      ),
      body: MasterDetailLayout(
        showDetail: _selectedPatientId != null,
        master: PatientListScreen(
          selectedPatientId: _selectedPatientId,
          onPatientSelected: (patientId) {
            setState(() => _selectedPatientId = patientId);
            // On narrow screens, navigate to detail page
            if (MediaQuery.of(context).size.width <= 900) {
              context.go('/patients/$patientId');
            }
          },
        ),
        detail: _selectedPatientId != null
            ? PatientDetailScreen(patientId: _selectedPatientId!)
            : const _EmptyDetailPanel(),
      ),
    );
  }
}

class _EmptyDetailPanel extends StatelessWidget {
  const _EmptyDetailPanel();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_search_outlined,
            size: 64,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Select a patient',
            style: AppTypography.h3.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Choose a patient from the list to view their details.',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
