import type {
  PriceQuote,
  FxRate,
  WealthSnapshot,
  WealthEvent,
  WealthTrendPoint,
} from "@sprout/shared";
import { config } from "../config.js";

/**
 * Reconciliation estimation model.
 *
 * Sprout is a reconciliation engine, not a live-sync app:
 *   CONFIRMED BASELINE (from uploaded statement/screenshot)
 *     + daily NAV × units (price moves fund value)
 *     + daily FX × balances (rate moves cash value)
 *     + manual transactions (salary in, transfer out, spend)
 *     + pending/in-transit (money moved but not yet unitized)
 *     = ESTIMATED TODAY'S TOTAL (shown with "estimated since <baseline date>")
 *
 * Every number is either confirmed (as-of last statement) or estimated
 * (computed forward since). This distinction is visible, not hidden.
 */

export type ValuationKind = "confirmed" | "estimated";

export interface EnrichedHolding {
  id: string;
  kind: "mutual_fund" | "cash" | "equity" | "other";
  institution: string;
  label: string;
  fundCode?: string;
  currency: string;
  units?: number;
  unitsConfirmedAsOf?: string; // date units were last confirmed by a statement
  valueNative?: number;
  valuePkr: number;
  price?: PriceQuote;
  fxRate?: FxRate;
  priceAsOf: string;
  priceSource: string;
  freshness: "fresh" | "stale" | "manual" | "unavailable" | "estimated";
  valuationKind: ValuationKind; // confirmed or estimated
  baselineId?: string;
}

export interface PendingInvestment {
  id: string;
  amountPkr: number;
  destination: string;
  initiatedOn: string;
  status: "pending" | "unitized";
}

export interface ProjectedIncomeEntry {
  id: string;
  amount: number;
  currency: string;
  expectedOn: string;
  convertedPkrEstimate?: number;
  note?: string;
}

export interface ManualAdjustment {
  id: string;
  amount: number; // signed: + for inflow, - for outflow
  currency: string;
  occurredAt: string;
  note?: string;
  affectsAccount?: string;
}

/** Determine freshness based on how old the price/FX date is. */
export function determineFreshness(
  priceAsOf: string | null | undefined,
  kind: string,
  referenceDate = new Date().toISOString().slice(0, 10),
): "fresh" | "stale" | "manual" | "unavailable" | "estimated" {
  if (!priceAsOf) return "unavailable";
  const ageDays = Math.floor(
    (new Date(`${referenceDate}T12:00:00Z`).getTime() - new Date(`${priceAsOf}T12:00:00Z`).getTime()) / (1000 * 60 * 60 * 24)
  );
  const threshold = kind === "cash" ? config.staleFxDays : config.staleNavDays;
  if (ageDays <= threshold) return "fresh";
  return "stale";
}

/**
 * Determine valuation kind: confirmed if units/balance come from a recent
 * baseline and no manual adjustments exist since; estimated otherwise.
 */
export function determineValuationKind(params: {
  unitsConfirmedAsOf?: string;
  hasAdjustmentsSinceBaseline: boolean;
}): ValuationKind {
  if (!params.unitsConfirmedAsOf) return "estimated";
  if (params.hasAdjustmentsSinceBaseline) return "estimated";
  return "confirmed";
}

/** Compute valuePkr for a holding from its price/FX. Code owns the arithmetic. */
export function computeHoldingValuePkr(holding: {
  kind: string;
  currency: string;
  units?: number;
  valueNative?: number;
  price?: PriceQuote;
  fxRate?: FxRate;
}): number {
  if (holding.currency === "PKR") {
    if (holding.kind === "cash") {
      return Math.round(holding.valueNative ?? 0);
    }
    const units = holding.units ?? 0;
    const nav = holding.price?.value ?? 0;
    return Math.round(units * nav);
  }

  if (holding.kind === "cash") {
    const native = holding.valueNative ?? 0;
    const fx = holding.fxRate?.value ?? 0;
    return Math.round(native * fx);
  }

  const units = holding.units ?? 0;
  const nav = holding.price?.value ?? 0;
  const fx = holding.fxRate?.value ?? 1;
  return Math.round(units * nav * fx);
}

/**
 * Estimate a Wise/cash holding's current value by applying manual adjustments
 * since the last confirmed baseline, then revaluing at today's FX.
 *
 * estimate = baseline_balance + Σ(adjustments since baseline) → revalue at today's FX
 */
