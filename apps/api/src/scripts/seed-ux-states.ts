import { eq } from "drizzle-orm";
import {
  mockWealthBriefing,
  WealthBriefingSchema,
  type WealthBriefing,
  type Holding,
} from "@sprout/shared";
import { hashPassword } from "../auth/crypto.js";
import { closeDb, db, schema } from "../db/client.js";

const password = "SproutUX2026!";
const today = new Date().toISOString().slice(0, 10);
const generatedAt = `${today}T06:00:00.000Z`;
const datedDaysAgo = (days: number): string => {
  const value = new Date();
  value.setUTCDate(value.getUTCDate() - days);
  return value.toISOString().slice(0, 10);
};
const yesterday = datedDaysAgo(1);
const threeDaysAgo = datedDaysAgo(3);

const stateNames = [
  "zero-data",
  "thin-wealth",
  "good-day",
  "down-day",
  "stale",
  "insufficient-score",
  "offline-with-cache",
  "offline-no-cache",
  "briefing-failed",
  "quiet-week",
  "populated-insights",
  "uncertain-transactions",
] as const;

type StateName = (typeof stateNames)[number];

const cloneBriefing = (): WealthBriefing => structuredClone(mockWealthBriefing);

function zeroBriefing(userId: string): WealthBriefing {
  const briefing = cloneBriefing();
  return {
    ...briefing,
    id: `ux-zero-${userId}`,
    userId,
    briefingDate: today,
    generatedAt,
    greeting: "Salaam, friend",
    summary: "Sprout is still getting to know your money.",
    healthScore: null,
    healthStatus: null,
    scoreState: "insufficient_data",
    scoreExplanation: "Add one cash entry to begin a useful picture.",
    scoreFactors: [],
    wealthSnapshot: {
      date: today,
      totalPkr: 0,
      perHoldingBreakdown: [],
      changeVsYesterday: 0,
      changeMtd: 0,
      mainReason: "No movement yet",
      interpretation: [
        "Nothing to explain yet — add a cash entry and Sprout starts learning",
      ],
      trend: [],
      provenanceSummary: "No money added yet · manual entry is ready",
    },
    wealthEvents: [],
    learnThreads: [],
    recommendedAction: {
      id: "ux-add-first-cash",
      label: "Add your first cash entry",
      severity: "all_good",
      effect: "Starts a private manual money picture",
      xp: 0,
      completionKind: "log_cash",
    },
    goals: [],
    holdings: [],
    streak: 0,
    xp: 0,
    level: 1,
  };
}

function baseBriefing(userId: string): WealthBriefing {
  const briefing = cloneBriefing();
  return {
    ...briefing,
    id: `ux-${userId}`,
    userId,
    briefingDate: today,
    generatedAt,
  };
}

function goodDay(userId: string): WealthBriefing {
  const briefing = baseBriefing(userId);
  return {
    ...briefing,
    mascotMood: "thriving",
    summary:
      "You’re steady today. Your funds added PKR 45,000, and the month is moving gently up.",
    healthScore: 84,
    healthStatus: "strong",
    wealthSnapshot: {
      ...briefing.wealthSnapshot,
      date: today,
      changeVsYesterday: 45000,
      changeMtd: 118000,
      mainReason: "Al Meezan NAVs rose",
      interpretation: [
        "Al Meezan NAVs rose today, adding PKR 45,000. The month remains gently up.",
      ],
    },
    wealthEvents: [
      {
        id: "ux-good-nav",
        date: today,
        holdingId: briefing.holdings[0]?.id,
        kind: "nav_move",
        magnitudePkr: 45000,
        direction: "up",
        plainWhy: "Al Meezan NAVs rose after a quiet session.",
        severity: "all_good",
      },
    ],
  };
}

function thinBriefing(userId: string, holding: Holding): WealthBriefing {
  const briefing = zeroBriefing(userId);
  return {
    ...briefing,
    id: `ux-thin-${userId}`,
    summary: "Your cash is steady today. One small goal step is ready.",
    healthScore: 67,
    healthStatus: "watch",
    scoreState: "available",
    scoreExplanation: "Based on your manually tracked cash and goal.",
    holdings: [holding],
    wealthSnapshot: {
      ...briefing.wealthSnapshot,
      totalPkr: 125000,
      perHoldingBreakdown: [
        {
          holdingId: holding.id,
          label: holding.label,
          valuePkr: 125000,
          changeVsYesterday: 0,
          changeMtd: 0,
        },
      ],
      provenanceSummary: "PKR cash · saved manually today",
    },
    goals: [
      {
        id: "ux-thin-goal",
        name: "Emergency cushion",
        type: "emergency",
        targetAmount: 300000,
        currentAmount: 125000,
        currency: "PKR",
        status: "active",
        pace: "on_track",
        nextStep: "Add PKR 5,000 when it feels comfortable",
        remainingToTarget: 175000,
        paceNote: "PKR 1.8 lakh to go",
      },
    ],
    recommendedAction: {
      id: "ux-thin-goal-step",
      label: "Add PKR 5,000 to your cushion",
      severity: "all_good",
      effect: "Moves your emergency cushion closer",
      xp: 10,
      completionKind: "contribute_to_goal",
      targetId: "ux-thin-goal",
      goalRelativeNote: "PKR 1.8 lakh to go",
    },
  };
}

