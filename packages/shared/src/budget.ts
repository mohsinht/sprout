import { z } from "zod";

import { CurrencySchema, RecommendedActionSchema } from "./models.js";

export const BudgetBandSchema = z.enum(["healthy", "watch", "over"]);
export const BillRiskSchema = z.enum(["low", "medium", "high"]);

export const BudgetPeriodSchema = z.object({
  monthLabel: z.string(),
  startsOn: z.string(),
  endsOn: z.string(),
  daysElapsed: z.number().int().nonnegative(),
  daysTotal: z.number().int().positive(),
});

export const CategoryBudgetSchema = z.object({
  id: z.string(),
  category: z.string(),
  budgeted: z.number().nonnegative(),
  spent: z.number().nonnegative(),
  band: BudgetBandSchema,
  typicalForYou: z.number().nonnegative(),
  factor: z.string(),
});

export const UpcomingBillSchema = z.object({
  id: z.string(),
  name: z.string(),
  amount: z.number().nonnegative(),
  currency: CurrencySchema,
  dueDate: z.string(),
  dueRisk: BillRiskSchema,
  note: z.string(),
});

export const BudgetTotalsSchema = z.object({
  budgeted: z.number().nonnegative(),
  spent: z.number().nonnegative(),
  remaining: z.number(),
  paceRatio: z.number().nonnegative(),
  billsAtRiskTotal: z.number().nonnegative(),
});

export const BudgetResponseSchema = z.object({
  currency: CurrencySchema,
  period: BudgetPeriodSchema,
  categories: z.array(CategoryBudgetSchema),
  upcomingBills: z.array(UpcomingBillSchema),
  totals: BudgetTotalsSchema,
  recommendedAction: RecommendedActionSchema,
});

export type BudgetBand = z.infer<typeof BudgetBandSchema>;
export type BillRisk = z.infer<typeof BillRiskSchema>;
export type BudgetPeriod = z.infer<typeof BudgetPeriodSchema>;
export type CategoryBudget = z.infer<typeof CategoryBudgetSchema>;
export type UpcomingBill = z.infer<typeof UpcomingBillSchema>;
export type BudgetTotals = z.infer<typeof BudgetTotalsSchema>;
export type BudgetResponse = z.infer<typeof BudgetResponseSchema>;
