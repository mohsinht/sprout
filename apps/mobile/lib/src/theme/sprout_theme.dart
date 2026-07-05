import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'sprout_tokens.dart';

/// Adaptive Sprout color tokens resolved from the current [Theme] brightness.
///
/// Screens should prefer `SproutColors.of(context)` for surface/ink/muted/line
/// so they adapt to dark mode. Brand accents (seed, gold, sky, lilac, tomato)
/// are constant across themes.
@immutable
class SproutColorScheme extends ThemeExtension<SproutColorScheme> {
  const SproutColorScheme({
    required this.brightness,
    required this.surface,
    required this.background,
    required this.ink,
    required this.muted,
    required this.line,
    required this.mint,
  });

  final Brightness brightness;
  final Color surface;
  final Color background;
  final Color ink;
  final Color muted;
  final Color line;
  final Color mint;

  static const light = SproutColorScheme(
    brightness: Brightness.light,
    surface: SproutColors.surface,
    background: SproutColors.background,
    ink: SproutColors.ink,
    muted: SproutColors.muted,
    line: SproutColors.line,
    mint: SproutColors.mint,
  );

  static const dark = SproutColorScheme(
    brightness: Brightness.dark,
    surface: SproutColors.darkSurface,
    background: SproutColors.darkBackground,
    ink: SproutColors.darkInk,
    muted: SproutColors.darkMuted,
    line: SproutColors.darkLine,
    mint: SproutColors.darkMint,
  );

  static SproutColorScheme of(BuildContext context) {
    final ext = Theme.of(context).extension<SproutColorScheme>();
    return ext ?? light;
  }

  @override
  SproutColorScheme copyWith({
    Brightness? brightness,
    Color? surface,
    Color? background,
    Color? ink,
    Color? muted,
    Color? line,
    Color? mint,
  }) {
    return SproutColorScheme(
      brightness: brightness ?? this.brightness,
      surface: surface ?? this.surface,
      background: background ?? this.background,
      ink: ink ?? this.ink,
      muted: muted ?? this.muted,
      line: line ?? this.line,
      mint: mint ?? this.mint,
    );
  }

  @override
  SproutColorScheme lerp(ThemeExtension<SproutColorScheme>? other, double t) {
    if (other is! SproutColorScheme) return this;
    return SproutColorScheme(
      brightness: t < 0.5 ? brightness : other.brightness,
      surface: Color.lerp(surface, other.surface, t)!,
      background: Color.lerp(background, other.background, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      line: Color.lerp(line, other.line, t)!,
      mint: Color.lerp(mint, other.mint, t)!,
    );
  }
}

class SproutType {
  const SproutType._();

  static TextStyle playfulTitle({
    required Color color,
    double size = 24,
    FontWeight weight = FontWeight.w700,
    double height = 1.2,
  }) {
    return GoogleFonts.fredoka(
      color: color,
      fontSize: size,
      fontWeight: weight,
      height: height,
      letterSpacing: 0,
    );
  }

  static TextStyle playfulLabel({
    required Color color,
    double size = 14,
    FontWeight weight = FontWeight.w700,
    double height = 1.15,
  }) {
    return GoogleFonts.fredoka(
      color: color,
      fontSize: size,
      fontWeight: weight,
      height: height,
      letterSpacing: 0,
    );
  }

  static TextStyle moneyValue({
    required Color color,
    double size = 18,
    FontWeight weight = FontWeight.w700,
    double height = 1.05,
  }) {
    return GoogleFonts.inter(
      color: color,
      fontSize: size,
      fontWeight: weight,
      height: height,
      letterSpacing: 0,
    );
  }

  static TextStyle metricValue({
    required Color color,
    double size = 14,
    FontWeight weight = FontWeight.w700,
    double height = 1.05,
  }) {
    return GoogleFonts.inter(
      color: color,
      fontSize: size,
      fontWeight: weight,
      height: height,
      letterSpacing: 0,
    );
  }

  static TextStyle scoreValue({
    required Color color,
    double size = 30,
    FontWeight weight = FontWeight.w800,
    double height = 1,
  }) {
    return GoogleFonts.inter(
      color: color,
      fontSize: size,
      fontWeight: weight,
      height: height,
      letterSpacing: 0,
    );
  }

