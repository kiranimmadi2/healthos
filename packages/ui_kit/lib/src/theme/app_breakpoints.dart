import 'package:flutter/widgets.dart';

/// Device size class — used to drive layout, padding, and typography decisions.
///
/// Thresholds align with common Material 3 / web design conventions:
/// - mobile  : <  600 dp (phones, narrow web)
/// - tablet  : >= 600 dp and < 1024 dp (tablets, foldables, narrow desktop)
/// - desktop : >= 1024 dp and < 1440 dp (laptops, standard desktop)
/// - large   : >= 1440 dp (wide desktop, external monitors)
enum HosDeviceSize { mobile, tablet, desktop, large }

class AppBreakpoints {
  AppBreakpoints._();

  static const double mobile = 600;
  static const double tablet = 1024;
  static const double desktop = 1440;

  /// Maximum content width on very wide screens — keeps line lengths readable.
  static const double maxContentWidth = 1280;

  /// Width above which a navigation rail is preferred over a bottom bar.
  static const double railThreshold = 720;

  /// Width above which the navigation rail should be extended (icon + label).
  static const double railExtendedThreshold = 1280;

  static HosDeviceSize sizeOf(double width) {
    if (width < mobile) return HosDeviceSize.mobile;
    if (width < tablet) return HosDeviceSize.tablet;
    if (width < desktop) return HosDeviceSize.desktop;
    return HosDeviceSize.large;
  }
}

extension HosBreakpointContext on BuildContext {
  Size get _size => MediaQuery.sizeOf(this);

  double get screenWidth => _size.width;
  double get screenHeight => _size.height;

  HosDeviceSize get deviceSize => AppBreakpoints.sizeOf(screenWidth);

  bool get isMobile => deviceSize == HosDeviceSize.mobile;
  bool get isTablet => deviceSize == HosDeviceSize.tablet;
  bool get isDesktop =>
      deviceSize == HosDeviceSize.desktop || deviceSize == HosDeviceSize.large;
  bool get isLargeDesktop => deviceSize == HosDeviceSize.large;

  bool get isCompact => isMobile;
  bool get isExpanded => screenWidth >= AppBreakpoints.tablet;

  /// True when the navigation rail should be the primary nav, not a bottom bar.
  bool get useRailNav => screenWidth >= AppBreakpoints.railThreshold;

  /// True when the navigation rail should show labels (extended).
  bool get useExtendedRail => screenWidth >= AppBreakpoints.railExtendedThreshold;

  /// Pick a value based on the current device size.
  /// Falls back from large → desktop → tablet → mobile if a value is omitted.
  T responsive<T>({
    required T mobile,
    T? tablet,
    T? desktop,
    T? large,
  }) {
    switch (deviceSize) {
      case HosDeviceSize.large:
        return large ?? desktop ?? tablet ?? mobile;
      case HosDeviceSize.desktop:
        return desktop ?? tablet ?? mobile;
      case HosDeviceSize.tablet:
        return tablet ?? mobile;
      case HosDeviceSize.mobile:
        return mobile;
    }
  }
}
