import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

class DoctorAppShell extends ConsumerWidget {
  const DoctorAppShell({super.key, required this.child});

  final Widget child;

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/dashboard') || location.startsWith('/patients')) {
      return 0;
    }
    if (location.startsWith('/appointments')) return 1;
    if (location.startsWith('/notifications')) return 2;
    if (location.startsWith('/profile')) return 3;
    return 0;
  }

  void _onSelect(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/dashboard');
      case 1:
        context.go('/appointments');
      case 2:
        context.go('/notifications');
      case 3:
        context.go('/profile');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return HosNavShell(
      selectedIndex: _currentIndex(context),
      onDestinationSelected: (i) => _onSelect(context, i),
      brandIcon: Icons.medical_services_rounded,
      brandTitle: 'HealthOS Dr',
      destinations: const [
        HosNavDestination(
          label: 'Patients',
          icon: Icons.people_outlined,
          selectedIcon: Icons.people_rounded,
        ),
        HosNavDestination(
          label: 'Appointments',
          icon: Icons.calendar_month_outlined,
          selectedIcon: Icons.calendar_month_rounded,
        ),
        HosNavDestination(
          label: 'Notifications',
          icon: Icons.notifications_outlined,
          selectedIcon: Icons.notifications_rounded,
        ),
        HosNavDestination(
          label: 'Profile',
          icon: Icons.person_outline,
          selectedIcon: Icons.person_rounded,
        ),
      ],
      child: child,
    );
  }
}
