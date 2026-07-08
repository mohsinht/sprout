import { z } from "zod";

export const PriceQuoteSchema = z.object({
  value: z.number().positive(),
  asOf: z.string(),
  source: z.string(),
  sourceUrl: z.string().optional(),
  currency: z.string(),
});

export const FxRateSchema = z.object({
  pair: z.string(),
  value: z.number().positive(),
  asOf: z.string(),
  source: z.string(),
  sourceUrl: z.string().optional(),
});

export const HoldingSchema = z.object({
  id: z.string(),
  kind: z.enum(["mutual_fund", "cash", "equity", "other"]),
  institution: z.string(),
  label: z.string(),
  fundCode: z.string().optional(),
  currency: z.string(),
  units: z.number().nonnegative().optional(),
  price: PriceQuoteSchema.optional(),
  fxRate: FxRateSchema.optional(),
  valuePkr: z.number().nonnegative(),
  valueNative: z.number().nonnegative().optional(),
  priceAsOf: z.string(),
  priceSource: z.string(),
  freshness: z.enum(["fresh", "stale", "manual", "unavailable"]),
});

export const WealthTrendPointSchema = z.object({
  date: z.string(),
  totalPkr: z.number().nonnegative(),
  perHolding: z.array(
    z.object({
      holdingId: z.string(),
      valuePkr: z.number().nonnegative(),
    })
  ),
});

export const WealthSnapshotSchema = z.object({
  date: z.string(),
  totalPkr: z.number().nonnegative(),
  perHoldingBreakdown: z.array(
    z.object({
      holdingId: z.string(),
      label: z.string(),
      valuePkr: z.number().nonnegative(),
      changeVsYesterday: z.number(),
      changeMtd: z.number(),
    })
  ),
  changeVsYesterday: z.number(),
  changeMtd: z.number(),
  mainReason: z.string(),
  interpretation: z.array(z.string()),
  trend: z.array(WealthTrendPointSchema),
  provenanceSummary: z.string(),
});

export const WealthEventSchema = z.object({
  id: z.string(),
  date: z.string(),
  holdingId: z.string().optional(),
  kind: z.enum([
    "nav_move",
    "fx_move",
    "contribution",
    "withdrawal",
    "bill",
    "goal_milestone",
    "news_context",
  ]),
  magnitudePkr: z.number(),
  direction: z.enum(["up", "down", "flat"]),
  plainWhy: z.string(),
  learnMoreId: z.string().optional(),
  severity: z.enum(["all_good", "heads_up", "worth_doing", "needs_attention"]),
});

export const LearnThreadSchema = z.object({
  id: z.string(),
  title: z.string(),
  summary: z.string(),
  body: z.string(),
  relatedEventId: z.string(),
  createdAt: z.string(),
});

export const WealthGoalSchema = z.object({
  id: z.string(),
  name: z.string(),
  type: z.enum([
    "emergency",
    "car",
    "home",
    "education",
    "eidi",
    "zakat",
    "travel",
    "custom",
  ]),
  targetAmount: z.number().nonnegative(),
  currentAmount: z.number().nonnegative(),
  currency: z.literal("PKR"),
  deadline: z.string().optional(),
  status: z.enum(["active", "complete", "paused"]),
  pace: z.enum(["ahead", "on_track", "watch", "behind"]),
  nextStep: z.string(),
  remainingToTarget: z.number().nonnegative(),
  paceNote: z.string(),
});

export const WealthBriefingActionSchema = z.object({
  id: z.string(),
  label: z.string(),
  severity: z.enum(["all_good", "heads_up", "worth_doing", "needs_attention"]),
  effect: z.string(),
  xp: z.number().int().nonnegative(),
  completionKind: z.enum([
    "confirm_transaction",
    "log_cash",
    "move_money",
    "review",
    "set_goal",
    "contribute_to_goal",
    "rebalance",
  ]),
  targetId: z.string().optional(),
  goalRelativeNote: z.string().optional(),
});

export const WealthBriefingSchema = z.object({
  id: z.string(),
  userId: z.string(),
  briefingDate: z.string(),
  generatedAt: z.string(),
  freshness: z.enum(["fresh", "stale", "local_fallback", "unavailable"]),
  mascotMood: z.enum(["thriving", "content", "watchful", "concerned"]),
  greeting: z.string(),
  summary: z.string(),
  healthScore: z.number().int().min(0).max(100),
  healthStatus: z.enum(["strong", "healthy", "watch", "urgent"]),
  wealthSnapshot: WealthSnapshotSchema,
  wealthEvents: z.array(WealthEventSchema),
  learnThreads: z.array(LearnThreadSchema),
  recommendedAction: WealthBriefingActionSchema,
  goals: z.array(WealthGoalSchema),
  holdings: z.array(HoldingSchema),
  streak: z.number().int().nonnegative(),
  xp: z.number().int().nonnegative(),
  level: z.number().int().positive(),
});

export type PriceQuote = z.infer<typeof PriceQuoteSchema>;
export type FxRate = z.infer<typeof FxRateSchema>;
export type Holding = z.infer<typeof HoldingSchema>;
export type WealthTrendPoint = z.infer<typeof WealthTrendPointSchema>;
export type WealthSnapshot = z.infer<typeof WealthSnapshotSchema>;
export type WealthEvent = z.infer<typeof WealthEventSchema>;
export type LearnThread = z.infer<typeof LearnThreadSchema>;
export type WealthGoal = z.infer<typeof WealthGoalSchema>;
export type WealthBriefingAction = z.infer<typeof WealthBriefingActionSchema>;
export type WealthBriefing = z.infer<typeof WealthBriefingSchema>;