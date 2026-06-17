import 'package:flutter/material.dart';

import '../layout/responsive_layout.dart';

class HealthPage extends StatelessWidget {
  const HealthPage({
    super.key,
    required this.child,
    this.maxWidth = 1280,
    this.bottomPadding = 32,
  });

  final Widget child;
  final double maxWidth;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    final padding = ResponsiveLayout.pagePadding(context);
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(padding, 24, padding, bottomPadding),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: child,
        ),
      ),
    );
  }
}
