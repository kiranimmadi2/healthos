import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import '../providers/auth_provider.dart';

class LabShell extends ConsumerWidget {
  const LabShell({super.key, required this.child});

  final Widget child;

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/upload')) return 0;
    if (location.startsWith('/reports')) return 1;
    if (location.startsWith('/patients')) return 2;
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return HosNavShell(
      destinations: const [
        HosNavDestination(
          label: 'Upload',
          icon: Icons.upload_file_outlined,
          selectedIcon: Icons.upload_file_rounded,
        ),
        HosNavDestination(
          label: 'Reports',
          icon: Icons.science_outlined,
          selectedIcon: Icons.science_rounded,
        ),
        HosNavDestination(
          label: 'Patients',
          icon: Icons.person_search_outlined,
          selectedIcon: Icons.person_search_rounded,
        ),
      ],
      selectedIndex: _currentIndex(context),
      onDestinationSelected: (index) {
        switch (index) {
          case 0:
            context.go('/upload');
          case 1:
            context.go('/reports');
          case 2:
            context.go('/patients');
        }
      },
      brandIcon: Icons.biotech_rounded,
      brandTitle: 'HealthOS Lab',
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
