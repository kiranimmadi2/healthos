import 'package:flutter/material.dart';

abstract final class AppColors {
  static const primary = Color(0xFF2563EB);
  static const primaryDark = Color(0xFF1D4ED8);
  static const primarySoft = Color(0xFFEFF6FF);
  static const secondary = Color(0xFF0F8F83);
  static const secondarySoft = Color(0xFFECFDF5);
  static const success = Color(0xFF15803D);
  static const successSoft = Color(0xFFF0FDF4);
  static const warning = Color(0xFFB45309);
  static const warningSoft = Color(0xFFFFFBEB);
  static const error = Color(0xFFDC2626);
  static const errorSoft = Color(0xFFFEF2F2);
  static const background = Color(0xFFF8FAFC);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceMuted = Color(0xFFF1F5F9);
  static const border = Color(0xFFE2E8F0);
  static const textPrimary = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF475569);
  static const textMuted = Color(0xFF64748B);

  // Accent Colors
  static const accentPurple = Color(0xFF7C3AED);
  static const accentPurpleSoft = Color(0xFFF3E8FF);
  static const accentTeal = Color(0xFF0D9488);
  static const accentTealSoft = Color(0xFFCCFBF1);
  static const accentEmerald = Color(0xFF059669);
  static const accentEmeraldSoft = Color(0xFFD1FAE5);
  static const accentAmber = Color(0xFFD97706);
  static const accentAmberSoft = Color(0xFFFEF3C7);

  // Gradients
  static const primaryGradient = LinearGradient(
    colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
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

