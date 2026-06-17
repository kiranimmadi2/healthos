import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/theme.dart';
import '../../../shared/presentation/layout/responsive_layout.dart';
import '../../../shared/presentation/shell/health_destination.dart';
import '../../../shared/presentation/shell/health_shell.dart';
import '../../auth/application/auth_providers.dart';
import 'widgets/doctor_workspace_widgets.dart';
import 'workspaces/doctor_dashboard.dart';
import 'workspaces/messages_workspace.dart';
import 'workspaces/patients_workspace.dart';
import 'workspaces/reports_workspace.dart';
import 'workspaces/schedule_workspace.dart';

class DoctorHomeScreen extends ConsumerStatefulWidget {
  const DoctorHomeScreen({super.key});

  @override
  ConsumerState<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends ConsumerState<DoctorHomeScreen> {
  int _currentIndex = 0;

  static const _destinations = [
    HealthDestination(
      label: 'Dashboard',
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard_rounded,
    ),
    HealthDestination(
      label: 'Patients',
      icon: Icons.people_outline_rounded,
      selectedIcon: Icons.people_rounded,
    ),
    HealthDestination(
      label: 'Schedule',
      icon: Icons.calendar_month_outlined,
      selectedIcon: Icons.calendar_month_rounded,
    ),
    HealthDestination(
      label: 'Messages',
      icon: Icons.chat_bubble_outline_rounded,
      selectedIcon: Icons.chat_bubble_rounded,
    ),
    HealthDestination(
      label: 'Reports',
      icon: Icons.analytics_outlined,
      selectedIcon: Icons.analytics_rounded,
    ),
  ];

  late final List<Widget> _screens = [
    DoctorDashboard(onOpenSection: _selectSection),
    const PatientsWorkspace(),
    const ScheduleWorkspace(),
    const MessagesWorkspace(),
    const ReportsWorkspace(),
  ];

  void _selectSection(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop =
        MediaQuery.sizeOf(context).width >= AppBreakpoints.tabletMax;
    final labels = _destinations
        .map((destination) => destination.label)
        .toList();
    const subtitles = [
      'Live appointments and requests',
      '128 active patients',
      'Week of June 8–14',
      'Live patient conversations',
      '5 reports need review',
    ];

    return HealthShell(
      title: labels[_currentIndex],
      subtitle: subtitles[_currentIndex],
      destinations: _destinations,
      selectedIndex: _currentIndex,
      onDestinationSelected: _selectSection,
      leading: IconButton(
        tooltip: 'Sign out',
        onPressed: () => ref.read(authRepositoryProvider).signOut(),
        icon: const Icon(Icons.logout_rounded),
      ),
      actions: [
        SizedBox(
          width: isDesktop ? 280 : 48,
          child: isDesktop
              ? TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search workspace',
                    prefixIcon: Icon(Icons.search_rounded),
                    isDense: true,
                  ),
                  onSubmitted: (value) {
                    if (value.trim().isEmpty) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Searching for “${value.trim()}”'),
                      ),
                    );
                  },
                )
              : IconButton(
                  tooltip: 'Search workspace',
                  onPressed: () => _showSearch(context),
                  icon: const Icon(Icons.search_rounded),
                ),
        ),
        IconButton(
          tooltip: 'Notifications',
          onPressed: () => _showNotifications(context),
          icon: const Badge(
            label: Text('3'),
            child: Icon(Icons.notifications_outlined),
          ),
        ),
        if (isDesktop)
          const CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.secondarySoft,
            child: Text(
              'AS',
              style: TextStyle(
                color: AppColors.secondary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
      ],
      child: _screens[_currentIndex],
    );
  }

  Future<void> _showSearch(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          MediaQuery.viewInsetsOf(context).bottom + 20,
        ),
        child: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search patients, reports, messages...',
            prefixIcon: Icon(Icons.search_rounded),
          ),
          onSubmitted: (_) => Navigator.pop(context),
        ),
      ),
    );
  }

  Future<void> _showNotifications(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => const SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Notifications',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 16),
              NotificationTile(
                icon: Icons.science_outlined,
                color: AppColors.warning,
                title: 'Critical lab result',
                detail: 'Priya Nair · Troponin result is ready',
                time: '8 min',
              ),
              NotificationTile(
                icon: Icons.event_available_outlined,
                color: AppColors.primary,
                title: 'Appointment checked in',
                detail: 'Aarav Mehta is ready for consultation',
                time: '14 min',
              ),
              NotificationTile(
                icon: Icons.chat_bubble_outline_rounded,
                color: AppColors.secondary,
                title: 'New patient message',
                detail: 'Meera Iyer sent a follow-up question',
                time: '32 min',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
