import 'package:flutter/material.dart';

import '../theme/app_breakpoints.dart';
import '../theme/app_spacing.dart';

/// Builds a different widget tree per breakpoint. Falls back from
/// large -> desktop -> tablet -> mobile if a builder is omitted.
class HosResponsive extends StatelessWidget {
  const HosResponsive({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.large,
  });

  final WidgetBuilder mobile;
  final WidgetBuilder? tablet;
  final WidgetBuilder? desktop;
  final WidgetBuilder? large;

  @override
  Widget build(BuildContext context) {
    final builder = context.responsive<WidgetBuilder>(
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
      large: large,
    );
    return builder(context);
  }
}

/// Caps content width on wide screens so reading lines stay short, and
/// applies responsive page padding. Drop in as the outer wrapper of any
/// scrollable page body.
class HosPageContainer extends StatelessWidget {
  const HosPageContainer({
    super.key,
    required this.child,
    this.maxWidth = AppBreakpoints.maxContentWidth,
    this.padding,
    this.center = true,
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;
  final bool center;

  @override
  Widget build(BuildContext context) {
    final resolvedPadding = padding ?? AppSpacing.pagePaddingOf(context);
    final content = ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Padding(padding: resolvedPadding, child: child),
    );
    return center ? Center(child: content) : content;
  }
}

/// Responsive grid that picks a column count based on the current breakpoint
/// and lays children out with consistent gaps. Use for dashboards, card grids,
/// and any "tile" surface that should reflow on resize.
class HosResponsiveGrid extends StatelessWidget {
  const HosResponsiveGrid({
    super.key,
    required this.children,
    this.mobileColumns = 1,
    this.tabletColumns = 2,
    this.desktopColumns = 3,
    this.largeColumns = 4,
    this.spacing,
    this.runSpacing,
  });

  final List<Widget> children;
  final int mobileColumns;
  final int tabletColumns;
  final int desktopColumns;
  final int largeColumns;
  final double? spacing;
  final double? runSpacing;

  @override
  Widget build(BuildContext context) {
    final cols = context.responsive<int>(
      mobile: mobileColumns,
      tablet: tabletColumns,
      desktop: desktopColumns,
      large: largeColumns,
    );
    final gap = spacing ?? AppSpacing.gridGapOf(context);
    final runGap = runSpacing ?? gap;

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalGap = gap * (cols - 1);
        final tileWidth = (constraints.maxWidth - totalGap) / cols;
        return Wrap(
          spacing: gap,
          runSpacing: runGap,
          children: [
            for (final child in children)
              SizedBox(
                width: tileWidth.clamp(0.0, constraints.maxWidth),
                child: child,
              ),
          ],
        );
      },
    );
  }
}

/// Two-column layout: stacks vertically on mobile, side-by-side on tablet+.
/// Good for forms, settings, master/detail-like content within a page.
class HosTwoColumn extends StatelessWidget {
  const HosTwoColumn({
    super.key,
    required this.primary,
    required this.secondary,
    this.primaryFlex = 2,
    this.secondaryFlex = 1,
    this.gap,
    this.breakpoint = AppBreakpoints.tablet,
    this.secondaryFirstOnMobile = false,
  });

  final Widget primary;
  final Widget secondary;
  final int primaryFlex;
  final int secondaryFlex;
  final double? gap;
  final double breakpoint;
  final bool secondaryFirstOnMobile;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final spacing = gap ?? AppSpacing.sectionGapOf(context);

    if (width >= breakpoint) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: primaryFlex, child: primary),
          SizedBox(width: spacing),
          Expanded(flex: secondaryFlex, child: secondary),
        ],
      );
    }

    final children = secondaryFirstOnMobile
        ? [secondary, SizedBox(height: spacing), primary]
        : [primary, SizedBox(height: spacing), secondary];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }
}
