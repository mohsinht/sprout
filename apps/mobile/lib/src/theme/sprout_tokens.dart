import 'package:flutter/material.dart';

/// Canonical Sprout design tokens.
///
/// These mirror `packages/design_tokens/src/index.ts` which is the single
/// source of truth for the Sprout brand across web, API and mobile. When you
/// change a value here, update the TS package too (and vice versa).
class SproutColors {
  static const seed = Color(0xFF2FB46E);
  static const leaf = Color(0xFF167A4A);
  static const mint = Color(0xFFE9F8EF);
  static const sky = Color(0xFF2E7BEF);
  static const lilac = Color(0xFF7B61FF);
  static const gold = Color(0xFFF3B43F);
  static const tomato = Color(0xFFE05252);
  static const ink = Color(0xFF17201B);
  static const muted = Color(0xFF647067);
  static const line = Color(0xFFDCE8E1);
  static const surface = Color(0xFFFFFFFF);
  static const background = Color(0xFFF6FAF7);

  // Hero gradient stops (per-screen accent surfaces)
  static const heroGreenStart = Color(0xFF2FB46E);
  static const heroGreenEnd = Color(0xFF167A4A);
  static const heroSkyStart = Color(0xFF4C8FF3);
  static const heroSkyEnd = Color(0xFF2E67DC);
  static const heroLilacStart = Color(0xFF9E70F2);
  static const heroLilacEnd = Color(0xFF7A47E4);
  static const heroGoldStart = Color(0xFFFFF6DB);
  static const heroGoldEnd = Color(0xFFFFE6A7);
  static const heroTealStart = Color(0xFF14B59B);
  static const heroTealEnd = Color(0xFF0B8D79);

  // Soft tint surfaces used by tiles / pills
  static const tintGold = Color(0xFFFFF3D3);
  static const tintSky = Color(0xFFEAF2FF);
  static const tintMint = Color(0xFFE9F8EF);
  static const tintLilac = Color(0xFFF1EAFE);
  static const tintWarm = Color(0xFFFFF4E4);

  // Status accents
  static const attention = Color(0xFFFF8A80);
  static const healthy = Color(0xFFA7E8B7);
  static const locked = Color(0xFFC6D1CC);
  static const navIdle = Color(0xFF3F4A43);
  // Readable ink for text on gold tints
  static const goldInk = Color(0xFF9A6200);

  // Dark theme variant
  static const darkSeed = Color(0xFF3FCB7C);
  static const darkLeaf = Color(0xFF3FCB7C);
  static const darkMint = Color(0xFF133A26);
  static const darkSky = Color(0xFF5B9BFF);
  static const darkLilac = Color(0xFF9B83FF);
  static const darkGold = Color(0xFFF5C25B);
  static const darkTomato = Color(0xFFF06A6A);
  static const darkInk = Color(0xFFE8F0EB);
  static const darkMuted = Color(0xFF9DB2A6);
  static const darkLine = Color(0xFF243029);
  static const darkSurface = Color(0xFF121C16);
  static const darkBackground = Color(0xFF0B1410);
}

class SproutSpacing {
  static const xs = 4.0;
  static const sm = 6.0;
  static const md = 10.0;
  static const lg = 16.0;
  static const xl = 26.0;
  static const xxl = 42.0;
  static const pageHorizontal = 20.0;
  static const pageTop = 10.0;
  static const pageBottom = 26.0;
}

/// Golden-ratio (φ ≈ 1.618) type scale. Each step is ×√φ ≈ 1.272; every
/// second step is ×φ. Use these for font sizes so type is consistent across
/// every screen instead of ad-hoc point sizes.
class SproutTypeScale {
  const SproutTypeScale._();

  static const s11 = 11.0;
  static const s14 = 14.0;
  static const s18 = 18.0;
  static const s23 = 23.0;
  static const s29 = 29.0;
  static const s37 = 37.0;
  static const s47 = 47.0;
  static const s60 = 60.0;
}

class SproutRadius {
  static const card = 24.0;
  static const hero = 28.0;
  static const tile = 20.0;
  static const pill = 999.0;
}

class SproutElevation {
  /// Standard card shadow.
  static List<BoxShadow> card({Color? color}) => [
        BoxShadow(
          color: (color ?? SproutColors.ink).withValues(alpha: 0.06),
          blurRadius: 24,
          offset: const Offset(0, 12),
        ),
      ];

  /// Raised panel shadow (slightly stronger than card).
  static List<BoxShadow> raised({Color? color}) => [
        BoxShadow(
          color: (color ?? SproutColors.ink).withValues(alpha: 0.08),
          blurRadius: 26,
          offset: const Offset(0, 14),
        ),
      ];

  /// Hero gradient surface shadow (tinted by the hero color).
  static List<BoxShadow> hero(Color tint) => [
        BoxShadow(
          color: tint.withValues(alpha: 0.24),
          blurRadius: 26,
          offset: const Offset(0, 16),
        ),
      ];
}

class SproutGradients {
  static const green = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [SproutColors.heroGreenStart, SproutColors.heroGreenEnd],
  );
  static const sky = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [SproutColors.heroSkyStart, SproutColors.heroSkyEnd],
  );
  static const lilac = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [SproutColors.heroLilacStart, SproutColors.heroLilacEnd],
  );
  static const gold = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [SproutColors.heroGoldStart, SproutColors.heroGoldEnd],
  );
  static const teal = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [SproutColors.heroTealStart, SproutColors.heroTealEnd],
  );
}
