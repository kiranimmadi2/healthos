import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';

/// A responsive two-column layout for tablet-first design.
///
/// On screens wider than [breakpoint] (default [AppBreakpoints.tablet],
/// 1024dp), displays a [master] panel on the left and [detail] panel
/// (expanded) on the right. On narrower screens, shows only the [master]
/// panel or [detail] panel based on [showDetail].
///
/// The master panel width adapts to the device size:
/// - mobile: 380 (only used if breakpoint is overridden lower)
/// - tablet: 360
/// - desktop: 380
/// - large: 420
class MasterDetailLayout extends StatelessWidget {
  const MasterDetailLayout({
    super.key,
    required this.master,
    required this.detail,
    this.showDetail = false,
    this.breakpoint = AppBreakpoints.tablet,
    this.masterWidth,
  });

  /// The left panel widget (patient list, navigation, etc.).
  final Widget master;

  /// The right panel widget (patient detail, forms, etc.).
  final Widget detail;

  /// On narrow screens, whether to show [detail] instead of [master].
  final bool showDetail;

  /// The width threshold for switching between single and two-column layout.
  final double breakpoint;

  /// Optional explicit master panel width. If null, picks a width based on
  /// the current device size.
  final double? masterWidth;

  @override
  Widget build(BuildContext context) {
    final resolvedMasterWidth = masterWidth ??
        context.responsive<double>(
          mobile: 380,
          tablet: 360,
          desktop: 380,
          large: 420,
        );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > breakpoint;

        if (isWide) {
          return Row(
            children: [
              SizedBox(
                width: resolvedMasterWidth,
                child: master,
              ),
              const VerticalDivider(
                width: 1,
                color: AppColors.divider,
              ),
              Expanded(child: detail),
            ],
          );
        }

        // Narrow screen: show one panel at a time
        if (showDetail) {
          return detail;
        }
        return master;
      },
    );
  }
}
