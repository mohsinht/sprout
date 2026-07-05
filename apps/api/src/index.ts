import { serve } from "@hono/node-server";
import { Hono } from "hono";
import { cors } from "hono/cors";
import { calculateFinancialHealthScore } from "@sprout/domain";
import { mockTodayResponse, TodayResponseSchema } from "@sprout/shared";
import { budgetRoute } from "./routes/budget.js";
import { profileRoute } from "./routes/profile.js";
import { learnRoute } from "./routes/learn.js";
import { growRoute } from "./routes/grow.js";

const app = new Hono();

app.use(
  "*",
  cors({
    origin: ["http://localhost:3000", "http://localhost:5173"],
    allowMethods: ["GET", "POST", "OPTIONS"],
    allowHeaders: ["Content-Type", "Authorization"],
  }),
);

app.get("/health", (c) =>
  c.json({
    ok: true,
    service: "sprout-api",
    version: "0.1.0",
  }),
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
    goalConsistencyRatio: 0.6,
  });

  const response = TodayResponseSchema.parse({
    ...mockTodayResponse,
    health: {
      ...calculatedHealth,
      positiveFactors: [
        "Emergency buffer is strong",
        "Salary lands in 3 days",
        "Al Meezan NAV updated yesterday",
      ],
    },
  });

  return c.json(response);
});

app.route("/v1/budget", budgetRoute);
app.route("/v1/profile", profileRoute);
app.route("/v1/learn", learnRoute);
app.route("/v1/grow", growRoute);

const port = Number(process.env.PORT ?? 8787);

serve(
  {
    fetch: app.fetch,
    port,
  },
  (info) => {
    console.log(`Sprout API listening on http://localhost:${info.port}`);
  },
);
