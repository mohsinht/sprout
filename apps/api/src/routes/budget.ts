import { Hono } from "hono";
import { BudgetResponseSchema, mockBudgetResponse } from "@sprout/shared";

export const budgetRoute = new Hono();

budgetRoute.get("/", (c) => {
  const response = BudgetResponseSchema.parse({
    ...mockBudgetResponse,
    upcomingBills: [...mockBudgetResponse.upcomingBills].sort((a, b) => {
      const riskOrder = { high: 0, medium: 1, low: 2 };
      return riskOrder[a.dueRisk] - riskOrder[b.dueRisk];
    }),
  });

  return c.json(response);
});
