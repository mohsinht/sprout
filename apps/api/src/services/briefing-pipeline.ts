import { eq, and, desc } from "drizzle-orm";
import type { WealthBriefing, WealthTrendPoint } from "@sprout/shared";
import { db, schema } from "../db/client.js";
import { config } from "../config.js";
import { createFxSource } from "../sources/fx-source.js";
import { createNavSource } from "../sources/nav-source.js";
import {
  computeHoldingValuePkr,
  determineFreshness,
  determineValuationKind,
  computeWealthSnapshot,
  detectWealthEvents,
  estimateCashHoldingValue,
  type EnrichedHolding,
  type PendingInvestment,
  type ManualAdjustment,
} from "../lib/wealth.js";
import {
  calculateWealthHealthScore,
  computeTrendStability,
  computeDiversification,
  type ScoreInputs,
} from "../lib/scoring.js";
import {
  selectRecommendedAction,
  deterministicInterpretation,
  deterministicGreeting,
  deterministicSummary,
  validateBriefing,
  checkGuardrails,
} from "../lib/briefing-validation.js";
import { createAiService, type AiService } from "../services/ai-service.js";

export interface BriefingResult {
  briefing: WealthBriefing;
  aiCostCents: number;
  aiModel: string;
  guardrailViolations: string[];
}

/**
 * The deterministic briefing pipeline (reconciliation model):
 *
 * 1. Gather (holdings, goals, transactions, pending, projected income, baselines)
 * 2. Fetch prices/FX (with provenance)
 * 3. Compute estimated values: baseline + adjustments + price/FX revaluation
 * 4. Compute WealthSnapshot (confirmed + estimated + pending, never double-counted)
 * 5. Detect WealthEvents
 * 6. Compute score
 * 7. Select recommended action
 * 8. Call AI for copy (or deterministic fallback)
 * 9. Validate against schema + guardrails
 * 10. Store
 *
 * Projected income is a SIDE NOTE — never added to current wealth.
 * Pending investments are in-transit — included in total but flagged, never double-counted.
 */
