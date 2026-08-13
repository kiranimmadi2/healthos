import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/theme.dart';
import '../../../shared/presentation/shell/health_destination.dart';
import '../../../shared/presentation/shell/health_shell.dart';
import '../../../shared/presentation/widgets/user_profile_dialog.dart';
import '../../ai_triage/ai_triage.dart';
import '../../auth/application/auth_providers.dart';
import '../../doctors/doctors.dart';
import '../../food_nutrition/food_nutrition.dart';
import '../../records/records.dart';
import 'dashboard/dashboard_content.dart';
import 'notifications_sheet.dart';

class PatientHomeScreen extends ConsumerStatefulWidget {
  const PatientHomeScreen({super.key});

  @override
  ConsumerState<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends ConsumerState<PatientHomeScreen> {
  int _currentIndex = 0;

  List<HealthDestination> get _destinations => [
        const HealthDestination(
          label: 'Home',
          icon: Icons.home_outlined,
          selectedIcon: Icons.home_rounded,
        ),
        if (!kIsWeb)
          const HealthDestination(
            label: 'Meal Check',
            icon: Icons.restaurant_outlined,
            selectedIcon: Icons.restaurant_rounded,
          ),
        const HealthDestination(
          label: 'Doctors',
          icon: Icons.medical_services_outlined,
          selectedIcon: Icons.medical_services_rounded,
        ),
        const HealthDestination(
          label: 'Records',
          icon: Icons.folder_shared_outlined,
          selectedIcon: Icons.folder_shared_rounded,
        ),
        const HealthDestination(
          label: 'Care Assistant',
          icon: Icons.health_and_safety_outlined,
          selectedIcon: Icons.health_and_safety_rounded,
        ),
      ];

  List<Widget> get _screens => [
        DashboardContent(onNavigate: _selectDestination),
        if (!kIsWeb) const MealAnalyzerScreen(),
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
      if (!kIsWeb) 'Meal & Food Analyzer',
      'Find a Doctor',
      'Medical Records',
      'Care Assistant',
    ];
    final subtitles = [
      'Your personal care overview',
      if (!kIsWeb) 'AI food & nutrition analysis',
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
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 100;
              return Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.logout_rounded,
                    color: AppColors.error,
                    size: 20,
                  ),
                  if (isWide) ...[
                    const SizedBox(width: 8),
                    const Flexible(
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
                ],
              );
            },
          ),
        ),
      ),
      actions: [
        const NotificationsBell(),
        const SizedBox(width: 6),

        Semantics(
          button: true,
          label: 'Open profile',
          child: InkWell(
            onTap: () => showUserProfileModal(context),
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
