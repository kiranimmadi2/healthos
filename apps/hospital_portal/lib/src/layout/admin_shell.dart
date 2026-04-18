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
    final colorScheme = Theme.of(context).colorScheme;
    final isExtended = MediaQuery.of(context).size.width > 1200;

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            extended: isExtended,
            selectedIndex: selectedIndex,
            backgroundColor: colorScheme.surface,
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
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.local_hospital_rounded,
                      size: 22,
                      color: colorScheme.primary,
                    ),
                  ),
                  if (isExtended) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'HealthOS',
                      style: AppTypography.label.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                  child: IconButton(
                    icon: const Icon(Icons.logout_rounded),
                    tooltip: 'Sign Out',
                    color: AppColors.textTertiary,
                    onPressed: () async {
                      await ref.read(authServiceProvider).signOut();
                    },
                  ),
                ),
              ),
            ),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard_rounded),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.medical_services_outlined),
                selectedIcon: Icon(Icons.medical_services_rounded),
                label: Text('Doctors'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people_outlined),
                selectedIcon: Icon(Icons.people_rounded),
                label: Text('Patients'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings_rounded),
                label: Text('Settings'),
              ),
            ],
          ),
          VerticalDivider(
            thickness: 1,
            width: 1,
            color: Theme.of(context).dividerColor,
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}