export async function generateBriefing(params: {
  userId: string;
  date?: string;
  aiService?: AiService;
}): Promise<BriefingResult> {
  const { userId } = params;
  const date = params.date ?? new Date().toISOString().slice(0, 10);
  const aiService = params.aiService ?? createAiService();

  // ── 1. Gather ──────────────────────────────────────────────────────────────
  const [profile] = await db
    .select()
    .from(schema.profiles)
    .where(eq(schema.profiles.userId, userId))
    .limit(1);
  const name = profile?.name ?? "friend";

  const goalRows = await db
    .select()
    .from(schema.goals)
    .where(eq(schema.goals.userId, userId));

  const holdingRows = await db
    .select()
    .from(schema.holdings)
    .where(eq(schema.holdings.userId, userId));

  const accountRows = await db
    .select()
    .from(schema.accounts)
    .where(eq(schema.accounts.userId, userId));

  const txRows = await db
    .select()
    .from(schema.transactions)
    .where(eq(schema.transactions.userId, userId));

  const pendingRows = await db
    .select()
    .from(schema.pendingInvestments)
    .where(eq(schema.pendingInvestments.userId, userId));

  const projectedIncomeRows = await db
    .select()
    .from(schema.projectedIncome)
    .where(eq(schema.projectedIncome.userId, userId));

  const priorSnapshots = await db
    .select()
    .from(schema.wealthSnapshots)
    .where(eq(schema.wealthSnapshots.userId, userId))
    .orderBy(desc(schema.wealthSnapshots.date))
    .limit(config.trendDays + 1);

  const priorSnapshot = priorSnapshots[0];
  const monthStart = date.slice(0, 8) + "01";
  const monthStartSnapshot = priorSnapshots.find((s) => s.date === monthStart);

  // ── 2. Fetch prices/FX ──────────────────────────────────────────────────────
  const fxSource = createFxSource();
  const navSource = createNavSource();

  const fxCache = new Map<string, import("@sprout/shared").FxRate>();
  for (const h of holdingRows) {
    if (h.currency !== "PKR" && !fxCache.has(h.currency)) {
      const rate = await fxSource.fetchRate(`${h.currency}/PKR`);
      if (rate) fxCache.set(h.currency, rate);
    }
  }
  for (const account of accountRows) {
    if (account.currency !== "PKR" && !fxCache.has(account.currency)) {
      const rate = await fxSource.fetchRate(`${account.currency}/PKR`);
      if (rate) fxCache.set(account.currency, rate);
    }
  }

  for (const rate of fxCache.values()) {
    await db.insert(schema.fxRates).values({
      pair: rate.pair,
      rate: rate.value.toString(),
      asOf: rate.asOf,
      source: rate.source,
      sourceUrl: rate.sourceUrl,
    }).onConflictDoNothing();
  }

  const navCache = new Map<string, import("@sprout/shared").PriceQuote>();
  for (const h of holdingRows) {
    if (h.kind === "mutual_fund" && h.fundCode && !navCache.has(h.fundCode)) {
      const nav = await navSource.fetchNav(h.fundCode);
      if (nav) navCache.set(h.fundCode, nav);
    }
  }

  for (const [instrument, quote] of navCache.entries()) {
    await db.insert(schema.priceQuotes).values({
      instrument,
      value: quote.value.toString(),
      asOf: quote.asOf,
      source: quote.source,
      sourceUrl: quote.sourceUrl,
      currency: quote.currency,
    }).onConflictDoNothing();
  }

  // ── 3. Build manual adjustments from transactions since last baseline ───────
  const manualAdjustments: ManualAdjustment[] = txRows.map((t) => ({
    id: t.id,
    amount: t.type === "income" ? t.amount : t.type === "expense" ? -t.amount : 0,
    currency: t.currency,
    occurredAt: t.occurredAt.toISOString(),
    note: t.note ?? undefined,
  }));

  // ── 4. Enrich holdings + compute estimated values ───────────────────────────
  const enrichedHoldings: EnrichedHolding[] = holdingRows.map((h) => {
    const price = h.fundCode ? navCache.get(h.fundCode) : undefined;
    const fxRate = h.currency !== "PKR" ? fxCache.get(h.currency) : undefined;

    const priceAsOf = price?.asOf ?? fxRate?.asOf ?? h.priceAsOf ?? null;
    const freshness = h.kind === "cash" && h.currency === "PKR"
      ? "manual" as const
      : determineFreshness(priceAsOf, h.kind);

    // Determine if there are adjustments since the baseline
    const hasAdjustmentsSinceBaseline =
      h.unitsConfirmedAsOf != null &&
      manualAdjustments.some(
        (a) => new Date(a.occurredAt) > new Date(h.unitsConfirmedAsOf!)
      );

    const valuationKind = determineValuationKind({
      unitsConfirmedAsOf: h.unitsConfirmedAsOf ?? undefined,
      hasAdjustmentsSinceBaseline,
    });

    // For cash holdings with adjustments, use the estimation model
    let valuePkr: number;
    let valueNative: number | undefined;

    if (h.kind === "cash" && h.valueNative && hasAdjustmentsSinceBaseline) {
      const estimated = estimateCashHoldingValue({
        confirmedBalanceNative: parseFloat(h.valueNative),
        currency: h.currency,
        adjustments: manualAdjustments,
        fxRate: fxRate ?? undefined,
      });
      valueNative = estimated.valueNative;
      valuePkr = estimated.valuePkr;
    } else {
      valuePkr = computeHoldingValuePkr({
        kind: h.kind,
        currency: h.currency,
        units: h.units ? parseFloat(h.units) : undefined,
        valueNative: h.valueNative ? parseFloat(h.valueNative) : undefined,
        price,
        fxRate,
      });
      valueNative = h.valueNative ? parseFloat(h.valueNative) : undefined;
    }

    return {
      id: h.id,
      kind: h.kind,
      institution: h.institution,
      label: h.label,
      fundCode: h.fundCode ?? undefined,
      currency: h.currency,
      units: h.units ? parseFloat(h.units) : undefined,
      unitsConfirmedAsOf: h.unitsConfirmedAsOf ?? undefined,
      valueNative,
      // A missing dated quote/FX rate is unavailable, not a reason to reuse an
      // old or mock number. PKR cash is the only manual valuation here.
      valuePkr: valuePkr || (h.kind === "cash" && h.currency === "PKR" ? h.valuePkr : 0),
      price,
      fxRate,
      priceAsOf: priceAsOf ?? "unknown",
      priceSource: price?.source ?? fxRate?.source ?? h.priceSource ?? "Manual",
      freshness,
      valuationKind,
      baselineId: h.baselineId ?? undefined,
    };
  });

  for (const account of accountRows) {
    const ledgerChange = txRows
      .filter((transaction) => transaction.accountId === account.id)
      .reduce((sum, transaction) => {
        if (transaction.type === "income") return sum + transaction.amount;
        if (transaction.type === "expense") return sum - transaction.amount;
        return sum;
      }, 0);
    const valueNative = account.openingBalance + ledgerChange;
    const fxRate = account.currency === "PKR" ? undefined : fxCache.get(account.currency);
    const freshness = account.currency === "PKR"
      ? "manual" as const
      : determineFreshness(fxRate?.asOf, "cash");

    enrichedHoldings.push({
      id: account.id,
      kind: "cash",
      institution: account.provider,
      label: account.label,
      currency: account.currency,
      valueNative,
      valuePkr: account.currency === "PKR" ? valueNative : Math.round(valueNative * (fxRate?.value ?? 0)),
      fxRate,
      priceAsOf: fxRate?.asOf ?? "unknown",
      priceSource: fxRate?.source ?? "Manual entry",
      freshness,
      valuationKind: "estimated",
    });
  }

  // ── 5. Build pending investments ─────────────────────────────────────────────
  const pendingInvestments: PendingInvestment[] = pendingRows.map((p) => ({
    id: p.id,
    amountPkr: p.amountPkr,
    destination: p.destination,
    initiatedOn: p.initiatedOn,
    status: p.status,
  }));

  // ── 6. Compute WealthSnapshot ───────────────────────────────────────────────
  const trend: WealthTrendPoint[] = priorSnapshots
    .reverse()
    .map((s) => ({
      date: s.date,
      totalPkr: s.totalPkr,
      perHolding: (s.perHoldingJson as { holdingId: string; valuePkr: number }[]) ?? [],
    }));

  const todayTotal =
    enrichedHoldings.reduce((sum, h) => sum + h.valuePkr, 0) +
    pendingInvestments.filter((p) => p.status === "pending").reduce((sum, p) => sum + p.amountPkr, 0);

  trend.push({
    date,
    totalPkr: todayTotal,
    perHolding: enrichedHoldings.map((h) => ({ holdingId: h.id, valuePkr: h.valuePkr })),
  });

  const recentTrend = trend.slice(-config.trendDays);

  const wealthSnapshot = computeWealthSnapshot({
    date,
    holdings: enrichedHoldings,
    pendingInvestments,
    priorSnapshot: priorSnapshot
      ? {
          totalPkr: priorSnapshot.totalPkr,
          perHoldingBreakdown: priorSnapshot.perHoldingJson as { holdingId: string; valuePkr: number }[],
        }
      : undefined,
    monthStartSnapshot: monthStartSnapshot
      ? {
          totalPkr: monthStartSnapshot.totalPkr,
          perHoldingBreakdown: monthStartSnapshot.perHoldingJson as { holdingId: string; valuePkr: number }[],
        }
      : undefined,
    trend: recentTrend,
  });

  // ── 7. Detect WealthEvents ──────────────────────────────────────────────────
  const priorHoldingsMap = new Map<string, EnrichedHolding>();
  if (priorSnapshot) {
    const priorBreakdown = priorSnapshot.perHoldingJson as { holdingId: string; valuePkr: number }[];
    for (const p of priorBreakdown) {
      const current = enrichedHoldings.find((h) => h.id === p.holdingId);
      if (current) {
        priorHoldingsMap.set(p.holdingId, { ...current, valuePkr: p.valuePkr });
      }
    }
  }

  const wealthEvents = detectWealthEvents({
    date,
    holdings: enrichedHoldings,
    priorHoldings: priorHoldingsMap,
    pendingInvestments,
  });

  // ── 8. Compute score ────────────────────────────────────────────────────────
  const activeGoals = goalRows
    .filter((g) => g.status === "active")
    .sort((a, b) => {
      if (a.isPrimary !== b.isPrimary) return a.isPrimary ? -1 : 1;
      if (a.sortOrder !== b.sortOrder) return a.sortOrder - b.sortOrder;
      const aProgress = a.targetAmount > 0 ? a.currentAmount / a.targetAmount : 0;
      const bProgress = b.targetAmount > 0 ? b.currentAmount / b.targetAmount : 0;
      return bProgress - aProgress;
    });
  const goalPaceRatio = activeGoals.length > 0
    ? activeGoals.reduce((sum, g) => sum + g.currentAmount / g.targetAmount, 0) / activeGoals.length
    : 0;

  const holdingValues = enrichedHoldings.map((h) => h.valuePkr);
  const diversificationRatio = computeDiversification(holdingValues);
  const dailyTotals = recentTrend.map((t) => t.totalPkr);
  const trendStabilityRatio = computeTrendStability(dailyTotals);

  const unconfirmedCount = txRows.filter((t) => t.needsReview).length;
  const stalePriceCount = enrichedHoldings.filter((h) => h.freshness === "stale").length;

  const pkrCash = enrichedHoldings
    .filter((h) => h.kind === "cash" && h.currency === "PKR")
    .reduce((sum, h) => sum + h.valuePkr, 0);
  const monthlyExpensesEstimate = 100000;
  const emergencyBufferMonths = pkrCash / monthlyExpensesEstimate;
  const contributionConsistencyRatio = 0.5;

  const scoreInputs: ScoreInputs = {
    goalPaceRatio,
    emergencyBufferMonths,
    contributionConsistencyRatio,
    diversificationRatio,
    trendStabilityRatio,
    upcomingBillsCoverageRatio: 1,
    debtPaymentRatio: 0,
    unconfirmedImportantTransactions: unconfirmedCount,
    stalePriceCount,
  };

  const scoreResult = calculateWealthHealthScore(scoreInputs);

  // ── 9. Select recommended action ────────────────────────────────────────────
  const goalsForAction = activeGoals.map((g) => ({
    id: g.id,
    name: g.name,
    targetAmount: g.targetAmount,
    currentAmount: g.currentAmount,
    remainingToTarget: Math.max(0, g.targetAmount - g.currentAmount),
  }));

  const recommendedAction = selectRecommendedAction({
    score: scoreResult,
    goals: goalsForAction,
    holdings: enrichedHoldings.map((h) => ({ id: h.id, label: h.label, valuePkr: h.valuePkr })),
    unconfirmedCount,
    stalePriceCount,
  });

  // ── 10. Deterministic fallback copy ─────────────────────────────────────────
  const fallbackInterpretation = deterministicInterpretation({
    changeVsYesterday: wealthSnapshot.changeVsYesterday,
    changeMtd: wealthSnapshot.changeMtd,
    mainReason: wealthSnapshot.mainReason,
    holdings: wealthSnapshot.perHoldingBreakdown,
  });

  const fallbackGreeting = deterministicGreeting(name, scoreResult.mascotMood);
  const fallbackSummary = deterministicSummary({
    changeVsYesterday: wealthSnapshot.changeVsYesterday,
    changeMtd: wealthSnapshot.changeMtd,
    mainReason: wealthSnapshot.mainReason,
  });

  // ── 11. Call AI for copy ─────────────────────────────────────────────────────
  let aiCostCents = 0;
  let aiModel = "none";
  let greeting = fallbackGreeting;
  let summary = fallbackSummary;
  let interpretation = fallbackInterpretation;
  let mascotMood = scoreResult.mascotMood;

  try {
    const aiResult = await aiService.generateBriefingCopy({
      greeting: fallbackGreeting,
      summary: fallbackSummary,
      wealthSnapshot: {
        totalPkr: wealthSnapshot.totalPkr,
        changeVsYesterday: wealthSnapshot.changeVsYesterday,
        changeMtd: wealthSnapshot.changeMtd,
        mainReason: wealthSnapshot.mainReason,
        interpretation: fallbackInterpretation,
        provenanceSummary: wealthSnapshot.provenanceSummary,
      },
      wealthEvents: wealthEvents.map((e) => ({
        id: e.id,
        plainWhy: e.plainWhy,
        magnitudePkr: e.magnitudePkr,
        direction: e.direction,
        severity: e.severity,
      })),
      recommendedAction: {
        id: recommendedAction.id,
        label: recommendedAction.label,
        severity: recommendedAction.severity,
        effect: recommendedAction.effect,
        goalRelativeNote: recommendedAction.goalRelativeNote,
      },
      mascotMood: scoreResult.mascotMood,
      score: scoreResult.score,
      band: scoreResult.band,
    });

    greeting = aiResult.output.greeting || fallbackGreeting;
    summary = aiResult.output.summary || fallbackSummary;
    interpretation = aiResult.output.interpretation?.length
      ? aiResult.output.interpretation
      : fallbackInterpretation;
    aiCostCents = aiResult.costCents;
    aiModel = aiService.name;
  } catch {
    aiModel = "fallback";
  }

  // ── 12. Build the briefing object ───────────────────────────────────────────
  const briefingFreshness = enrichedHoldings.some((h) => h.freshness === "unavailable")
    ? "unavailable" as const
    : enrichedHoldings.some((h) => h.freshness === "stale")
      ? "stale" as const
      : "fresh" as const;

  const briefing: WealthBriefing = {
    id: `briefing-${date}`,
    userId,
    briefingDate: date,
    generatedAt: new Date().toISOString(),
    freshness: briefingFreshness,
    mascotMood,
    greeting,
    summary,
    healthScore: scoreResult.score,
    healthStatus: scoreResult.band,
    wealthSnapshot: {
      ...wealthSnapshot,
      interpretation,
    },
    wealthEvents,
    learnThreads: [],
    recommendedAction,
    goals: activeGoals.map((g) => ({
      id: g.id,
      name: g.name,
      type: g.type,
      targetAmount: g.targetAmount,
      currentAmount: g.currentAmount,
      currency: "PKR" as const,
      deadline: g.deadline ?? undefined,
      status: g.status,
      pace: "on_track" as const,
      nextStep: `Add PKR 25,000 this month`,
      remainingToTarget: Math.max(0, g.targetAmount - g.currentAmount),
      paceNote: `PKR ${Math.max(0, g.targetAmount - g.currentAmount).toLocaleString()} to go`,
    })),
    holdings: enrichedHoldings.map((h) => ({
      id: h.id,
      kind: h.kind,
      institution: h.institution,
      label: h.label,
      fundCode: h.fundCode,
      currency: h.currency,
      units: h.units,
      price: h.price,
      fxRate: h.fxRate,
      valuePkr: h.valuePkr,
      valueNative: h.valueNative,
      priceAsOf: h.priceAsOf,
      priceSource: h.priceSource,
      freshness: h.freshness as "fresh" | "stale" | "manual" | "unavailable" | "estimated",
    })),
    streak: 0,
    xp: 0,
    level: 1,
  };

  // ── 13. Validate ────────────────────────────────────────────────────────────
  const validated = validateBriefing(briefing);
  const violations = checkGuardrails(validated);

  if (violations.length > 0) {
    validated.greeting = fallbackGreeting;
    validated.summary = fallbackSummary;
    validated.wealthSnapshot.interpretation = fallbackInterpretation;
    validated.mascotMood = scoreResult.mascotMood;
  }

  return {
    briefing: validated,
    aiCostCents,
    aiModel,
    guardrailViolations: violations,
  };
}

