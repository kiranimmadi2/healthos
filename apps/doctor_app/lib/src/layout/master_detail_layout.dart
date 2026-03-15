import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';

/// A responsive two-column layout for tablet-first design.
///
/// On screens wider than [breakpoint] (default 900px), displays a
/// [master] panel (380px) on the left and [detail] panel (expanded)
/// on the right. On narrower screens, shows only the [master] panel
/// or [detail] panel based on [showDetail].
class MasterDetailLayout extends StatelessWidget {
  const MasterDetailLayout({
    super.key,
    required this.master,
    required this.detail,
    this.showDetail = false,
    this.breakpoint = 900,
    this.masterWidth = 380,
  });

  /// The left panel widget (patient list, navigation, etc.).
  final Widget master;

  /// The right panel widget (patient detail, forms, etc.).
  final Widget detail;

  /// On narrow screens, whether to show [detail] instead of [master].
  final bool showDetail;

  /// The width threshold for switching between single and two-column layout.
  final double breakpoint;

  /// The fixed width of the master panel in two-column mode.
  final double masterWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > breakpoint;

        if (isWide) {
          return Row(
            children: [
              SizedBox(
                width: masterWidth,
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
