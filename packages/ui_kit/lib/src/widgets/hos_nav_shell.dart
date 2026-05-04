import 'package:flutter/material.dart';

import '../theme/app_breakpoints.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// A single destination in [HosNavShell].
class HosNavDestination {
  const HosNavDestination({
    required this.label,
    required this.icon,
    this.selectedIcon,
    this.tooltip,
  });

  final String label;
  final IconData icon;
  final IconData? selectedIcon;
  final String? tooltip;
}

/// Adaptive navigation shell.
///
/// - **Mobile** (< railThreshold, 720dp): bottom NavigationBar
/// - **Tablet/Desktop** (>= 720dp): collapsed NavigationRail (icons only)
/// - **Large desktop** (>= 1280dp): extended NavigationRail (icons + labels) with a brand header
///
/// Use this as the persistent shell for every app. Pass a callback for
/// destination selection (typically `context.go(...)`) plus an optional
/// branding header (logo + app name) and trailing action (sign out, etc.).
class HosNavShell extends StatelessWidget {
  const HosNavShell({
    super.key,
    required this.child,
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.brandIcon,
    this.brandTitle,
    this.trailing,
    this.appBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.backgroundColor,
  });

  final Widget child;
  final List<HosNavDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  /// Optional brand icon shown above the rail (desktop) or as the leading
  /// app-bar icon (mobile, when [appBar] is null).
  final IconData? brandIcon;

  /// App name shown beside [brandIcon] on extended rails.
  final String? brandTitle;

  /// Optional trailing widget anchored to the bottom of the rail
  /// (desktop) — usually a sign-out button.
  final Widget? trailing;

  /// Optional app bar shown above [child]. Mobile-only by default;
  /// also rendered on wider layouts when provided.
  final PreferredSizeWidget? appBar;

  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final useRail = context.useRailNav;
    final extended = context.useExtendedRail;

    if (useRail) {
      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: appBar,
        body: SafeArea(
          child: Row(
            children: [
              _Rail(
                destinations: destinations,
                selectedIndex: selectedIndex,
                onDestinationSelected: onDestinationSelected,
                extended: extended,
                brandIcon: brandIcon,
                brandTitle: brandTitle,
                trailing: trailing,
              ),
              const VerticalDivider(width: 1, thickness: 1),
              Expanded(child: child),
            ],
          ),
        ),
        floatingActionButton: floatingActionButton,
        floatingActionButtonLocation: floatingActionButtonLocation,
      );
    }

    // Mobile / compact: bottom navigation
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: appBar,
      body: SafeArea(top: appBar == null, child: child),
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
        destinations: [
          for (final d in destinations)
            NavigationDestination(
              icon: Icon(d.icon),
              selectedIcon: Icon(d.selectedIcon ?? d.icon),
              label: d.label,
              tooltip: d.tooltip,
            ),
        ],
      ),
    );
  }
}

class _Rail extends StatelessWidget {
  const _Rail({
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.extended,
    this.brandIcon,
    this.brandTitle,
    this.trailing,
  });

  final List<HosNavDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final bool extended;
  final IconData? brandIcon;
  final String? brandTitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    Widget? leading;
    if (brandIcon != null) {
      leading = Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(brandIcon, size: 22, color: colorScheme.primary),
            ),
            if (extended && brandTitle != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                brandTitle!,
                style: AppTypography.label.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ],
          ],
        ),
      );
    }

    Widget? trailingWidget;
    if (trailing != null) {
      trailingWidget = Expanded(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.lg),
            child: trailing,
          ),
        ),
      );
    }

    return NavigationRail(
      extended: extended,
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      backgroundColor: colorScheme.surface,
      indicatorColor: colorScheme.primary.withValues(alpha: 0.1),
      selectedIconTheme: IconThemeData(color: colorScheme.primary),
      unselectedIconTheme: const IconThemeData(color: AppColors.textTertiary),
      selectedLabelTextStyle: TextStyle(
        color: colorScheme.primary,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
      unselectedLabelTextStyle: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 13,
      ),
      leading: leading,
      trailing: trailingWidget,
      labelType: extended ? NavigationRailLabelType.none : NavigationRailLabelType.all,
      destinations: [
        for (final d in destinations)
          NavigationRailDestination(
            icon: Icon(d.icon),
            selectedIcon: Icon(d.selectedIcon ?? d.icon),
            label: Text(d.label),
          ),
      ],
    );
  }
}
