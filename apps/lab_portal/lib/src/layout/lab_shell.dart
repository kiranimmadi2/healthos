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
                  context.go('/upload');
                case 1:
                  context.go('/reports');
                case 2:
                  context.go('/patients');
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
                      Icons.biotech_rounded,
                      size: 22,
                      color: colorScheme.primary,
                    ),
                  ),
                  if (isExtended) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'HealthOS Lab',
                      style: AppTypography.caption.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
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
                icon: Icon(Icons.upload_file_outlined),
                selectedIcon: Icon(Icons.upload_file_rounded),
                label: Text('Upload'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.science_outlined),
                selectedIcon: Icon(Icons.science_rounded),
                label: Text('Reports'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.person_search_outlined),
                selectedIcon: Icon(Icons.person_search_rounded),
                label: Text('Patients'),
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
