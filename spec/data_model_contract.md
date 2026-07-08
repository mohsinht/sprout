# Data Model Contract

> **Realignment note (2026-07-09):** Sprout is redefined as a personal
> wealth-health tracker. The hero of Today is now **total net wealth** across
> holdings (mutual funds + multi-currency cash + PKR cash), with today's and
> month-to-date movement, a plain-language "why," and one goal-relative AI
> next-step. This doc adds four foundational models — `Holding`,
> `PriceQuote`/`FxRate`, `WealthSnapshot`, and `WealthEvent` — extends `Goal`
> with `remainingToTarget`/`paceNote`, and extends `DailyBriefing` to carry
> the wealth snapshot, events, and goal-relative recommended action.
> "Check-in" as a health-changing action is removed from the model.
> Expense/transaction models are **retained** (first-class for the cash use
> case) but are no longer the Today hero. All new models are additive and
> backward-compatible behind the repository interface.

## Purpose

All screens should consume structured product data through stable contracts. AI output should be shaped before it reaches UI so screens render deterministic states.

Current TypeScript contracts live in `packages/shared/src/`. Current Flutter domain models live in `apps/mobile/lib/src/domain/`.

## Contract Rules

- Currency is `PKR` unless explicitly converted for display.
- Money amounts are stored as whole Pakistani rupees (`int`). Paisa is not represented in v0 because it is not meaningful in daily consumer use. If a source provides decimals, round to the nearest rupee at ingestion and preserve the raw source value only in parser/debug metadata.
- Every auto-captured transaction includes source, parser version, dedupe fingerprint, confidence, and review state.
- Every insight includes an explanation path.
- Every recommendation includes a small action, severity, and expected effect.
- Models must support manual-only and offline states.

## DailyBriefing

The target daily briefing object consumed by Today:

```ts
type DailyBriefing = {
  id: string;
  userId: string;
  briefingDate: string;
  generatedAt: string;
  freshness: "fresh" | "stale" | "local_fallback" | "unavailable";
  mascotMood: "thriving" | "content" | "watchful" | "concerned";
  greeting: string;
  summary: string;
  health: GardenHealthScore;
  recommendedAction: BriefingAction;
  glanceTiles: GlanceTile[];
  findings: Finding[];
  sourceSummary: BriefingSourceSummary;
  streak: StreakState;
};
```

## GardenHealthScore

```ts
type GardenHealthScore = {
  score: number; // 0-100
  delta: number;
  status: "strong" | "healthy" | "watch" | "urgent";
  explanation: string;
  positiveFactors: ScoreFactor[];
  attentionFactors: ScoreFactor[];
};

type ScoreFactor = {
  id: string;
  label: string;
  detail: string;
  contribution: number;
  sourceIds: string[];
};
```

Current equivalent:

- `FinancialHealthScoreSchema` in `packages/shared/src/models.ts`
- `FinancialHealthScore` in `apps/mobile/lib/src/domain/today_models.dart`

## BriefingAction

```ts
type BriefingAction = {
  id: string;
  label: string;
  severity: "all_good" | "heads_up" | "worth_doing" | "needs_attention";
  effect: string;
  xp: number;
  completionKind: "confirm_transaction" | "log_cash" | "move_money" | "review" | "set_goal" | "contribute_to_goal" | "rebalance";
  targetId?: string;        // goalId or holdingId the action relates to
  goalRelativeNote?: string; // e.g. "PKR 2 lakh to your car goal"
};
```

> **Realignment note:** `"check_in"` is removed from `completionKind`.
> Opening the app / checking in no longer changes health or awards XP.
> `contribute_to_goal` and `rebalance` are added for goal-relative wealth
> next-steps. `goalRelativeNote` carries the plain-language goal framing.

Current equivalent:

- `RecommendedActionSchema`
- `RecommendedAction`

## GlanceTile

```ts
type GlanceTile = {
  id: string;
  kind: "wealth" | "holding" | "goal" | "market" | "scan_summary" | "bill" | "salary" | "trend";
  title: string;
  value: string;
  detail: string;
  severity: "all_good" | "heads_up" | "worth_doing" | "needs_attention";
  explanationId: string;
};
```

> **Realignment note:** `"wallet"` is replaced by `"wealth"` and `"holding"`.
> `"trend"` is added for the 6-day wealth trend depth tile. The Today hero
> is the `wealth` tile (total net worth + today/MTD change).

## BriefingSourceSummary

```ts
type BriefingSourceSummary = {
  connectedCount: number;
  manualOnly: boolean;
  staleSourceIds: string[];
  needsReviewCount: number;
  lastSuccessfulScanAt?: string;
  summary: string;
};
```

## Finding

