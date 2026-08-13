import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../app/theme/theme.dart';

/// Canvas with ambient floating glowing mesh gradient orbs behind content
class GlassCanvas extends StatelessWidget {
  const GlassCanvas({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final hos = context.hos;

    return Stack(
      children: [
        // Base canvas background
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [hos.canvasStart, hos.canvasMid, hos.canvasEnd],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        _Orb(
          top: -120,
          left: -100,
          size: 450,
          colors: [hos.orbBlue, hos.orbBlueSoft, Colors.transparent],
        ),
        _Orb(
          top: -60,
          right: -80,
          size: 500,
          colors: [hos.orbPurple, hos.orbPurpleSoft, Colors.transparent],
        ),
        _Orb(
          top: 300,
          right: -100,
          size: 400,
          colors: [hos.orbCyan, hos.orbCyanSoft, Colors.transparent],
        ),
        _Orb(
          bottom: -100,
          left: -120,
          size: 450,
          colors: [hos.orbLavender, Colors.transparent],
        ),
        // Main Child
        Positioned.fill(child: child),
      ],
    );
  }
}

/// One blurred ambient glow behind the glass surfaces.
class _Orb extends StatelessWidget {
  const _Orb({
    required this.size,
    required this.colors,
    this.top,
    this.left,
    this.right,
    this.bottom,
  });

  final double size;
  final List<Color> colors;
  final double? top;
  final double? left;
  final double? right;
  final double? bottom;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(colors: colors),
          ),
        ),
      ),
    );
  }
}

/// Frosted Glass Container with subtle border, blur, and elevation
class GlassContainer extends StatelessWidget {
  const GlassContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.borderRadius = 24.0,
    this.blur = 20.0,
    this.opacity = 0.65,
    this.borderColor,
    this.backgroundColor,
    this.gradient,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final double borderRadius;
  final double blur;
  final double opacity;
  final Color? borderColor;
  final Color? backgroundColor;
  final Gradient? gradient;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final hos = context.hos;

    // `opacity` scales the token's own alpha so callers that pass a custom
    // value keep working across both themes.
    final base = hos.glassFill;
    final defaultBg = base.withValues(
      alpha: (base.a * (opacity / 0.65)).clamp(0.0, 1.0),
    );
    final effectiveBg = backgroundColor ?? (gradient == null ? defaultBg : null);
    final defaultBorder = hos.glassBorder;

    Widget content = Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: effectiveBg,
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor ?? defaultBorder,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: hos.glassShadow,
            blurRadius: 24,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
          // Inner top highlight. Fully transparent in dark, where it would
          // read as a seam rather than a bevel.
          BoxShadow(
            color: hos.glassHighlight,
            blurRadius: 4,
            spreadRadius: 0,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: child,
    );

    if (onTap != null) {
      content = Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: content,
        ),
      );
    }

    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: content,
        ),
      ),
    );
  }
}

/// Circular Glass Button/Badge like in the reference design
class GlassPillButton extends StatelessWidget {
  const GlassPillButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.isSelected = false,
    this.accentColor = AppColors.primary,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isSelected;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final hos = context.hos;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GlassContainer(
            borderRadius: 30,
            blur: 16,
            borderColor: isSelected
                ? accentColor.withValues(alpha: 0.5)
                : hos.glassBorder,
            backgroundColor:
                isSelected ? hos.glassFillStrong : hos.glassFill,
            padding: const EdgeInsets.all(16),
            child: Icon(
              icon,
              size: 22,
              color: isSelected ? accentColor : hos.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? accentColor : hos.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