export function estimateCashHoldingValue(params: {
  confirmedBalanceNative: number;
  currency: string;
  adjustments: ManualAdjustment[];
  fxRate?: FxRate;
}): { valueNative: number; valuePkr: number } {
  const { confirmedBalanceNative, currency, adjustments, fxRate } = params;

  const adjustedNative = adjustments.reduce(
    (sum, a) => sum + (a.currency === currency ? a.amount : 0),
    confirmedBalanceNative
  );

  const valuePkr =
    currency === "PKR"
      ? Math.round(adjustedNative)
      : Math.round(adjustedNative * (fxRate?.value ?? 0));

  return { valueNative: adjustedNative, valuePkr };
}

/**
 * Build a WealthSnapshot from enriched holdings + pending investments + trend.
 * Total wealth = Σ(holding values) + Σ(pending in-transit).
 * Pending is never double-counted (once as pending, again as units).
 */
export function computeWealthSnapshot(params: {
  date: string;
  holdings: EnrichedHolding[];
  pendingInvestments: PendingInvestment[];
  priorSnapshot?: {
    totalPkr: number;
    perHoldingBreakdown: { holdingId: string; valuePkr: number }[];
  };
  monthStartSnapshot?: {
    totalPkr: number;
    perHoldingBreakdown: { holdingId: string; valuePkr: number }[];
  };
  trend: WealthTrendPoint[];
}): WealthSnapshot {
  const { date, holdings, pendingInvestments, trend } = params;

  const holdingsTotal = holdings.reduce((sum, h) => sum + h.valuePkr, 0);
  const pendingTotal = pendingInvestments
    .filter((p) => p.status === "pending")
    .reduce((sum, p) => sum + p.amountPkr, 0);
  const totalPkr = holdingsTotal + pendingTotal;

  const perHoldingBreakdown = holdings.map((h) => {
    const yesterdayValue =
      params.priorSnapshot?.perHoldingBreakdown.find((p) => p.holdingId === h.id)?.valuePkr ??
      h.valuePkr;
    const monthStartValue =
      params.monthStartSnapshot?.perHoldingBreakdown.find((p) => p.holdingId === h.id)?.valuePkr ??
      h.valuePkr;
    return {
      holdingId: h.id,
      label: h.label,
      valuePkr: h.valuePkr,
      changeVsYesterday: h.valuePkr - yesterdayValue,
      changeMtd: h.valuePkr - monthStartValue,
    };
  });

  if (pendingTotal > 0) {
    perHoldingBreakdown.push({
      holdingId: "pending-in-transit",
      label: "In transit (pending)",
      valuePkr: pendingTotal,
      changeVsYesterday: 0,
      changeMtd: 0,
    });
  }

  const changeVsYesterday = totalPkr - (params.priorSnapshot?.totalPkr ?? totalPkr);
  const changeMtd = totalPkr - (params.monthStartSnapshot?.totalPkr ?? totalPkr);

  const movements = perHoldingBreakdown
    .map((h) => ({ ...h, absChange: Math.abs(h.changeVsYesterday) }))
    .filter((h) => h.absChange > 0)
    .sort((a, b) => b.absChange - a.absChange);

  const mainReason = movements.length > 0
    ? movements[0].label + " movement"
    : "No significant movement";

  const sources = new Set<string>();
  const estimatedHoldings = holdings.filter((h) => h.valuationKind === "estimated");
  for (const h of holdings) {
    if (h.priceSource) sources.add(h.priceSource);
  }
  const hasEstimates = estimatedHoldings.length > 0 || pendingTotal > 0;
  const provenanceParts = [Array.from(sources).join("; ")];
  if (hasEstimates) {
    const earliestBaseline = holdings
      .map((h) => h.unitsConfirmedAsOf)
      .filter((d): d is string => !!d)
      .sort()[0];
    if (earliestBaseline) {
      provenanceParts.push(`estimated since ${earliestBaseline}`);
    }
    if (pendingTotal > 0) {
      provenanceParts.push(`PKR ${pendingTotal.toLocaleString()} in transit`);
    }
  }
  const provenanceSummary = provenanceParts.filter(Boolean).join("; ") || "Manual entry";

  return {
    date,
    totalPkr,
    perHoldingBreakdown,
    changeVsYesterday,
    changeMtd,
    mainReason,
    interpretation: [],
    trend,
    provenanceSummary,
  };
}

