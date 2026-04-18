import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary — Blue 600/400/700 (Tailwind)
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryLight = Color(0xFF60A5FA);
  static const Color primaryDark = Color(0xFF1D4ED8);

  // Secondary — Emerald 500/400/600
  static const Color secondary = Color(0xFF10B981);
  static const Color secondaryLight = Color(0xFF34D399);
  static const Color secondaryDark = Color(0xFF059669);

  // Semantic
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF2563EB);

  // Neutrals (Light)
  static const Color white = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color divider = Color(0xFFE2E8F0);
  static const Color disabled = Color(0xFFCBD5E1);

  // Text (Light)
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary = Color(0xFF94A3B8);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Biomarker status
  static const Color biomarkerNormal = Color(0xFF10B981);
  static const Color biomarkerLow = Color(0xFFF59E0B);
  static const Color biomarkerHigh = Color(0xFFEF4444);

  // Triage levels
  static const Color triageHomeCare = Color(0xFF10B981);
  static const Color triageSeeDoctor = Color(0xFFF59E0B);
  static const Color triageEmergency = Color(0xFFEF4444);

  // Dark theme — Slate 900/800 (Tailwind, warmer navy)
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkCard = Color(0xFF1E293B);
  static const Color darkDivider = Color(0xFF334155);
  static const Color darkTextPrimary = Color(0xFFF1F5F9);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextTertiary = Color(0xFF64748B);
  static const Color darkPrimary = Color(0xFF3B82F6);
  static const Color darkSecondary = Color(0xFF34D399);
}
