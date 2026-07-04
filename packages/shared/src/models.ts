import { z } from "zod";

export const CurrencySchema = z.literal("PKR");

export const RecommendedActionSchema = z.object({
  title: z.string(),
  xp: z.number().int().nonnegative(),
  impact: z.string()
});

export const FinancialHealthScoreSchema = z.object({
  score: z.number().int().min(0).max(100),
  status: z.enum(["strong", "healthy", "watch", "urgent"]),
  summary: z.string(),
  positiveFactors: z.array(z.string()),
  attentionFactors: z.array(z.string()),
  recommendedAction: RecommendedActionSchema
});

export const AccountSchema = z.object({
  id: z.string(),
  provider: z.string(),
  label: z.string(),
  maskedRef: z.string(),
  type: z.enum(["bank", "wallet", "investment", "foreign_balance", "cash"]),
  balance: z.number(),
  currency: CurrencySchema,
  updatedLabel: z.string()
});

export const TransactionSchema = z.object({
  id: z.string(),
  label: z.string(),
  category: z.string(),
  amount: z.number(),
  currency: CurrencySchema,
  capturedFrom: z.enum(["manual", "gmail", "sms", "csv", "wise", "al_meezan"]),
  needsConfirmation: z.boolean()
});

export const AutoCaptureSourceSchema = z.object({
  id: z.string(),
  label: z.string(),
  status: z.enum(["connected", "detected", "imported", "updated", "needs_review", "not_connected"]),
  detail: z.string()
});

export const TodaySnapshotSchema = z.object({
  availableCash: z.number(),
  monthSpent: z.number(),
  budgetRemaining: z.number(),
  upcomingBills: z.number(),
  unconfirmedTransactions: z.number()
});

export const TodayResponseSchema = z.object({
  user: z.object({
    firstName: z.string(),
    level: z.number().int().positive(),
    xp: z.number().int().nonnegative(),
    dayStreak: z.number().int().nonnegative()
  }),
  currency: CurrencySchema,
  salary: z.object({
    nextPayday: z.string(),
    daysUntilSalary: z.number().int().nonnegative()
  }),
  health: FinancialHealthScoreSchema,
  accounts: z.array(AccountSchema),
  transactions: z.array(TransactionSchema),
  autoCapture: z.array(AutoCaptureSourceSchema),
  snapshot: TodaySnapshotSchema,
  quickActions: z.array(z.string())
});

export type RecommendedAction = z.infer<typeof RecommendedActionSchema>;
export type FinancialHealthScore = z.infer<typeof FinancialHealthScoreSchema>;
export type Account = z.infer<typeof AccountSchema>;
export type Transaction = z.infer<typeof TransactionSchema>;
export type AutoCaptureSource = z.infer<typeof AutoCaptureSourceSchema>;
export type TodaySnapshot = z.infer<typeof TodaySnapshotSchema>;
export type TodayResponse = z.infer<typeof TodayResponseSchema>;
