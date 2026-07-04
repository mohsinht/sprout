import { serve } from "@hono/node-server";
import { Hono } from "hono";
import { cors } from "hono/cors";
import { calculateFinancialHealthScore } from "@sprout/domain";
import { mockTodayResponse, TodayResponseSchema } from "@sprout/shared";

const app = new Hono();

app.use(
  "*",
  cors({
    origin: ["http://localhost:3000", "http://localhost:5173"],
    allowMethods: ["GET", "POST", "OPTIONS"],
    allowHeaders: ["Content-Type", "Authorization"]
  })
);

app.get("/health", (c) =>
  c.json({
    ok: true,
    service: "sprout-api",
    version: "0.1.0"
  })
);

app.get("/v1/today", (c) => {
  const calculatedHealth = calculateFinancialHealthScore({
    emergencyBufferMonths: 3.2,
    spendingPaceRatio: 1.08,
    savingsProgressRatio: 0.72,
    debtPaymentRatio: 0.08,
    upcomingBillsCoverageRatio: 1,
    daysUntilSalary: mockTodayResponse.salary.daysUntilSalary,
    investmentBuckets: 2,
    unconfirmedTransactions: mockTodayResponse.snapshot.unconfirmedTransactions,
    goalConsistencyRatio: 0.6
  });

  const response = TodayResponseSchema.parse({
    ...mockTodayResponse,
    health: {
      ...calculatedHealth,
      positiveFactors: [
        "Emergency buffer is strong",
        "Salary lands in 3 days",
        "Al Meezan NAV updated yesterday"
      ]
    }
  });

  return c.json(response);
});

const port = Number(process.env.PORT ?? 8787);

serve(
  {
    fetch: app.fetch,
    port
  },
  (info) => {
    console.log(`Sprout API listening on http://localhost:${info.port}`);
  }
);
