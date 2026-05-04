import 'package:flutter/material.dart';

import 'app_breakpoints.dart';

class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
  static const double xxxl = 64;

  static const double borderRadius = 12;
  static const double borderRadiusSm = 8;
  static const double borderRadiusLg = 16;
  static const double borderRadiusXl = 24;

  static const EdgeInsets screenPadding = EdgeInsets.all(md);
  static const EdgeInsets cardPadding = EdgeInsets.all(md);
  static const EdgeInsets listItemPadding = EdgeInsets.symmetric(
    horizontal: md,
    vertical: sm,
  );

  /// Page-level horizontal padding that grows with screen width.
  /// Mobile: 16, Tablet: 24, Desktop: 32, Large: 48.
  static EdgeInsets pagePaddingOf(BuildContext context) {
    final h = context.responsive<double>(
      mobile: md,
      tablet: lg,
      desktop: xl,
      large: xxl,
    );
    final v = context.responsive<double>(
      mobile: md,
      tablet: lg,
      desktop: lg,
    );
    return EdgeInsets.symmetric(horizontal: h, vertical: v);
  }

  /// Default gap between major content blocks at the current breakpoint.
  static double sectionGapOf(BuildContext context) => context.responsive<double>(
        mobile: lg,
        tablet: xl,
        desktop: xl,
      );

  /// Default gap between cards in a grid at the current breakpoint.
  static double gridGapOf(BuildContext context) => context.responsive<double>(
        mobile: md,
        tablet: md,
        desktop: lg,
      );
}
