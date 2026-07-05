export const sproutTokens = {
  color: {
    seed: "#2FB46E",
    leaf: "#167A4A",
    mint: "#E9F8EF",
    sky: "#2E7BEF",
    lilac: "#7B61FF",
    gold: "#F3B43F",
    tomato: "#E05252",
    ink: "#17201B",
    muted: "#647067",
    line: "#DCE8E1",
    surface: "#FFFFFF",
    background: "#F6FAF7",
    // Hero gradient stops (per-screen accent surfaces)
    heroGreenStart: "#2FB46E",
    heroGreenEnd: "#167A4A",
    heroSkyStart: "#4C8FF3",
    heroSkyEnd: "#2E67DC",
    heroLilacStart: "#9E70F2",
    heroLilacEnd: "#7A47E4",
    heroGoldStart: "#FFF6DB",
    heroGoldEnd: "#FFE6A7",
    heroTealStart: "#14B59B",
    heroTealEnd: "#0B8D79",
    // Soft tint surfaces used by tiles / pills
    tintGold: "#FFF3D3",
    tintSky: "#EAF2FF",
    tintMint: "#E9F8EF",
    tintLilac: "#F1EAFE",
    tintWarm: "#FFF4E4",
    // Status accents
    attention: "#FF8A80",
    healthy: "#A7E8B7",
    locked: "#C6D1CC",
    navIdle: "#3F4A43",
    goldInk: "#9A6200"
  },
  colorDark: {
    seed: "#3FCB7C",
    leaf: "#3FCB7C",
    mint: "#133A26",
    sky: "#5B9BFF",
    lilac: "#9B83FF",
    gold: "#F5C25B",
    tomato: "#F06A6A",
    ink: "#E8F0EB",
    muted: "#9DB2A6",
    line: "#243029",
    surface: "#121C16",
    background: "#0B1410"
  },
  radius: {
    card: 24,
    hero: 28,
    tile: 20,
    pill: 999
  },
  spacing: {
    xs: 4,
    sm: 8,
    md: 12,
    lg: 16,
    xl: 24,
    xxl: 32,
    pageHorizontal: 20
  },
  elevation: {
    card: { blur: 24, y: 12, alpha: 0.06 },
    raised: { blur: 26, y: 14, alpha: 0.08 },
    hero: { blur: 26, y: 16, alpha: 0.24 }
  },
  motion: {
    quickMs: 160,
    normalMs: 260,
    celebratoryMs: 520
  }
} as const;
