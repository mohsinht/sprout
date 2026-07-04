import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'sprout_tokens.dart';

ThemeData buildSproutTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: SproutColors.seed,
    brightness: Brightness.light,
    surface: SproutColors.surface,
  );

  final baseText = GoogleFonts.hankenGroteskTextTheme();
  final display = GoogleFonts.baloo2;

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme.copyWith(
      primary: SproutColors.seed,
      secondary: SproutColors.sky,
      tertiary: SproutColors.lilac,
      error: SproutColors.tomato,
      surface: SproutColors.surface,
    ),
    scaffoldBackgroundColor: SproutColors.background,
    textTheme: baseText.copyWith(
      displaySmall: display(
        fontSize: 34,
        fontWeight: FontWeight.w800,
        color: SproutColors.ink,
      ),
      headlineSmall: display(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: SproutColors.ink,
      ),
      titleLarge: display(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: SproutColors.ink,
      ),
      titleMedium: GoogleFonts.hankenGrotesk(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: SproutColors.ink,
      ),
      bodyLarge: GoogleFonts.hankenGrotesk(
        fontSize: 16,
        height: 1.35,
        fontWeight: FontWeight.w600,
        color: SproutColors.ink,
      ),
      bodyMedium: GoogleFonts.hankenGrotesk(
        fontSize: 14,
        height: 1.35,
        fontWeight: FontWeight.w600,
        color: SproutColors.muted,
      ),
      labelLarge: GoogleFonts.hankenGrotesk(
        fontSize: 14,
        fontWeight: FontWeight.w800,
      ),
    ),
    cardTheme: CardThemeData(
      color: SproutColors.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
  );
}