  static TextStyle body({
    required Color color,
    double size = 14,
    FontWeight weight = FontWeight.w500,
    double height = 1.4,
  }) {
    return GoogleFonts.nunitoSans(
      color: color,
      fontSize: size,
      fontWeight: weight,
      height: height,
      letterSpacing: 0,
    );
  }
}

ThemeData buildSproutTheme({Brightness brightness = Brightness.light}) {
  final isDark = brightness == Brightness.dark;
  final scheme = isDark ? SproutColorScheme.dark : SproutColorScheme.light;

  final colorScheme = ColorScheme.fromSeed(
    seedColor: SproutColors.seed,
    brightness: brightness,
    surface: scheme.surface,
  ).copyWith(
    primary: isDark ? SproutColors.darkSeed : SproutColors.seed,
    secondary: isDark ? SproutColors.darkSky : SproutColors.sky,
    tertiary: isDark ? SproutColors.darkLilac : SproutColors.lilac,
    error: isDark ? SproutColors.darkTomato : SproutColors.tomato,
    surface: scheme.surface,
    onSurface: scheme.ink,
  );

  final baseText = GoogleFonts.nunitoSansTextTheme();
  const displayWeight = FontWeight.w700; // Fredoka SemiBold/Bold
  const bodyWeight = FontWeight.w500; // Medium
  const labelWeight = FontWeight.w700; // Bold
  final ink = scheme.ink;
  final muted = scheme.muted;

  // Fredoka for playful headings / quest labels / display numbers.
  TextStyle fredoka(double size, FontWeight w, Color c, {double ls = 0}) =>
      GoogleFonts.fredoka(
        fontSize: size,
        fontWeight: w,
        color: c,
        letterSpacing: ls,
        height: 1.25,
      );

  // Nunito Sans for body / explanations / clean UI.
  TextStyle nunito(double size, FontWeight w, Color c, {double h = 1.45}) =>
      GoogleFonts.nunitoSans(
        fontSize: size,
        fontWeight: w,
        color: c,
        height: h,
      );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: scheme.background,
    extensions: [scheme],
    textTheme: baseText.copyWith(
      // Display / large numbers — Fredoka Bold (φ scale)
      displayLarge: fredoka(SproutTypeScale.s47, displayWeight, ink, ls: -0.5),
      displayMedium: fredoka(SproutTypeScale.s37, displayWeight, ink, ls: -0.5),
      displaySmall: fredoka(SproutTypeScale.s29, displayWeight, ink, ls: -0.3),
      // Headlines — Fredoka SemiBold
      headlineLarge: fredoka(SproutTypeScale.s29, FontWeight.w600, ink),
      headlineMedium: fredoka(SproutTypeScale.s23, FontWeight.w600, ink),
      headlineSmall: fredoka(SproutTypeScale.s18, FontWeight.w600, ink),
      // Titles — Fredoka SemiBold
      titleLarge: fredoka(SproutTypeScale.s23, FontWeight.w600, ink),
      titleMedium: fredoka(SproutTypeScale.s18, FontWeight.w600, ink),
      titleSmall: fredoka(SproutTypeScale.s14, FontWeight.w600, ink),
      // Body — Nunito Sans Medium (clean, readable)
      bodyLarge: nunito(SproutTypeScale.s18, bodyWeight, ink),
      bodyMedium: nunito(SproutTypeScale.s14, bodyWeight, muted),
      bodySmall: nunito(SproutTypeScale.s11, bodyWeight, muted, h: 1.35),
      // Labels — Nunito Sans Bold
      labelLarge: nunito(SproutTypeScale.s14, labelWeight, ink, h: 1.2),
      labelMedium: nunito(SproutTypeScale.s11, labelWeight, ink, h: 1.2),
      labelSmall: nunito(SproutTypeScale.s11, labelWeight, muted, h: 1.2),
    ),
    cardTheme: CardThemeData(
      color: scheme.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SproutRadius.card),
      ),
    ),
    dividerTheme: DividerThemeData(
      color: scheme.line,
      thickness: 1,
      space: 1,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: SproutColors.seed,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SproutRadius.pill),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: GoogleFonts.nunitoSans(
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: SproutColors.seed,
        textStyle: GoogleFonts.nunitoSans(
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(SproutRadius.card),
        borderSide: BorderSide(color: scheme.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(SproutRadius.card),
        borderSide: BorderSide(color: scheme.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(SproutRadius.card),
        borderSide: const BorderSide(color: SproutColors.seed, width: 1.5),
      ),
      labelStyle: GoogleFonts.nunitoSans(color: muted),
      hintStyle: GoogleFonts.nunitoSans(color: muted),
    ),
  );
}
