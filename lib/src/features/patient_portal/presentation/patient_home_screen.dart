import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/theme.dart';
import '../../../shared/presentation/shell/health_destination.dart';
import '../../../shared/presentation/shell/health_shell.dart';
import '../../ai_triage/ai_triage.dart';
import '../../auth/application/auth_providers.dart';
import '../../doctors/doctors.dart';
import '../../records/records.dart';
import 'dashboard/dashboard_content.dart';

class PatientHomeScreen extends ConsumerStatefulWidget {
  const PatientHomeScreen({super.key});

  @override
  ConsumerState<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends ConsumerState<PatientHomeScreen> {
  int _currentIndex = 0;

  static const _destinations = [
    HealthDestination(
      label: 'Home',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
    ),
    HealthDestination(
      label: 'Doctors',
      icon: Icons.medical_services_outlined,
      selectedIcon: Icons.medical_services_rounded,
    ),
    HealthDestination(
      label: 'Records',
      icon: Icons.folder_shared_outlined,
      selectedIcon: Icons.folder_shared_rounded,
    ),
    HealthDestination(
      label: 'Care Assistant',
      icon: Icons.smart_toy_outlined,
      selectedIcon: Icons.smart_toy_rounded,
    ),
  ];

  late final List<Widget> _screens = [
    DashboardContent(onNavigate: _selectDestination),
    const DoctorListScreen(),
    const RecordsScreen(),
    const AITriageScreen(),
  ];

  void _selectDestination(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final titles = [
      'My Health',
      'Find a Doctor',
      'Medical Records',
      'Care Assistant',
    ];
    final subtitles = [
      'Your personal care overview',
      'Verified medical specialists',
      'Reports, prescriptions & test history',
      'AI guidance for your health questions',
    ];

    return HealthShell(
      title: titles[_currentIndex],
      subtitle: subtitles[_currentIndex],
      destinations: _destinations,
      selectedIndex: _currentIndex,
      onDestinationSelected: _selectDestination,
      leading: InkWell(
        onTap: () => ref.read(authRepositoryProvider).signOut(),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.logout_rounded,
                color: AppColors.error,
                size: 20,
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  'Sign Out',
                  style: TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
          tooltip: 'Notifications',
          onPressed: () {},
          icon: const Badge(
            backgroundColor: AppColors.error,
            smallSize: 8,
            child: Icon(Icons.notifications_none_rounded, size: 22),
          ),
        ),
        const SizedBox(width: 6),
        Semantics(
          button: true,
          label: 'Open profile',
          child: InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(24),
            child: const CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primarySoft,
              child: Icon(
                Icons.person_rounded,
                color: AppColors.primary,
                size: 20,
              ),
            ),
          ),
        ),
      ],
      child: _screens[_currentIndex],
    );
  }
}
