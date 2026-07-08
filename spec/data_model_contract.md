# Data Model Contract

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
  completionKind: "check_in" | "confirm_transaction" | "log_cash" | "move_money" | "review" | "set_goal";
  targetId?: string;
};
```

Current equivalent:

- `RecommendedActionSchema`
- `RecommendedAction`

## GlanceTile

```ts
type GlanceTile = {
  id: string;
  kind: "wallet" | "goal" | "market" | "scan_summary" | "bill" | "salary";
  title: string;
  value: string;
  detail: string;
  severity: "all_good" | "heads_up" | "worth_doing" | "needs_attention";
  explanationId: string;
};
```

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
};
```

Current equivalents:

- `SavingsGoalSchema` for Grow.
- `SproutGoal` for Flutter.

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

The current `TodayResponseSchema` is usable for the mock Today screen but does not yet include the full `DailyBriefing`, `Finding`, `GlanceTile`, or `MarketSnapshot` structures. Phase 2 should add those without breaking current UI by adapting `TodayResponse` into `DailyBriefing` behind a repository.