async function saveBriefing(briefing: WealthBriefing): Promise<void> {
  const checked = WealthBriefingSchema.parse(briefing);
  await db.insert(schema.dailyBriefings).values({
    userId: checked.userId,
    briefingDate: checked.briefingDate,
    generatedAt: new Date(checked.generatedAt),
    freshness: checked.freshness,
    mascotMood: checked.mascotMood,
    greeting: checked.greeting,
    summary: checked.summary,
    healthScore: checked.healthScore,
    healthStatus: checked.healthStatus,
    scoreState: checked.scoreState,
    scoreExplanation: checked.scoreExplanation,
    scoreFactorsJson: checked.scoreFactors,
    wealthSnapshotJson: checked.wealthSnapshot,
    wealthEventsJson: checked.wealthEvents,
    learnThreadsJson: checked.learnThreads,
    recommendedActionJson: checked.recommendedAction,
    goalsJson: checked.goals,
    holdingsJson: checked.holdings,
    streak: checked.streak,
    xp: checked.xp,
    level: checked.level,
  });
}

async function insertCashHolding(
  userId: string,
  valuePkr: number,
  options: { currency?: string; label?: string; freshness?: "fresh" | "stale" | "manual" } = {},
): Promise<Holding> {
  const currency = options.currency ?? "PKR";
  const [row] = await db.insert(schema.holdings).values({
    userId,
    kind: "cash",
    institution: currency === "PKR" ? "Manual" : "Wise",
    label: options.label ?? `${currency} Cash`,
    currency,
    valueNative: valuePkr.toString(),
    valuePkr,
    priceAsOf: today,
    priceSource: currency === "PKR" ? "Manual entry" : "UX sweep fixture",
    freshness: options.freshness ?? "manual",
    valuationKind: "confirmed",
  }).returning();
  return {
    id: row.id,
    kind: "cash",
    institution: row.institution,
    label: row.label,
    currency,
    valuePkr,
    valueNative: valuePkr,
    priceAsOf: row.priceAsOf ?? today,
    priceSource: row.priceSource ?? "Manual entry",
    freshness: row.freshness,
  };
}

async function seedState(state: StateName, passwordHash: string): Promise<string> {
  const email = `ux+${state}@sprout.local`;
  const existing = await db.select({ id: schema.users.id })
    .from(schema.users).where(eq(schema.users.email, email)).limit(1);
  if (existing[0]) await db.delete(schema.users).where(eq(schema.users.id, existing[0].id));

  const [user] = await db.insert(schema.users).values({ email, passwordHash }).returning();
  await db.insert(schema.profiles).values({
    userId: user.id,
    name: state === "good-day" ? "Ayesha" : "friend",
    onboardingComplete: true,
  });

  let briefing = zeroBriefing(user.id);
  if (state === "thin-wealth") {
    briefing = thinBriefing(user.id, await insertCashHolding(user.id, 125000));
  } else if (["good-day", "populated-insights", "uncertain-transactions"].includes(state)) {
    briefing = goodDay(user.id);
  } else if (state === "down-day") {
    briefing = { ...baseBriefing(user.id), briefingDate: today, generatedAt };
  } else if (state === "stale") {
    const stale = baseBriefing(user.id);
    briefing = {
      ...stale,
      briefingDate: threeDaysAgo,
      generatedAt: `${threeDaysAgo}T06:00:00.000Z`,
      freshness: "stale",
      mascotMood: "watchful",
      summary: "Your last saved picture is calm. Prices were updated 3 days ago.",
      holdings: stale.holdings.map((holding) => ({ ...holding, freshness: "stale" })),
      wealthSnapshot: {
        ...stale.wealthSnapshot,
        date: today,
        provenanceSummary: "Prices updated 3 days ago · tap a holding for sources",
      },
    };
  } else if (state === "insufficient-score") {
    const base = baseBriefing(user.id);
    briefing = {
      ...base,
      briefingDate: today,
      generatedAt,
      healthScore: null,
      healthStatus: null,
      scoreState: "insufficient_data",
      scoreExplanation: "Sprout needs a little more history before showing a score.",
      mascotMood: "content",
    };
  } else if (state === "briefing-failed") {
    briefing = {
      ...goodDay(user.id),
      briefingDate: yesterday,
      generatedAt: `${yesterday}T06:00:00.000Z`,
      freshness: "local_fallback",
      summary: "I could not refresh the scan, so I am using what I already know. You’re okay to stop here.",
    };
    await db.insert(schema.jobRuns).values({
      userId: user.id,
      type: "on_demand",
      status: "failed",
      startedAt: new Date(),
      finishedAt: new Date(),
      error: "UX fixture: briefing provider unavailable",
      idempotencyKey: `ux-briefing-failed-${user.id}`,
    });
  } else if (state.startsWith("offline-")) {
    briefing = goodDay(user.id);
  }

  if (state === "uncertain-transactions") {
    const [account] = await db.insert(schema.accounts).values({
      userId: user.id,
      label: "Cash pocket",
      type: "cash",
      openingBalance: 50000,
    }).returning();
    await db.insert(schema.transactions).values({
      userId: user.id,
      accountId: account.id,
      amount: 3200,
      type: "expense",
      category: "Needs review",
      merchant: "Possible grocery payment",
      occurredAt: new Date(),
      source: "email",
      provider: "UX fixture",
      parserVersion: "ux-1",
      dedupeFingerprint: `ux-uncertain-${user.id}`,
      confidence: "0.42",
      needsReview: true,
      reviewReason: "The merchant name was unclear",
    });
  }

  if (state === "populated-insights") {
    const usd = await insertCashHolding(user.id, 350000, { currency: "USD", label: "Wise USD" });
    await db.insert(schema.holdings).values({
      userId: user.id,
      kind: "mutual_fund",
      institution: "Al Meezan",
      label: "Al Meezan fund",
      fundCode: "UX-MIF",
      currency: "PKR",
      units: "5000",
      valuePkr: 500000,
      priceAsOf: today,
      priceSource: "UX sweep source",
      freshness: "fresh",
      valuationKind: "confirmed",
    });
    await db.insert(schema.goals).values({
      userId: user.id,
      name: "Car fund",
      type: "car",
      targetAmount: 2000000,
      currentAmount: 750000,
      isPrimary: true,
    });
    briefing = { ...briefing, holdings: [...briefing.holdings, usd] };
  }

  await saveBriefing(briefing);
  return email;
}

