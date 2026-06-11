import 'package:flutter/material.dart';

/// Standard breakpoints for HealthOS responsiveness
class AppBreakpoints {
  static const double mobileMax = 600;
  static const double tabletMax = 1024;
}

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < AppBreakpoints.mobileMax;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= AppBreakpoints.mobileMax &&
      MediaQuery.of(context).size.width < AppBreakpoints.tabletMax;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= AppBreakpoints.tabletMax;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= AppBreakpoints.tabletMax) {
          return desktop;
        } else if (constraints.maxWidth >= AppBreakpoints.mobileMax) {
          return tablet ?? desktop; // Use desktop as fallback for tablet
        } else {
          return mobile;
        }
      },
    );
  }
}