```ts
type Finding = {
  id: string;
  title: string;
  explanation: string;
  severity: "all_good" | "heads_up" | "worth_doing" | "needs_attention";
  category:
    | "savings"
    | "rainy_day"
    | "salary_timing"
    | "market"
    | "income_outlook"
    | "spending"
    | "bill"
    | "data_quality"
    | "idea";
  confidence: "high" | "medium" | "low";
  sourceIds: string[];
  action?: BriefingAction;
  why: string;
};
```

## Transaction

```ts
type Transaction = {
  id: string;
  amount: number;
  currency: "PKR";
  type: "expense" | "income" | "transfer";
  category: string;
  merchant?: string;
  note?: string;
  occurredAt: string;
  accountId?: string;
  source: "manual" | "sms" | "email" | "statement" | "wise" | "al_meezan";
  provider?: string;
  parserVersion?: string;
  dedupeFingerprint: string;
  sourceRefs: TransactionSourceRef[];
  confidence: number; // 0-1
  needsReview: boolean;
  reviewReason?: string;
};

type TransactionSourceRef = {
  source: "manual" | "sms" | "email" | "statement" | "api" | "import";
  provider?: string;
  rawRef?: string;
  parserVersion?: string;
  capturedAt: string;
};
```

Dedupe fingerprint rule: hash normalized amount, timestamp window, merchant/counterparty, and masked account reference. See [Capture Reliability](capture_reliability.md).

Current equivalents:

- `TransactionSchema` in shared TS.
- `SproutTransaction` in Flutter.

## Account

```ts
type Account = {
  id: string;
  provider: string;
  label: string;
  maskedRef?: string;
  type: "cash" | "bank" | "wallet" | "wise" | "investment" | "foreign_balance" | "other";
  balance: number;
  currency: "PKR";
  freshness: "updated_today" | "recent" | "stale" | "manual";
  updatedLabel: string;
  isManual: boolean;
};
```

Current equivalents:

- `AccountSchema`
- `SproutAccount`

## Goal

```ts
type Goal = {
  id: string;
  name: string;
  type: "emergency" | "car" | "home" | "education" | "eidi" | "zakat" | "travel" | "custom";
  targetAmount: number;
  currentAmount: number;
  currency: "PKR";
  deadline?: string;
  status: "active" | "complete" | "paused";
  pace: "ahead" | "on_track" | "watch" | "behind";
  nextStep: string;
  remainingToTarget: number;   // targetAmount - currentAmount, always >= 0
  paceNote: string;             // plain-language, e.g. "PKR 2 lakh to go"
};
```

Current equivalents:

- `SavingsGoalSchema` for Grow.
- `SproutGoal` for Flutter.

## Holding

A holding is one position the user owns: a mutual fund, a cash balance in
any currency, an equity, or another asset. Holdings are the core domain
object of the wealth-health tracker. Every valuation carries dated
provenance.

```ts
type Holding = {
  id: string;
  kind: "mutual_fund" | "cash" | "equity" | "other";
  institution: string;          // e.g. "Al Meezan", "Wise"
  label: string;                // user-facing, e.g. "Al Meezan Mutual Fund"
  fundCode?: string;            // e.g. "AMMF", "MIF", "MSF", "MDIP", "MFPF-AAP"
  currency: "PKR" | "USD" | "EUR" | string;  // native currency of the holding
  units?: number;               // for funds/equity; omitted for cash
  price?: PriceQuote;           // NAV or unit price (funds/equity); omitted for cash
  fxRate?: FxRate;              // FX to PKR if currency != PKR; omitted if PKR
  valuePkr: number;              // current value in PKR (whole rupees)
  valueNative?: number;         // current value in native currency (for display)
  priceAsOf: string;            // ISO date of the price/FX used (required)
  priceSource: string;          // human-readable source label, e.g. "Al Meezan redemption prices"
  freshness: "fresh" | "stale" | "manual" | "unavailable";
};
```

Rules:

- A holding with `kind: "cash"` has `valueNative` (the balance in its own
  currency) and `fxRate` if non-PKR; no `units` or `price`.
- A holding with `kind: "mutual_fund"` has `units`, `price` (the NAV), and
  `priceAsOf`/`priceSource`.
- `valuePkr` is always derived: `units * price.value * fxRate.value` (for
  funds in foreign currency), `units * price.value` (for PKR funds), or
  `valueNative * fxRate.value` (for foreign cash). The backend computes and
  stores it; the UI never re-derives.
- `freshness: "stale"` means the price or FX is older than the expected
  cadence (e.g. NAV not updated for 2+ market days, or FX older than 1
  business day). The UI must label it, never silently trust.

## PriceQuote

A dated unit price or NAV with its source. Provenance is first-class — a
valuation without a dated price is invalid.