async function seedWorldFacts(): Promise<void> {
  const facts = [
    { key: "ux-fx", kind: "fx_move" as const, summary: "USD/PKR moved gently this week.", currencies: ["USD"] },
    { key: "ux-nav", kind: "nav_move" as const, summary: "Mutual-fund NAVs changed after a quiet session.", assets: ["mutual_fund"] },
    { key: "ux-goal", kind: "goal_cost_context" as const, summary: "Car-price context changed this month.", goals: ["car"] },
  ];
  for (const fact of facts) {
    await db.insert(schema.worldFacts).values({
      stableKey: fact.key,
      kind: fact.kind,
      observedOn: today,
      magnitude: "0.50",
      unit: "percent",
      direction: "up",
      sourceId: `ux-source-${fact.key}`,
      sourceLabel: "UX sweep source",
      freshness: "fresh",
      plainSummary: fact.summary,
      affectsAssetClassesJson: fact.assets ?? [],
      affectsCurrenciesJson: fact.currencies ?? [],
      affectsGoalTypesJson: fact.goals ?? [],
      normalizer: "deterministic",
      normalizerVersion: "ux-1",
    }).onConflictDoUpdate({
      target: schema.worldFacts.stableKey,
      set: { observedOn: today, plainSummary: fact.summary, updatedAt: new Date() },
    });
  }
}

async function main(): Promise<void> {
  const databaseUrl = process.env.DATABASE_URL ?? "";
  const isLocalDatabase = /(?:localhost|127\.0\.0\.1):5432\/sprout(?:\?|$)/.test(databaseUrl);
  if (!isLocalDatabase && process.env.ALLOW_REMOTE_UX_SEED !== "true") {
    throw new Error(
      "Refusing to seed UX accounts outside the local Sprout database. Set ALLOW_REMOTE_UX_SEED=true only for an intentional non-production test database.",
    );
  }
  const passwordHash = await hashPassword(password);
  await seedWorldFacts();
  const rows: { state: StateName; email: string }[] = [];
  for (const state of stateNames) rows.push({ state, email: await seedState(state, passwordHash) });

  console.log("Sprout UX states seeded into the real database (mocks OFF).");
  console.log(`Password for every UX account: ${password}`);
  console.table(rows);
  console.log("Sweep build flags:");
  console.log("  --dart-define=SPROUT_ENV=sweep");
  console.log("  --dart-define=SPROUT_SWEEP_THEME=light|dark");
  console.log("  --dart-define=SPROUT_SWEEP_TEXT_SCALE=1.0|1.3");
  console.log("  --dart-define=SPROUT_SWEEP_OFFLINE=true|false");
}

main().finally(closeDb);
