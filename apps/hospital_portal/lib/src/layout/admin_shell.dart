import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import '../providers/auth_provider.dart';

class AdminShell extends ConsumerWidget {
  const AdminShell({super.key, required this.child});

  final Widget child;

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/dashboard')) return 0;
    if (location.startsWith('/doctors')) return 1;
    if (location.startsWith('/patients')) return 2;
    if (location.startsWith('/settings')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = _currentIndex(context);

    return HosNavShell(
      destinations: const [
        HosNavDestination(
          label: 'Dashboard',
          icon: Icons.dashboard_outlined,
          selectedIcon: Icons.dashboard_rounded,
        ),
        HosNavDestination(
          label: 'Doctors',
          icon: Icons.medical_services_outlined,
          selectedIcon: Icons.medical_services_rounded,
        ),
        HosNavDestination(
          label: 'Patients',
          icon: Icons.people_outlined,
          selectedIcon: Icons.people_rounded,
        ),
        HosNavDestination(
          label: 'Settings',
          icon: Icons.settings_outlined,
          selectedIcon: Icons.settings_rounded,
        ),
      ],
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) {
        switch (index) {
          case 0:
            context.go('/dashboard');
          case 1:
            context.go('/doctors');
          case 2:
            context.go('/patients');
          case 3:
            context.go('/settings');
        }
      },
      brandIcon: Icons.local_hospital_rounded,
      brandTitle: 'HealthOS',
      trailing: IconButton(
        icon: const Icon(Icons.logout_rounded),
        tooltip: 'Sign Out',
        color: AppColors.textTertiary,
        onPressed: () async {
          await ref.read(authServiceProvider).signOut();
        },
      ),
      child: child,
    );
  }
}