/** Store the briefing + snapshot + events in the DB. */
export async function storeBriefing(
  briefing: WealthBriefing,
  aiCostCents: number,
  aiModel: string
): Promise<void> {
  const date = briefing.briefingDate;
  await db.transaction(async (tx) => {
    await tx.delete(schema.wealthEvents).where(
      and(eq(schema.wealthEvents.userId, briefing.userId), eq(schema.wealthEvents.date, date)),
    );
    await tx.delete(schema.wealthSnapshots).where(
      and(eq(schema.wealthSnapshots.userId, briefing.userId), eq(schema.wealthSnapshots.date, date)),
    );
    await tx.insert(schema.wealthSnapshots).values({
      userId: briefing.userId,
      date,
      totalPkr: briefing.wealthSnapshot.totalPkr,
      perHoldingJson: briefing.wealthSnapshot.perHoldingBreakdown,
      changeVsYesterday: briefing.wealthSnapshot.changeVsYesterday,
      changeMtd: briefing.wealthSnapshot.changeMtd,
      mainReason: briefing.wealthSnapshot.mainReason,
      interpretationJson: briefing.wealthSnapshot.interpretation,
      freshness: briefing.freshness === "local_fallback" ? "stale" : briefing.freshness,
    });

    for (const event of briefing.wealthEvents) {
      await tx.insert(schema.wealthEvents).values({
        userId: briefing.userId,
        date,
        holdingId: event.holdingId,
        kind: event.kind,
        magnitudePkr: event.magnitudePkr,
        direction: event.direction,
        plainWhy: event.plainWhy,
        learnMoreId: event.learnMoreId,
        severity: event.severity,
      });
    }

    await tx.delete(schema.dailyBriefings).where(
      and(eq(schema.dailyBriefings.userId, briefing.userId), eq(schema.dailyBriefings.briefingDate, date)),
    );
    await tx.insert(schema.dailyBriefings).values({
      userId: briefing.userId,
      briefingDate: date,
      generatedAt: new Date(briefing.generatedAt),
      freshness: briefing.freshness,
      mascotMood: briefing.mascotMood,
      greeting: briefing.greeting,
      summary: briefing.summary,
      healthScore: briefing.healthScore,
      healthStatus: briefing.healthStatus as "strong" | "healthy" | "watch" | "urgent",
      wealthSnapshotJson: briefing.wealthSnapshot,
      wealthEventsJson: briefing.wealthEvents,
      learnThreadsJson: briefing.learnThreads,
      recommendedActionJson: briefing.recommendedAction,
      goalsJson: briefing.goals,
      holdingsJson: briefing.holdings,
      streak: briefing.streak,
      xp: briefing.xp,
      level: briefing.level,
      aiModel,
      aiCostCents,
    });
  });
}

