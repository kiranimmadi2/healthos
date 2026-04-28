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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex(context),
        onDestinationSelected: (index) {
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
        },
        destinations: [
          NavigationDestination(
            icon: Icon(HosIcons.home),
            selectedIcon: Icon(HosIcons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(HosIcons.reports),
            selectedIcon: Icon(HosIcons.reports),
            label: 'Records',
          ),
          NavigationDestination(
            icon: Icon(HosIcons.appointment),
            selectedIcon: Icon(HosIcons.appointment),
            label: 'Visits',
          ),
          NavigationDestination(
            icon: Icon(HosIcons.ai),
            selectedIcon: Icon(HosIcons.ai),
            label: 'Assist',
          ),
          NavigationDestination(
            icon: Icon(HosIcons.profile),
            selectedIcon: Icon(HosIcons.profile),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
