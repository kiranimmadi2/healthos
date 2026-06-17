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
      icon: Icons.folder_outlined,
      selectedIcon: Icons.folder_rounded,
    ),
    HealthDestination(
      label: 'Care assistant',
      icon: Icons.chat_bubble_outline_rounded,
      selectedIcon: Icons.chat_bubble_rounded,
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
      'My health',
      'Find a doctor',
      'Medical records',
      'Care assistant',
    ];
    final subtitles = [
      'Your care overview',
      'Verified specialists near you',
      'Reports, prescriptions, and history',
      'Guidance for non-emergency symptoms',
    ];

    return HealthShell(
      title: titles[_currentIndex],
      subtitle: subtitles[_currentIndex],
      destinations: _destinations,
      selectedIndex: _currentIndex,
      onDestinationSelected: _selectDestination,
      leading: IconButton(
        tooltip: 'Sign out',
        onPressed: () => ref.read(authRepositoryProvider).signOut(),
        icon: const Icon(Icons.logout_rounded),
      ),
      actions: [
        IconButton(
          tooltip: 'Notifications',
          onPressed: () {},
          icon: Badge(
            backgroundColor: AppColors.error,
            smallSize: 8,
            child: const Icon(Icons.notifications_outlined),
          ),
        ),
        const SizedBox(width: 4),
        Semantics(
          button: true,
          label: 'Open profile',
          child: InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(24),
            child: const CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.primarySoft,
              child: Icon(Icons.person_rounded, color: AppColors.primary),
            ),
          ),
        ),
      ],
      child: _screens[_currentIndex],
    );
  }
}
