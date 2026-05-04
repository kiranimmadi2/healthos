import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/reports')) return 1;
    if (location.startsWith('/appointments')) return 2;
    if (location.startsWith('/symptoms')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  void _onSelect(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/home');
      case 1:
        context.go('/reports');
      case 2:
        context.go('/appointments');
      case 3:
        context.go('/symptoms');
      case 4:
        context.go('/profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    return HosNavShell(
      selectedIndex: _currentIndex(context),
      onDestinationSelected: (i) => _onSelect(context, i),
      brandIcon: Icons.health_and_safety_rounded,
      brandTitle: 'HealthOS',
      destinations: const [
        HosNavDestination(label: 'Home', icon: HosIcons.home),
        HosNavDestination(label: 'Records', icon: HosIcons.reports),
        HosNavDestination(label: 'Visits', icon: HosIcons.appointment),
        HosNavDestination(label: 'Assist', icon: HosIcons.ai),
        HosNavDestination(label: 'Profile', icon: HosIcons.profile),
      ],
      child: child,
    );
  }
}