```ts
type PriceQuote = {
  value: number;          // NAV or unit price in the holding's native currency
  asOf: string;           // ISO date the price is valid for
  source: string;         // e.g. "Al Meezan redemption prices"
  sourceUrl?: string;     // optional URL for transparency
  currency: string;       // currency of the price (matches holding.currency)
};
```

## FxRate

A dated FX rate from a named source. Required for any non-PKR holding.

```ts
type FxRate = {
  pair: string;           // e.g. "USD/PKR", "EUR/PKR"
  value: number;          // the rate (e.g. 277.992)
  asOf: string;            // ISO date the rate is valid for
  source: string;          // e.g. "Xe"
  sourceUrl?: string;
};
```

## WealthSnapshot

The daily snapshot of total wealth. This is the hero object of the Today
screen. One per day, produced by the nightly job.

```ts
type WealthSnapshot = {
  date: string;                    // ISO date of the snapshot
  totalPkr: number;                 // total net wealth in PKR (whole rupees)
  perHoldingBreakdown: {
    holdingId: string;
    label: string;
    valuePkr: number;
    changeVsYesterday: number;      // PKR change since yesterday's snapshot
    changeMtd: number;              // PKR change since start of month
  }[];
  changeVsYesterday: number;        // total PKR change since yesterday
  changeMtd: number;                // total PKR change since start of month
  mainReason: string;               // plain-language, e.g. "NAV movement"
  interpretation: string[];          // ordered lines in Sprout's voice
  trend: WealthTrendPoint[];       // recent days for the sparkline/chart
  provenanceSummary: string;        // e.g. "Al Meezan prices valid 7 Jul 2026; FX from Xe"
};

type WealthTrendPoint = {
  date: string;
  totalPkr: number;
  perHolding: { holdingId: string; valuePkr: number }[];
};
```

Rules:

- `changeVsYesterday` and `changeMtd` are always shown together on Today.
- `mainReason` is a short label; `interpretation` is the full plain-language
  story (one or more lines). Every movement shown in the UI must trace to
  either `mainReason` or a `WealthEvent`.
- `trend` holds the last N days (v0: 6 days) for the depth chart. It is a
  depth element, not a Today-hero element.

## WealthEvent

A real, dated event that moved wealth or marks a goal milestone. Events
reference prior days to form a story, not a snapshot. Mix good and not-good
honestly.

```ts
type WealthEvent = {
  id: string;
  date: string;
  holdingId?: string;       // which holding, if applicable
  kind: "nav_move" | "fx_move" | "contribution" | "withdrawal"
      | "bill" | "goal_milestone" | "news_context";
  magnitudePkr: number;      // signed: positive = up, negative = down
  direction: "up" | "down" | "flat";
  plainWhy: string;         // e.g. "Al Meezan pulled back after yesterday's jump (equity NAV correction)."
  learnMoreId?: string;     // links to a LearnThread for "learn later"
  severity: "all_good" | "heads_up" | "worth_doing" | "needs_attention";
};
```

Rules:

- Every event has a `plainWhy` — no event is shown without its driver.
- `learnMoreId` connects to a `LearnThread` (below) so an event flagged for
  learning is retrievable later, not lost.
- `news_context` events appear **only** when they explain the user's own
  holding movement or goal impact (per `market_personalization_spec.md`).

## LearnThread

A retrievable "learn later" thread attached to a `WealthEvent`. The full
learn-later UX is intentionally minimal in v0: the thread must be retrievable
from the event and from the Money/depth surface.

```ts
type LearnThread = {
  id: string;               // matches WealthEvent.learnMoreId
  title: string;            // e.g. "Why do fund NAVs move day to day?"
  summary: string;          // one-line plain-language summary
  body: string;             // short explanation (2-4 sentences)
  relatedEventId: string;
  createdAt: string;
};
```

## DailyBriefing

The target daily briefing object consumed by Today:

```ts
type DailyBriefing = {
  id: string;
  userId: string;
  briefingDate: string;
  generatedAt: string;
  freshness: "fresh" | "stale" | "local_fallback" | "unavailable";
  mascotMood: "thriving" | "content" | "watchful" | "concerned";
  greeting: string;
  summary: string;
  health: GardenHealthScore;
  wealthSnapshot: WealthSnapshot;        // NEW — the Today hero
  wealthEvents: WealthEvent[];           // NEW — "what happened" with yesterday-continuity
  recommendedAction: BriefingAction;     // goal-relative next-step (see §2.6)
  glanceTiles: GlanceTile[];
  findings: Finding[];
  sourceSummary: BriefingSourceSummary;
  streak: StreakState;
};
```

Backward compatibility: the existing `TodayResponse` is adapted into
`DailyBriefing` behind the repository. The new fields (`wealthSnapshot`,
`wealthEvents`) are additive; existing consumers that don't read them still
work. The `recommendedAction` `completionKind` loses `"check_in"` — opening
the app no longer changes health.

