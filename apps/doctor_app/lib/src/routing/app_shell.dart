import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import '../providers/doctor_provider.dart';

class DoctorAppShell extends ConsumerWidget {
  const DoctorAppShell({super.key, required this.child});

  final Widget child;

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/dashboard')) return 0;
    if (location.startsWith('/patients')) return 1;
    if (location.startsWith('/appointments')) return 2;
    if (location.startsWith('/prescriptions')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLargeScreen = MediaQuery.of(context).size.width >= 900;
    final isExtraLargeScreen = MediaQuery.of(context).size.width >= 1200;
    final doctorAsync = ref.watch(currentDoctorProvider);

    if (isLargeScreen) {
      return Scaffold(
        body: Row(
          children: [
            _NavigationRail(
              currentIndex: _currentIndex(context),
              isExtended: isExtraLargeScreen,
              doctorAsync: doctorAsync,
              onNavigate: (index) => _handleNavigation(context, index),
            ),
            Expanded(child: child),
          ],
        ),
      );
    } else {
      return Scaffold(
        body: child,
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex(context),
          onDestinationSelected: _handleNavigation(context),
          destinations: [
            NavigationDestination(
              icon: Icon(HosIcons.dashboard),
              selectedIcon: Icon(HosIcons.dashboard),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Icon(HosIcons.patients),
              selectedIcon: Icon(HosIcons.patients),
              label: 'Patients',
            ),
            NavigationDestination(
              icon: Icon(HosIcons.calendar),
              selectedIcon: Icon(HosIcons.calendar),
              label: 'Schedule',
            ),
            NavigationDestination(
              icon: Icon(HosIcons.prescription),
              selectedIcon: Icon(HosIcons.prescription),
              label: 'Rx',
            ),
          ],
        ),
      );
    }
  }

  Function(int) _handleNavigation(BuildContext context) {
    return (index) {
      switch (index) {
        case 0:
          context.go('/dashboard');
        case 1:
          context.go('/dashboard');
        case 2:
          context.go('/appointments');
        case 3:
          context.go('/prescriptions');
      }
    };
  }
}

class _NavigationRail extends StatelessWidget {
  const _NavigationRail({
    required this.currentIndex,
    required this.isExtended,
    required this.doctorAsync,
    required this.onNavigate,
  });

  final int currentIndex;
  final bool isExtended;
  final AsyncValue<dynamic> doctorAsync;
  final Function(int) onNavigate;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isExtended ? 240 : 72,
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(
            color: AppColors.divider,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          SizedBox(height: 16),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                'H',
                style: AppTypography.h4.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _NavItem(
                  icon: HosIcons.dashboard,
                  label: 'Dashboard',
                  isSelected: currentIndex == 0,
                  isExtended: isExtended,
                  onTap: () => onNavigate(0),
                ),
                _NavItem(
                  icon: HosIcons.patients,
                  label: 'Patients',
                  isSelected: currentIndex == 1,
                  isExtended: isExtended,
                  onTap: () => onNavigate(1),
                ),
                _NavItem(
                  icon: HosIcons.calendar,
                  label: 'Schedule',
                  isSelected: currentIndex == 2,
                  isExtended: isExtended,
                  onTap: () => onNavigate(2),
                ),
                _NavItem(
                  icon: HosIcons.prescription,
                  label: 'Prescriptions',
                  isSelected: currentIndex == 3,
                  isExtended: isExtended,
                  onTap: () => onNavigate(3),
                ),
              ],
            ),
          ),
          Divider(color: AppColors.divider, height: 1),
          Padding(
            padding: const EdgeInsets.all(8),
            child: GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const DoctorProfilePlaceholder()),
              ),
              child: doctorAsync.when(
                data: (doctor) {
                  final initials = doctor?.fullName
                      ?.split(' ')
                      .map((e) => e[0])
                      .join('')
                      .toUpperCase() ??
                  'DR';
                  return Container(
                    width: isExtended ? null : 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Center(
                      child: Text(
                        initials.length > 2 ? initials.substring(0, 2) : initials,
                        style: AppTypography.label.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                },
                loading: () => Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                error: (_, __) => Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.isExtended,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final bool isExtended;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 56,
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary.withValues(alpha: 0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              SizedBox(width: 16),
              Icon(
                icon,
                color: isSelected ? AppColors.primary : AppColors.textTertiary,
                size: 22,
              ),
              if (isExtended) ...[
                SizedBox(width: 12),
                Text(
                  label,
                  style: AppTypography.label.copyWith(
                    color: isSelected ? AppColors.primary : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class DoctorProfilePlaceholder extends StatelessWidget {
  const DoctorProfilePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: const Center(child: Text('Profile')),
    );
  }
}