/** Detect WealthEvents from holding movements. Every event has a plainWhy. */
export function detectWealthEvents(params: {
  date: string;
  holdings: EnrichedHolding[];
  priorHoldings: Map<string, EnrichedHolding>;
  pendingInvestments: PendingInvestment[];
}): WealthEvent[] {
  const events: WealthEvent[] = [];

  for (const h of params.holdings) {
    const prior = params.priorHoldings.get(h.id);
    if (!prior) continue;

    const change = h.valuePkr - prior.valuePkr;
    if (change === 0) continue;

    const direction = change > 0 ? "up" : "down";
    const magnitude = Math.abs(change);
    if (magnitude < 1000) continue;

    let kind: WealthEvent["kind"];
    let plainWhy: string;

    if (h.kind === "mutual_fund") {
      kind = "nav_move";
      plainWhy = `${h.label} ${direction === "up" ? "gained" : "pulled back"} PKR ${magnitude.toLocaleString()} — NAV movement.`;
    } else if (h.kind === "cash" && h.currency !== "PKR") {
      kind = "fx_move";
      plainWhy = `${h.label} ${direction === "up" ? "nudged up" : "eased"} PKR ${magnitude.toLocaleString()} — ${h.fxRate?.pair ?? "FX"} moved.`;
    } else {
      kind = "contribution";
      plainWhy = `${h.label} ${direction === "up" ? "increased" : "decreased"} by PKR ${magnitude.toLocaleString()}.`;
    }

    const severity: WealthEvent["severity"] =
      magnitude > 50000 ? "heads_up" : "all_good";

    events.push({
      id: `event-${h.id}-${params.date}`,
      date: params.date,
      holdingId: h.id,
      kind,
      magnitudePkr: change,
      direction,
      plainWhy,
      severity,
    });
  }

  for (const p of params.pendingInvestments) {
    if (p.status === "pending") {
      events.push({
        id: `event-pending-${p.id}`,
        date: params.date,
        kind: "contribution",
        magnitudePkr: p.amountPkr,
        direction: "up",
        plainWhy: `PKR ${p.amountPkr.toLocaleString()} in transit to ${p.destination} — will show as units once your next statement confirms.`,
        severity: "heads_up",
      });
    }
  }

  return events;
}

/**
 * Compute the "working" — the transparent breakdown of how an estimate was
 * derived. This is the trust core: the user can see WHY a number is what it is.
 */
export interface EstimateWorking {
  holdingId: string;
  label: string;
  kind: string;
  valuationKind: ValuationKind;
  confirmedAsOf?: string;
  working: string;
}

export function computeEstimateWorking(
  holding: EnrichedHolding,
  adjustments: ManualAdjustment[]
): EstimateWorking {
  if (holding.valuationKind === "confirmed") {
    return {
      holdingId: holding.id,
      label: holding.label,
      kind: holding.kind,
      valuationKind: "confirmed",
      confirmedAsOf: holding.unitsConfirmedAsOf,
      working: `Confirmed from statement as of ${holding.unitsConfirmedAsOf ?? "unknown"}. ${holding.kind === "mutual_fund" ? `${holding.units ?? 0} units × NAV ${holding.price?.value ?? 0}` : `Balance ${holding.valueNative ?? 0} ${holding.currency}`}.`,
    };
  }

  const relevantAdjustments = adjustments.filter(
    (a) => a.affectsAccount === holding.id || a.currency === holding.currency
  );

  if (holding.kind === "cash" && holding.currency !== "PKR") {
    const adjSummary = relevantAdjustments.length > 0
      ? relevantAdjustments.map((a) => `${a.amount > 0 ? "+" : ""}${a.amount} ${a.currency}`).join(", ")
      : "no adjustments";
    return {
      holdingId: holding.id,
      label: holding.label,
      kind: holding.kind,
      valuationKind: "estimated",
      confirmedAsOf: holding.unitsConfirmedAsOf,
      working: `Last confirmed balance ${holding.valueNative ?? 0} ${holding.currency} (as of ${holding.unitsConfirmedAsOf ?? "unknown"}) + ${adjSummary}, revalued at ${holding.fxRate?.pair ?? "FX"} ${holding.fxRate?.value ?? 0}.`,
    };
  }

  if (holding.kind === "mutual_fund") {
    return {
      holdingId: holding.id,
      label: holding.label,
      kind: holding.kind,
      valuationKind: "estimated",
      confirmedAsOf: holding.unitsConfirmedAsOf,
      working: `${holding.units ?? 0} units (confirmed ${holding.unitsConfirmedAsOf ?? "unknown"}) × today's NAV ${holding.price?.value ?? 0} = PKR ${holding.valuePkr.toLocaleString()}. Estimated until next statement.`,
    };
  }

  return {
    holdingId: holding.id,
    label: holding.label,
    kind: holding.kind,
    valuationKind: "estimated",
    confirmedAsOf: holding.unitsConfirmedAsOf,
    working: `Estimated value PKR ${holding.valuePkr.toLocaleString()} since ${holding.unitsConfirmedAsOf ?? "last statement"}.`,
  };
}