/** Retrieve the latest stored briefing for a user. Returns null if none. */
export async function getLatestBriefing(userId: string): Promise<WealthBriefing | null> {
  const rows = await db
    .select()
    .from(schema.dailyBriefings)
    .where(eq(schema.dailyBriefings.userId, userId))
    .orderBy(desc(schema.dailyBriefings.briefingDate))
    .limit(1);

  const row = rows[0];
  if (!row) return null;

  return {
    id: row.id,
    userId: row.userId,
    briefingDate: row.briefingDate,
    generatedAt: row.generatedAt.toISOString(),
    freshness: row.freshness,
    mascotMood: row.mascotMood,
    greeting: row.greeting,
    summary: row.summary,
    healthScore: row.healthScore,
    healthStatus: row.healthStatus as "strong" | "healthy" | "watch" | "urgent",
    wealthSnapshot: row.wealthSnapshotJson as WealthBriefing["wealthSnapshot"],
    wealthEvents: row.wealthEventsJson as WealthBriefing["wealthEvents"],
    learnThreads: (row.learnThreadsJson ?? []) as WealthBriefing["learnThreads"],
    recommendedAction: row.recommendedActionJson as WealthBriefing["recommendedAction"],
    goals: row.goalsJson as WealthBriefing["goals"],
    holdings: row.holdingsJson as WealthBriefing["holdings"],
    streak: row.streak,
    xp: row.xp,
    level: row.level,
  };
}
