import type { FxRate } from "@sprout/shared";
import { config } from "../config.js";

/** A swappable FX source. Every implementation carries provenance. */
export interface FxSource {
  readonly name: string;
  /** Fetch the latest FX rate for a pair (e.g. "USD/PKR"). Returns null on failure. */
  fetchRate(pair: string): Promise<FxRate | null>;
}

/** Mock FX source — returns the canonical example values. Labelled as mock. */
export class MockFxSource implements FxSource {
  readonly name = "Mock FX";

  private readonly mockRates: Record<string, FxRate> = {
    "USD/PKR": {
      pair: "USD/PKR",
      value: 277.992,
      asOf: new Date().toISOString().slice(0, 10),
      source: "Mock FX (not real data)",
    },
    "EUR/PKR": {
      pair: "EUR/PKR",
      value: 317.536,
      asOf: new Date().toISOString().slice(0, 10),
      source: "Mock FX (not real data)",
    },
  };

  async fetchRate(pair: string): Promise<FxRate | null> {
    return this.mockRates[pair] ?? null;
  }
}

/**
 * Real FX source using the free exchangerate.host API.
 * One call per pair per day — near-zero cost.
 * Falls back to null on any error (the caller uses last-known + labels stale).
 */
export class ExchangeRateHostFxSource implements FxSource {
  readonly name = "exchangerate.host";

  async fetchRate(pair: string): Promise<FxRate | null> {
    const [base, quote] = pair.split("/");
    if (!base || !quote) return null;

    try {
      const url = `https://api.exchangerate.host/latest?base=${base}&symbols=${quote}`;
      const res = await fetch(url, { signal: AbortSignal.timeout(10000) });
      if (!res.ok) return null;
      const data = (await res.json()) as { rates?: Record<string, number> };
      const rate = data.rates?.[quote];
      if (!rate || rate <= 0) return null;

      return {
        pair,
        value: rate,
        asOf: new Date().toISOString().slice(0, 10),
        source: this.name,
        sourceUrl: url,
      };
    } catch {
      return null;
    }
  }
}

/** Xe Currency Data API source. It is opt-in because credentials are paid/account based. */
export class XeFxSource implements FxSource {
  readonly name = "Xe";

  async fetchRate(pair: string): Promise<FxRate | null> {
    const [base, quote] = pair.split("/");
    if (!base || !quote || !config.xeAccountId || !config.xeApiKey) return null;

    try {
      const url = `https://xecdapi.xe.com/v1/convert_from.json/?from=${base}&to=${quote}&amount=1`;
      const auth = Buffer.from(`${config.xeAccountId}:${config.xeApiKey}`).toString("base64");
      const res = await fetch(url, {
        headers: { Authorization: `Basic ${auth}` },
        signal: AbortSignal.timeout(10000),
      });
      if (!res.ok) return null;
      const data = (await res.json()) as { to?: Record<string, number>; timestamp?: string };
      const rate = data.to?.[quote];
      if (!rate || rate <= 0) return null;
      return {
        pair,
        value: rate,
        asOf: data.timestamp?.slice(0, 10) ?? new Date().toISOString().slice(0, 10),
        source: this.name,
        sourceUrl: url,
      };
    } catch {
      return null;
    }
  }
}

class UnavailableFxSource implements FxSource {
  readonly name = "FX unavailable";
  async fetchRate(_pair: string): Promise<FxRate | null> {
    return null;
  }
}

/** Factory: returns real source if enabled, else mock. */
export function createFxSource(): FxSource {
  if (config.fxSource === "xe") {
    return new XeFxSource();
  }
  if (config.fxSource === "exchange_rate_host") {
    return new ExchangeRateHostFxSource();
  }
  if (config.fxSource === "mock" && !config.isProduction) return new MockFxSource();
  return new UnavailableFxSource();
}
