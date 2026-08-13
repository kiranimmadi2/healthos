import 'package:flutter/material.dart';

/// Brightness-aware semantic colour tokens.
///
/// [AppColors] holds the raw brand palette (and separate `dark*` constants that
/// nothing ever resolved between). This extension is the piece that actually
/// resolves: read `context.hos.textPrimary` and you get the right value for the
/// active theme, with no `isDark ? a : b` branching at the call site.
///
/// It is a [ThemeExtension] rather than a brightness-sensing static because:
///  * `MaterialApp` already animates theme changes (300ms, easeInOutCubic), and
///    a ThemeExtension participates in that lerp — so light/dark cross-fades
///    instead of snapping.
///  * It respects locally overridden `Theme` widgets (e.g. the date picker in
///    `profile_setup_screen`), which a global static cannot see.
///  * It is `const` and directly assertable in widget tests.
///
/// Alpha is pre-baked into the ARGB literals so both variants stay `const`
/// (`Color.withOpacity` is not a const expression).
@immutable
class HosColors extends ThemeExtension<HosColors> {
  const HosColors({
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.textInverse,
    required this.surface,
    required this.surfaceMuted,
    required this.surfaceElevated,
    required this.background,
    required this.border,
    required this.borderStrong,
    required this.glassFill,
    required this.glassFillStrong,
    required this.glassBorder,
    required this.glassShadow,
    required this.glassHighlight,
    required this.canvasStart,
    required this.canvasMid,
    required this.canvasEnd,
    required this.orbBlue,
    required this.orbBlueSoft,
    required this.orbPurple,
    required this.orbPurpleSoft,
    required this.orbCyan,
    required this.orbCyanSoft,
    required this.orbLavender,
    required this.brand,
    required this.brandSoft,
    required this.successFg,
    required this.successBg,
    required this.warningFg,
    required this.warningBg,
    required this.dangerFg,
    required this.dangerBg,
    required this.infoFg,
    required this.infoBg,
    required this.categoryLab,
    required this.categoryPrescription,
    required this.categoryImaging,
    required this.categoryImmunization,
    required this.categoryOther,
  });

  // Text ramp
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;

  /// Readable against [brand] fills and gradient heroes.
  final Color textInverse;

  // Surfaces
  final Color surface;
  final Color surfaceMuted;
  final Color surfaceElevated;
  final Color background;

  // Borders
  final Color border;
  final Color borderStrong;

  // Glassmorphism (see GlassContainer)
  final Color glassFill;
  final Color glassFillStrong;
  final Color glassBorder;
  final Color glassShadow;

  /// Inner top highlight that sells the "frosted" look. Transparent in dark.
  final Color glassHighlight;

  // Ambient canvas (see GlassCanvas)
  final Color canvasStart;
  final Color canvasMid;
  final Color canvasEnd;
  final Color orbBlue;
  final Color orbBlueSoft;
  final Color orbPurple;
  final Color orbPurpleSoft;
  final Color orbCyan;
  final Color orbCyanSoft;
  final Color orbLavender;

  // Brand + semantics
  final Color brand;
  final Color brandSoft;
  final Color successFg;
  final Color successBg;
  final Color warningFg;
  final Color warningBg;
  final Color dangerFg;
  final Color dangerBg;
  final Color infoFg;
  final Color infoBg;

  // Medical record categories
  final Color categoryLab;
  final Color categoryPrescription;
  final Color categoryImaging;
  final Color categoryImmunization;
  final Color categoryOther;

  static const light = HosColors(
    textPrimary: Color(0xFF0F172A),
    textSecondary: Color(0xFF475569),
    textMuted: Color(0xFF64748B),
    textInverse: Color(0xFFFFFFFF),
    surface: Color(0xFFFFFFFF),
    surfaceMuted: Color(0xFFF8FAFC),
    surfaceElevated: Color(0xFFFFFFFF),
    background: Color(0xFFF1F5F9),
    border: Color(0xFFE2E8F0),
    borderStrong: Color(0xFFCBD5E1),
    glassFill: Color(0xA6FFFFFF),
    glassFillStrong: Color(0xD9FFFFFF),
    glassBorder: Color(0xBFFFFFFF),
    glassShadow: Color(0x0F0F172A),
    glassHighlight: Color(0x99FFFFFF),
    canvasStart: Color(0xFFE2E8F0),
    canvasMid: Color(0xFFE0E7FF),
    canvasEnd: Color(0xFFF1F5F9),
    orbBlue: Color(0x473B82F6),
    orbBlueSoft: Color(0x1F60A5FA),
    orbPurple: Color(0x408B5CF6),
    orbPurpleSoft: Color(0x1AA78BFA),
    orbCyan: Color(0x3306B6D4),
    orbCyanSoft: Color(0x0F38BDF8),
    orbLavender: Color(0x33C084FC),
    brand: Color(0xFF2563EB),
    brandSoft: Color(0xFFEFF6FF),
    successFg: Color(0xFF059669),
    successBg: Color(0xFFECFDF5),
    warningFg: Color(0xFFB45309),
    warningBg: Color(0xFFFEF3C7),
    dangerFg: Color(0xFFDC2626),
    dangerBg: Color(0xFFFEF2F2),
    infoFg: Color(0xFF2563EB),
    infoBg: Color(0xFFEFF6FF),
    categoryLab: Color(0xFFB45309),
    categoryPrescription: Color(0xFF2563EB),
    categoryImaging: Color(0xFF0F8F83),
    categoryImmunization: Color(0xFF059669),
    categoryOther: Color(0xFF64748B),
  );

