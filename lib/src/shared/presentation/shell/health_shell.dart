import 'package:flutter/material.dart';

import '../../../app/theme/theme.dart';
import '../branding/app_logo.dart';
import '../layout/responsive_layout.dart';
import '../widgets/glass_container.dart';
import '../widgets/theme_toggle_button.dart';
import 'health_destination.dart';

class HealthShell extends StatelessWidget {
  const HealthShell({
    super.key,
    required this.title,
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.child,
    this.subtitle,
    this.actions = const [],
    this.leading,
  });

  final String title;
  final String? subtitle;
  final List<HealthDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final Widget child;
  final List<Widget> actions;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GlassCanvas(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < AppBreakpoints.mobileMax;
            final isDesktop = constraints.maxWidth >= AppBreakpoints.tabletMax;

            if (isMobile) {
              return Scaffold(
                backgroundColor: Colors.transparent,
                appBar: _buildAppBar(context),
                body: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: KeyedSubtree(key: ValueKey(selectedIndex), child: child),
                ),
                bottomNavigationBar: GlassContainer(
                  borderRadius: 0,
                  blur: 24,
                  opacity: 0.70,
                  padding: EdgeInsets.zero,
                  child: NavigationBar(
                    backgroundColor: Colors.transparent,
                    selectedIndex: selectedIndex,
                    onDestinationSelected: onDestinationSelected,
                    destinations: [
                      for (final destination in destinations)
                        NavigationDestination(
                          icon: Icon(destination.icon),
                          selectedIcon: Icon(destination.selectedIcon),
                          label: destination.label,
                          tooltip: destination.label,
                        ),
                    ],
                  ),
                ),
              );
            }

            return Row(
              children: [
                SafeArea(
                  right: false,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GlassContainer(
                      width: isDesktop ? 240 : 76,
                      borderRadius: 28,
                      blur: 24,
                      opacity: 0.60,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                            child: isDesktop
                                ? const _BrandMark(showLabel: true)
                                : const _BrandMark(showLabel: false),
                          ),
                          Divider(height: 1, color: Colors.white.withOpacity(0.4)),
                          const SizedBox(height: 16),
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              itemCount: destinations.length,
                              itemBuilder: (context, index) {
                                final destination = destinations[index];
                                final isSelected = selectedIndex == index;

                                if (!isDesktop) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                    child: InkWell(
                                      onTap: () => onDestinationSelected(index),
                                      borderRadius: BorderRadius.circular(20),
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        height: 52,
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? Colors.white
                                              : Colors.transparent,
                                          borderRadius: BorderRadius.circular(20),
                                          boxShadow: isSelected
                                              ? [
                                                  BoxShadow(
                                                    color: AppColors.textPrimary
                                                        .withOpacity(0.08),
                                                    blurRadius: 16,
                                                    offset: const Offset(0, 4),
                                                  ),
                                                ]
                                              : [],
                                        ),
                                        child: Icon(
                                          isSelected
                                              ? destination.selectedIcon
                                              : destination.icon,
                                          color: isSelected
                                              ? AppColors.primary
                                              : AppColors.textMuted,
                                          size: 22,
                                        ),
                                      ),
                                    ),
                                  );
                                }

                                final isDark = Theme.of(context).brightness == Brightness.dark;
                                final activeBgColor = isDark ? const Color(0xFF2563EB) : Colors.white;
                                final activeTextColor = isDark ? Colors.white : AppColors.textPrimary;
                                final unselectedTextColor = isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary;

                                return Container(
                                  margin: const EdgeInsets.symmetric(vertical: 4),
                                  child: InkWell(
                                    onTap: () => onDestinationSelected(index),
                                    borderRadius: BorderRadius.circular(24),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 18,
                                        vertical: 14,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? activeBgColor
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(24),
                                        border: isSelected
                                            ? Border.all(
                                                color: isDark ? const Color(0xFF60A5FA) : Colors.white,
                                                width: 1.5,
                                              )
                                            : null,
                                        boxShadow: isSelected
                                            ? [
                                                BoxShadow(
                                                  color: isDark
                                                      ? Colors.blue.withOpacity(0.3)
                                                      : const Color(0xFF0F172A).withOpacity(0.08),
                                                  blurRadius: 16,
                                                  spreadRadius: 0,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ]
                                            : [],
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            isSelected
                                                ? destination.selectedIcon
                                                : destination.icon,
                                            color: isSelected
                                                ? activeTextColor
                                                : unselectedTextColor,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 14),
                                          Expanded(
                                            child: Text(
                                              destination.label,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: isSelected
                                                    ? FontWeight.w700
                                                    : FontWeight.w500,
                                                color: isSelected
                                                    ? activeTextColor
                                                    : unselectedTextColor,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          if (leading != null) ...[
                            Divider(height: 1, color: Colors.white.withOpacity(0.4)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                              child: isDesktop
                                  ? leading
                                  : SizedBox(
                                      height: 40,
                                      child: Center(
                                        child: ClipRRect(
                                          child: leading,
                                        ),
                                      ),
                                    ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      _buildDesktopHeader(context),
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: KeyedSubtree(
                            key: ValueKey(selectedIndex),
                            child: child,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      toolbarHeight: 72,
      titleSpacing: 20,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          if (subtitle != null)
            Text(
              subtitle!,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
            ),
        ],
      ),
      actions: [
        ...actions,
        const SizedBox(width: 8),
        const ThemeToggleButton(isCompact: true),
        const SizedBox(width: 12),
      ],
    );
  }

  Widget _buildDesktopHeader(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        height: 76,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 28,
                      letterSpacing: -0.6,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textMuted,
                        fontSize: 13,
                      ),
                    ),
                ],
              ),
            ),
            ...actions,
            const SizedBox(width: 12),
            const ThemeToggleButton(),
          ],
        ),
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark({required this.showLabel});

  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const AppLogo(size: 40),
        if (showLabel) ...[
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              'HealthOS',
              style: Theme.of(context).textTheme.titleLarge,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }
}
