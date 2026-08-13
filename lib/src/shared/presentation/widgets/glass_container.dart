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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        // Base canvas background
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? const [
                        Color(0xFF090D16),
                        Color(0xFF0F172A),
                        Color(0xFF131C31),
                      ]
                    : const [
                        Color(0xFFE2E8F0),
                        Color(0xFFE0E7FF),
                        Color(0xFFF1F5F9),
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        // Top-left glowing blue orb
        Positioned(
          top: -120,
          left: -100,
          child: Container(
            width: 450,
            height: 450,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: isDark
                    ? [
                        const Color(0xFF2563EB).withOpacity(0.35),
                        const Color(0xFF1D4ED8).withOpacity(0.15),
                        Colors.transparent,
                      ]
                    : [
                        const Color(0xFF3B82F6).withOpacity(0.28),
                        const Color(0xFF60A5FA).withOpacity(0.12),
                        Colors.transparent,
                      ],
              ),
            ),
          ),
        ),
        // Top-right glowing purple/violet orb
        Positioned(
          top: -60,
          right: -80,
          child: Container(
            width: 500,
            height: 500,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: isDark
                    ? [
                        const Color(0xFF7C3AED).withOpacity(0.30),
                        const Color(0xFF6D28D9).withOpacity(0.12),
                        Colors.transparent,
                      ]
                    : [
                        const Color(0xFF8B5CF6).withOpacity(0.25),
                        const Color(0xFFA78BFA).withOpacity(0.10),
                        Colors.transparent,
                      ],
              ),
            ),
          ),
        ),
        // Center-right glowing cyan orb
        Positioned(
          top: 300,
          right: -100,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: isDark
                    ? [
                        const Color(0xFF0E7490).withOpacity(0.28),
                        Colors.transparent,
                      ]
                    : [
                        const Color(0xFF06B6D4).withOpacity(0.20),
                        const Color(0xFF38BDF8).withOpacity(0.06),
                        Colors.transparent,
                      ],
              ),
            ),
          ),
        ),
        // Bottom-left soft lavender glow
        Positioned(
          bottom: -100,
          left: -120,
          child: Container(
            width: 450,
            height: 450,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: isDark
                    ? [
                        const Color(0xFF9333EA).withOpacity(0.22),
                        Colors.transparent,
                      ]
                    : [
                        const Color(0xFFC084FC).withOpacity(0.20),
                        Colors.transparent,
                      ],
              ),
            ),
          ),
        ),
        // Main Child
        Positioned.fill(child: child),
      ],
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final defaultBg = isDark
        ? const Color(0xFF1E293B).withOpacity(opacity * 0.95)
        : Colors.white.withOpacity(opacity);
    final effectiveBg = backgroundColor ?? (gradient == null ? defaultBg : null);

    final defaultBorder = isDark
        ? const Color(0xFF334155).withOpacity(0.85)
        : Colors.white.withOpacity(0.75);

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
            color: isDark
                ? Colors.black.withOpacity(0.35)
                : const Color(0xFF0F172A).withOpacity(0.06),
            blurRadius: 24,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
          if (!isDark)
            BoxShadow(
              color: Colors.white.withOpacity(0.6),
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GlassContainer(
            borderRadius: 30,
            blur: 16,
            opacity: isSelected ? 0.90 : 0.60,
            borderColor: isSelected ? accentColor.withOpacity(0.5) : Colors.white.withOpacity(0.8),
            backgroundColor: isSelected ? Colors.white : Colors.white.withOpacity(0.55),
            padding: const EdgeInsets.all(16),
            child: Icon(
              icon,
              size: 22,
              color: isSelected ? accentColor : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? accentColor : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