  static const dark = HosColors(
    textPrimary: Color(0xFFF8FAFC),
    textSecondary: Color(0xFFCBD5E1),
    textMuted: Color(0xFF94A3B8),
    textInverse: Color(0xFF0F172A),
    surface: Color(0xFF1E293B),
    surfaceMuted: Color(0xFF0F172A),
    surfaceElevated: Color(0xFF273449),
    background: Color(0xFF0B0F19),
    border: Color(0xFF334155),
    borderStrong: Color(0xFF475569),
    glassFill: Color(0x9D1E293B),
    glassFillStrong: Color(0xE01E293B),
    glassBorder: Color(0xD9334155),
    glassShadow: Color(0x59000000),
    glassHighlight: Color(0x00FFFFFF),
    canvasStart: Color(0xFF090D16),
    canvasMid: Color(0xFF0F172A),
    canvasEnd: Color(0xFF131C31),
    orbBlue: Color(0x592563EB),
    orbBlueSoft: Color(0x261D4ED8),
    orbPurple: Color(0x4D7C3AED),
    orbPurpleSoft: Color(0x1F6D28D9),
    orbCyan: Color(0x470E7490),
    orbCyanSoft: Color(0x0F0E7490),
    orbLavender: Color(0x389333EA),
    brand: Color(0xFF60A5FA),
    brandSoft: Color(0xFF1E3A8A),
    successFg: Color(0xFF34D399),
    successBg: Color(0x2E10B981),
    warningFg: Color(0xFFFBBF24),
    warningBg: Color(0x2EF59E0B),
    dangerFg: Color(0xFFF87171),
    dangerBg: Color(0x2EEF4444),
    infoFg: Color(0xFF60A5FA),
    infoBg: Color(0x2E3B82F6),
    categoryLab: Color(0xFFFBBF24),
    categoryPrescription: Color(0xFF60A5FA),
    categoryImaging: Color(0xFF2DD4BF),
    categoryImmunization: Color(0xFF34D399),
    categoryOther: Color(0xFF94A3B8),
  );

