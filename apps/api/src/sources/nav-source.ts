import type { PriceQuote } from "@sprout/shared";

/** A swappable NAV/price source. Every implementation carries provenance. */
export interface NavSource {
  readonly name: string;
  /** Fetch the latest NAV for a fund code (e.g. "AMMF"). Returns null on failure. */
  fetchNav(fundCode: string): Promise<PriceQuote | null>;
}

/** Mock NAV source — returns the canonical example values. Labelled as mock. */
export class MockNavSource implements NavSource {
  readonly name = "Mock NAV (not real data)";

  private readonly mockPrices: Record<string, number> = {
    AMMF: 54.2187,
    MIF: 17.5462,
    MSF: 63.4471,
    MDIP: 28.9134,
    "MFPF-AAP": 51.0723,
  };

  async fetchNav(fundCode: string): Promise<PriceQuote | null> {
    const value = this.mockPrices[fundCode.toUpperCase()];
    if (!value) return null;
    return {
      value,
      asOf: new Date().toISOString().slice(0, 10),
      source: this.name,
      currency: "PKR",
    };
  }
}

/**
 * MUFAP NAV source — fetches daily NAVs from mufap.com.pk.
 * This is the closest thing to an official source for Pakistani mutual funds.
 * Scrapes gently (once daily, cache, respect the site).
 * The parser is versioned and monitored — if the format changes, it fails loudly.
 *
 * NOTE: The actual MUFAP page structure is not verified. This implementation
 * is a scaffold that will need the real selector/path once the page is inspected.
 * Until then, it returns null and the caller falls back to last-known + stale label.
 */
export class MufapNavSource implements NavSource {
  readonly name = "MUFAP";
  readonly parserVersion = "mufap-nav-v1";

  async fetchNav(fundCode: string): Promise<PriceQuote | null> {
    try {
      // MUFAP publishes a daily NAV list. The exact URL and format need
      // verification against the live site. This is a scaffold.
      // When implemented: fetch the daily NAV table, match fundCode,
      // parse the NAV value and validity date, store provenance.
      //
      // For now, return null so the caller uses last-known + labels stale.
      void fundCode;
      return null;
    } catch {
      return null;
    }
  }
}

class UnavailableNavSource implements NavSource {
  readonly name = "NAV unavailable";
  async fetchNav(_fundCode: string): Promise<PriceQuote | null> {
    return null;
  }
}

/** Factory: returns real source if enabled, else mock. */
export function createNavSource(): NavSource {
  if (process.env.NAV_SOURCE === "mufap_validation") {
    return new MufapNavSource();
  }
  if (process.env.NAV_SOURCE === "mock" && process.env.NODE_ENV !== "production") {
    return new MockNavSource();
  }
  return new UnavailableNavSource();
}
