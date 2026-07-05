import { z } from "zod";

import { CurrencySchema, RecommendedActionSchema } from "./models.js";

export const SavingsGoalSchema = z.object({
  id: z.string(),
  name: z.string(),
  target: z.number().nonnegative(),
  saved: z.number().nonnegative(),
  pct: z.number().min(0).max(1),
  currency: CurrencySchema,
  category: z.enum([
    "car",
    "emergency",
    "home",
    "education",
    "eidi",
    "zakat",
    "travel",
    "custom",
  ]),
  monthlyPlant: z.number().nonnegative(),
  nextMilestonePct: z.number().min(0).max(1),
  milestoneLabel: z.string(),
  recommendedAction: RecommendedActionSchema,
});

export const EmergencyFundSchema = z.object({
  saved: z.number().nonnegative(),
  target: z.number().nonnegative(),
  pct: z.number().min(0).max(1),
  monthsCovered: z.number().nonnegative(),
  targetMonths: z.number().positive(),
  status: z.enum(["starter", "building", "steady", "strong"]),
  encouragement: z.string(),
  recommendedAction: RecommendedActionSchema,
});

export const MutualFundSchema = z.object({
  id: z.string(),
  fundName: z.string(),
  provider: z.string(),
  category: z.string(),
  nav: z.number().positive(),
  units: z.number().nonnegative(),
  marketValue: z.number().nonnegative(),
  returnPct: z.number(),
  navDate: z.string(),
  tone: z.enum(["calm", "watch", "growing"]),
});

export const CashGoalSummarySchema = z.object({
  label: z.string(),
  amount: z.number().nonnegative(),
  currency: CurrencySchema,
});

export const InvestmentsSchema = z.object({
  totalValue: z.number().nonnegative(),
  dayChange: z.number(),
  dayChangePct: z.number(),
  currency: CurrencySchema,
  mutualFunds: z.array(MutualFundSchema),
  cashGoals: z.array(CashGoalSummarySchema),
  note: z.string(),
});

export const GrowMilestoneSchema = z.object({
  thresholdPct: z.number().min(0).max(1),
  title: z.string(),
  xp: z.number().int().nonnegative(),
  celebrated: z.boolean(),
});

export const GrowResponseSchema = z.object({
  currency: CurrencySchema,
  summary: z.object({
    title: z.string(),
    subtitle: z.string(),
    totalGardenValue: z.number().nonnegative(),
    todayChange: z.number(),
  }),
  savingsGoals: z.array(SavingsGoalSchema),
  emergencyFund: EmergencyFundSchema,
  investments: InvestmentsSchema,
  milestones: z.array(GrowMilestoneSchema),
  emptyState: z.object({
    title: z.string(),
    subtitle: z.string(),
    actionLabel: z.string(),
  }),
});

export type SavingsGoal = z.infer<typeof SavingsGoalSchema>;
export type EmergencyFund = z.infer<typeof EmergencyFundSchema>;
export type MutualFund = z.infer<typeof MutualFundSchema>;
export type CashGoalSummary = z.infer<typeof CashGoalSummarySchema>;
export type Investments = z.infer<typeof InvestmentsSchema>;
export type GrowMilestone = z.infer<typeof GrowMilestoneSchema>;
export type GrowResponse = z.infer<typeof GrowResponseSchema>;
