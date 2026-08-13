import 'package:flutter/material.dart';

abstract final class AppColors {
  // Primary Vibrant Blue
  static const primary = Color(0xFF2563EB);
  static const primaryDark = Color(0xFF1E40AF);
  static const primarySoft = Color(0xFFEFF6FF);
  
  // Secondary Teal & Accents
  static const secondary = Color(0xFF0F8F83);
  static const secondarySoft = Color(0xFFECFDF5);
  static const success = Color(0xFF10B981);
  static const successSoft = Color(0xFFECFDF5);
  static const warning = Color(0xFFF59E0B);
  static const warningSoft = Color(0xFFFEF3C7);
  static const error = Color(0xFFEF4444);
  static const errorSoft = Color(0xFFFEF2F2);

  // Glass Surface & Background
  static const background = Color(0xFFF1F5F9);
  static const canvasGradientStart = Color(0xFFE2E8F0);
  static const canvasGradientEnd = Color(0xFFE0E7FF);
  
  static final glassSurface = Colors.white.withOpacity(0.65);
  static final glassSurfaceHover = Colors.white.withOpacity(0.85);
  static final glassBorder = Colors.white.withOpacity(0.75);
  
  static const surface = Color(0xFFFFFFFF);
  static const surfaceMuted = Color(0xFFF8FAFC);
  static const border = Color(0xFFE2E8F0);
  static const textPrimary = Color(0xFF0F172A);
  static const textMain = textPrimary;
  static const textSecondary = Color(0xFF475569);
  static const textMuted = Color(0xFF64748B);

  // Dark Mode Theme Color Palette
  static const darkBackground = Color(0xFF0B0F19);
  static const darkSurface = Color(0xFF1E293B);
  static const darkSurfaceMuted = Color(0xFF0F172A);
  static const darkBorder = Color(0xFF334155);
  static const darkTextPrimary = Color(0xFFF8FAFC);
  static const darkTextMain = darkTextPrimary;
  static const darkTextSecondary = Color(0xFFCBD5E1);
  static const darkTextMuted = Color(0xFF94A3B8);
  static const darkPrimarySoft = Color(0xFF1E3A8A);

  // Accent Colors
  static const accentPurple = Color(0xFF7C3AED);
  static const accentPurpleSoft = Color(0xFFF3E8FF);
  static const accentTeal = Color(0xFF0D9488);
  static const accentTealSoft = Color(0xFFCCFBF1);
  static const accentEmerald = Color(0xFF059669);
  static const accentEmeraldSoft = Color(0xFFD1FAE5);
  static const accentAmber = Color(0xFFD97706);
  static const accentAmberSoft = Color(0xFFFEF3C7);

  // Premium Gradients
  static const primaryGradient = LinearGradient(
    colors: [Color(0xFF2563EB), Color(0xFF4F46E5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const glassHeroGradient = LinearGradient(
    colors: [Color(0xEEFFFFFF), Color(0xCCF8FAFC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const secondaryGradient = LinearGradient(
    colors: [Color(0xFF0F8F83), Color(0xFF14B8A6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const purpleGradient = LinearGradient(
    colors: [Color(0xFF7C3AED), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const emeraldGradient = LinearGradient(
    colors: [Color(0xFF059669), Color(0xFF10B981)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}