## MarketSnapshot

```ts
type MarketSnapshot = {
  id: string;
  date: string;
  indexLabel: string;
  movePct: number;
  oneLineMeaning: string;
  relevanceReason: string;
  sourceFreshness: "fresh" | "stale" | "mock" | "unavailable";
  severity: "all_good" | "heads_up" | "worth_doing" | "needs_attention";
  sourceLabel: string;
};
```

Market context is optional and Phase 2. It appears only when personally relevant under [Market Personalization Spec](market_personalization_spec.md).

## UserProfile

```ts
type UserProfile = {
  id: string;
  displayName: string;
  nameSource: "typed" | "nickname" | "default";
  incomeType?: "salary" | "freelance" | "business" | "irregular" | "student" | "other";
  salaryDate?: number;
  goals: Goal[];
  memory: UserMemory;
  streak: StreakState;
  locale: "en" | "ur";
  preferences: {
    hideBalancesDefault: boolean;
    notifications: NotificationPreferences;
    reduceMotion: boolean;
  };
};
```

## NotificationPreferences

```ts
type NotificationPreferences = {
  dailyCheckIn: boolean;
  billReminders: boolean;
  salaryIncomeReminders: boolean;
  weeklySummary: boolean;
  streakProtection: boolean;
  hideSensitiveAmounts: boolean;
  preferredCheckInWindow?: {
    startLocalTime: string; // HH:mm
    endLocalTime: string; // HH:mm
  };
};
```

## UserMemory

```ts
type UserMemory = {
  incomeNotes: IncomeContextNote[];
  planningAssumptions: PlanningAssumption[];
  askHistory: AskHistoryItem[];
};

type IncomeContextNote = {
  id: string;
  label: string;
  source: "user_entered" | "sprout_asked";
  expectedDate?: string;
  amount?: number;
  confidence: "user_confirmed" | "tentative";
  createdAt: string;
  expiresAt?: string;
};

type PlanningAssumption = {
  id: string;
  topic: "income" | "bill" | "goal" | "family" | "other";
  statement: string;
  source: "user_entered" | "sprout_asked";
  createdAt: string;
  expiresAt?: string;
};

type AskHistoryItem = {
  id: string;
  topic: "salary_date" | "income_type" | "additional_goal" | "bill_timing" | "category_correction" | "source_connection";
  askedAt: string;
  status: "answered" | "skipped" | "deferred";
  nextEligibleAskAt?: string;
};
```

Sprout may ask about uncertain income and store the user's answer here. It must not replace missing user answers with model predictions.

## StreakState

```ts
type StreakState = {
  current: number;
  longest: number;
  lastCheckInDate?: string;
  freezeCredits: number;
  repairAvailable: boolean;
  protectedDates: string[];
  status: "active" | "protected" | "repair_available" | "rest";
};
```

Streak rules:

- Honest check-in preserves the streak.
- Financial hardship never breaks the streak by itself.
- Freeze or repair protects missed check-ins caused by hardship, offline access, or notification failure.
- Freeze/repair is a streak behavior, not a money-performance reward.

## DataSource

```ts
type DataSource = {
  id: string;
  label: string;
  kind: "manual" | "email" | "statement" | "sms_android" | "bank_partner" | "wise" | "investment" | "official_data";
  status: "connected" | "not_connected" | "needs_review" | "error" | "manual";
  confidence: "high" | "medium" | "low";
  lastSyncedAt?: string;
  lastSyncedLabel: string;
  parserVersion?: string;
  parserHealth?: "healthy" | "watch" | "drift_detected" | "disabled";
  reads: string[];
  needsReviewCount: number;
};
```

Current equivalent:

- `AutoCaptureSourceSchema`
- `DataSourceSchema` in `profile.ts`

## Migration Notes

The current `TodayResponseSchema` is usable for the mock Today screen but does not yet include the full `DailyBriefing`, `Finding`, `GlanceTile`, `MarketSnapshot`, `Holding`, `WealthSnapshot`, or `WealthEvent` structures. Phase 2 should add those without breaking current UI by adapting `TodayResponse` into `DailyBriefing` behind a repository.

> **Realignment migration:** The production mock (§5 of the realignment doc)
> adds `Holding`, `PriceQuote`, `FxRate`, `WealthSnapshot`, `WealthEvent`,
> `LearnThread`, and the `Goal` extensions to `packages/shared/src/` and
> `apps/mobile/lib/src/domain/`. These are additive — the existing
> `TodayResponse`/`Transaction`/`Account` models remain for the cash/expense
> use case. The mock is wired behind the existing `TodayRepository` /
> `/v1/today` interface so the real backend swaps in later.