  @override
  HosColors copyWith({
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? textInverse,
    Color? surface,
    Color? surfaceMuted,
    Color? surfaceElevated,
    Color? background,
    Color? border,
    Color? borderStrong,
    Color? glassFill,
    Color? glassFillStrong,
    Color? glassBorder,
    Color? glassShadow,
    Color? glassHighlight,
    Color? canvasStart,
    Color? canvasMid,
    Color? canvasEnd,
    Color? orbBlue,
    Color? orbBlueSoft,
    Color? orbPurple,
    Color? orbPurpleSoft,
    Color? orbCyan,
    Color? orbCyanSoft,
    Color? orbLavender,
    Color? brand,
    Color? brandSoft,
    Color? successFg,
    Color? successBg,
    Color? warningFg,
    Color? warningBg,
    Color? dangerFg,
    Color? dangerBg,
    Color? infoFg,
    Color? infoBg,
    Color? categoryLab,
    Color? categoryPrescription,
    Color? categoryImaging,
    Color? categoryImmunization,
    Color? categoryOther,
  }) {
    return HosColors(
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      textInverse: textInverse ?? this.textInverse,
      surface: surface ?? this.surface,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      background: background ?? this.background,
      border: border ?? this.border,
      borderStrong: borderStrong ?? this.borderStrong,
      glassFill: glassFill ?? this.glassFill,
      glassFillStrong: glassFillStrong ?? this.glassFillStrong,
      glassBorder: glassBorder ?? this.glassBorder,
      glassShadow: glassShadow ?? this.glassShadow,
      glassHighlight: glassHighlight ?? this.glassHighlight,
      canvasStart: canvasStart ?? this.canvasStart,
      canvasMid: canvasMid ?? this.canvasMid,
      canvasEnd: canvasEnd ?? this.canvasEnd,
      orbBlue: orbBlue ?? this.orbBlue,
      orbBlueSoft: orbBlueSoft ?? this.orbBlueSoft,
      orbPurple: orbPurple ?? this.orbPurple,
      orbPurpleSoft: orbPurpleSoft ?? this.orbPurpleSoft,
      orbCyan: orbCyan ?? this.orbCyan,
      orbCyanSoft: orbCyanSoft ?? this.orbCyanSoft,
      orbLavender: orbLavender ?? this.orbLavender,
      brand: brand ?? this.brand,
      brandSoft: brandSoft ?? this.brandSoft,
      successFg: successFg ?? this.successFg,
      successBg: successBg ?? this.successBg,
      warningFg: warningFg ?? this.warningFg,
      warningBg: warningBg ?? this.warningBg,
      dangerFg: dangerFg ?? this.dangerFg,
      dangerBg: dangerBg ?? this.dangerBg,
      infoFg: infoFg ?? this.infoFg,
      infoBg: infoBg ?? this.infoBg,
      categoryLab: categoryLab ?? this.categoryLab,
      categoryPrescription: categoryPrescription ?? this.categoryPrescription,
      categoryImaging: categoryImaging ?? this.categoryImaging,
      categoryImmunization: categoryImmunization ?? this.categoryImmunization,
      categoryOther: categoryOther ?? this.categoryOther,
    );
  }

  @override
  HosColors lerp(ThemeExtension<HosColors>? other, double t) {
    if (other is! HosColors) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return HosColors(
      textPrimary: mix(textPrimary, other.textPrimary),
      textSecondary: mix(textSecondary, other.textSecondary),
      textMuted: mix(textMuted, other.textMuted),
      textInverse: mix(textInverse, other.textInverse),
      surface: mix(surface, other.surface),
      surfaceMuted: mix(surfaceMuted, other.surfaceMuted),
      surfaceElevated: mix(surfaceElevated, other.surfaceElevated),
      background: mix(background, other.background),
      border: mix(border, other.border),
      borderStrong: mix(borderStrong, other.borderStrong),
      glassFill: mix(glassFill, other.glassFill),
      glassFillStrong: mix(glassFillStrong, other.glassFillStrong),
      glassBorder: mix(glassBorder, other.glassBorder),
      glassShadow: mix(glassShadow, other.glassShadow),
      glassHighlight: mix(glassHighlight, other.glassHighlight),
      canvasStart: mix(canvasStart, other.canvasStart),
      canvasMid: mix(canvasMid, other.canvasMid),
      canvasEnd: mix(canvasEnd, other.canvasEnd),
      orbBlue: mix(orbBlue, other.orbBlue),
      orbBlueSoft: mix(orbBlueSoft, other.orbBlueSoft),
      orbPurple: mix(orbPurple, other.orbPurple),
      orbPurpleSoft: mix(orbPurpleSoft, other.orbPurpleSoft),
      orbCyan: mix(orbCyan, other.orbCyan),
      orbCyanSoft: mix(orbCyanSoft, other.orbCyanSoft),
      orbLavender: mix(orbLavender, other.orbLavender),
      brand: mix(brand, other.brand),
      brandSoft: mix(brandSoft, other.brandSoft),
      successFg: mix(successFg, other.successFg),
      successBg: mix(successBg, other.successBg),
      warningFg: mix(warningFg, other.warningFg),
      warningBg: mix(warningBg, other.warningBg),
      dangerFg: mix(dangerFg, other.dangerFg),
      dangerBg: mix(dangerBg, other.dangerBg),
      infoFg: mix(infoFg, other.infoFg),
      infoBg: mix(infoBg, other.infoBg),
      categoryLab: mix(categoryLab, other.categoryLab),
      categoryPrescription: mix(categoryPrescription, other.categoryPrescription),
      categoryImaging: mix(categoryImaging, other.categoryImaging),
      categoryImmunization: mix(categoryImmunization, other.categoryImmunization),
      categoryOther: mix(categoryOther, other.categoryOther),
    );
  }
}

/// `context.hos.textPrimary` — the standard way to read a semantic colour.
extension HosColorsX on BuildContext {
  HosColors get hos =>
      Theme.of(this).extension<HosColors>() ?? HosColors.light;
}
